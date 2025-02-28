
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

0000000000000332 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 332:	1101                	addi	sp,sp,-32
 334:	ec06                	sd	ra,24(sp)
 336:	e822                	sd	s0,16(sp)
 338:	1000                	addi	s0,sp,32
 33a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 33e:	4605                	li	a2,1
 340:	fef40593          	addi	a1,s0,-17
 344:	f5fff0ef          	jal	2a2 <write>
}
 348:	60e2                	ld	ra,24(sp)
 34a:	6442                	ld	s0,16(sp)
 34c:	6105                	addi	sp,sp,32
 34e:	8082                	ret

0000000000000350 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 350:	7139                	addi	sp,sp,-64
 352:	fc06                	sd	ra,56(sp)
 354:	f822                	sd	s0,48(sp)
 356:	f426                	sd	s1,40(sp)
 358:	0080                	addi	s0,sp,64
 35a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 35c:	c299                	beqz	a3,362 <printint+0x12>
 35e:	0805c963          	bltz	a1,3f0 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 362:	2581                	sext.w	a1,a1
  neg = 0;
 364:	4881                	li	a7,0
 366:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 36a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 36c:	2601                	sext.w	a2,a2
 36e:	00000517          	auipc	a0,0x0
 372:	4fa50513          	addi	a0,a0,1274 # 868 <digits>
 376:	883a                	mv	a6,a4
 378:	2705                	addiw	a4,a4,1
 37a:	02c5f7bb          	remuw	a5,a1,a2
 37e:	1782                	slli	a5,a5,0x20
 380:	9381                	srli	a5,a5,0x20
 382:	97aa                	add	a5,a5,a0
 384:	0007c783          	lbu	a5,0(a5)
 388:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 38c:	0005879b          	sext.w	a5,a1
 390:	02c5d5bb          	divuw	a1,a1,a2
 394:	0685                	addi	a3,a3,1
 396:	fec7f0e3          	bgeu	a5,a2,376 <printint+0x26>
  if(neg)
 39a:	00088c63          	beqz	a7,3b2 <printint+0x62>
    buf[i++] = '-';
 39e:	fd070793          	addi	a5,a4,-48
 3a2:	00878733          	add	a4,a5,s0
 3a6:	02d00793          	li	a5,45
 3aa:	fef70823          	sb	a5,-16(a4)
 3ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3b2:	02e05a63          	blez	a4,3e6 <printint+0x96>
 3b6:	f04a                	sd	s2,32(sp)
 3b8:	ec4e                	sd	s3,24(sp)
 3ba:	fc040793          	addi	a5,s0,-64
 3be:	00e78933          	add	s2,a5,a4
 3c2:	fff78993          	addi	s3,a5,-1
 3c6:	99ba                	add	s3,s3,a4
 3c8:	377d                	addiw	a4,a4,-1
 3ca:	1702                	slli	a4,a4,0x20
 3cc:	9301                	srli	a4,a4,0x20
 3ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3d2:	fff94583          	lbu	a1,-1(s2)
 3d6:	8526                	mv	a0,s1
 3d8:	f5bff0ef          	jal	332 <putc>
  while(--i >= 0)
 3dc:	197d                	addi	s2,s2,-1
 3de:	ff391ae3          	bne	s2,s3,3d2 <printint+0x82>
 3e2:	7902                	ld	s2,32(sp)
 3e4:	69e2                	ld	s3,24(sp)
}
 3e6:	70e2                	ld	ra,56(sp)
 3e8:	7442                	ld	s0,48(sp)
 3ea:	74a2                	ld	s1,40(sp)
 3ec:	6121                	addi	sp,sp,64
 3ee:	8082                	ret
    x = -xx;
 3f0:	40b005bb          	negw	a1,a1
    neg = 1;
 3f4:	4885                	li	a7,1
    x = -xx;
 3f6:	bf85                	j	366 <printint+0x16>

