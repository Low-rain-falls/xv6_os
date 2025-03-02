
user/_xv6:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int main (int argc, char* argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    int n = atoi(argv[1]);
   8:	6588                	ld	a0,8(a1)
   a:	182000ef          	jal	18c <atoi>
    xv6(n);
   e:	31c000ef          	jal	32a <xv6>

    exit(0);
  12:	4501                	li	a0,0
  14:	26e000ef          	jal	282 <exit>

0000000000000018 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  18:	1141                	addi	sp,sp,-16
  1a:	e406                	sd	ra,8(sp)
  1c:	e022                	sd	s0,0(sp)
  1e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  20:	fe1ff0ef          	jal	0 <main>
  exit(0);
  24:	4501                	li	a0,0
  26:	25c000ef          	jal	282 <exit>

000000000000002a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	86be                	mv	a3,a5
  84:	0785                	addi	a5,a5,1
  86:	fff7c703          	lbu	a4,-1(a5)
  8a:	ff65                	bnez	a4,82 <strlen+0x10>
  8c:	40a6853b          	subw	a0,a3,a0
  90:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  for(n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void*
memset(void *dst, int c, uint n)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ca19                	beqz	a2,b8 <memset+0x1c>
  a4:	87aa                	mv	a5,a0
  a6:	1602                	slli	a2,a2,0x20
  a8:	9201                	srli	a2,a2,0x20
  aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b2:	0785                	addi	a5,a5,1
  b4:	fee79de3          	bne	a5,a4,ae <memset+0x12>
  }
  return dst;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strchr>:

char*
strchr(const char *s, char c)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cb99                	beqz	a5,de <strchr+0x20>
    if(*s == c)
  ca:	00f58763          	beq	a1,a5,d8 <strchr+0x1a>
  for(; *s; s++)
  ce:	0505                	addi	a0,a0,1
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbfd                	bnez	a5,ca <strchr+0xc>
      return (char*)s;
  return 0;
  d6:	4501                	li	a0,0
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret
  return 0;
  de:	4501                	li	a0,0
  e0:	bfe5                	j	d8 <strchr+0x1a>

00000000000000e2 <gets>:

char*
gets(char *buf, int max)
{
  e2:	711d                	addi	sp,sp,-96
  e4:	ec86                	sd	ra,88(sp)
  e6:	e8a2                	sd	s0,80(sp)
  e8:	e4a6                	sd	s1,72(sp)
  ea:	e0ca                	sd	s2,64(sp)
  ec:	fc4e                	sd	s3,56(sp)
  ee:	f852                	sd	s4,48(sp)
  f0:	f456                	sd	s5,40(sp)
  f2:	f05a                	sd	s6,32(sp)
  f4:	ec5e                	sd	s7,24(sp)
  f6:	1080                	addi	s0,sp,96
  f8:	8baa                	mv	s7,a0
  fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fc:	892a                	mv	s2,a0
  fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 100:	4aa9                	li	s5,10
 102:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 104:	89a6                	mv	s3,s1
 106:	2485                	addiw	s1,s1,1
 108:	0344d663          	bge	s1,s4,134 <gets+0x52>
    cc = read(0, &c, 1);
 10c:	4605                	li	a2,1
 10e:	faf40593          	addi	a1,s0,-81
 112:	4501                	li	a0,0
 114:	186000ef          	jal	29a <read>
    if(cc < 1)
 118:	00a05e63          	blez	a0,134 <gets+0x52>
    buf[i++] = c;
 11c:	faf44783          	lbu	a5,-81(s0)
 120:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 124:	01578763          	beq	a5,s5,132 <gets+0x50>
 128:	0905                	addi	s2,s2,1
 12a:	fd679de3          	bne	a5,s6,104 <gets+0x22>
    buf[i++] = c;
 12e:	89a6                	mv	s3,s1
 130:	a011                	j	134 <gets+0x52>
 132:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 134:	99de                	add	s3,s3,s7
 136:	00098023          	sb	zero,0(s3)
  return buf;
}
 13a:	855e                	mv	a0,s7
 13c:	60e6                	ld	ra,88(sp)
 13e:	6446                	ld	s0,80(sp)
 140:	64a6                	ld	s1,72(sp)
 142:	6906                	ld	s2,64(sp)
 144:	79e2                	ld	s3,56(sp)
 146:	7a42                	ld	s4,48(sp)
 148:	7aa2                	ld	s5,40(sp)
 14a:	7b02                	ld	s6,32(sp)
 14c:	6be2                	ld	s7,24(sp)
 14e:	6125                	addi	sp,sp,96
 150:	8082                	ret

0000000000000152 <stat>:

int
stat(const char *n, struct stat *st)
{
 152:	1101                	addi	sp,sp,-32
 154:	ec06                	sd	ra,24(sp)
 156:	e822                	sd	s0,16(sp)
 158:	e04a                	sd	s2,0(sp)
 15a:	1000                	addi	s0,sp,32
 15c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 15e:	4581                	li	a1,0
 160:	162000ef          	jal	2c2 <open>
  if(fd < 0)
 164:	02054263          	bltz	a0,188 <stat+0x36>
 168:	e426                	sd	s1,8(sp)
 16a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 16c:	85ca                	mv	a1,s2
 16e:	16c000ef          	jal	2da <fstat>
 172:	892a                	mv	s2,a0
  close(fd);
 174:	8526                	mv	a0,s1
 176:	134000ef          	jal	2aa <close>
  return r;
 17a:	64a2                	ld	s1,8(sp)
}
 17c:	854a                	mv	a0,s2
 17e:	60e2                	ld	ra,24(sp)
 180:	6442                	ld	s0,16(sp)
 182:	6902                	ld	s2,0(sp)
 184:	6105                	addi	sp,sp,32
 186:	8082                	ret
    return -1;
 188:	597d                	li	s2,-1
 18a:	bfcd                	j	17c <stat+0x2a>

000000000000018c <atoi>:

int
atoi(const char *s)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 192:	00054683          	lbu	a3,0(a0)
 196:	fd06879b          	addiw	a5,a3,-48
 19a:	0ff7f793          	zext.b	a5,a5
 19e:	4625                	li	a2,9
 1a0:	02f66863          	bltu	a2,a5,1d0 <atoi+0x44>
 1a4:	872a                	mv	a4,a0
  n = 0;
 1a6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1a8:	0705                	addi	a4,a4,1
 1aa:	0025179b          	slliw	a5,a0,0x2
 1ae:	9fa9                	addw	a5,a5,a0
 1b0:	0017979b          	slliw	a5,a5,0x1
 1b4:	9fb5                	addw	a5,a5,a3
 1b6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ba:	00074683          	lbu	a3,0(a4)
 1be:	fd06879b          	addiw	a5,a3,-48
 1c2:	0ff7f793          	zext.b	a5,a5
 1c6:	fef671e3          	bgeu	a2,a5,1a8 <atoi+0x1c>
  return n;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  n = 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <atoi+0x3e>

00000000000001d4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1da:	02b57463          	bgeu	a0,a1,202 <memmove+0x2e>
    while(n-- > 0)
 1de:	00c05f63          	blez	a2,1fc <memmove+0x28>
 1e2:	1602                	slli	a2,a2,0x20
 1e4:	9201                	srli	a2,a2,0x20
 1e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 1ec:	0585                	addi	a1,a1,1
 1ee:	0705                	addi	a4,a4,1
 1f0:	fff5c683          	lbu	a3,-1(a1)
 1f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1f8:	fef71ae3          	bne	a4,a5,1ec <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
    dst += n;
 202:	00c50733          	add	a4,a0,a2
    src += n;
 206:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 208:	fec05ae3          	blez	a2,1fc <memmove+0x28>
 20c:	fff6079b          	addiw	a5,a2,-1
 210:	1782                	slli	a5,a5,0x20
 212:	9381                	srli	a5,a5,0x20
 214:	fff7c793          	not	a5,a5
 218:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 21a:	15fd                	addi	a1,a1,-1
 21c:	177d                	addi	a4,a4,-1
 21e:	0005c683          	lbu	a3,0(a1)
 222:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 226:	fee79ae3          	bne	a5,a4,21a <memmove+0x46>
 22a:	bfc9                	j	1fc <memmove+0x28>

000000000000022c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 232:	ca05                	beqz	a2,262 <memcmp+0x36>
 234:	fff6069b          	addiw	a3,a2,-1
 238:	1682                	slli	a3,a3,0x20
 23a:	9281                	srli	a3,a3,0x20
 23c:	0685                	addi	a3,a3,1
 23e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 240:	00054783          	lbu	a5,0(a0)
 244:	0005c703          	lbu	a4,0(a1)
 248:	00e79863          	bne	a5,a4,258 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 24c:	0505                	addi	a0,a0,1
    p2++;
 24e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 250:	fed518e3          	bne	a0,a3,240 <memcmp+0x14>
  }
  return 0;
 254:	4501                	li	a0,0
 256:	a019                	j	25c <memcmp+0x30>
      return *p1 - *p2;
 258:	40e7853b          	subw	a0,a5,a4
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  return 0;
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <memcmp+0x30>

0000000000000266 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e406                	sd	ra,8(sp)
 26a:	e022                	sd	s0,0(sp)
 26c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 26e:	f67ff0ef          	jal	1d4 <memmove>
}
 272:	60a2                	ld	ra,8(sp)
 274:	6402                	ld	s0,0(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret

000000000000027a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 27a:	4885                	li	a7,1
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <exit>:
.global exit
exit:
 li a7, SYS_exit
 282:	4889                	li	a7,2
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <wait>:
.global wait
wait:
 li a7, SYS_wait
 28a:	488d                	li	a7,3
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 292:	4891                	li	a7,4
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <read>:
.global read
read:
 li a7, SYS_read
 29a:	4895                	li	a7,5
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <write>:
.global write
write:
 li a7, SYS_write
 2a2:	48c1                	li	a7,16
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <close>:
.global close
close:
 li a7, SYS_close
 2aa:	48d5                	li	a7,21
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2b2:	4899                	li	a7,6
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ba:	489d                	li	a7,7
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <open>:
.global open
open:
 li a7, SYS_open
 2c2:	48bd                	li	a7,15
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2ca:	48c5                	li	a7,17
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2d2:	48c9                	li	a7,18
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2da:	48a1                	li	a7,8
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <link>:
.global link
link:
 li a7, SYS_link
 2e2:	48cd                	li	a7,19
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2ea:	48d1                	li	a7,20
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2f2:	48a5                	li	a7,9
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <dup>:
.global dup
dup:
 li a7, SYS_dup
 2fa:	48a9                	li	a7,10
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 302:	48ad                	li	a7,11
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 30a:	48b1                	li	a7,12
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 312:	48b5                	li	a7,13
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 31a:	48b9                	li	a7,14
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <hello>:
.global hello
hello:
 li a7, SYS_hello
 322:	48d9                	li	a7,22
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <xv6>:
.global xv6
xv6:
 li a7, SYS_xv6
 32a:	48dd                	li	a7,23
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <trace>:
.global trace
trace:
 li a7, SYS_trace
 332:	48e1                	li	a7,24
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 33a:	48e5                	li	a7,25
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	1000                	addi	s0,sp,32
 34a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 34e:	4605                	li	a2,1
 350:	fef40593          	addi	a1,s0,-17
 354:	f4fff0ef          	jal	2a2 <write>
}
 358:	60e2                	ld	ra,24(sp)
 35a:	6442                	ld	s0,16(sp)
 35c:	6105                	addi	sp,sp,32
 35e:	8082                	ret