00000000000003f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3f8:	711d                	addi	sp,sp,-96
 3fa:	ec86                	sd	ra,88(sp)
 3fc:	e8a2                	sd	s0,80(sp)
 3fe:	e0ca                	sd	s2,64(sp)
 400:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 402:	0005c903          	lbu	s2,0(a1)
 406:	26090863          	beqz	s2,676 <vprintf+0x27e>
 40a:	e4a6                	sd	s1,72(sp)
 40c:	fc4e                	sd	s3,56(sp)
 40e:	f852                	sd	s4,48(sp)
 410:	f456                	sd	s5,40(sp)
 412:	f05a                	sd	s6,32(sp)
 414:	ec5e                	sd	s7,24(sp)
 416:	e862                	sd	s8,16(sp)
 418:	e466                	sd	s9,8(sp)
 41a:	8b2a                	mv	s6,a0
 41c:	8a2e                	mv	s4,a1
 41e:	8bb2                	mv	s7,a2
  state = 0;
 420:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 422:	4481                	li	s1,0
 424:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 426:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 42a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 42e:	06c00c93          	li	s9,108
 432:	a005                	j	452 <vprintf+0x5a>
        putc(fd, c0);
 434:	85ca                	mv	a1,s2
 436:	855a                	mv	a0,s6
 438:	efbff0ef          	jal	332 <putc>
 43c:	a019                	j	442 <vprintf+0x4a>
    } else if(state == '%'){
 43e:	03598263          	beq	s3,s5,462 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 442:	2485                	addiw	s1,s1,1
 444:	8726                	mv	a4,s1
 446:	009a07b3          	add	a5,s4,s1
 44a:	0007c903          	lbu	s2,0(a5)
 44e:	20090c63          	beqz	s2,666 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 452:	0009079b          	sext.w	a5,s2
    if(state == 0){
 456:	fe0994e3          	bnez	s3,43e <vprintf+0x46>
      if(c0 == '%'){
 45a:	fd579de3          	bne	a5,s5,434 <vprintf+0x3c>
        state = '%';
 45e:	89be                	mv	s3,a5
 460:	b7cd                	j	442 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 462:	00ea06b3          	add	a3,s4,a4
 466:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 46a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 46c:	c681                	beqz	a3,474 <vprintf+0x7c>
 46e:	9752                	add	a4,a4,s4
 470:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 474:	03878f63          	beq	a5,s8,4b2 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 478:	05978963          	beq	a5,s9,4ca <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 47c:	07500713          	li	a4,117
 480:	0ee78363          	beq	a5,a4,566 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 484:	07800713          	li	a4,120
 488:	12e78563          	beq	a5,a4,5b2 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 48c:	07000713          	li	a4,112
 490:	14e78a63          	beq	a5,a4,5e4 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 494:	07300713          	li	a4,115
 498:	18e78a63          	beq	a5,a4,62c <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 49c:	02500713          	li	a4,37
 4a0:	04e79563          	bne	a5,a4,4ea <vprintf+0xf2>
        putc(fd, '%');
 4a4:	02500593          	li	a1,37
 4a8:	855a                	mv	a0,s6
 4aa:	e89ff0ef          	jal	332 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4ae:	4981                	li	s3,0
 4b0:	bf49                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4b2:	008b8913          	addi	s2,s7,8
 4b6:	4685                	li	a3,1
 4b8:	4629                	li	a2,10
 4ba:	000ba583          	lw	a1,0(s7)
 4be:	855a                	mv	a0,s6
 4c0:	e91ff0ef          	jal	350 <printint>
 4c4:	8bca                	mv	s7,s2
      state = 0;
 4c6:	4981                	li	s3,0
 4c8:	bfad                	j	442 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4ca:	06400793          	li	a5,100
 4ce:	02f68963          	beq	a3,a5,500 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4d2:	06c00793          	li	a5,108
 4d6:	04f68263          	beq	a3,a5,51a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4da:	07500793          	li	a5,117
 4de:	0af68063          	beq	a3,a5,57e <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 4e2:	07800793          	li	a5,120
 4e6:	0ef68263          	beq	a3,a5,5ca <vprintf+0x1d2>
        putc(fd, '%');
 4ea:	02500593          	li	a1,37
 4ee:	855a                	mv	a0,s6
 4f0:	e43ff0ef          	jal	332 <putc>
        putc(fd, c0);
 4f4:	85ca                	mv	a1,s2
 4f6:	855a                	mv	a0,s6
 4f8:	e3bff0ef          	jal	332 <putc>
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b791                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 500:	008b8913          	addi	s2,s7,8
 504:	4685                	li	a3,1
 506:	4629                	li	a2,10
 508:	000ba583          	lw	a1,0(s7)
 50c:	855a                	mv	a0,s6
 50e:	e43ff0ef          	jal	350 <printint>
        i += 1;
 512:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 514:	8bca                	mv	s7,s2
      state = 0;
 516:	4981                	li	s3,0
        i += 1;
 518:	b72d                	j	442 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 51a:	06400793          	li	a5,100
 51e:	02f60763          	beq	a2,a5,54c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 522:	07500793          	li	a5,117
 526:	06f60963          	beq	a2,a5,598 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 52a:	07800793          	li	a5,120
 52e:	faf61ee3          	bne	a2,a5,4ea <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 532:	008b8913          	addi	s2,s7,8
 536:	4681                	li	a3,0
 538:	4641                	li	a2,16
 53a:	000ba583          	lw	a1,0(s7)
 53e:	855a                	mv	a0,s6
 540:	e11ff0ef          	jal	350 <printint>
        i += 2;
 544:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 546:	8bca                	mv	s7,s2
      state = 0;
 548:	4981                	li	s3,0
        i += 2;
 54a:	bde5                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54c:	008b8913          	addi	s2,s7,8
 550:	4685                	li	a3,1
 552:	4629                	li	a2,10
 554:	000ba583          	lw	a1,0(s7)
 558:	855a                	mv	a0,s6
 55a:	df7ff0ef          	jal	350 <printint>
        i += 2;
 55e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
        i += 2;
 564:	bdf9                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 566:	008b8913          	addi	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	dddff0ef          	jal	350 <printint>
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b5d9                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	008b8913          	addi	s2,s7,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	dc5ff0ef          	jal	350 <printint>
        i += 1;
 590:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 592:	8bca                	mv	s7,s2
      state = 0;
 594:	4981                	li	s3,0
        i += 1;
 596:	b575                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	008b8913          	addi	s2,s7,8
 59c:	4681                	li	a3,0
 59e:	4629                	li	a2,10
 5a0:	000ba583          	lw	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	dabff0ef          	jal	350 <printint>
        i += 2;
 5aa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
        i += 2;
 5b0:	bd49                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4641                	li	a2,16
 5ba:	000ba583          	lw	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	d91ff0ef          	jal	350 <printint>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bdad                	j	442 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	d79ff0ef          	jal	350 <printint>
        i += 1;
 5dc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
        i += 1;
 5e2:	b585                	j	442 <vprintf+0x4a>
 5e4:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5e6:	008b8d13          	addi	s10,s7,8
 5ea:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ee:	03000593          	li	a1,48
 5f2:	855a                	mv	a0,s6
 5f4:	d3fff0ef          	jal	332 <putc>
  putc(fd, 'x');
 5f8:	07800593          	li	a1,120
 5fc:	855a                	mv	a0,s6
 5fe:	d35ff0ef          	jal	332 <putc>
 602:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 604:	00000b97          	auipc	s7,0x0
 608:	264b8b93          	addi	s7,s7,612 # 868 <digits>
 60c:	03c9d793          	srli	a5,s3,0x3c
 610:	97de                	add	a5,a5,s7
 612:	0007c583          	lbu	a1,0(a5)
 616:	855a                	mv	a0,s6
 618:	d1bff0ef          	jal	332 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61c:	0992                	slli	s3,s3,0x4
 61e:	397d                	addiw	s2,s2,-1
 620:	fe0916e3          	bnez	s2,60c <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 624:	8bea                	mv	s7,s10
      state = 0;
 626:	4981                	li	s3,0
 628:	6d02                	ld	s10,0(sp)
 62a:	bd21                	j	442 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 62c:	008b8993          	addi	s3,s7,8
 630:	000bb903          	ld	s2,0(s7)
 634:	00090f63          	beqz	s2,652 <vprintf+0x25a>
        for(; *s; s++)
 638:	00094583          	lbu	a1,0(s2)
 63c:	c195                	beqz	a1,660 <vprintf+0x268>
          putc(fd, *s);
 63e:	855a                	mv	a0,s6
 640:	cf3ff0ef          	jal	332 <putc>
        for(; *s; s++)
 644:	0905                	addi	s2,s2,1
 646:	00094583          	lbu	a1,0(s2)
 64a:	f9f5                	bnez	a1,63e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 64c:	8bce                	mv	s7,s3
      state = 0;
 64e:	4981                	li	s3,0
 650:	bbcd                	j	442 <vprintf+0x4a>
          s = "(null)";
 652:	00000917          	auipc	s2,0x0
 656:	20e90913          	addi	s2,s2,526 # 860 <malloc+0x102>
        for(; *s; s++)
 65a:	02800593          	li	a1,40
 65e:	b7c5                	j	63e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	bbf9                	j	442 <vprintf+0x4a>
 666:	64a6                	ld	s1,72(sp)
 668:	79e2                	ld	s3,56(sp)
 66a:	7a42                	ld	s4,48(sp)
 66c:	7aa2                	ld	s5,40(sp)
 66e:	7b02                	ld	s6,32(sp)
 670:	6be2                	ld	s7,24(sp)
 672:	6c42                	ld	s8,16(sp)
 674:	6ca2                	ld	s9,8(sp)
    }
  }
}
 676:	60e6                	ld	ra,88(sp)
 678:	6446                	ld	s0,80(sp)
 67a:	6906                	ld	s2,64(sp)
 67c:	6125                	addi	sp,sp,96
 67e:	8082                	ret