0000000000000360 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 360:	7139                	addi	sp,sp,-64
 362:	fc06                	sd	ra,56(sp)
 364:	f822                	sd	s0,48(sp)
 366:	f426                	sd	s1,40(sp)
 368:	0080                	addi	s0,sp,64
 36a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 36c:	c299                	beqz	a3,372 <printint+0x12>
 36e:	0805c963          	bltz	a1,400 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 372:	2581                	sext.w	a1,a1
  neg = 0;
 374:	4881                	li	a7,0
 376:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 37a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 37c:	2601                	sext.w	a2,a2
 37e:	00000517          	auipc	a0,0x0
 382:	4fa50513          	addi	a0,a0,1274 # 878 <digits>
 386:	883a                	mv	a6,a4
 388:	2705                	addiw	a4,a4,1
 38a:	02c5f7bb          	remuw	a5,a1,a2
 38e:	1782                	slli	a5,a5,0x20
 390:	9381                	srli	a5,a5,0x20
 392:	97aa                	add	a5,a5,a0
 394:	0007c783          	lbu	a5,0(a5)
 398:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 39c:	0005879b          	sext.w	a5,a1
 3a0:	02c5d5bb          	divuw	a1,a1,a2
 3a4:	0685                	addi	a3,a3,1
 3a6:	fec7f0e3          	bgeu	a5,a2,386 <printint+0x26>
  if(neg)
 3aa:	00088c63          	beqz	a7,3c2 <printint+0x62>
    buf[i++] = '-';
 3ae:	fd070793          	addi	a5,a4,-48
 3b2:	00878733          	add	a4,a5,s0
 3b6:	02d00793          	li	a5,45
 3ba:	fef70823          	sb	a5,-16(a4)
 3be:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c2:	02e05a63          	blez	a4,3f6 <printint+0x96>
 3c6:	f04a                	sd	s2,32(sp)
 3c8:	ec4e                	sd	s3,24(sp)
 3ca:	fc040793          	addi	a5,s0,-64
 3ce:	00e78933          	add	s2,a5,a4
 3d2:	fff78993          	addi	s3,a5,-1
 3d6:	99ba                	add	s3,s3,a4
 3d8:	377d                	addiw	a4,a4,-1
 3da:	1702                	slli	a4,a4,0x20
 3dc:	9301                	srli	a4,a4,0x20
 3de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e2:	fff94583          	lbu	a1,-1(s2)
 3e6:	8526                	mv	a0,s1
 3e8:	f5bff0ef          	jal	342 <putc>
  while(--i >= 0)
 3ec:	197d                	addi	s2,s2,-1
 3ee:	ff391ae3          	bne	s2,s3,3e2 <printint+0x82>
 3f2:	7902                	ld	s2,32(sp)
 3f4:	69e2                	ld	s3,24(sp)
}
 3f6:	70e2                	ld	ra,56(sp)
 3f8:	7442                	ld	s0,48(sp)
 3fa:	74a2                	ld	s1,40(sp)
 3fc:	6121                	addi	sp,sp,64
 3fe:	8082                	ret
    x = -xx;
 400:	40b005bb          	negw	a1,a1
    neg = 1;
 404:	4885                	li	a7,1
    x = -xx;
 406:	bf85                	j	376 <printint+0x16>