0000000000000680 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 680:	715d                	addi	sp,sp,-80
 682:	ec06                	sd	ra,24(sp)
 684:	e822                	sd	s0,16(sp)
 686:	1000                	addi	s0,sp,32
 688:	e010                	sd	a2,0(s0)
 68a:	e414                	sd	a3,8(s0)
 68c:	e818                	sd	a4,16(s0)
 68e:	ec1c                	sd	a5,24(s0)
 690:	03043023          	sd	a6,32(s0)
 694:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 698:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 69c:	8622                	mv	a2,s0
 69e:	d5bff0ef          	jal	3f8 <vprintf>
}
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6161                	addi	sp,sp,80
 6a8:	8082                	ret

00000000000006aa <printf>:

void
printf(const char *fmt, ...)
{
 6aa:	711d                	addi	sp,sp,-96
 6ac:	ec06                	sd	ra,24(sp)
 6ae:	e822                	sd	s0,16(sp)
 6b0:	1000                	addi	s0,sp,32
 6b2:	e40c                	sd	a1,8(s0)
 6b4:	e810                	sd	a2,16(s0)
 6b6:	ec14                	sd	a3,24(s0)
 6b8:	f018                	sd	a4,32(s0)
 6ba:	f41c                	sd	a5,40(s0)
 6bc:	03043823          	sd	a6,48(s0)
 6c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	00840613          	addi	a2,s0,8
 6c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6cc:	85aa                	mv	a1,a0
 6ce:	4505                	li	a0,1
 6d0:	d29ff0ef          	jal	3f8 <vprintf>
}
 6d4:	60e2                	ld	ra,24(sp)
 6d6:	6442                	ld	s0,16(sp)
 6d8:	6125                	addi	sp,sp,96
 6da:	8082                	ret