0000000000000408 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 408:	711d                	addi	sp,sp,-96
 40a:	ec86                	sd	ra,88(sp)
 40c:	e8a2                	sd	s0,80(sp)
 40e:	e0ca                	sd	s2,64(sp)
 410:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 412:	0005c903          	lbu	s2,0(a1)
 416:	26090863          	beqz	s2,686 <vprintf+0x27e>
 41a:	e4a6                	sd	s1,72(sp)
 41c:	fc4e                	sd	s3,56(sp)
 41e:	f852                	sd	s4,48(sp)
 420:	f456                	sd	s5,40(sp)
 422:	f05a                	sd	s6,32(sp)
 424:	ec5e                	sd	s7,24(sp)
 426:	e862                	sd	s8,16(sp)
 428:	e466                	sd	s9,8(sp)
 42a:	8b2a                	mv	s6,a0
 42c:	8a2e                	mv	s4,a1
 42e:	8bb2                	mv	s7,a2
  state = 0;
 430:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 432:	4481                	li	s1,0
 434:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 436:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 43a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 43e:	06c00c93          	li	s9,108
 442:	a005                	j	462 <vprintf+0x5a>
        putc(fd, c0);
 444:	85ca                	mv	a1,s2
 446:	855a                	mv	a0,s6
 448:	efbff0ef          	jal	342 <putc>
 44c:	a019                	j	452 <vprintf+0x4a>
    } else if(state == '%'){
 44e:	03598263          	beq	s3,s5,472 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 452:	2485                	addiw	s1,s1,1
 454:	8726                	mv	a4,s1
 456:	009a07b3          	add	a5,s4,s1
 45a:	0007c903          	lbu	s2,0(a5)
 45e:	20090c63          	beqz	s2,676 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 462:	0009079b          	sext.w	a5,s2
    if(state == 0){
 466:	fe0994e3          	bnez	s3,44e <vprintf+0x46>
      if(c0 == '%'){
 46a:	fd579de3          	bne	a5,s5,444 <vprintf+0x3c>
        state = '%';
 46e:	89be                	mv	s3,a5
 470:	b7cd                	j	452 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 472:	00ea06b3          	add	a3,s4,a4
 476:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 47a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 47c:	c681                	beqz	a3,484 <vprintf+0x7c>
 47e:	9752                	add	a4,a4,s4
 480:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 484:	03878f63          	beq	a5,s8,4c2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 488:	05978963          	beq	a5,s9,4da <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 48c:	07500713          	li	a4,117
 490:	0ee78363          	beq	a5,a4,576 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 494:	07800713          	li	a4,120
 498:	12e78563          	beq	a5,a4,5c2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 49c:	07000713          	li	a4,112
 4a0:	14e78a63          	beq	a5,a4,5f4 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4a4:	07300713          	li	a4,115
 4a8:	18e78a63          	beq	a5,a4,63c <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4ac:	02500713          	li	a4,37
 4b0:	04e79563          	bne	a5,a4,4fa <vprintf+0xf2>
        putc(fd, '%');
 4b4:	02500593          	li	a1,37
 4b8:	855a                	mv	a0,s6
 4ba:	e89ff0ef          	jal	342 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4be:	4981                	li	s3,0
 4c0:	bf49                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4c2:	008b8913          	addi	s2,s7,8
 4c6:	4685                	li	a3,1
 4c8:	4629                	li	a2,10
 4ca:	000ba583          	lw	a1,0(s7)
 4ce:	855a                	mv	a0,s6
 4d0:	e91ff0ef          	jal	360 <printint>
 4d4:	8bca                	mv	s7,s2
      state = 0;
 4d6:	4981                	li	s3,0
 4d8:	bfad                	j	452 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4da:	06400793          	li	a5,100
 4de:	02f68963          	beq	a3,a5,510 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4e2:	06c00793          	li	a5,108
 4e6:	04f68263          	beq	a3,a5,52a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4ea:	07500793          	li	a5,117
 4ee:	0af68063          	beq	a3,a5,58e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 4f2:	07800793          	li	a5,120
 4f6:	0ef68263          	beq	a3,a5,5da <vprintf+0x1d2>
        putc(fd, '%');
 4fa:	02500593          	li	a1,37
 4fe:	855a                	mv	a0,s6
 500:	e43ff0ef          	jal	342 <putc>
        putc(fd, c0);
 504:	85ca                	mv	a1,s2
 506:	855a                	mv	a0,s6
 508:	e3bff0ef          	jal	342 <putc>
      state = 0;
 50c:	4981                	li	s3,0
 50e:	b791                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 510:	008b8913          	addi	s2,s7,8
 514:	4685                	li	a3,1
 516:	4629                	li	a2,10
 518:	000ba583          	lw	a1,0(s7)
 51c:	855a                	mv	a0,s6
 51e:	e43ff0ef          	jal	360 <printint>
        i += 1;
 522:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 524:	8bca                	mv	s7,s2
      state = 0;
 526:	4981                	li	s3,0
        i += 1;
 528:	b72d                	j	452 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 52a:	06400793          	li	a5,100
 52e:	02f60763          	beq	a2,a5,55c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 532:	07500793          	li	a5,117
 536:	06f60963          	beq	a2,a5,5a8 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 53a:	07800793          	li	a5,120
 53e:	faf61ee3          	bne	a2,a5,4fa <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 542:	008b8913          	addi	s2,s7,8
 546:	4681                	li	a3,0
 548:	4641                	li	a2,16
 54a:	000ba583          	lw	a1,0(s7)
 54e:	855a                	mv	a0,s6
 550:	e11ff0ef          	jal	360 <printint>
        i += 2;
 554:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 556:	8bca                	mv	s7,s2
      state = 0;
 558:	4981                	li	s3,0
        i += 2;
 55a:	bde5                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 55c:	008b8913          	addi	s2,s7,8
 560:	4685                	li	a3,1
 562:	4629                	li	a2,10
 564:	000ba583          	lw	a1,0(s7)
 568:	855a                	mv	a0,s6
 56a:	df7ff0ef          	jal	360 <printint>
        i += 2;
 56e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	8bca                	mv	s7,s2
      state = 0;
 572:	4981                	li	s3,0
        i += 2;
 574:	bdf9                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 576:	008b8913          	addi	s2,s7,8
 57a:	4681                	li	a3,0
 57c:	4629                	li	a2,10
 57e:	000ba583          	lw	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	dddff0ef          	jal	360 <printint>
 588:	8bca                	mv	s7,s2
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b5d9                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 58e:	008b8913          	addi	s2,s7,8
 592:	4681                	li	a3,0
 594:	4629                	li	a2,10
 596:	000ba583          	lw	a1,0(s7)
 59a:	855a                	mv	a0,s6
 59c:	dc5ff0ef          	jal	360 <printint>
        i += 1;
 5a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
        i += 1;
 5a6:	b575                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a8:	008b8913          	addi	s2,s7,8
 5ac:	4681                	li	a3,0
 5ae:	4629                	li	a2,10
 5b0:	000ba583          	lw	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	dabff0ef          	jal	360 <printint>
        i += 2;
 5ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
        i += 2;
 5c0:	bd49                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4681                	li	a3,0
 5c8:	4641                	li	a2,16
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	d91ff0ef          	jal	360 <printint>
 5d4:	8bca                	mv	s7,s2
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	bdad                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4681                	li	a3,0
 5e0:	4641                	li	a2,16
 5e2:	000ba583          	lw	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	d79ff0ef          	jal	360 <printint>
        i += 1;
 5ec:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	8bca                	mv	s7,s2
      state = 0;
 5f0:	4981                	li	s3,0
        i += 1;
 5f2:	b585                	j	452 <vprintf+0x4a>
 5f4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5f6:	008b8d13          	addi	s10,s7,8
 5fa:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fe:	03000593          	li	a1,48
 602:	855a                	mv	a0,s6
 604:	d3fff0ef          	jal	342 <putc>
  putc(fd, 'x');
 608:	07800593          	li	a1,120
 60c:	855a                	mv	a0,s6
 60e:	d35ff0ef          	jal	342 <putc>
 612:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 614:	00000b97          	auipc	s7,0x0
 618:	264b8b93          	addi	s7,s7,612 # 878 <digits>
 61c:	03c9d793          	srli	a5,s3,0x3c
 620:	97de                	add	a5,a5,s7
 622:	0007c583          	lbu	a1,0(a5)
 626:	855a                	mv	a0,s6
 628:	d1bff0ef          	jal	342 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62c:	0992                	slli	s3,s3,0x4
 62e:	397d                	addiw	s2,s2,-1
 630:	fe0916e3          	bnez	s2,61c <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 634:	8bea                	mv	s7,s10
      state = 0;
 636:	4981                	li	s3,0
 638:	6d02                	ld	s10,0(sp)
 63a:	bd21                	j	452 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 63c:	008b8993          	addi	s3,s7,8
 640:	000bb903          	ld	s2,0(s7)
 644:	00090f63          	beqz	s2,662 <vprintf+0x25a>
        for(; *s; s++)
 648:	00094583          	lbu	a1,0(s2)
 64c:	c195                	beqz	a1,670 <vprintf+0x268>
          putc(fd, *s);
 64e:	855a                	mv	a0,s6
 650:	cf3ff0ef          	jal	342 <putc>
        for(; *s; s++)
 654:	0905                	addi	s2,s2,1
 656:	00094583          	lbu	a1,0(s2)
 65a:	f9f5                	bnez	a1,64e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 65c:	8bce                	mv	s7,s3
      state = 0;
 65e:	4981                	li	s3,0
 660:	bbcd                	j	452 <vprintf+0x4a>
          s = "(null)";
 662:	00000917          	auipc	s2,0x0
 666:	20e90913          	addi	s2,s2,526 # 870 <malloc+0x102>
        for(; *s; s++)
 66a:	02800593          	li	a1,40
 66e:	b7c5                	j	64e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 670:	8bce                	mv	s7,s3
      state = 0;
 672:	4981                	li	s3,0
 674:	bbf9                	j	452 <vprintf+0x4a>
 676:	64a6                	ld	s1,72(sp)
 678:	79e2                	ld	s3,56(sp)
 67a:	7a42                	ld	s4,48(sp)
 67c:	7aa2                	ld	s5,40(sp)
 67e:	7b02                	ld	s6,32(sp)
 680:	6be2                	ld	s7,24(sp)
 682:	6c42                	ld	s8,16(sp)
 684:	6ca2                	ld	s9,8(sp)
    }
  }
}
 686:	60e6                	ld	ra,88(sp)
 688:	6446                	ld	s0,80(sp)
 68a:	6906                	ld	s2,64(sp)
 68c:	6125                	addi	sp,sp,96
 68e:	8082                	ret

0000000000000690 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 690:	715d                	addi	sp,sp,-80
 692:	ec06                	sd	ra,24(sp)
 694:	e822                	sd	s0,16(sp)
 696:	1000                	addi	s0,sp,32
 698:	e010                	sd	a2,0(s0)
 69a:	e414                	sd	a3,8(s0)
 69c:	e818                	sd	a4,16(s0)
 69e:	ec1c                	sd	a5,24(s0)
 6a0:	03043023          	sd	a6,32(s0)
 6a4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ac:	8622                	mv	a2,s0
 6ae:	d5bff0ef          	jal	408 <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6161                	addi	sp,sp,80
 6b8:	8082                	ret

00000000000006ba <printf>:

void
printf(const char *fmt, ...)
{
 6ba:	711d                	addi	sp,sp,-96
 6bc:	ec06                	sd	ra,24(sp)
 6be:	e822                	sd	s0,16(sp)
 6c0:	1000                	addi	s0,sp,32
 6c2:	e40c                	sd	a1,8(s0)
 6c4:	e810                	sd	a2,16(s0)
 6c6:	ec14                	sd	a3,24(s0)
 6c8:	f018                	sd	a4,32(s0)
 6ca:	f41c                	sd	a5,40(s0)
 6cc:	03043823          	sd	a6,48(s0)
 6d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d4:	00840613          	addi	a2,s0,8
 6d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6dc:	85aa                	mv	a1,a0
 6de:	4505                	li	a0,1
 6e0:	d29ff0ef          	jal	408 <vprintf>
}
 6e4:	60e2                	ld	ra,24(sp)
 6e6:	6442                	ld	s0,16(sp)
 6e8:	6125                	addi	sp,sp,96
 6ea:	8082                	ret