00000000000006dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e6:	00001797          	auipc	a5,0x1
 6ea:	91a7b783          	ld	a5,-1766(a5) # 1000 <freep>
 6ee:	a02d                	j	718 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f0:	4618                	lw	a4,8(a2)
 6f2:	9f2d                	addw	a4,a4,a1
 6f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f8:	6398                	ld	a4,0(a5)
 6fa:	6310                	ld	a2,0(a4)
 6fc:	a83d                	j	73a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6fe:	ff852703          	lw	a4,-8(a0)
 702:	9f31                	addw	a4,a4,a2
 704:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 706:	ff053683          	ld	a3,-16(a0)
 70a:	a091                	j	74e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70c:	6398                	ld	a4,0(a5)
 70e:	00e7e463          	bltu	a5,a4,716 <free+0x3a>
 712:	00e6ea63          	bltu	a3,a4,726 <free+0x4a>
{
 716:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 718:	fed7fae3          	bgeu	a5,a3,70c <free+0x30>
 71c:	6398                	ld	a4,0(a5)
 71e:	00e6e463          	bltu	a3,a4,726 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 722:	fee7eae3          	bltu	a5,a4,716 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 726:	ff852583          	lw	a1,-8(a0)
 72a:	6390                	ld	a2,0(a5)
 72c:	02059813          	slli	a6,a1,0x20
 730:	01c85713          	srli	a4,a6,0x1c
 734:	9736                	add	a4,a4,a3
 736:	fae60de3          	beq	a2,a4,6f0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 73a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 73e:	4790                	lw	a2,8(a5)
 740:	02061593          	slli	a1,a2,0x20
 744:	01c5d713          	srli	a4,a1,0x1c
 748:	973e                	add	a4,a4,a5
 74a:	fae68ae3          	beq	a3,a4,6fe <free+0x22>
    p->s.ptr = bp->s.ptr;
 74e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 750:	00001717          	auipc	a4,0x1
 754:	8af73823          	sd	a5,-1872(a4) # 1000 <freep>
}
 758:	6422                	ld	s0,8(sp)
 75a:	0141                	addi	sp,sp,16
 75c:	8082                	ret