00000000000006ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ec:	1141                	addi	sp,sp,-16
 6ee:	e422                	sd	s0,8(sp)
 6f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	00001797          	auipc	a5,0x1
 6fa:	90a7b783          	ld	a5,-1782(a5) # 1000 <freep>
 6fe:	a02d                	j	728 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 700:	4618                	lw	a4,8(a2)
 702:	9f2d                	addw	a4,a4,a1
 704:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 708:	6398                	ld	a4,0(a5)
 70a:	6310                	ld	a2,0(a4)
 70c:	a83d                	j	74a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 70e:	ff852703          	lw	a4,-8(a0)
 712:	9f31                	addw	a4,a4,a2
 714:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 716:	ff053683          	ld	a3,-16(a0)
 71a:	a091                	j	75e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71c:	6398                	ld	a4,0(a5)
 71e:	00e7e463          	bltu	a5,a4,726 <free+0x3a>
 722:	00e6ea63          	bltu	a3,a4,736 <free+0x4a>
{
 726:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 728:	fed7fae3          	bgeu	a5,a3,71c <free+0x30>
 72c:	6398                	ld	a4,0(a5)
 72e:	00e6e463          	bltu	a3,a4,736 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 732:	fee7eae3          	bltu	a5,a4,726 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 736:	ff852583          	lw	a1,-8(a0)
 73a:	6390                	ld	a2,0(a5)
 73c:	02059813          	slli	a6,a1,0x20
 740:	01c85713          	srli	a4,a6,0x1c
 744:	9736                	add	a4,a4,a3
 746:	fae60de3          	beq	a2,a4,700 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 74a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 74e:	4790                	lw	a2,8(a5)
 750:	02061593          	slli	a1,a2,0x20
 754:	01c5d713          	srli	a4,a1,0x1c
 758:	973e                	add	a4,a4,a5
 75a:	fae68ae3          	beq	a3,a4,70e <free+0x22>
    p->s.ptr = bp->s.ptr;
 75e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 760:	00001717          	auipc	a4,0x1
 764:	8af73023          	sd	a5,-1888(a4) # 1000 <freep>
}
 768:	6422                	ld	s0,8(sp)
 76a:	0141                	addi	sp,sp,16
 76c:	8082                	ret

000000000000076e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 76e:	7139                	addi	sp,sp,-64
 770:	fc06                	sd	ra,56(sp)
 772:	f822                	sd	s0,48(sp)
 774:	f426                	sd	s1,40(sp)
 776:	ec4e                	sd	s3,24(sp)
 778:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77a:	02051493          	slli	s1,a0,0x20
 77e:	9081                	srli	s1,s1,0x20
 780:	04bd                	addi	s1,s1,15
 782:	8091                	srli	s1,s1,0x4
 784:	0014899b          	addiw	s3,s1,1
 788:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 78a:	00001517          	auipc	a0,0x1
 78e:	87653503          	ld	a0,-1930(a0) # 1000 <freep>
 792:	c915                	beqz	a0,7c6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 794:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 796:	4798                	lw	a4,8(a5)
 798:	08977a63          	bgeu	a4,s1,82c <malloc+0xbe>
 79c:	f04a                	sd	s2,32(sp)
 79e:	e852                	sd	s4,16(sp)
 7a0:	e456                	sd	s5,8(sp)
 7a2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7a4:	8a4e                	mv	s4,s3
 7a6:	0009871b          	sext.w	a4,s3
 7aa:	6685                	lui	a3,0x1
 7ac:	00d77363          	bgeu	a4,a3,7b2 <malloc+0x44>
 7b0:	6a05                	lui	s4,0x1
 7b2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7b6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ba:	00001917          	auipc	s2,0x1
 7be:	84690913          	addi	s2,s2,-1978 # 1000 <freep>
  if(p == (char*)-1)
 7c2:	5afd                	li	s5,-1
 7c4:	a081                	j	804 <malloc+0x96>
 7c6:	f04a                	sd	s2,32(sp)
 7c8:	e852                	sd	s4,16(sp)
 7ca:	e456                	sd	s5,8(sp)
 7cc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ce:	00001797          	auipc	a5,0x1
 7d2:	84278793          	addi	a5,a5,-1982 # 1010 <base>
 7d6:	00001717          	auipc	a4,0x1
 7da:	82f73523          	sd	a5,-2006(a4) # 1000 <freep>
 7de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e4:	b7c1                	j	7a4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7e6:	6398                	ld	a4,0(a5)
 7e8:	e118                	sd	a4,0(a0)
 7ea:	a8a9                	j	844 <malloc+0xd6>
  hp->s.size = nu;
 7ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f0:	0541                	addi	a0,a0,16
 7f2:	efbff0ef          	jal	6ec <free>
  return freep;
 7f6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7fa:	c12d                	beqz	a0,85c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fe:	4798                	lw	a4,8(a5)
 800:	02977263          	bgeu	a4,s1,824 <malloc+0xb6>
    if(p == freep)
 804:	00093703          	ld	a4,0(s2)
 808:	853e                	mv	a0,a5
 80a:	fef719e3          	bne	a4,a5,7fc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 80e:	8552                	mv	a0,s4
 810:	afbff0ef          	jal	30a <sbrk>
  if(p == (char*)-1)
 814:	fd551ce3          	bne	a0,s5,7ec <malloc+0x7e>
        return 0;
 818:	4501                	li	a0,0
 81a:	7902                	ld	s2,32(sp)
 81c:	6a42                	ld	s4,16(sp)
 81e:	6aa2                	ld	s5,8(sp)
 820:	6b02                	ld	s6,0(sp)
 822:	a03d                	j	850 <malloc+0xe2>
 824:	7902                	ld	s2,32(sp)
 826:	6a42                	ld	s4,16(sp)
 828:	6aa2                	ld	s5,8(sp)
 82a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 82c:	fae48de3          	beq	s1,a4,7e6 <malloc+0x78>
        p->s.size -= nunits;
 830:	4137073b          	subw	a4,a4,s3
 834:	c798                	sw	a4,8(a5)
        p += p->s.size;
 836:	02071693          	slli	a3,a4,0x20
 83a:	01c6d713          	srli	a4,a3,0x1c
 83e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 840:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 844:	00000717          	auipc	a4,0x0
 848:	7aa73e23          	sd	a0,1980(a4) # 1000 <freep>
      return (void*)(p + 1);
 84c:	01078513          	addi	a0,a5,16
  }
}
 850:	70e2                	ld	ra,56(sp)
 852:	7442                	ld	s0,48(sp)
 854:	74a2                	ld	s1,40(sp)
 856:	69e2                	ld	s3,24(sp)
 858:	6121                	addi	sp,sp,64
 85a:	8082                	ret
 85c:	7902                	ld	s2,32(sp)
 85e:	6a42                	ld	s4,16(sp)
 860:	6aa2                	ld	s5,8(sp)
 862:	6b02                	ld	s6,0(sp)
 864:	b7f5                	j	850 <malloc+0xe2>