000000000000075e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 75e:	7139                	addi	sp,sp,-64
 760:	fc06                	sd	ra,56(sp)
 762:	f822                	sd	s0,48(sp)
 764:	f426                	sd	s1,40(sp)
 766:	ec4e                	sd	s3,24(sp)
 768:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76a:	02051493          	slli	s1,a0,0x20
 76e:	9081                	srli	s1,s1,0x20
 770:	04bd                	addi	s1,s1,15
 772:	8091                	srli	s1,s1,0x4
 774:	0014899b          	addiw	s3,s1,1
 778:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 77a:	00001517          	auipc	a0,0x1
 77e:	88653503          	ld	a0,-1914(a0) # 1000 <freep>
 782:	c915                	beqz	a0,7b6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 784:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 786:	4798                	lw	a4,8(a5)
 788:	08977a63          	bgeu	a4,s1,81c <malloc+0xbe>
 78c:	f04a                	sd	s2,32(sp)
 78e:	e852                	sd	s4,16(sp)
 790:	e456                	sd	s5,8(sp)
 792:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 794:	8a4e                	mv	s4,s3
 796:	0009871b          	sext.w	a4,s3
 79a:	6685                	lui	a3,0x1
 79c:	00d77363          	bgeu	a4,a3,7a2 <malloc+0x44>
 7a0:	6a05                	lui	s4,0x1
 7a2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7aa:	00001917          	auipc	s2,0x1
 7ae:	85690913          	addi	s2,s2,-1962 # 1000 <freep>
  if(p == (char*)-1)
 7b2:	5afd                	li	s5,-1
 7b4:	a081                	j	7f4 <malloc+0x96>
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	e852                	sd	s4,16(sp)
 7ba:	e456                	sd	s5,8(sp)
 7bc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7be:	00001797          	auipc	a5,0x1
 7c2:	85278793          	addi	a5,a5,-1966 # 1010 <base>
 7c6:	00001717          	auipc	a4,0x1
 7ca:	82f73d23          	sd	a5,-1990(a4) # 1000 <freep>
 7ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d4:	b7c1                	j	794 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7d6:	6398                	ld	a4,0(a5)
 7d8:	e118                	sd	a4,0(a0)
 7da:	a8a9                	j	834 <malloc+0xd6>
  hp->s.size = nu;
 7dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e0:	0541                	addi	a0,a0,16
 7e2:	efbff0ef          	jal	6dc <free>
  return freep;
 7e6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ea:	c12d                	beqz	a0,84c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ee:	4798                	lw	a4,8(a5)
 7f0:	02977263          	bgeu	a4,s1,814 <malloc+0xb6>
    if(p == freep)
 7f4:	00093703          	ld	a4,0(s2)
 7f8:	853e                	mv	a0,a5
 7fa:	fef719e3          	bne	a4,a5,7ec <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 7fe:	8552                	mv	a0,s4
 800:	b0bff0ef          	jal	30a <sbrk>
  if(p == (char*)-1)
 804:	fd551ce3          	bne	a0,s5,7dc <malloc+0x7e>
        return 0;
 808:	4501                	li	a0,0
 80a:	7902                	ld	s2,32(sp)
 80c:	6a42                	ld	s4,16(sp)
 80e:	6aa2                	ld	s5,8(sp)
 810:	6b02                	ld	s6,0(sp)
 812:	a03d                	j	840 <malloc+0xe2>
 814:	7902                	ld	s2,32(sp)
 816:	6a42                	ld	s4,16(sp)
 818:	6aa2                	ld	s5,8(sp)
 81a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 81c:	fae48de3          	beq	s1,a4,7d6 <malloc+0x78>
        p->s.size -= nunits;
 820:	4137073b          	subw	a4,a4,s3
 824:	c798                	sw	a4,8(a5)
        p += p->s.size;
 826:	02071693          	slli	a3,a4,0x20
 82a:	01c6d713          	srli	a4,a3,0x1c
 82e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 830:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 834:	00000717          	auipc	a4,0x0
 838:	7ca73623          	sd	a0,1996(a4) # 1000 <freep>
      return (void*)(p + 1);
 83c:	01078513          	addi	a0,a5,16
  }
}
 840:	70e2                	ld	ra,56(sp)
 842:	7442                	ld	s0,48(sp)
 844:	74a2                	ld	s1,40(sp)
 846:	69e2                	ld	s3,24(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
 84c:	7902                	ld	s2,32(sp)
 84e:	6a42                	ld	s4,16(sp)
 850:	6aa2                	ld	s5,8(sp)
 852:	6b02                	ld	s6,0(sp)
 854:	b7f5                	j	840 <malloc+0xe2>
