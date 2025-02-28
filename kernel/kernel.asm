
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	28013103          	ld	sp,640(sp) # 8000a280 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	549040ef          	jal	80004d5e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  //check valid: size of page, in ragnge from end to phystop
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00023797          	auipc	a5,0x23
    80000034:	7d078793          	addi	a5,a5,2000 # 80023800 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree"); //stop the system

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	106000ef          	jal	8000014e <memset>

  r = (struct run*)pa;

  //put page pa to free list
  acquire(&kmem.lock);
    8000004c:	0000a917          	auipc	s2,0xa
    80000050:	28490913          	addi	s2,s2,644 # 8000a2d0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	76a050ef          	jal	800057c0 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	7f2050ef          	jal	80005858 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree"); //stop the system
    80000076:	00007517          	auipc	a0,0x7
    8000007a:	f8a50513          	addi	a0,a0,-118 # 80007000 <etext>
    8000007e:	414050ef          	jal	80005492 <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start); // round the value
    8000008c:	6785                	lui	a5,0x1
    8000008e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000092:	00e504b3          	add	s1,a0,a4
    80000096:	777d                	lui	a4,0xfffff
    80000098:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) // loop through each page
    8000009a:	94be                	add	s1,s1,a5
    8000009c:	0295e263          	bltu	a1,s1,800000c0 <freerange+0x3e>
    800000a0:	e84a                	sd	s2,16(sp)
    800000a2:	e44e                	sd	s3,8(sp)
    800000a4:	e052                	sd	s4,0(sp)
    800000a6:	892e                	mv	s2,a1
    kfree(p); //relase each page = put each page into free list of page
    800000a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) // loop through each page
    800000aa:	6985                	lui	s3,0x1
    kfree(p); //relase each page = put each page into free list of page
    800000ac:	01448533          	add	a0,s1,s4
    800000b0:	f6dff0ef          	jal	8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) // loop through each page
    800000b4:	94ce                	add	s1,s1,s3
    800000b6:	fe997be3          	bgeu	s2,s1,800000ac <freerange+0x2a>
    800000ba:	6942                	ld	s2,16(sp)
    800000bc:	69a2                	ld	s3,8(sp)
    800000be:	6a02                	ld	s4,0(sp)
}
    800000c0:	70a2                	ld	ra,40(sp)
    800000c2:	7402                	ld	s0,32(sp)
    800000c4:	64e2                	ld	s1,24(sp)
    800000c6:	6145                	addi	sp,sp,48
    800000c8:	8082                	ret

00000000800000ca <kinit>:
{
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e406                	sd	ra,8(sp)
    800000ce:	e022                	sd	s0,0(sp)
    800000d0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem"); //initialize a lock named "kmem"
    800000d2:	00007597          	auipc	a1,0x7
    800000d6:	f3e58593          	addi	a1,a1,-194 # 80007010 <etext+0x10>
    800000da:	0000a517          	auipc	a0,0xa
    800000de:	1f650513          	addi	a0,a0,502 # 8000a2d0 <kmem>
    800000e2:	65e050ef          	jal	80005740 <initlock>
  freerange(end, (void*)PHYSTOP); //release a range of page from "end" to phystop = put a range to free list pf page
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00023517          	auipc	a0,0x23
    800000ee:	71650513          	addi	a0,a0,1814 # 80023800 <end>
    800000f2:	f91ff0ef          	jal	80000082 <freerange>
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000fe:	1101                	addi	sp,sp,-32
    80000100:	ec06                	sd	ra,24(sp)
    80000102:	e822                	sd	s0,16(sp)
    80000104:	e426                	sd	s1,8(sp)
    80000106:	1000                	addi	s0,sp,32
  struct run *r;

  //get the first page in the free list
  acquire(&kmem.lock);
    80000108:	0000a497          	auipc	s1,0xa
    8000010c:	1c848493          	addi	s1,s1,456 # 8000a2d0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	6ae050ef          	jal	800057c0 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	1b450513          	addi	a0,a0,436 # 8000a2d0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	732050ef          	jal	80005858 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk to easily detect errors if there is misuse.
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	01e000ef          	jal	8000014e <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	0000a517          	auipc	a0,0xa
    80000144:	19050513          	addi	a0,a0,400 # 8000a2d0 <kmem>
    80000148:	710050ef          	jal	80005858 <release>
  if(r)
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>

000000008000014e <memset>:

//Assign the value c to each byte in memory starting from dst, lasting n bytes
//Fill with junk (c)
void*
memset(void *dst, int c, uint n)
{
    8000014e:	1141                	addi	sp,sp,-16
    80000150:	e422                	sd	s0,8(sp)
    80000152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000154:	ca19                	beqz	a2,8000016a <memset+0x1c>
    80000156:	87aa                	mv	a5,a0
    80000158:	1602                	slli	a2,a2,0x20
    8000015a:	9201                	srli	a2,a2,0x20
    8000015c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000160:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000164:	0785                	addi	a5,a5,1
    80000166:	fee79de3          	bne	a5,a4,80000160 <memset+0x12>
  }
  return dst;
}
    8000016a:	6422                	ld	s0,8(sp)
    8000016c:	0141                	addi	sp,sp,16
    8000016e:	8082                	ret

0000000080000170 <memcmp>:

//Compare n bytes between two memory areas v1 and v2.
int
memcmp(const void *v1, const void *v2, uint n)
{
    80000170:	1141                	addi	sp,sp,-16
    80000172:	e422                	sd	s0,8(sp)
    80000174:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000176:	ca05                	beqz	a2,800001a6 <memcmp+0x36>
    80000178:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000017c:	1682                	slli	a3,a3,0x20
    8000017e:	9281                	srli	a3,a3,0x20
    80000180:	0685                	addi	a3,a3,1
    80000182:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000184:	00054783          	lbu	a5,0(a0)
    80000188:	0005c703          	lbu	a4,0(a1)
    8000018c:	00e79863          	bne	a5,a4,8000019c <memcmp+0x2c>
      return *s1 - *s2; // < 0 or > 0 : difference between bytes
    s1++, s2++;
    80000190:	0505                	addi	a0,a0,1
    80000192:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000194:	fed518e3          	bne	a0,a3,80000184 <memcmp+0x14>
  }

  return 0; // the same memory
    80000198:	4501                	li	a0,0
    8000019a:	a019                	j	800001a0 <memcmp+0x30>
      return *s1 - *s2; // < 0 or > 0 : difference between bytes
    8000019c:	40e7853b          	subw	a0,a5,a4
}
    800001a0:	6422                	ld	s0,8(sp)
    800001a2:	0141                	addi	sp,sp,16
    800001a4:	8082                	ret
  return 0; // the same memory
    800001a6:	4501                	li	a0,0
    800001a8:	bfe5                	j	800001a0 <memcmp+0x30>

00000000800001aa <memmove>:

//Copy n bytes from src to dst. Handles cases of overlapping memory areas.
void*
memmove(void *dst, const void *src, uint n)
{
    800001aa:	1141                	addi	sp,sp,-16
    800001ac:	e422                	sd	s0,8(sp)
    800001ae:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001b0:	c205                	beqz	a2,800001d0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  //check overlap
  if(s < d && s + n > d){
    800001b2:	02a5e263          	bltu	a1,a0,800001d6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001b6:	1602                	slli	a2,a2,0x20
    800001b8:	9201                	srli	a2,a2,0x20
    800001ba:	00c587b3          	add	a5,a1,a2
{
    800001be:	872a                	mv	a4,a0
      *d++ = *s++;
    800001c0:	0585                	addi	a1,a1,1
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb801>
    800001c4:	fff5c683          	lbu	a3,-1(a1)
    800001c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001cc:	feb79ae3          	bne	a5,a1,800001c0 <memmove+0x16>

  return dst;
}
    800001d0:	6422                	ld	s0,8(sp)
    800001d2:	0141                	addi	sp,sp,16
    800001d4:	8082                	ret
  if(s < d && s + n > d){
    800001d6:	02061693          	slli	a3,a2,0x20
    800001da:	9281                	srli	a3,a3,0x20
    800001dc:	00d58733          	add	a4,a1,a3
    800001e0:	fce57be3          	bgeu	a0,a4,800001b6 <memmove+0xc>
    d += n;
    800001e4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001e6:	fff6079b          	addiw	a5,a2,-1
    800001ea:	1782                	slli	a5,a5,0x20
    800001ec:	9381                	srli	a5,a5,0x20
    800001ee:	fff7c793          	not	a5,a5
    800001f2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001f4:	177d                	addi	a4,a4,-1
    800001f6:	16fd                	addi	a3,a3,-1
    800001f8:	00074603          	lbu	a2,0(a4)
    800001fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000200:	fef71ae3          	bne	a4,a5,800001f4 <memmove+0x4a>
    80000204:	b7f1                	j	800001d0 <memmove+0x26>

0000000080000206 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000206:	1141                	addi	sp,sp,-16
    80000208:	e406                	sd	ra,8(sp)
    8000020a:	e022                	sd	s0,0(sp)
    8000020c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000020e:	f9dff0ef          	jal	800001aa <memmove>
}
    80000212:	60a2                	ld	ra,8(sp)
    80000214:	6402                	ld	s0,0(sp)
    80000216:	0141                	addi	sp,sp,16
    80000218:	8082                	ret

000000008000021a <strncmp>:

//Compares the first n characters between two strings p and q.
int
strncmp(const char *p, const char *q, uint n)
{
    8000021a:	1141                	addi	sp,sp,-16
    8000021c:	e422                	sd	s0,8(sp)
    8000021e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000220:	ce11                	beqz	a2,8000023c <strncmp+0x22>
    80000222:	00054783          	lbu	a5,0(a0)
    80000226:	cf89                	beqz	a5,80000240 <strncmp+0x26>
    80000228:	0005c703          	lbu	a4,0(a1)
    8000022c:	00f71a63          	bne	a4,a5,80000240 <strncmp+0x26>
    n--, p++, q++;
    80000230:	367d                	addiw	a2,a2,-1
    80000232:	0505                	addi	a0,a0,1
    80000234:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000236:	f675                	bnez	a2,80000222 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000238:	4501                	li	a0,0
    8000023a:	a801                	j	8000024a <strncmp+0x30>
    8000023c:	4501                	li	a0,0
    8000023e:	a031                	j	8000024a <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000240:	00054503          	lbu	a0,0(a0)
    80000244:	0005c783          	lbu	a5,0(a1)
    80000248:	9d1d                	subw	a0,a0,a5
}
    8000024a:	6422                	ld	s0,8(sp)
    8000024c:	0141                	addi	sp,sp,16
    8000024e:	8082                	ret

0000000080000250 <strncpy>:

//Copy n characters from string t to s
char*
strncpy(char *s, const char *t, int n)
{
    80000250:	1141                	addi	sp,sp,-16
    80000252:	e422                	sd	s0,8(sp)
    80000254:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000256:	87aa                	mv	a5,a0
    80000258:	86b2                	mv	a3,a2
    8000025a:	367d                	addiw	a2,a2,-1
    8000025c:	02d05563          	blez	a3,80000286 <strncpy+0x36>
    80000260:	0785                	addi	a5,a5,1
    80000262:	0005c703          	lbu	a4,0(a1)
    80000266:	fee78fa3          	sb	a4,-1(a5)
    8000026a:	0585                	addi	a1,a1,1
    8000026c:	f775                	bnez	a4,80000258 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000026e:	873e                	mv	a4,a5
    80000270:	9fb5                	addw	a5,a5,a3
    80000272:	37fd                	addiw	a5,a5,-1
    80000274:	00c05963          	blez	a2,80000286 <strncpy+0x36>
    *s++ = 0; //add /0 to make sure that string end.
    80000278:	0705                	addi	a4,a4,1
    8000027a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    8000027e:	40e786bb          	subw	a3,a5,a4
    80000282:	fed04be3          	bgtz	a3,80000278 <strncpy+0x28>
  return os;
}
    80000286:	6422                	ld	s0,8(sp)
    80000288:	0141                	addi	sp,sp,16
    8000028a:	8082                	ret

000000008000028c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e422                	sd	s0,8(sp)
    80000290:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000292:	02c05363          	blez	a2,800002b8 <safestrcpy+0x2c>
    80000296:	fff6069b          	addiw	a3,a2,-1
    8000029a:	1682                	slli	a3,a3,0x20
    8000029c:	9281                	srli	a3,a3,0x20
    8000029e:	96ae                	add	a3,a3,a1
    800002a0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002a2:	00d58963          	beq	a1,a3,800002b4 <safestrcpy+0x28>
    800002a6:	0585                	addi	a1,a1,1
    800002a8:	0785                	addi	a5,a5,1
    800002aa:	fff5c703          	lbu	a4,-1(a1)
    800002ae:	fee78fa3          	sb	a4,-1(a5)
    800002b2:	fb65                	bnez	a4,800002a2 <safestrcpy+0x16>
    ;
  *s = 0;
    800002b4:	00078023          	sb	zero,0(a5)
  return os;
}
    800002b8:	6422                	ld	s0,8(sp)
    800002ba:	0141                	addi	sp,sp,16
    800002bc:	8082                	ret

00000000800002be <strlen>:

//get the length of the string
int
strlen(const char *s)
{
    800002be:	1141                	addi	sp,sp,-16
    800002c0:	e422                	sd	s0,8(sp)
    800002c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002c4:	00054783          	lbu	a5,0(a0)
    800002c8:	cf91                	beqz	a5,800002e4 <strlen+0x26>
    800002ca:	0505                	addi	a0,a0,1
    800002cc:	87aa                	mv	a5,a0
    800002ce:	86be                	mv	a3,a5
    800002d0:	0785                	addi	a5,a5,1
    800002d2:	fff7c703          	lbu	a4,-1(a5)
    800002d6:	ff65                	bnez	a4,800002ce <strlen+0x10>
    800002d8:	40a6853b          	subw	a0,a3,a0
    800002dc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800002de:	6422                	ld	s0,8(sp)
    800002e0:	0141                	addi	sp,sp,16
    800002e2:	8082                	ret
  for(n = 0; s[n]; n++)
    800002e4:	4501                	li	a0,0
    800002e6:	bfe5                	j	800002de <strlen+0x20>

00000000800002e8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002e8:	1141                	addi	sp,sp,-16
    800002ea:	e406                	sd	ra,8(sp)
    800002ec:	e022                	sd	s0,0(sp)
    800002ee:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002f0:	24b000ef          	jal	80000d3a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002f4:	0000a717          	auipc	a4,0xa
    800002f8:	fac70713          	addi	a4,a4,-84 # 8000a2a0 <started>
  if(cpuid() == 0){
    800002fc:	c51d                	beqz	a0,8000032a <main+0x42>
    while(started == 0)
    800002fe:	431c                	lw	a5,0(a4)
    80000300:	2781                	sext.w	a5,a5
    80000302:	dff5                	beqz	a5,800002fe <main+0x16>
      ;
    __sync_synchronize();
    80000304:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000308:	233000ef          	jal	80000d3a <cpuid>
    8000030c:	85aa                	mv	a1,a0
    8000030e:	00007517          	auipc	a0,0x7
    80000312:	d2a50513          	addi	a0,a0,-726 # 80007038 <etext+0x38>
    80000316:	6ab040ef          	jal	800051c0 <printf>
    kvminithart();    // turn on paging
    8000031a:	080000ef          	jal	8000039a <kvminithart>
    trapinithart();   // install kernel trap vector
    8000031e:	540010ef          	jal	8000185e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000322:	456040ef          	jal	80004778 <plicinithart>
  }

  scheduler();        
    80000326:	67d000ef          	jal	800011a2 <scheduler>
    consoleinit();
    8000032a:	5c1040ef          	jal	800050ea <consoleinit>
    printfinit();
    8000032e:	19e050ef          	jal	800054cc <printfinit>
    printf("\n");
    80000332:	00007517          	auipc	a0,0x7
    80000336:	ce650513          	addi	a0,a0,-794 # 80007018 <etext+0x18>
    8000033a:	687040ef          	jal	800051c0 <printf>
    printf("xv6 kernel is booting\n");
    8000033e:	00007517          	auipc	a0,0x7
    80000342:	ce250513          	addi	a0,a0,-798 # 80007020 <etext+0x20>
    80000346:	67b040ef          	jal	800051c0 <printf>
    printf("\n");
    8000034a:	00007517          	auipc	a0,0x7
    8000034e:	cce50513          	addi	a0,a0,-818 # 80007018 <etext+0x18>
    80000352:	66f040ef          	jal	800051c0 <printf>
    kinit();         // physical page allocator
    80000356:	d75ff0ef          	jal	800000ca <kinit>
    kvminit();       // create kernel page table
    8000035a:	2ca000ef          	jal	80000624 <kvminit>
    kvminithart();   // turn on paging
    8000035e:	03c000ef          	jal	8000039a <kvminithart>
    procinit();      // process table
    80000362:	123000ef          	jal	80000c84 <procinit>
    trapinit();      // trap vectors
    80000366:	4d4010ef          	jal	8000183a <trapinit>
    trapinithart();  // install kernel trap vector
    8000036a:	4f4010ef          	jal	8000185e <trapinithart>
    plicinit();      // set up interrupt controller
    8000036e:	3f0040ef          	jal	8000475e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000372:	406040ef          	jal	80004778 <plicinithart>
    binit();         // buffer cache
    80000376:	3a7010ef          	jal	80001f1c <binit>
    iinit();         // inode table
    8000037a:	198020ef          	jal	80002512 <iinit>
    fileinit();      // file table
    8000037e:	745020ef          	jal	800032c2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000382:	4e6040ef          	jal	80004868 <virtio_disk_init>
    userinit();      // first user process
    80000386:	449000ef          	jal	80000fce <userinit>
    __sync_synchronize();
    8000038a:	0330000f          	fence	rw,rw
    started = 1;
    8000038e:	4785                	li	a5,1
    80000390:	0000a717          	auipc	a4,0xa
    80000394:	f0f72823          	sw	a5,-240(a4) # 8000a2a0 <started>
    80000398:	b779                	j	80000326 <main+0x3e>

000000008000039a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000039a:	1141                	addi	sp,sp,-16
    8000039c:	e422                	sd	s0,8(sp)
    8000039e:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003a0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003a4:	0000a797          	auipc	a5,0xa
    800003a8:	f047b783          	ld	a5,-252(a5) # 8000a2a8 <kernel_pagetable>
    800003ac:	83b1                	srli	a5,a5,0xc
    800003ae:	577d                	li	a4,-1
    800003b0:	177e                	slli	a4,a4,0x3f
    800003b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003b4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003b8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003bc:	6422                	ld	s0,8(sp)
    800003be:	0141                	addi	sp,sp,16
    800003c0:	8082                	ret

00000000800003c2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003c2:	7139                	addi	sp,sp,-64
    800003c4:	fc06                	sd	ra,56(sp)
    800003c6:	f822                	sd	s0,48(sp)
    800003c8:	f426                	sd	s1,40(sp)
    800003ca:	f04a                	sd	s2,32(sp)
    800003cc:	ec4e                	sd	s3,24(sp)
    800003ce:	e852                	sd	s4,16(sp)
    800003d0:	e456                	sd	s5,8(sp)
    800003d2:	e05a                	sd	s6,0(sp)
    800003d4:	0080                	addi	s0,sp,64
    800003d6:	84aa                	mv	s1,a0
    800003d8:	89ae                	mv	s3,a1
    800003da:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800003dc:	57fd                	li	a5,-1
    800003de:	83e9                	srli	a5,a5,0x1a
    800003e0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800003e2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800003e4:	02b7fc63          	bgeu	a5,a1,8000041c <walk+0x5a>
    panic("walk");
    800003e8:	00007517          	auipc	a0,0x7
    800003ec:	c6850513          	addi	a0,a0,-920 # 80007050 <etext+0x50>
    800003f0:	0a2050ef          	jal	80005492 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800003f4:	060a8263          	beqz	s5,80000458 <walk+0x96>
    800003f8:	d07ff0ef          	jal	800000fe <kalloc>
    800003fc:	84aa                	mv	s1,a0
    800003fe:	c139                	beqz	a0,80000444 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000400:	6605                	lui	a2,0x1
    80000402:	4581                	li	a1,0
    80000404:	d4bff0ef          	jal	8000014e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000408:	00c4d793          	srli	a5,s1,0xc
    8000040c:	07aa                	slli	a5,a5,0xa
    8000040e:	0017e793          	ori	a5,a5,1
    80000412:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000416:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb7f7>
    80000418:	036a0063          	beq	s4,s6,80000438 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000041c:	0149d933          	srl	s2,s3,s4
    80000420:	1ff97913          	andi	s2,s2,511
    80000424:	090e                	slli	s2,s2,0x3
    80000426:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000428:	00093483          	ld	s1,0(s2)
    8000042c:	0014f793          	andi	a5,s1,1
    80000430:	d3f1                	beqz	a5,800003f4 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000432:	80a9                	srli	s1,s1,0xa
    80000434:	04b2                	slli	s1,s1,0xc
    80000436:	b7c5                	j	80000416 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000438:	00c9d513          	srli	a0,s3,0xc
    8000043c:	1ff57513          	andi	a0,a0,511
    80000440:	050e                	slli	a0,a0,0x3
    80000442:	9526                	add	a0,a0,s1
}
    80000444:	70e2                	ld	ra,56(sp)
    80000446:	7442                	ld	s0,48(sp)
    80000448:	74a2                	ld	s1,40(sp)
    8000044a:	7902                	ld	s2,32(sp)
    8000044c:	69e2                	ld	s3,24(sp)
    8000044e:	6a42                	ld	s4,16(sp)
    80000450:	6aa2                	ld	s5,8(sp)
    80000452:	6b02                	ld	s6,0(sp)
    80000454:	6121                	addi	sp,sp,64
    80000456:	8082                	ret
        return 0;
    80000458:	4501                	li	a0,0
    8000045a:	b7ed                	j	80000444 <walk+0x82>

000000008000045c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000045c:	57fd                	li	a5,-1
    8000045e:	83e9                	srli	a5,a5,0x1a
    80000460:	00b7f463          	bgeu	a5,a1,80000468 <walkaddr+0xc>
    return 0;
    80000464:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000466:	8082                	ret
{
    80000468:	1141                	addi	sp,sp,-16
    8000046a:	e406                	sd	ra,8(sp)
    8000046c:	e022                	sd	s0,0(sp)
    8000046e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000470:	4601                	li	a2,0
    80000472:	f51ff0ef          	jal	800003c2 <walk>
  if(pte == 0)
    80000476:	c105                	beqz	a0,80000496 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000478:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000047a:	0117f693          	andi	a3,a5,17
    8000047e:	4745                	li	a4,17
    return 0;
    80000480:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000482:	00e68663          	beq	a3,a4,8000048e <walkaddr+0x32>
}
    80000486:	60a2                	ld	ra,8(sp)
    80000488:	6402                	ld	s0,0(sp)
    8000048a:	0141                	addi	sp,sp,16
    8000048c:	8082                	ret
  pa = PTE2PA(*pte);
    8000048e:	83a9                	srli	a5,a5,0xa
    80000490:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000494:	bfcd                	j	80000486 <walkaddr+0x2a>
    return 0;
    80000496:	4501                	li	a0,0
    80000498:	b7fd                	j	80000486 <walkaddr+0x2a>

000000008000049a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000049a:	715d                	addi	sp,sp,-80
    8000049c:	e486                	sd	ra,72(sp)
    8000049e:	e0a2                	sd	s0,64(sp)
    800004a0:	fc26                	sd	s1,56(sp)
    800004a2:	f84a                	sd	s2,48(sp)
    800004a4:	f44e                	sd	s3,40(sp)
    800004a6:	f052                	sd	s4,32(sp)
    800004a8:	ec56                	sd	s5,24(sp)
    800004aa:	e85a                	sd	s6,16(sp)
    800004ac:	e45e                	sd	s7,8(sp)
    800004ae:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004b0:	03459793          	slli	a5,a1,0x34
    800004b4:	e7a9                	bnez	a5,800004fe <mappages+0x64>
    800004b6:	8aaa                	mv	s5,a0
    800004b8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004ba:	03461793          	slli	a5,a2,0x34
    800004be:	e7b1                	bnez	a5,8000050a <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800004c0:	ca39                	beqz	a2,80000516 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800004c2:	77fd                	lui	a5,0xfffff
    800004c4:	963e                	add	a2,a2,a5
    800004c6:	00b609b3          	add	s3,a2,a1
  a = va;
    800004ca:	892e                	mv	s2,a1
    800004cc:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004d0:	6b85                	lui	s7,0x1
    800004d2:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800004d6:	4605                	li	a2,1
    800004d8:	85ca                	mv	a1,s2
    800004da:	8556                	mv	a0,s5
    800004dc:	ee7ff0ef          	jal	800003c2 <walk>
    800004e0:	c539                	beqz	a0,8000052e <mappages+0x94>
    if(*pte & PTE_V)
    800004e2:	611c                	ld	a5,0(a0)
    800004e4:	8b85                	andi	a5,a5,1
    800004e6:	ef95                	bnez	a5,80000522 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800004e8:	80b1                	srli	s1,s1,0xc
    800004ea:	04aa                	slli	s1,s1,0xa
    800004ec:	0164e4b3          	or	s1,s1,s6
    800004f0:	0014e493          	ori	s1,s1,1
    800004f4:	e104                	sd	s1,0(a0)
    if(a == last)
    800004f6:	05390863          	beq	s2,s3,80000546 <mappages+0xac>
    a += PGSIZE;
    800004fa:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800004fc:	bfd9                	j	800004d2 <mappages+0x38>
    panic("mappages: va not aligned");
    800004fe:	00007517          	auipc	a0,0x7
    80000502:	b5a50513          	addi	a0,a0,-1190 # 80007058 <etext+0x58>
    80000506:	78d040ef          	jal	80005492 <panic>
    panic("mappages: size not aligned");
    8000050a:	00007517          	auipc	a0,0x7
    8000050e:	b6e50513          	addi	a0,a0,-1170 # 80007078 <etext+0x78>
    80000512:	781040ef          	jal	80005492 <panic>
    panic("mappages: size");
    80000516:	00007517          	auipc	a0,0x7
    8000051a:	b8250513          	addi	a0,a0,-1150 # 80007098 <etext+0x98>
    8000051e:	775040ef          	jal	80005492 <panic>
      panic("mappages: remap");
    80000522:	00007517          	auipc	a0,0x7
    80000526:	b8650513          	addi	a0,a0,-1146 # 800070a8 <etext+0xa8>
    8000052a:	769040ef          	jal	80005492 <panic>
      return -1;
    8000052e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000530:	60a6                	ld	ra,72(sp)
    80000532:	6406                	ld	s0,64(sp)
    80000534:	74e2                	ld	s1,56(sp)
    80000536:	7942                	ld	s2,48(sp)
    80000538:	79a2                	ld	s3,40(sp)
    8000053a:	7a02                	ld	s4,32(sp)
    8000053c:	6ae2                	ld	s5,24(sp)
    8000053e:	6b42                	ld	s6,16(sp)
    80000540:	6ba2                	ld	s7,8(sp)
    80000542:	6161                	addi	sp,sp,80
    80000544:	8082                	ret
  return 0;
    80000546:	4501                	li	a0,0
    80000548:	b7e5                	j	80000530 <mappages+0x96>

000000008000054a <kvmmap>:
{
    8000054a:	1141                	addi	sp,sp,-16
    8000054c:	e406                	sd	ra,8(sp)
    8000054e:	e022                	sd	s0,0(sp)
    80000550:	0800                	addi	s0,sp,16
    80000552:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000554:	86b2                	mv	a3,a2
    80000556:	863e                	mv	a2,a5
    80000558:	f43ff0ef          	jal	8000049a <mappages>
    8000055c:	e509                	bnez	a0,80000566 <kvmmap+0x1c>
}
    8000055e:	60a2                	ld	ra,8(sp)
    80000560:	6402                	ld	s0,0(sp)
    80000562:	0141                	addi	sp,sp,16
    80000564:	8082                	ret
    panic("kvmmap");
    80000566:	00007517          	auipc	a0,0x7
    8000056a:	b5250513          	addi	a0,a0,-1198 # 800070b8 <etext+0xb8>
    8000056e:	725040ef          	jal	80005492 <panic>

0000000080000572 <kvmmake>:
{
    80000572:	1101                	addi	sp,sp,-32
    80000574:	ec06                	sd	ra,24(sp)
    80000576:	e822                	sd	s0,16(sp)
    80000578:	e426                	sd	s1,8(sp)
    8000057a:	e04a                	sd	s2,0(sp)
    8000057c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000057e:	b81ff0ef          	jal	800000fe <kalloc>
    80000582:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000584:	6605                	lui	a2,0x1
    80000586:	4581                	li	a1,0
    80000588:	bc7ff0ef          	jal	8000014e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000058c:	4719                	li	a4,6
    8000058e:	6685                	lui	a3,0x1
    80000590:	10000637          	lui	a2,0x10000
    80000594:	100005b7          	lui	a1,0x10000
    80000598:	8526                	mv	a0,s1
    8000059a:	fb1ff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000059e:	4719                	li	a4,6
    800005a0:	6685                	lui	a3,0x1
    800005a2:	10001637          	lui	a2,0x10001
    800005a6:	100015b7          	lui	a1,0x10001
    800005aa:	8526                	mv	a0,s1
    800005ac:	f9fff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005b0:	4719                	li	a4,6
    800005b2:	040006b7          	lui	a3,0x4000
    800005b6:	0c000637          	lui	a2,0xc000
    800005ba:	0c0005b7          	lui	a1,0xc000
    800005be:	8526                	mv	a0,s1
    800005c0:	f8bff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005c4:	00007917          	auipc	s2,0x7
    800005c8:	a3c90913          	addi	s2,s2,-1476 # 80007000 <etext>
    800005cc:	4729                	li	a4,10
    800005ce:	80007697          	auipc	a3,0x80007
    800005d2:	a3268693          	addi	a3,a3,-1486 # 7000 <_entry-0x7fff9000>
    800005d6:	4605                	li	a2,1
    800005d8:	067e                	slli	a2,a2,0x1f
    800005da:	85b2                	mv	a1,a2
    800005dc:	8526                	mv	a0,s1
    800005de:	f6dff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800005e2:	46c5                	li	a3,17
    800005e4:	06ee                	slli	a3,a3,0x1b
    800005e6:	4719                	li	a4,6
    800005e8:	412686b3          	sub	a3,a3,s2
    800005ec:	864a                	mv	a2,s2
    800005ee:	85ca                	mv	a1,s2
    800005f0:	8526                	mv	a0,s1
    800005f2:	f59ff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800005f6:	4729                	li	a4,10
    800005f8:	6685                	lui	a3,0x1
    800005fa:	00006617          	auipc	a2,0x6
    800005fe:	a0660613          	addi	a2,a2,-1530 # 80006000 <_trampoline>
    80000602:	040005b7          	lui	a1,0x4000
    80000606:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000608:	05b2                	slli	a1,a1,0xc
    8000060a:	8526                	mv	a0,s1
    8000060c:	f3fff0ef          	jal	8000054a <kvmmap>
  proc_mapstacks(kpgtbl);
    80000610:	8526                	mv	a0,s1
    80000612:	5da000ef          	jal	80000bec <proc_mapstacks>
}
    80000616:	8526                	mv	a0,s1
    80000618:	60e2                	ld	ra,24(sp)
    8000061a:	6442                	ld	s0,16(sp)
    8000061c:	64a2                	ld	s1,8(sp)
    8000061e:	6902                	ld	s2,0(sp)
    80000620:	6105                	addi	sp,sp,32
    80000622:	8082                	ret

0000000080000624 <kvminit>:
{
    80000624:	1141                	addi	sp,sp,-16
    80000626:	e406                	sd	ra,8(sp)
    80000628:	e022                	sd	s0,0(sp)
    8000062a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000062c:	f47ff0ef          	jal	80000572 <kvmmake>
    80000630:	0000a797          	auipc	a5,0xa
    80000634:	c6a7bc23          	sd	a0,-904(a5) # 8000a2a8 <kernel_pagetable>
}
    80000638:	60a2                	ld	ra,8(sp)
    8000063a:	6402                	ld	s0,0(sp)
    8000063c:	0141                	addi	sp,sp,16
    8000063e:	8082                	ret

0000000080000640 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000640:	715d                	addi	sp,sp,-80
    80000642:	e486                	sd	ra,72(sp)
    80000644:	e0a2                	sd	s0,64(sp)
    80000646:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000648:	03459793          	slli	a5,a1,0x34
    8000064c:	e39d                	bnez	a5,80000672 <uvmunmap+0x32>
    8000064e:	f84a                	sd	s2,48(sp)
    80000650:	f44e                	sd	s3,40(sp)
    80000652:	f052                	sd	s4,32(sp)
    80000654:	ec56                	sd	s5,24(sp)
    80000656:	e85a                	sd	s6,16(sp)
    80000658:	e45e                	sd	s7,8(sp)
    8000065a:	8a2a                	mv	s4,a0
    8000065c:	892e                	mv	s2,a1
    8000065e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000660:	0632                	slli	a2,a2,0xc
    80000662:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000666:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000668:	6b05                	lui	s6,0x1
    8000066a:	0735ff63          	bgeu	a1,s3,800006e8 <uvmunmap+0xa8>
    8000066e:	fc26                	sd	s1,56(sp)
    80000670:	a0a9                	j	800006ba <uvmunmap+0x7a>
    80000672:	fc26                	sd	s1,56(sp)
    80000674:	f84a                	sd	s2,48(sp)
    80000676:	f44e                	sd	s3,40(sp)
    80000678:	f052                	sd	s4,32(sp)
    8000067a:	ec56                	sd	s5,24(sp)
    8000067c:	e85a                	sd	s6,16(sp)
    8000067e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80000680:	00007517          	auipc	a0,0x7
    80000684:	a4050513          	addi	a0,a0,-1472 # 800070c0 <etext+0xc0>
    80000688:	60b040ef          	jal	80005492 <panic>
      panic("uvmunmap: walk");
    8000068c:	00007517          	auipc	a0,0x7
    80000690:	a4c50513          	addi	a0,a0,-1460 # 800070d8 <etext+0xd8>
    80000694:	5ff040ef          	jal	80005492 <panic>
      panic("uvmunmap: not mapped");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a5050513          	addi	a0,a0,-1456 # 800070e8 <etext+0xe8>
    800006a0:	5f3040ef          	jal	80005492 <panic>
      panic("uvmunmap: not a leaf");
    800006a4:	00007517          	auipc	a0,0x7
    800006a8:	a5c50513          	addi	a0,a0,-1444 # 80007100 <etext+0x100>
    800006ac:	5e7040ef          	jal	80005492 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800006b0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006b4:	995a                	add	s2,s2,s6
    800006b6:	03397863          	bgeu	s2,s3,800006e6 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800006ba:	4601                	li	a2,0
    800006bc:	85ca                	mv	a1,s2
    800006be:	8552                	mv	a0,s4
    800006c0:	d03ff0ef          	jal	800003c2 <walk>
    800006c4:	84aa                	mv	s1,a0
    800006c6:	d179                	beqz	a0,8000068c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    800006c8:	6108                	ld	a0,0(a0)
    800006ca:	00157793          	andi	a5,a0,1
    800006ce:	d7e9                	beqz	a5,80000698 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    800006d0:	3ff57793          	andi	a5,a0,1023
    800006d4:	fd7788e3          	beq	a5,s7,800006a4 <uvmunmap+0x64>
    if(do_free){
    800006d8:	fc0a8ce3          	beqz	s5,800006b0 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    800006dc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800006de:	0532                	slli	a0,a0,0xc
    800006e0:	93dff0ef          	jal	8000001c <kfree>
    800006e4:	b7f1                	j	800006b0 <uvmunmap+0x70>
    800006e6:	74e2                	ld	s1,56(sp)
    800006e8:	7942                	ld	s2,48(sp)
    800006ea:	79a2                	ld	s3,40(sp)
    800006ec:	7a02                	ld	s4,32(sp)
    800006ee:	6ae2                	ld	s5,24(sp)
    800006f0:	6b42                	ld	s6,16(sp)
    800006f2:	6ba2                	ld	s7,8(sp)
  }
}
    800006f4:	60a6                	ld	ra,72(sp)
    800006f6:	6406                	ld	s0,64(sp)
    800006f8:	6161                	addi	sp,sp,80
    800006fa:	8082                	ret

00000000800006fc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800006fc:	1101                	addi	sp,sp,-32
    800006fe:	ec06                	sd	ra,24(sp)
    80000700:	e822                	sd	s0,16(sp)
    80000702:	e426                	sd	s1,8(sp)
    80000704:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000706:	9f9ff0ef          	jal	800000fe <kalloc>
    8000070a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000070c:	c509                	beqz	a0,80000716 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000070e:	6605                	lui	a2,0x1
    80000710:	4581                	li	a1,0
    80000712:	a3dff0ef          	jal	8000014e <memset>
  return pagetable;
}
    80000716:	8526                	mv	a0,s1
    80000718:	60e2                	ld	ra,24(sp)
    8000071a:	6442                	ld	s0,16(sp)
    8000071c:	64a2                	ld	s1,8(sp)
    8000071e:	6105                	addi	sp,sp,32
    80000720:	8082                	ret

0000000080000722 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000722:	7179                	addi	sp,sp,-48
    80000724:	f406                	sd	ra,40(sp)
    80000726:	f022                	sd	s0,32(sp)
    80000728:	ec26                	sd	s1,24(sp)
    8000072a:	e84a                	sd	s2,16(sp)
    8000072c:	e44e                	sd	s3,8(sp)
    8000072e:	e052                	sd	s4,0(sp)
    80000730:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000732:	6785                	lui	a5,0x1
    80000734:	04f67063          	bgeu	a2,a5,80000774 <uvmfirst+0x52>
    80000738:	8a2a                	mv	s4,a0
    8000073a:	89ae                	mv	s3,a1
    8000073c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000073e:	9c1ff0ef          	jal	800000fe <kalloc>
    80000742:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000744:	6605                	lui	a2,0x1
    80000746:	4581                	li	a1,0
    80000748:	a07ff0ef          	jal	8000014e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000074c:	4779                	li	a4,30
    8000074e:	86ca                	mv	a3,s2
    80000750:	6605                	lui	a2,0x1
    80000752:	4581                	li	a1,0
    80000754:	8552                	mv	a0,s4
    80000756:	d45ff0ef          	jal	8000049a <mappages>
  memmove(mem, src, sz);
    8000075a:	8626                	mv	a2,s1
    8000075c:	85ce                	mv	a1,s3
    8000075e:	854a                	mv	a0,s2
    80000760:	a4bff0ef          	jal	800001aa <memmove>
}
    80000764:	70a2                	ld	ra,40(sp)
    80000766:	7402                	ld	s0,32(sp)
    80000768:	64e2                	ld	s1,24(sp)
    8000076a:	6942                	ld	s2,16(sp)
    8000076c:	69a2                	ld	s3,8(sp)
    8000076e:	6a02                	ld	s4,0(sp)
    80000770:	6145                	addi	sp,sp,48
    80000772:	8082                	ret
    panic("uvmfirst: more than a page");
    80000774:	00007517          	auipc	a0,0x7
    80000778:	9a450513          	addi	a0,a0,-1628 # 80007118 <etext+0x118>
    8000077c:	517040ef          	jal	80005492 <panic>

0000000080000780 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000780:	1101                	addi	sp,sp,-32
    80000782:	ec06                	sd	ra,24(sp)
    80000784:	e822                	sd	s0,16(sp)
    80000786:	e426                	sd	s1,8(sp)
    80000788:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000078a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000078c:	00b67d63          	bgeu	a2,a1,800007a6 <uvmdealloc+0x26>
    80000790:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000792:	6785                	lui	a5,0x1
    80000794:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000796:	00f60733          	add	a4,a2,a5
    8000079a:	76fd                	lui	a3,0xfffff
    8000079c:	8f75                	and	a4,a4,a3
    8000079e:	97ae                	add	a5,a5,a1
    800007a0:	8ff5                	and	a5,a5,a3
    800007a2:	00f76863          	bltu	a4,a5,800007b2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007a6:	8526                	mv	a0,s1
    800007a8:	60e2                	ld	ra,24(sp)
    800007aa:	6442                	ld	s0,16(sp)
    800007ac:	64a2                	ld	s1,8(sp)
    800007ae:	6105                	addi	sp,sp,32
    800007b0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007b2:	8f99                	sub	a5,a5,a4
    800007b4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007b6:	4685                	li	a3,1
    800007b8:	0007861b          	sext.w	a2,a5
    800007bc:	85ba                	mv	a1,a4
    800007be:	e83ff0ef          	jal	80000640 <uvmunmap>
    800007c2:	b7d5                	j	800007a6 <uvmdealloc+0x26>

00000000800007c4 <uvmalloc>:
  if(newsz < oldsz)
    800007c4:	08b66f63          	bltu	a2,a1,80000862 <uvmalloc+0x9e>
{
    800007c8:	7139                	addi	sp,sp,-64
    800007ca:	fc06                	sd	ra,56(sp)
    800007cc:	f822                	sd	s0,48(sp)
    800007ce:	ec4e                	sd	s3,24(sp)
    800007d0:	e852                	sd	s4,16(sp)
    800007d2:	e456                	sd	s5,8(sp)
    800007d4:	0080                	addi	s0,sp,64
    800007d6:	8aaa                	mv	s5,a0
    800007d8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800007da:	6785                	lui	a5,0x1
    800007dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007de:	95be                	add	a1,a1,a5
    800007e0:	77fd                	lui	a5,0xfffff
    800007e2:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800007e6:	08c9f063          	bgeu	s3,a2,80000866 <uvmalloc+0xa2>
    800007ea:	f426                	sd	s1,40(sp)
    800007ec:	f04a                	sd	s2,32(sp)
    800007ee:	e05a                	sd	s6,0(sp)
    800007f0:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800007f2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800007f6:	909ff0ef          	jal	800000fe <kalloc>
    800007fa:	84aa                	mv	s1,a0
    if(mem == 0){
    800007fc:	c515                	beqz	a0,80000828 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800007fe:	6605                	lui	a2,0x1
    80000800:	4581                	li	a1,0
    80000802:	94dff0ef          	jal	8000014e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000806:	875a                	mv	a4,s6
    80000808:	86a6                	mv	a3,s1
    8000080a:	6605                	lui	a2,0x1
    8000080c:	85ca                	mv	a1,s2
    8000080e:	8556                	mv	a0,s5
    80000810:	c8bff0ef          	jal	8000049a <mappages>
    80000814:	e915                	bnez	a0,80000848 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000816:	6785                	lui	a5,0x1
    80000818:	993e                	add	s2,s2,a5
    8000081a:	fd496ee3          	bltu	s2,s4,800007f6 <uvmalloc+0x32>
  return newsz;
    8000081e:	8552                	mv	a0,s4
    80000820:	74a2                	ld	s1,40(sp)
    80000822:	7902                	ld	s2,32(sp)
    80000824:	6b02                	ld	s6,0(sp)
    80000826:	a811                	j	8000083a <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80000828:	864e                	mv	a2,s3
    8000082a:	85ca                	mv	a1,s2
    8000082c:	8556                	mv	a0,s5
    8000082e:	f53ff0ef          	jal	80000780 <uvmdealloc>
      return 0;
    80000832:	4501                	li	a0,0
    80000834:	74a2                	ld	s1,40(sp)
    80000836:	7902                	ld	s2,32(sp)
    80000838:	6b02                	ld	s6,0(sp)
}
    8000083a:	70e2                	ld	ra,56(sp)
    8000083c:	7442                	ld	s0,48(sp)
    8000083e:	69e2                	ld	s3,24(sp)
    80000840:	6a42                	ld	s4,16(sp)
    80000842:	6aa2                	ld	s5,8(sp)
    80000844:	6121                	addi	sp,sp,64
    80000846:	8082                	ret
      kfree(mem);
    80000848:	8526                	mv	a0,s1
    8000084a:	fd2ff0ef          	jal	8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000084e:	864e                	mv	a2,s3
    80000850:	85ca                	mv	a1,s2
    80000852:	8556                	mv	a0,s5
    80000854:	f2dff0ef          	jal	80000780 <uvmdealloc>
      return 0;
    80000858:	4501                	li	a0,0
    8000085a:	74a2                	ld	s1,40(sp)
    8000085c:	7902                	ld	s2,32(sp)
    8000085e:	6b02                	ld	s6,0(sp)
    80000860:	bfe9                	j	8000083a <uvmalloc+0x76>
    return oldsz;
    80000862:	852e                	mv	a0,a1
}
    80000864:	8082                	ret
  return newsz;
    80000866:	8532                	mv	a0,a2
    80000868:	bfc9                	j	8000083a <uvmalloc+0x76>

000000008000086a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000086a:	7179                	addi	sp,sp,-48
    8000086c:	f406                	sd	ra,40(sp)
    8000086e:	f022                	sd	s0,32(sp)
    80000870:	ec26                	sd	s1,24(sp)
    80000872:	e84a                	sd	s2,16(sp)
    80000874:	e44e                	sd	s3,8(sp)
    80000876:	e052                	sd	s4,0(sp)
    80000878:	1800                	addi	s0,sp,48
    8000087a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000087c:	84aa                	mv	s1,a0
    8000087e:	6905                	lui	s2,0x1
    80000880:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000882:	4985                	li	s3,1
    80000884:	a819                	j	8000089a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000886:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000888:	00c79513          	slli	a0,a5,0xc
    8000088c:	fdfff0ef          	jal	8000086a <freewalk>
      pagetable[i] = 0;
    80000890:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000894:	04a1                	addi	s1,s1,8
    80000896:	01248f63          	beq	s1,s2,800008b4 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000089a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000089c:	00f7f713          	andi	a4,a5,15
    800008a0:	ff3703e3          	beq	a4,s3,80000886 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800008a4:	8b85                	andi	a5,a5,1
    800008a6:	d7fd                	beqz	a5,80000894 <freewalk+0x2a>
      panic("freewalk: leaf");
    800008a8:	00007517          	auipc	a0,0x7
    800008ac:	89050513          	addi	a0,a0,-1904 # 80007138 <etext+0x138>
    800008b0:	3e3040ef          	jal	80005492 <panic>
    }
  }
  kfree((void*)pagetable);
    800008b4:	8552                	mv	a0,s4
    800008b6:	f66ff0ef          	jal	8000001c <kfree>
}
    800008ba:	70a2                	ld	ra,40(sp)
    800008bc:	7402                	ld	s0,32(sp)
    800008be:	64e2                	ld	s1,24(sp)
    800008c0:	6942                	ld	s2,16(sp)
    800008c2:	69a2                	ld	s3,8(sp)
    800008c4:	6a02                	ld	s4,0(sp)
    800008c6:	6145                	addi	sp,sp,48
    800008c8:	8082                	ret

00000000800008ca <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800008ca:	1101                	addi	sp,sp,-32
    800008cc:	ec06                	sd	ra,24(sp)
    800008ce:	e822                	sd	s0,16(sp)
    800008d0:	e426                	sd	s1,8(sp)
    800008d2:	1000                	addi	s0,sp,32
    800008d4:	84aa                	mv	s1,a0
  if(sz > 0)
    800008d6:	e989                	bnez	a1,800008e8 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800008d8:	8526                	mv	a0,s1
    800008da:	f91ff0ef          	jal	8000086a <freewalk>
}
    800008de:	60e2                	ld	ra,24(sp)
    800008e0:	6442                	ld	s0,16(sp)
    800008e2:	64a2                	ld	s1,8(sp)
    800008e4:	6105                	addi	sp,sp,32
    800008e6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800008e8:	6785                	lui	a5,0x1
    800008ea:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008ec:	95be                	add	a1,a1,a5
    800008ee:	4685                	li	a3,1
    800008f0:	00c5d613          	srli	a2,a1,0xc
    800008f4:	4581                	li	a1,0
    800008f6:	d4bff0ef          	jal	80000640 <uvmunmap>
    800008fa:	bff9                	j	800008d8 <uvmfree+0xe>

00000000800008fc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800008fc:	c65d                	beqz	a2,800009aa <uvmcopy+0xae>
{
    800008fe:	715d                	addi	sp,sp,-80
    80000900:	e486                	sd	ra,72(sp)
    80000902:	e0a2                	sd	s0,64(sp)
    80000904:	fc26                	sd	s1,56(sp)
    80000906:	f84a                	sd	s2,48(sp)
    80000908:	f44e                	sd	s3,40(sp)
    8000090a:	f052                	sd	s4,32(sp)
    8000090c:	ec56                	sd	s5,24(sp)
    8000090e:	e85a                	sd	s6,16(sp)
    80000910:	e45e                	sd	s7,8(sp)
    80000912:	0880                	addi	s0,sp,80
    80000914:	8b2a                	mv	s6,a0
    80000916:	8aae                	mv	s5,a1
    80000918:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000091a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000091c:	4601                	li	a2,0
    8000091e:	85ce                	mv	a1,s3
    80000920:	855a                	mv	a0,s6
    80000922:	aa1ff0ef          	jal	800003c2 <walk>
    80000926:	c121                	beqz	a0,80000966 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000928:	6118                	ld	a4,0(a0)
    8000092a:	00177793          	andi	a5,a4,1
    8000092e:	c3b1                	beqz	a5,80000972 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000930:	00a75593          	srli	a1,a4,0xa
    80000934:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000938:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000093c:	fc2ff0ef          	jal	800000fe <kalloc>
    80000940:	892a                	mv	s2,a0
    80000942:	c129                	beqz	a0,80000984 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000944:	6605                	lui	a2,0x1
    80000946:	85de                	mv	a1,s7
    80000948:	863ff0ef          	jal	800001aa <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000094c:	8726                	mv	a4,s1
    8000094e:	86ca                	mv	a3,s2
    80000950:	6605                	lui	a2,0x1
    80000952:	85ce                	mv	a1,s3
    80000954:	8556                	mv	a0,s5
    80000956:	b45ff0ef          	jal	8000049a <mappages>
    8000095a:	e115                	bnez	a0,8000097e <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000095c:	6785                	lui	a5,0x1
    8000095e:	99be                	add	s3,s3,a5
    80000960:	fb49eee3          	bltu	s3,s4,8000091c <uvmcopy+0x20>
    80000964:	a805                	j	80000994 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000966:	00006517          	auipc	a0,0x6
    8000096a:	7e250513          	addi	a0,a0,2018 # 80007148 <etext+0x148>
    8000096e:	325040ef          	jal	80005492 <panic>
      panic("uvmcopy: page not present");
    80000972:	00006517          	auipc	a0,0x6
    80000976:	7f650513          	addi	a0,a0,2038 # 80007168 <etext+0x168>
    8000097a:	319040ef          	jal	80005492 <panic>
      kfree(mem);
    8000097e:	854a                	mv	a0,s2
    80000980:	e9cff0ef          	jal	8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000984:	4685                	li	a3,1
    80000986:	00c9d613          	srli	a2,s3,0xc
    8000098a:	4581                	li	a1,0
    8000098c:	8556                	mv	a0,s5
    8000098e:	cb3ff0ef          	jal	80000640 <uvmunmap>
  return -1;
    80000992:	557d                	li	a0,-1
}
    80000994:	60a6                	ld	ra,72(sp)
    80000996:	6406                	ld	s0,64(sp)
    80000998:	74e2                	ld	s1,56(sp)
    8000099a:	7942                	ld	s2,48(sp)
    8000099c:	79a2                	ld	s3,40(sp)
    8000099e:	7a02                	ld	s4,32(sp)
    800009a0:	6ae2                	ld	s5,24(sp)
    800009a2:	6b42                	ld	s6,16(sp)
    800009a4:	6ba2                	ld	s7,8(sp)
    800009a6:	6161                	addi	sp,sp,80
    800009a8:	8082                	ret
  return 0;
    800009aa:	4501                	li	a0,0
}
    800009ac:	8082                	ret

00000000800009ae <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800009ae:	1141                	addi	sp,sp,-16
    800009b0:	e406                	sd	ra,8(sp)
    800009b2:	e022                	sd	s0,0(sp)
    800009b4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800009b6:	4601                	li	a2,0
    800009b8:	a0bff0ef          	jal	800003c2 <walk>
  if(pte == 0)
    800009bc:	c901                	beqz	a0,800009cc <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800009be:	611c                	ld	a5,0(a0)
    800009c0:	9bbd                	andi	a5,a5,-17
    800009c2:	e11c                	sd	a5,0(a0)
}
    800009c4:	60a2                	ld	ra,8(sp)
    800009c6:	6402                	ld	s0,0(sp)
    800009c8:	0141                	addi	sp,sp,16
    800009ca:	8082                	ret
    panic("uvmclear");
    800009cc:	00006517          	auipc	a0,0x6
    800009d0:	7bc50513          	addi	a0,a0,1980 # 80007188 <etext+0x188>
    800009d4:	2bf040ef          	jal	80005492 <panic>

00000000800009d8 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800009d8:	cad1                	beqz	a3,80000a6c <copyout+0x94>
{
    800009da:	711d                	addi	sp,sp,-96
    800009dc:	ec86                	sd	ra,88(sp)
    800009de:	e8a2                	sd	s0,80(sp)
    800009e0:	e4a6                	sd	s1,72(sp)
    800009e2:	fc4e                	sd	s3,56(sp)
    800009e4:	f456                	sd	s5,40(sp)
    800009e6:	f05a                	sd	s6,32(sp)
    800009e8:	ec5e                	sd	s7,24(sp)
    800009ea:	1080                	addi	s0,sp,96
    800009ec:	8baa                	mv	s7,a0
    800009ee:	8aae                	mv	s5,a1
    800009f0:	8b32                	mv	s6,a2
    800009f2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800009f4:	74fd                	lui	s1,0xfffff
    800009f6:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800009f8:	57fd                	li	a5,-1
    800009fa:	83e9                	srli	a5,a5,0x1a
    800009fc:	0697ea63          	bltu	a5,s1,80000a70 <copyout+0x98>
    80000a00:	e0ca                	sd	s2,64(sp)
    80000a02:	f852                	sd	s4,48(sp)
    80000a04:	e862                	sd	s8,16(sp)
    80000a06:	e466                	sd	s9,8(sp)
    80000a08:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000a0a:	4cd5                	li	s9,21
    80000a0c:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80000a0e:	8c3e                	mv	s8,a5
    80000a10:	a025                	j	80000a38 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    80000a12:	83a9                	srli	a5,a5,0xa
    80000a14:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a16:	409a8533          	sub	a0,s5,s1
    80000a1a:	0009061b          	sext.w	a2,s2
    80000a1e:	85da                	mv	a1,s6
    80000a20:	953e                	add	a0,a0,a5
    80000a22:	f88ff0ef          	jal	800001aa <memmove>

    len -= n;
    80000a26:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a2a:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80000a2c:	02098963          	beqz	s3,80000a5e <copyout+0x86>
    if(va0 >= MAXVA)
    80000a30:	054c6263          	bltu	s8,s4,80000a74 <copyout+0x9c>
    80000a34:	84d2                	mv	s1,s4
    80000a36:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80000a38:	4601                	li	a2,0
    80000a3a:	85a6                	mv	a1,s1
    80000a3c:	855e                	mv	a0,s7
    80000a3e:	985ff0ef          	jal	800003c2 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000a42:	c121                	beqz	a0,80000a82 <copyout+0xaa>
    80000a44:	611c                	ld	a5,0(a0)
    80000a46:	0157f713          	andi	a4,a5,21
    80000a4a:	05971b63          	bne	a4,s9,80000aa0 <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    80000a4e:	01a48a33          	add	s4,s1,s10
    80000a52:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80000a56:	fb29fee3          	bgeu	s3,s2,80000a12 <copyout+0x3a>
    80000a5a:	894e                	mv	s2,s3
    80000a5c:	bf5d                	j	80000a12 <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80000a5e:	4501                	li	a0,0
    80000a60:	6906                	ld	s2,64(sp)
    80000a62:	7a42                	ld	s4,48(sp)
    80000a64:	6c42                	ld	s8,16(sp)
    80000a66:	6ca2                	ld	s9,8(sp)
    80000a68:	6d02                	ld	s10,0(sp)
    80000a6a:	a015                	j	80000a8e <copyout+0xb6>
    80000a6c:	4501                	li	a0,0
}
    80000a6e:	8082                	ret
      return -1;
    80000a70:	557d                	li	a0,-1
    80000a72:	a831                	j	80000a8e <copyout+0xb6>
    80000a74:	557d                	li	a0,-1
    80000a76:	6906                	ld	s2,64(sp)
    80000a78:	7a42                	ld	s4,48(sp)
    80000a7a:	6c42                	ld	s8,16(sp)
    80000a7c:	6ca2                	ld	s9,8(sp)
    80000a7e:	6d02                	ld	s10,0(sp)
    80000a80:	a039                	j	80000a8e <copyout+0xb6>
      return -1;
    80000a82:	557d                	li	a0,-1
    80000a84:	6906                	ld	s2,64(sp)
    80000a86:	7a42                	ld	s4,48(sp)
    80000a88:	6c42                	ld	s8,16(sp)
    80000a8a:	6ca2                	ld	s9,8(sp)
    80000a8c:	6d02                	ld	s10,0(sp)
}
    80000a8e:	60e6                	ld	ra,88(sp)
    80000a90:	6446                	ld	s0,80(sp)
    80000a92:	64a6                	ld	s1,72(sp)
    80000a94:	79e2                	ld	s3,56(sp)
    80000a96:	7aa2                	ld	s5,40(sp)
    80000a98:	7b02                	ld	s6,32(sp)
    80000a9a:	6be2                	ld	s7,24(sp)
    80000a9c:	6125                	addi	sp,sp,96
    80000a9e:	8082                	ret
      return -1;
    80000aa0:	557d                	li	a0,-1
    80000aa2:	6906                	ld	s2,64(sp)
    80000aa4:	7a42                	ld	s4,48(sp)
    80000aa6:	6c42                	ld	s8,16(sp)
    80000aa8:	6ca2                	ld	s9,8(sp)
    80000aaa:	6d02                	ld	s10,0(sp)
    80000aac:	b7cd                	j	80000a8e <copyout+0xb6>

0000000080000aae <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000aae:	c6a5                	beqz	a3,80000b16 <copyin+0x68>
{
    80000ab0:	715d                	addi	sp,sp,-80
    80000ab2:	e486                	sd	ra,72(sp)
    80000ab4:	e0a2                	sd	s0,64(sp)
    80000ab6:	fc26                	sd	s1,56(sp)
    80000ab8:	f84a                	sd	s2,48(sp)
    80000aba:	f44e                	sd	s3,40(sp)
    80000abc:	f052                	sd	s4,32(sp)
    80000abe:	ec56                	sd	s5,24(sp)
    80000ac0:	e85a                	sd	s6,16(sp)
    80000ac2:	e45e                	sd	s7,8(sp)
    80000ac4:	e062                	sd	s8,0(sp)
    80000ac6:	0880                	addi	s0,sp,80
    80000ac8:	8b2a                	mv	s6,a0
    80000aca:	8a2e                	mv	s4,a1
    80000acc:	8c32                	mv	s8,a2
    80000ace:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000ad0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000ad2:	6a85                	lui	s5,0x1
    80000ad4:	a00d                	j	80000af6 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000ad6:	018505b3          	add	a1,a0,s8
    80000ada:	0004861b          	sext.w	a2,s1
    80000ade:	412585b3          	sub	a1,a1,s2
    80000ae2:	8552                	mv	a0,s4
    80000ae4:	ec6ff0ef          	jal	800001aa <memmove>

    len -= n;
    80000ae8:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000aec:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000aee:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000af2:	02098063          	beqz	s3,80000b12 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000af6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000afa:	85ca                	mv	a1,s2
    80000afc:	855a                	mv	a0,s6
    80000afe:	95fff0ef          	jal	8000045c <walkaddr>
    if(pa0 == 0)
    80000b02:	cd01                	beqz	a0,80000b1a <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000b04:	418904b3          	sub	s1,s2,s8
    80000b08:	94d6                	add	s1,s1,s5
    if(n > len)
    80000b0a:	fc99f6e3          	bgeu	s3,s1,80000ad6 <copyin+0x28>
    80000b0e:	84ce                	mv	s1,s3
    80000b10:	b7d9                	j	80000ad6 <copyin+0x28>
  }
  return 0;
    80000b12:	4501                	li	a0,0
    80000b14:	a021                	j	80000b1c <copyin+0x6e>
    80000b16:	4501                	li	a0,0
}
    80000b18:	8082                	ret
      return -1;
    80000b1a:	557d                	li	a0,-1
}
    80000b1c:	60a6                	ld	ra,72(sp)
    80000b1e:	6406                	ld	s0,64(sp)
    80000b20:	74e2                	ld	s1,56(sp)
    80000b22:	7942                	ld	s2,48(sp)
    80000b24:	79a2                	ld	s3,40(sp)
    80000b26:	7a02                	ld	s4,32(sp)
    80000b28:	6ae2                	ld	s5,24(sp)
    80000b2a:	6b42                	ld	s6,16(sp)
    80000b2c:	6ba2                	ld	s7,8(sp)
    80000b2e:	6c02                	ld	s8,0(sp)
    80000b30:	6161                	addi	sp,sp,80
    80000b32:	8082                	ret

0000000080000b34 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000b34:	c6dd                	beqz	a3,80000be2 <copyinstr+0xae>
{
    80000b36:	715d                	addi	sp,sp,-80
    80000b38:	e486                	sd	ra,72(sp)
    80000b3a:	e0a2                	sd	s0,64(sp)
    80000b3c:	fc26                	sd	s1,56(sp)
    80000b3e:	f84a                	sd	s2,48(sp)
    80000b40:	f44e                	sd	s3,40(sp)
    80000b42:	f052                	sd	s4,32(sp)
    80000b44:	ec56                	sd	s5,24(sp)
    80000b46:	e85a                	sd	s6,16(sp)
    80000b48:	e45e                	sd	s7,8(sp)
    80000b4a:	0880                	addi	s0,sp,80
    80000b4c:	8a2a                	mv	s4,a0
    80000b4e:	8b2e                	mv	s6,a1
    80000b50:	8bb2                	mv	s7,a2
    80000b52:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000b54:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b56:	6985                	lui	s3,0x1
    80000b58:	a825                	j	80000b90 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000b5a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000b5e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000b60:	37fd                	addiw	a5,a5,-1
    80000b62:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000b66:	60a6                	ld	ra,72(sp)
    80000b68:	6406                	ld	s0,64(sp)
    80000b6a:	74e2                	ld	s1,56(sp)
    80000b6c:	7942                	ld	s2,48(sp)
    80000b6e:	79a2                	ld	s3,40(sp)
    80000b70:	7a02                	ld	s4,32(sp)
    80000b72:	6ae2                	ld	s5,24(sp)
    80000b74:	6b42                	ld	s6,16(sp)
    80000b76:	6ba2                	ld	s7,8(sp)
    80000b78:	6161                	addi	sp,sp,80
    80000b7a:	8082                	ret
    80000b7c:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80000b80:	9742                	add	a4,a4,a6
      --max;
    80000b82:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000b86:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000b8a:	04e58463          	beq	a1,a4,80000bd2 <copyinstr+0x9e>
{
    80000b8e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000b90:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000b94:	85a6                	mv	a1,s1
    80000b96:	8552                	mv	a0,s4
    80000b98:	8c5ff0ef          	jal	8000045c <walkaddr>
    if(pa0 == 0)
    80000b9c:	cd0d                	beqz	a0,80000bd6 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000b9e:	417486b3          	sub	a3,s1,s7
    80000ba2:	96ce                	add	a3,a3,s3
    if(n > max)
    80000ba4:	00d97363          	bgeu	s2,a3,80000baa <copyinstr+0x76>
    80000ba8:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80000baa:	955e                	add	a0,a0,s7
    80000bac:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80000bae:	c695                	beqz	a3,80000bda <copyinstr+0xa6>
    80000bb0:	87da                	mv	a5,s6
    80000bb2:	885a                	mv	a6,s6
      if(*p == '\0'){
    80000bb4:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80000bb8:	96da                	add	a3,a3,s6
    80000bba:	85be                	mv	a1,a5
      if(*p == '\0'){
    80000bbc:	00f60733          	add	a4,a2,a5
    80000bc0:	00074703          	lbu	a4,0(a4)
    80000bc4:	db59                	beqz	a4,80000b5a <copyinstr+0x26>
        *dst = *p;
    80000bc6:	00e78023          	sb	a4,0(a5)
      dst++;
    80000bca:	0785                	addi	a5,a5,1
    while(n > 0){
    80000bcc:	fed797e3          	bne	a5,a3,80000bba <copyinstr+0x86>
    80000bd0:	b775                	j	80000b7c <copyinstr+0x48>
    80000bd2:	4781                	li	a5,0
    80000bd4:	b771                	j	80000b60 <copyinstr+0x2c>
      return -1;
    80000bd6:	557d                	li	a0,-1
    80000bd8:	b779                	j	80000b66 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80000bda:	6b85                	lui	s7,0x1
    80000bdc:	9ba6                	add	s7,s7,s1
    80000bde:	87da                	mv	a5,s6
    80000be0:	b77d                	j	80000b8e <copyinstr+0x5a>
  int got_null = 0;
    80000be2:	4781                	li	a5,0
  if(got_null){
    80000be4:	37fd                	addiw	a5,a5,-1
    80000be6:	0007851b          	sext.w	a0,a5
}
    80000bea:	8082                	ret

0000000080000bec <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000bec:	7139                	addi	sp,sp,-64
    80000bee:	fc06                	sd	ra,56(sp)
    80000bf0:	f822                	sd	s0,48(sp)
    80000bf2:	f426                	sd	s1,40(sp)
    80000bf4:	f04a                	sd	s2,32(sp)
    80000bf6:	ec4e                	sd	s3,24(sp)
    80000bf8:	e852                	sd	s4,16(sp)
    80000bfa:	e456                	sd	s5,8(sp)
    80000bfc:	e05a                	sd	s6,0(sp)
    80000bfe:	0080                	addi	s0,sp,64
    80000c00:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c02:	0000a497          	auipc	s1,0xa
    80000c06:	b1e48493          	addi	s1,s1,-1250 # 8000a720 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c0a:	8b26                	mv	s6,s1
    80000c0c:	ff4df937          	lui	s2,0xff4df
    80000c10:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb1bd>
    80000c14:	0936                	slli	s2,s2,0xd
    80000c16:	6f590913          	addi	s2,s2,1781
    80000c1a:	0936                	slli	s2,s2,0xd
    80000c1c:	bd390913          	addi	s2,s2,-1069
    80000c20:	0932                	slli	s2,s2,0xc
    80000c22:	7a790913          	addi	s2,s2,1959
    80000c26:	040009b7          	lui	s3,0x4000
    80000c2a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c2c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c2e:	0000fa97          	auipc	s5,0xf
    80000c32:	6f2a8a93          	addi	s5,s5,1778 # 80010320 <tickslock>
    char *pa = kalloc();
    80000c36:	cc8ff0ef          	jal	800000fe <kalloc>
    80000c3a:	862a                	mv	a2,a0
    if(pa == 0)
    80000c3c:	cd15                	beqz	a0,80000c78 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c3e:	416485b3          	sub	a1,s1,s6
    80000c42:	8591                	srai	a1,a1,0x4
    80000c44:	032585b3          	mul	a1,a1,s2
    80000c48:	2585                	addiw	a1,a1,1
    80000c4a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c4e:	4719                	li	a4,6
    80000c50:	6685                	lui	a3,0x1
    80000c52:	40b985b3          	sub	a1,s3,a1
    80000c56:	8552                	mv	a0,s4
    80000c58:	8f3ff0ef          	jal	8000054a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c5c:	17048493          	addi	s1,s1,368
    80000c60:	fd549be3          	bne	s1,s5,80000c36 <proc_mapstacks+0x4a>
  }
}
    80000c64:	70e2                	ld	ra,56(sp)
    80000c66:	7442                	ld	s0,48(sp)
    80000c68:	74a2                	ld	s1,40(sp)
    80000c6a:	7902                	ld	s2,32(sp)
    80000c6c:	69e2                	ld	s3,24(sp)
    80000c6e:	6a42                	ld	s4,16(sp)
    80000c70:	6aa2                	ld	s5,8(sp)
    80000c72:	6b02                	ld	s6,0(sp)
    80000c74:	6121                	addi	sp,sp,64
    80000c76:	8082                	ret
      panic("kalloc");
    80000c78:	00006517          	auipc	a0,0x6
    80000c7c:	52050513          	addi	a0,a0,1312 # 80007198 <etext+0x198>
    80000c80:	013040ef          	jal	80005492 <panic>

0000000080000c84 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000c84:	7139                	addi	sp,sp,-64
    80000c86:	fc06                	sd	ra,56(sp)
    80000c88:	f822                	sd	s0,48(sp)
    80000c8a:	f426                	sd	s1,40(sp)
    80000c8c:	f04a                	sd	s2,32(sp)
    80000c8e:	ec4e                	sd	s3,24(sp)
    80000c90:	e852                	sd	s4,16(sp)
    80000c92:	e456                	sd	s5,8(sp)
    80000c94:	e05a                	sd	s6,0(sp)
    80000c96:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000c98:	00006597          	auipc	a1,0x6
    80000c9c:	50858593          	addi	a1,a1,1288 # 800071a0 <etext+0x1a0>
    80000ca0:	00009517          	auipc	a0,0x9
    80000ca4:	65050513          	addi	a0,a0,1616 # 8000a2f0 <pid_lock>
    80000ca8:	299040ef          	jal	80005740 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cac:	00006597          	auipc	a1,0x6
    80000cb0:	4fc58593          	addi	a1,a1,1276 # 800071a8 <etext+0x1a8>
    80000cb4:	00009517          	auipc	a0,0x9
    80000cb8:	65450513          	addi	a0,a0,1620 # 8000a308 <wait_lock>
    80000cbc:	285040ef          	jal	80005740 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cc0:	0000a497          	auipc	s1,0xa
    80000cc4:	a6048493          	addi	s1,s1,-1440 # 8000a720 <proc>
      initlock(&p->lock, "proc");
    80000cc8:	00006b17          	auipc	s6,0x6
    80000ccc:	4f0b0b13          	addi	s6,s6,1264 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cd0:	8aa6                	mv	s5,s1
    80000cd2:	ff4df937          	lui	s2,0xff4df
    80000cd6:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb1bd>
    80000cda:	0936                	slli	s2,s2,0xd
    80000cdc:	6f590913          	addi	s2,s2,1781
    80000ce0:	0936                	slli	s2,s2,0xd
    80000ce2:	bd390913          	addi	s2,s2,-1069
    80000ce6:	0932                	slli	s2,s2,0xc
    80000ce8:	7a790913          	addi	s2,s2,1959
    80000cec:	040009b7          	lui	s3,0x4000
    80000cf0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000cf2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf4:	0000fa17          	auipc	s4,0xf
    80000cf8:	62ca0a13          	addi	s4,s4,1580 # 80010320 <tickslock>
      initlock(&p->lock, "proc");
    80000cfc:	85da                	mv	a1,s6
    80000cfe:	8526                	mv	a0,s1
    80000d00:	241040ef          	jal	80005740 <initlock>
      p->state = UNUSED;
    80000d04:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d08:	415487b3          	sub	a5,s1,s5
    80000d0c:	8791                	srai	a5,a5,0x4
    80000d0e:	032787b3          	mul	a5,a5,s2
    80000d12:	2785                	addiw	a5,a5,1
    80000d14:	00d7979b          	slliw	a5,a5,0xd
    80000d18:	40f987b3          	sub	a5,s3,a5
    80000d1c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d1e:	17048493          	addi	s1,s1,368
    80000d22:	fd449de3          	bne	s1,s4,80000cfc <procinit+0x78>
  }
}
    80000d26:	70e2                	ld	ra,56(sp)
    80000d28:	7442                	ld	s0,48(sp)
    80000d2a:	74a2                	ld	s1,40(sp)
    80000d2c:	7902                	ld	s2,32(sp)
    80000d2e:	69e2                	ld	s3,24(sp)
    80000d30:	6a42                	ld	s4,16(sp)
    80000d32:	6aa2                	ld	s5,8(sp)
    80000d34:	6b02                	ld	s6,0(sp)
    80000d36:	6121                	addi	sp,sp,64
    80000d38:	8082                	ret

0000000080000d3a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e422                	sd	s0,8(sp)
    80000d3e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d40:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d42:	2501                	sext.w	a0,a0
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret

0000000080000d4a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d4a:	1141                	addi	sp,sp,-16
    80000d4c:	e422                	sd	s0,8(sp)
    80000d4e:	0800                	addi	s0,sp,16
    80000d50:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d52:	2781                	sext.w	a5,a5
    80000d54:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d56:	00009517          	auipc	a0,0x9
    80000d5a:	5ca50513          	addi	a0,a0,1482 # 8000a320 <cpus>
    80000d5e:	953e                	add	a0,a0,a5
    80000d60:	6422                	ld	s0,8(sp)
    80000d62:	0141                	addi	sp,sp,16
    80000d64:	8082                	ret

0000000080000d66 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d66:	1101                	addi	sp,sp,-32
    80000d68:	ec06                	sd	ra,24(sp)
    80000d6a:	e822                	sd	s0,16(sp)
    80000d6c:	e426                	sd	s1,8(sp)
    80000d6e:	1000                	addi	s0,sp,32
  push_off();
    80000d70:	211040ef          	jal	80005780 <push_off>
    80000d74:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d76:	2781                	sext.w	a5,a5
    80000d78:	079e                	slli	a5,a5,0x7
    80000d7a:	00009717          	auipc	a4,0x9
    80000d7e:	57670713          	addi	a4,a4,1398 # 8000a2f0 <pid_lock>
    80000d82:	97ba                	add	a5,a5,a4
    80000d84:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d86:	27f040ef          	jal	80005804 <pop_off>
  return p;
}
    80000d8a:	8526                	mv	a0,s1
    80000d8c:	60e2                	ld	ra,24(sp)
    80000d8e:	6442                	ld	s0,16(sp)
    80000d90:	64a2                	ld	s1,8(sp)
    80000d92:	6105                	addi	sp,sp,32
    80000d94:	8082                	ret

0000000080000d96 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e406                	sd	ra,8(sp)
    80000d9a:	e022                	sd	s0,0(sp)
    80000d9c:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000d9e:	fc9ff0ef          	jal	80000d66 <myproc>
    80000da2:	2b7040ef          	jal	80005858 <release>

  if (first) {
    80000da6:	00009797          	auipc	a5,0x9
    80000daa:	48a7a783          	lw	a5,1162(a5) # 8000a230 <first.1>
    80000dae:	e799                	bnez	a5,80000dbc <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000db0:	2c7000ef          	jal	80001876 <usertrapret>
}
    80000db4:	60a2                	ld	ra,8(sp)
    80000db6:	6402                	ld	s0,0(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
    fsinit(ROOTDEV);
    80000dbc:	4505                	li	a0,1
    80000dbe:	6e8010ef          	jal	800024a6 <fsinit>
    first = 0;
    80000dc2:	00009797          	auipc	a5,0x9
    80000dc6:	4607a723          	sw	zero,1134(a5) # 8000a230 <first.1>
    __sync_synchronize();
    80000dca:	0330000f          	fence	rw,rw
    80000dce:	b7cd                	j	80000db0 <forkret+0x1a>

0000000080000dd0 <allocpid>:
{
    80000dd0:	1101                	addi	sp,sp,-32
    80000dd2:	ec06                	sd	ra,24(sp)
    80000dd4:	e822                	sd	s0,16(sp)
    80000dd6:	e426                	sd	s1,8(sp)
    80000dd8:	e04a                	sd	s2,0(sp)
    80000dda:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000ddc:	00009917          	auipc	s2,0x9
    80000de0:	51490913          	addi	s2,s2,1300 # 8000a2f0 <pid_lock>
    80000de4:	854a                	mv	a0,s2
    80000de6:	1db040ef          	jal	800057c0 <acquire>
  pid = nextpid;
    80000dea:	00009797          	auipc	a5,0x9
    80000dee:	44a78793          	addi	a5,a5,1098 # 8000a234 <nextpid>
    80000df2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000df4:	0014871b          	addiw	a4,s1,1
    80000df8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000dfa:	854a                	mv	a0,s2
    80000dfc:	25d040ef          	jal	80005858 <release>
}
    80000e00:	8526                	mv	a0,s1
    80000e02:	60e2                	ld	ra,24(sp)
    80000e04:	6442                	ld	s0,16(sp)
    80000e06:	64a2                	ld	s1,8(sp)
    80000e08:	6902                	ld	s2,0(sp)
    80000e0a:	6105                	addi	sp,sp,32
    80000e0c:	8082                	ret

0000000080000e0e <proc_pagetable>:
{
    80000e0e:	1101                	addi	sp,sp,-32
    80000e10:	ec06                	sd	ra,24(sp)
    80000e12:	e822                	sd	s0,16(sp)
    80000e14:	e426                	sd	s1,8(sp)
    80000e16:	e04a                	sd	s2,0(sp)
    80000e18:	1000                	addi	s0,sp,32
    80000e1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000e1c:	8e1ff0ef          	jal	800006fc <uvmcreate>
    80000e20:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000e22:	cd05                	beqz	a0,80000e5a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000e24:	4729                	li	a4,10
    80000e26:	00005697          	auipc	a3,0x5
    80000e2a:	1da68693          	addi	a3,a3,474 # 80006000 <_trampoline>
    80000e2e:	6605                	lui	a2,0x1
    80000e30:	040005b7          	lui	a1,0x4000
    80000e34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000e36:	05b2                	slli	a1,a1,0xc
    80000e38:	e62ff0ef          	jal	8000049a <mappages>
    80000e3c:	02054663          	bltz	a0,80000e68 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000e40:	4719                	li	a4,6
    80000e42:	05893683          	ld	a3,88(s2)
    80000e46:	6605                	lui	a2,0x1
    80000e48:	020005b7          	lui	a1,0x2000
    80000e4c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000e4e:	05b6                	slli	a1,a1,0xd
    80000e50:	8526                	mv	a0,s1
    80000e52:	e48ff0ef          	jal	8000049a <mappages>
    80000e56:	00054f63          	bltz	a0,80000e74 <proc_pagetable+0x66>
}
    80000e5a:	8526                	mv	a0,s1
    80000e5c:	60e2                	ld	ra,24(sp)
    80000e5e:	6442                	ld	s0,16(sp)
    80000e60:	64a2                	ld	s1,8(sp)
    80000e62:	6902                	ld	s2,0(sp)
    80000e64:	6105                	addi	sp,sp,32
    80000e66:	8082                	ret
    uvmfree(pagetable, 0);
    80000e68:	4581                	li	a1,0
    80000e6a:	8526                	mv	a0,s1
    80000e6c:	a5fff0ef          	jal	800008ca <uvmfree>
    return 0;
    80000e70:	4481                	li	s1,0
    80000e72:	b7e5                	j	80000e5a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000e74:	4681                	li	a3,0
    80000e76:	4605                	li	a2,1
    80000e78:	040005b7          	lui	a1,0x4000
    80000e7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000e7e:	05b2                	slli	a1,a1,0xc
    80000e80:	8526                	mv	a0,s1
    80000e82:	fbeff0ef          	jal	80000640 <uvmunmap>
    uvmfree(pagetable, 0);
    80000e86:	4581                	li	a1,0
    80000e88:	8526                	mv	a0,s1
    80000e8a:	a41ff0ef          	jal	800008ca <uvmfree>
    return 0;
    80000e8e:	4481                	li	s1,0
    80000e90:	b7e9                	j	80000e5a <proc_pagetable+0x4c>

0000000080000e92 <proc_freepagetable>:
{
    80000e92:	1101                	addi	sp,sp,-32
    80000e94:	ec06                	sd	ra,24(sp)
    80000e96:	e822                	sd	s0,16(sp)
    80000e98:	e426                	sd	s1,8(sp)
    80000e9a:	e04a                	sd	s2,0(sp)
    80000e9c:	1000                	addi	s0,sp,32
    80000e9e:	84aa                	mv	s1,a0
    80000ea0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ea2:	4681                	li	a3,0
    80000ea4:	4605                	li	a2,1
    80000ea6:	040005b7          	lui	a1,0x4000
    80000eaa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000eac:	05b2                	slli	a1,a1,0xc
    80000eae:	f92ff0ef          	jal	80000640 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000eb2:	4681                	li	a3,0
    80000eb4:	4605                	li	a2,1
    80000eb6:	020005b7          	lui	a1,0x2000
    80000eba:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000ebc:	05b6                	slli	a1,a1,0xd
    80000ebe:	8526                	mv	a0,s1
    80000ec0:	f80ff0ef          	jal	80000640 <uvmunmap>
  uvmfree(pagetable, sz);
    80000ec4:	85ca                	mv	a1,s2
    80000ec6:	8526                	mv	a0,s1
    80000ec8:	a03ff0ef          	jal	800008ca <uvmfree>
}
    80000ecc:	60e2                	ld	ra,24(sp)
    80000ece:	6442                	ld	s0,16(sp)
    80000ed0:	64a2                	ld	s1,8(sp)
    80000ed2:	6902                	ld	s2,0(sp)
    80000ed4:	6105                	addi	sp,sp,32
    80000ed6:	8082                	ret

0000000080000ed8 <freeproc>:
{
    80000ed8:	1101                	addi	sp,sp,-32
    80000eda:	ec06                	sd	ra,24(sp)
    80000edc:	e822                	sd	s0,16(sp)
    80000ede:	e426                	sd	s1,8(sp)
    80000ee0:	1000                	addi	s0,sp,32
    80000ee2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000ee4:	6d28                	ld	a0,88(a0)
    80000ee6:	c119                	beqz	a0,80000eec <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000ee8:	934ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000eec:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000ef0:	68a8                	ld	a0,80(s1)
    80000ef2:	c501                	beqz	a0,80000efa <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000ef4:	64ac                	ld	a1,72(s1)
    80000ef6:	f9dff0ef          	jal	80000e92 <proc_freepagetable>
  p->pagetable = 0;
    80000efa:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000efe:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f02:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f06:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f0a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f0e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000f12:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000f16:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000f1a:	0004ac23          	sw	zero,24(s1)
}
    80000f1e:	60e2                	ld	ra,24(sp)
    80000f20:	6442                	ld	s0,16(sp)
    80000f22:	64a2                	ld	s1,8(sp)
    80000f24:	6105                	addi	sp,sp,32
    80000f26:	8082                	ret

0000000080000f28 <allocproc>:
{
    80000f28:	1101                	addi	sp,sp,-32
    80000f2a:	ec06                	sd	ra,24(sp)
    80000f2c:	e822                	sd	s0,16(sp)
    80000f2e:	e426                	sd	s1,8(sp)
    80000f30:	e04a                	sd	s2,0(sp)
    80000f32:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f34:	00009497          	auipc	s1,0x9
    80000f38:	7ec48493          	addi	s1,s1,2028 # 8000a720 <proc>
    80000f3c:	0000f917          	auipc	s2,0xf
    80000f40:	3e490913          	addi	s2,s2,996 # 80010320 <tickslock>
    acquire(&p->lock);
    80000f44:	8526                	mv	a0,s1
    80000f46:	07b040ef          	jal	800057c0 <acquire>
    if(p->state == UNUSED) {
    80000f4a:	4c9c                	lw	a5,24(s1)
    80000f4c:	cb91                	beqz	a5,80000f60 <allocproc+0x38>
      release(&p->lock);
    80000f4e:	8526                	mv	a0,s1
    80000f50:	109040ef          	jal	80005858 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f54:	17048493          	addi	s1,s1,368
    80000f58:	ff2496e3          	bne	s1,s2,80000f44 <allocproc+0x1c>
  return 0;
    80000f5c:	4481                	li	s1,0
    80000f5e:	a089                	j	80000fa0 <allocproc+0x78>
  p->pid = allocpid();
    80000f60:	e71ff0ef          	jal	80000dd0 <allocpid>
    80000f64:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000f66:	4785                	li	a5,1
    80000f68:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000f6a:	994ff0ef          	jal	800000fe <kalloc>
    80000f6e:	892a                	mv	s2,a0
    80000f70:	eca8                	sd	a0,88(s1)
    80000f72:	cd15                	beqz	a0,80000fae <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000f74:	8526                	mv	a0,s1
    80000f76:	e99ff0ef          	jal	80000e0e <proc_pagetable>
    80000f7a:	892a                	mv	s2,a0
    80000f7c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000f7e:	c121                	beqz	a0,80000fbe <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000f80:	07000613          	li	a2,112
    80000f84:	4581                	li	a1,0
    80000f86:	06048513          	addi	a0,s1,96
    80000f8a:	9c4ff0ef          	jal	8000014e <memset>
  p->context.ra = (uint64)forkret;
    80000f8e:	00000797          	auipc	a5,0x0
    80000f92:	e0878793          	addi	a5,a5,-504 # 80000d96 <forkret>
    80000f96:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000f98:	60bc                	ld	a5,64(s1)
    80000f9a:	6705                	lui	a4,0x1
    80000f9c:	97ba                	add	a5,a5,a4
    80000f9e:	f4bc                	sd	a5,104(s1)
}
    80000fa0:	8526                	mv	a0,s1
    80000fa2:	60e2                	ld	ra,24(sp)
    80000fa4:	6442                	ld	s0,16(sp)
    80000fa6:	64a2                	ld	s1,8(sp)
    80000fa8:	6902                	ld	s2,0(sp)
    80000faa:	6105                	addi	sp,sp,32
    80000fac:	8082                	ret
    freeproc(p);
    80000fae:	8526                	mv	a0,s1
    80000fb0:	f29ff0ef          	jal	80000ed8 <freeproc>
    release(&p->lock);
    80000fb4:	8526                	mv	a0,s1
    80000fb6:	0a3040ef          	jal	80005858 <release>
    return 0;
    80000fba:	84ca                	mv	s1,s2
    80000fbc:	b7d5                	j	80000fa0 <allocproc+0x78>
    freeproc(p);
    80000fbe:	8526                	mv	a0,s1
    80000fc0:	f19ff0ef          	jal	80000ed8 <freeproc>
    release(&p->lock);
    80000fc4:	8526                	mv	a0,s1
    80000fc6:	093040ef          	jal	80005858 <release>
    return 0;
    80000fca:	84ca                	mv	s1,s2
    80000fcc:	bfd1                	j	80000fa0 <allocproc+0x78>

0000000080000fce <userinit>:
{
    80000fce:	1101                	addi	sp,sp,-32
    80000fd0:	ec06                	sd	ra,24(sp)
    80000fd2:	e822                	sd	s0,16(sp)
    80000fd4:	e426                	sd	s1,8(sp)
    80000fd6:	1000                	addi	s0,sp,32
  p = allocproc();
    80000fd8:	f51ff0ef          	jal	80000f28 <allocproc>
    80000fdc:	84aa                	mv	s1,a0
  initproc = p;
    80000fde:	00009797          	auipc	a5,0x9
    80000fe2:	2ca7b923          	sd	a0,722(a5) # 8000a2b0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80000fe6:	03400613          	li	a2,52
    80000fea:	00009597          	auipc	a1,0x9
    80000fee:	25658593          	addi	a1,a1,598 # 8000a240 <initcode>
    80000ff2:	6928                	ld	a0,80(a0)
    80000ff4:	f2eff0ef          	jal	80000722 <uvmfirst>
  p->sz = PGSIZE;
    80000ff8:	6785                	lui	a5,0x1
    80000ffa:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80000ffc:	6cb8                	ld	a4,88(s1)
    80000ffe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001002:	6cb8                	ld	a4,88(s1)
    80001004:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001006:	4641                	li	a2,16
    80001008:	00006597          	auipc	a1,0x6
    8000100c:	1b858593          	addi	a1,a1,440 # 800071c0 <etext+0x1c0>
    80001010:	15848513          	addi	a0,s1,344
    80001014:	a78ff0ef          	jal	8000028c <safestrcpy>
  p->cwd = namei("/");
    80001018:	00006517          	auipc	a0,0x6
    8000101c:	1b850513          	addi	a0,a0,440 # 800071d0 <etext+0x1d0>
    80001020:	595010ef          	jal	80002db4 <namei>
    80001024:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001028:	478d                	li	a5,3
    8000102a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000102c:	8526                	mv	a0,s1
    8000102e:	02b040ef          	jal	80005858 <release>
}
    80001032:	60e2                	ld	ra,24(sp)
    80001034:	6442                	ld	s0,16(sp)
    80001036:	64a2                	ld	s1,8(sp)
    80001038:	6105                	addi	sp,sp,32
    8000103a:	8082                	ret

000000008000103c <growproc>:
{
    8000103c:	1101                	addi	sp,sp,-32
    8000103e:	ec06                	sd	ra,24(sp)
    80001040:	e822                	sd	s0,16(sp)
    80001042:	e426                	sd	s1,8(sp)
    80001044:	e04a                	sd	s2,0(sp)
    80001046:	1000                	addi	s0,sp,32
    80001048:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000104a:	d1dff0ef          	jal	80000d66 <myproc>
    8000104e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001050:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001052:	01204c63          	bgtz	s2,8000106a <growproc+0x2e>
  } else if(n < 0){
    80001056:	02094463          	bltz	s2,8000107e <growproc+0x42>
  p->sz = sz;
    8000105a:	e4ac                	sd	a1,72(s1)
  return 0;
    8000105c:	4501                	li	a0,0
}
    8000105e:	60e2                	ld	ra,24(sp)
    80001060:	6442                	ld	s0,16(sp)
    80001062:	64a2                	ld	s1,8(sp)
    80001064:	6902                	ld	s2,0(sp)
    80001066:	6105                	addi	sp,sp,32
    80001068:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000106a:	4691                	li	a3,4
    8000106c:	00b90633          	add	a2,s2,a1
    80001070:	6928                	ld	a0,80(a0)
    80001072:	f52ff0ef          	jal	800007c4 <uvmalloc>
    80001076:	85aa                	mv	a1,a0
    80001078:	f16d                	bnez	a0,8000105a <growproc+0x1e>
      return -1;
    8000107a:	557d                	li	a0,-1
    8000107c:	b7cd                	j	8000105e <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000107e:	00b90633          	add	a2,s2,a1
    80001082:	6928                	ld	a0,80(a0)
    80001084:	efcff0ef          	jal	80000780 <uvmdealloc>
    80001088:	85aa                	mv	a1,a0
    8000108a:	bfc1                	j	8000105a <growproc+0x1e>

000000008000108c <fork>:
{
    8000108c:	7139                	addi	sp,sp,-64
    8000108e:	fc06                	sd	ra,56(sp)
    80001090:	f822                	sd	s0,48(sp)
    80001092:	f04a                	sd	s2,32(sp)
    80001094:	e456                	sd	s5,8(sp)
    80001096:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001098:	ccfff0ef          	jal	80000d66 <myproc>
    8000109c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000109e:	e8bff0ef          	jal	80000f28 <allocproc>
    800010a2:	0e050e63          	beqz	a0,8000119e <fork+0x112>
    800010a6:	ec4e                	sd	s3,24(sp)
    800010a8:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010aa:	048ab603          	ld	a2,72(s5)
    800010ae:	692c                	ld	a1,80(a0)
    800010b0:	050ab503          	ld	a0,80(s5)
    800010b4:	849ff0ef          	jal	800008fc <uvmcopy>
    800010b8:	04054e63          	bltz	a0,80001114 <fork+0x88>
    800010bc:	f426                	sd	s1,40(sp)
    800010be:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800010c0:	048ab783          	ld	a5,72(s5)
    800010c4:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800010c8:	058ab683          	ld	a3,88(s5)
    800010cc:	87b6                	mv	a5,a3
    800010ce:	0589b703          	ld	a4,88(s3)
    800010d2:	12068693          	addi	a3,a3,288
    800010d6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800010da:	6788                	ld	a0,8(a5)
    800010dc:	6b8c                	ld	a1,16(a5)
    800010de:	6f90                	ld	a2,24(a5)
    800010e0:	01073023          	sd	a6,0(a4)
    800010e4:	e708                	sd	a0,8(a4)
    800010e6:	eb0c                	sd	a1,16(a4)
    800010e8:	ef10                	sd	a2,24(a4)
    800010ea:	02078793          	addi	a5,a5,32
    800010ee:	02070713          	addi	a4,a4,32
    800010f2:	fed792e3          	bne	a5,a3,800010d6 <fork+0x4a>
  np->trace_mask = p->trace_mask;
    800010f6:	168aa783          	lw	a5,360(s5)
    800010fa:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    800010fe:	0589b783          	ld	a5,88(s3)
    80001102:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001106:	0d0a8493          	addi	s1,s5,208
    8000110a:	0d098913          	addi	s2,s3,208
    8000110e:	150a8a13          	addi	s4,s5,336
    80001112:	a831                	j	8000112e <fork+0xa2>
    freeproc(np);
    80001114:	854e                	mv	a0,s3
    80001116:	dc3ff0ef          	jal	80000ed8 <freeproc>
    release(&np->lock);
    8000111a:	854e                	mv	a0,s3
    8000111c:	73c040ef          	jal	80005858 <release>
    return -1;
    80001120:	597d                	li	s2,-1
    80001122:	69e2                	ld	s3,24(sp)
    80001124:	a0b5                	j	80001190 <fork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001126:	04a1                	addi	s1,s1,8
    80001128:	0921                	addi	s2,s2,8
    8000112a:	01448963          	beq	s1,s4,8000113c <fork+0xb0>
    if(p->ofile[i])
    8000112e:	6088                	ld	a0,0(s1)
    80001130:	d97d                	beqz	a0,80001126 <fork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001132:	212020ef          	jal	80003344 <filedup>
    80001136:	00a93023          	sd	a0,0(s2)
    8000113a:	b7f5                	j	80001126 <fork+0x9a>
  np->cwd = idup(p->cwd);
    8000113c:	150ab503          	ld	a0,336(s5)
    80001140:	564010ef          	jal	800026a4 <idup>
    80001144:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001148:	4641                	li	a2,16
    8000114a:	158a8593          	addi	a1,s5,344
    8000114e:	15898513          	addi	a0,s3,344
    80001152:	93aff0ef          	jal	8000028c <safestrcpy>
  pid = np->pid;
    80001156:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000115a:	854e                	mv	a0,s3
    8000115c:	6fc040ef          	jal	80005858 <release>
  acquire(&wait_lock);
    80001160:	00009497          	auipc	s1,0x9
    80001164:	1a848493          	addi	s1,s1,424 # 8000a308 <wait_lock>
    80001168:	8526                	mv	a0,s1
    8000116a:	656040ef          	jal	800057c0 <acquire>
  np->parent = p;
    8000116e:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001172:	8526                	mv	a0,s1
    80001174:	6e4040ef          	jal	80005858 <release>
  acquire(&np->lock);
    80001178:	854e                	mv	a0,s3
    8000117a:	646040ef          	jal	800057c0 <acquire>
  np->state = RUNNABLE;
    8000117e:	478d                	li	a5,3
    80001180:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001184:	854e                	mv	a0,s3
    80001186:	6d2040ef          	jal	80005858 <release>
  return pid;
    8000118a:	74a2                	ld	s1,40(sp)
    8000118c:	69e2                	ld	s3,24(sp)
    8000118e:	6a42                	ld	s4,16(sp)
}
    80001190:	854a                	mv	a0,s2
    80001192:	70e2                	ld	ra,56(sp)
    80001194:	7442                	ld	s0,48(sp)
    80001196:	7902                	ld	s2,32(sp)
    80001198:	6aa2                	ld	s5,8(sp)
    8000119a:	6121                	addi	sp,sp,64
    8000119c:	8082                	ret
    return -1;
    8000119e:	597d                	li	s2,-1
    800011a0:	bfc5                	j	80001190 <fork+0x104>

00000000800011a2 <scheduler>:
{
    800011a2:	715d                	addi	sp,sp,-80
    800011a4:	e486                	sd	ra,72(sp)
    800011a6:	e0a2                	sd	s0,64(sp)
    800011a8:	fc26                	sd	s1,56(sp)
    800011aa:	f84a                	sd	s2,48(sp)
    800011ac:	f44e                	sd	s3,40(sp)
    800011ae:	f052                	sd	s4,32(sp)
    800011b0:	ec56                	sd	s5,24(sp)
    800011b2:	e85a                	sd	s6,16(sp)
    800011b4:	e45e                	sd	s7,8(sp)
    800011b6:	e062                	sd	s8,0(sp)
    800011b8:	0880                	addi	s0,sp,80
    800011ba:	8792                	mv	a5,tp
  int id = r_tp();
    800011bc:	2781                	sext.w	a5,a5
  c->proc = 0;
    800011be:	00779b13          	slli	s6,a5,0x7
    800011c2:	00009717          	auipc	a4,0x9
    800011c6:	12e70713          	addi	a4,a4,302 # 8000a2f0 <pid_lock>
    800011ca:	975a                	add	a4,a4,s6
    800011cc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800011d0:	00009717          	auipc	a4,0x9
    800011d4:	15870713          	addi	a4,a4,344 # 8000a328 <cpus+0x8>
    800011d8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800011da:	4c11                	li	s8,4
        c->proc = p;
    800011dc:	079e                	slli	a5,a5,0x7
    800011de:	00009a17          	auipc	s4,0x9
    800011e2:	112a0a13          	addi	s4,s4,274 # 8000a2f0 <pid_lock>
    800011e6:	9a3e                	add	s4,s4,a5
        found = 1;
    800011e8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800011ea:	0000f997          	auipc	s3,0xf
    800011ee:	13698993          	addi	s3,s3,310 # 80010320 <tickslock>
    800011f2:	a0a9                	j	8000123c <scheduler+0x9a>
      release(&p->lock);
    800011f4:	8526                	mv	a0,s1
    800011f6:	662040ef          	jal	80005858 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800011fa:	17048493          	addi	s1,s1,368
    800011fe:	03348563          	beq	s1,s3,80001228 <scheduler+0x86>
      acquire(&p->lock);
    80001202:	8526                	mv	a0,s1
    80001204:	5bc040ef          	jal	800057c0 <acquire>
      if(p->state == RUNNABLE) {
    80001208:	4c9c                	lw	a5,24(s1)
    8000120a:	ff2795e3          	bne	a5,s2,800011f4 <scheduler+0x52>
        p->state = RUNNING;
    8000120e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001212:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001216:	06048593          	addi	a1,s1,96
    8000121a:	855a                	mv	a0,s6
    8000121c:	5b4000ef          	jal	800017d0 <swtch>
        c->proc = 0;
    80001220:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001224:	8ade                	mv	s5,s7
    80001226:	b7f9                	j	800011f4 <scheduler+0x52>
    if(found == 0) {
    80001228:	000a9a63          	bnez	s5,8000123c <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000122c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001230:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001234:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001238:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000123c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001240:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001244:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001248:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000124a:	00009497          	auipc	s1,0x9
    8000124e:	4d648493          	addi	s1,s1,1238 # 8000a720 <proc>
      if(p->state == RUNNABLE) {
    80001252:	490d                	li	s2,3
    80001254:	b77d                	j	80001202 <scheduler+0x60>

0000000080001256 <sched>:
{
    80001256:	7179                	addi	sp,sp,-48
    80001258:	f406                	sd	ra,40(sp)
    8000125a:	f022                	sd	s0,32(sp)
    8000125c:	ec26                	sd	s1,24(sp)
    8000125e:	e84a                	sd	s2,16(sp)
    80001260:	e44e                	sd	s3,8(sp)
    80001262:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001264:	b03ff0ef          	jal	80000d66 <myproc>
    80001268:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000126a:	4ec040ef          	jal	80005756 <holding>
    8000126e:	c92d                	beqz	a0,800012e0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001270:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001272:	2781                	sext.w	a5,a5
    80001274:	079e                	slli	a5,a5,0x7
    80001276:	00009717          	auipc	a4,0x9
    8000127a:	07a70713          	addi	a4,a4,122 # 8000a2f0 <pid_lock>
    8000127e:	97ba                	add	a5,a5,a4
    80001280:	0a87a703          	lw	a4,168(a5)
    80001284:	4785                	li	a5,1
    80001286:	06f71363          	bne	a4,a5,800012ec <sched+0x96>
  if(p->state == RUNNING)
    8000128a:	4c98                	lw	a4,24(s1)
    8000128c:	4791                	li	a5,4
    8000128e:	06f70563          	beq	a4,a5,800012f8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001292:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001296:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001298:	e7b5                	bnez	a5,80001304 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000129a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000129c:	00009917          	auipc	s2,0x9
    800012a0:	05490913          	addi	s2,s2,84 # 8000a2f0 <pid_lock>
    800012a4:	2781                	sext.w	a5,a5
    800012a6:	079e                	slli	a5,a5,0x7
    800012a8:	97ca                	add	a5,a5,s2
    800012aa:	0ac7a983          	lw	s3,172(a5)
    800012ae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012b0:	2781                	sext.w	a5,a5
    800012b2:	079e                	slli	a5,a5,0x7
    800012b4:	00009597          	auipc	a1,0x9
    800012b8:	07458593          	addi	a1,a1,116 # 8000a328 <cpus+0x8>
    800012bc:	95be                	add	a1,a1,a5
    800012be:	06048513          	addi	a0,s1,96
    800012c2:	50e000ef          	jal	800017d0 <swtch>
    800012c6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800012c8:	2781                	sext.w	a5,a5
    800012ca:	079e                	slli	a5,a5,0x7
    800012cc:	993e                	add	s2,s2,a5
    800012ce:	0b392623          	sw	s3,172(s2)
}
    800012d2:	70a2                	ld	ra,40(sp)
    800012d4:	7402                	ld	s0,32(sp)
    800012d6:	64e2                	ld	s1,24(sp)
    800012d8:	6942                	ld	s2,16(sp)
    800012da:	69a2                	ld	s3,8(sp)
    800012dc:	6145                	addi	sp,sp,48
    800012de:	8082                	ret
    panic("sched p->lock");
    800012e0:	00006517          	auipc	a0,0x6
    800012e4:	ef850513          	addi	a0,a0,-264 # 800071d8 <etext+0x1d8>
    800012e8:	1aa040ef          	jal	80005492 <panic>
    panic("sched locks");
    800012ec:	00006517          	auipc	a0,0x6
    800012f0:	efc50513          	addi	a0,a0,-260 # 800071e8 <etext+0x1e8>
    800012f4:	19e040ef          	jal	80005492 <panic>
    panic("sched running");
    800012f8:	00006517          	auipc	a0,0x6
    800012fc:	f0050513          	addi	a0,a0,-256 # 800071f8 <etext+0x1f8>
    80001300:	192040ef          	jal	80005492 <panic>
    panic("sched interruptible");
    80001304:	00006517          	auipc	a0,0x6
    80001308:	f0450513          	addi	a0,a0,-252 # 80007208 <etext+0x208>
    8000130c:	186040ef          	jal	80005492 <panic>

0000000080001310 <yield>:
{
    80001310:	1101                	addi	sp,sp,-32
    80001312:	ec06                	sd	ra,24(sp)
    80001314:	e822                	sd	s0,16(sp)
    80001316:	e426                	sd	s1,8(sp)
    80001318:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000131a:	a4dff0ef          	jal	80000d66 <myproc>
    8000131e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001320:	4a0040ef          	jal	800057c0 <acquire>
  p->state = RUNNABLE;
    80001324:	478d                	li	a5,3
    80001326:	cc9c                	sw	a5,24(s1)
  sched();
    80001328:	f2fff0ef          	jal	80001256 <sched>
  release(&p->lock);
    8000132c:	8526                	mv	a0,s1
    8000132e:	52a040ef          	jal	80005858 <release>
}
    80001332:	60e2                	ld	ra,24(sp)
    80001334:	6442                	ld	s0,16(sp)
    80001336:	64a2                	ld	s1,8(sp)
    80001338:	6105                	addi	sp,sp,32
    8000133a:	8082                	ret

000000008000133c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000133c:	7179                	addi	sp,sp,-48
    8000133e:	f406                	sd	ra,40(sp)
    80001340:	f022                	sd	s0,32(sp)
    80001342:	ec26                	sd	s1,24(sp)
    80001344:	e84a                	sd	s2,16(sp)
    80001346:	e44e                	sd	s3,8(sp)
    80001348:	1800                	addi	s0,sp,48
    8000134a:	89aa                	mv	s3,a0
    8000134c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000134e:	a19ff0ef          	jal	80000d66 <myproc>
    80001352:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001354:	46c040ef          	jal	800057c0 <acquire>
  release(lk);
    80001358:	854a                	mv	a0,s2
    8000135a:	4fe040ef          	jal	80005858 <release>

  // Go to sleep.
  p->chan = chan;
    8000135e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001362:	4789                	li	a5,2
    80001364:	cc9c                	sw	a5,24(s1)

  sched();
    80001366:	ef1ff0ef          	jal	80001256 <sched>

  // Tidy up.
  p->chan = 0;
    8000136a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000136e:	8526                	mv	a0,s1
    80001370:	4e8040ef          	jal	80005858 <release>
  acquire(lk);
    80001374:	854a                	mv	a0,s2
    80001376:	44a040ef          	jal	800057c0 <acquire>
}
    8000137a:	70a2                	ld	ra,40(sp)
    8000137c:	7402                	ld	s0,32(sp)
    8000137e:	64e2                	ld	s1,24(sp)
    80001380:	6942                	ld	s2,16(sp)
    80001382:	69a2                	ld	s3,8(sp)
    80001384:	6145                	addi	sp,sp,48
    80001386:	8082                	ret

0000000080001388 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001388:	7139                	addi	sp,sp,-64
    8000138a:	fc06                	sd	ra,56(sp)
    8000138c:	f822                	sd	s0,48(sp)
    8000138e:	f426                	sd	s1,40(sp)
    80001390:	f04a                	sd	s2,32(sp)
    80001392:	ec4e                	sd	s3,24(sp)
    80001394:	e852                	sd	s4,16(sp)
    80001396:	e456                	sd	s5,8(sp)
    80001398:	0080                	addi	s0,sp,64
    8000139a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000139c:	00009497          	auipc	s1,0x9
    800013a0:	38448493          	addi	s1,s1,900 # 8000a720 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800013a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800013a6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013a8:	0000f917          	auipc	s2,0xf
    800013ac:	f7890913          	addi	s2,s2,-136 # 80010320 <tickslock>
    800013b0:	a801                	j	800013c0 <wakeup+0x38>
      }
      release(&p->lock);
    800013b2:	8526                	mv	a0,s1
    800013b4:	4a4040ef          	jal	80005858 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013b8:	17048493          	addi	s1,s1,368
    800013bc:	03248263          	beq	s1,s2,800013e0 <wakeup+0x58>
    if(p != myproc()){
    800013c0:	9a7ff0ef          	jal	80000d66 <myproc>
    800013c4:	fea48ae3          	beq	s1,a0,800013b8 <wakeup+0x30>
      acquire(&p->lock);
    800013c8:	8526                	mv	a0,s1
    800013ca:	3f6040ef          	jal	800057c0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800013ce:	4c9c                	lw	a5,24(s1)
    800013d0:	ff3791e3          	bne	a5,s3,800013b2 <wakeup+0x2a>
    800013d4:	709c                	ld	a5,32(s1)
    800013d6:	fd479ee3          	bne	a5,s4,800013b2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800013da:	0154ac23          	sw	s5,24(s1)
    800013de:	bfd1                	j	800013b2 <wakeup+0x2a>
    }
  }
}
    800013e0:	70e2                	ld	ra,56(sp)
    800013e2:	7442                	ld	s0,48(sp)
    800013e4:	74a2                	ld	s1,40(sp)
    800013e6:	7902                	ld	s2,32(sp)
    800013e8:	69e2                	ld	s3,24(sp)
    800013ea:	6a42                	ld	s4,16(sp)
    800013ec:	6aa2                	ld	s5,8(sp)
    800013ee:	6121                	addi	sp,sp,64
    800013f0:	8082                	ret

00000000800013f2 <reparent>:
{
    800013f2:	7179                	addi	sp,sp,-48
    800013f4:	f406                	sd	ra,40(sp)
    800013f6:	f022                	sd	s0,32(sp)
    800013f8:	ec26                	sd	s1,24(sp)
    800013fa:	e84a                	sd	s2,16(sp)
    800013fc:	e44e                	sd	s3,8(sp)
    800013fe:	e052                	sd	s4,0(sp)
    80001400:	1800                	addi	s0,sp,48
    80001402:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001404:	00009497          	auipc	s1,0x9
    80001408:	31c48493          	addi	s1,s1,796 # 8000a720 <proc>
      pp->parent = initproc;
    8000140c:	00009a17          	auipc	s4,0x9
    80001410:	ea4a0a13          	addi	s4,s4,-348 # 8000a2b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001414:	0000f997          	auipc	s3,0xf
    80001418:	f0c98993          	addi	s3,s3,-244 # 80010320 <tickslock>
    8000141c:	a029                	j	80001426 <reparent+0x34>
    8000141e:	17048493          	addi	s1,s1,368
    80001422:	01348b63          	beq	s1,s3,80001438 <reparent+0x46>
    if(pp->parent == p){
    80001426:	7c9c                	ld	a5,56(s1)
    80001428:	ff279be3          	bne	a5,s2,8000141e <reparent+0x2c>
      pp->parent = initproc;
    8000142c:	000a3503          	ld	a0,0(s4)
    80001430:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001432:	f57ff0ef          	jal	80001388 <wakeup>
    80001436:	b7e5                	j	8000141e <reparent+0x2c>
}
    80001438:	70a2                	ld	ra,40(sp)
    8000143a:	7402                	ld	s0,32(sp)
    8000143c:	64e2                	ld	s1,24(sp)
    8000143e:	6942                	ld	s2,16(sp)
    80001440:	69a2                	ld	s3,8(sp)
    80001442:	6a02                	ld	s4,0(sp)
    80001444:	6145                	addi	sp,sp,48
    80001446:	8082                	ret

0000000080001448 <exit>:
{
    80001448:	7179                	addi	sp,sp,-48
    8000144a:	f406                	sd	ra,40(sp)
    8000144c:	f022                	sd	s0,32(sp)
    8000144e:	ec26                	sd	s1,24(sp)
    80001450:	e84a                	sd	s2,16(sp)
    80001452:	e44e                	sd	s3,8(sp)
    80001454:	e052                	sd	s4,0(sp)
    80001456:	1800                	addi	s0,sp,48
    80001458:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000145a:	90dff0ef          	jal	80000d66 <myproc>
    8000145e:	89aa                	mv	s3,a0
  if(p == initproc)
    80001460:	00009797          	auipc	a5,0x9
    80001464:	e507b783          	ld	a5,-432(a5) # 8000a2b0 <initproc>
    80001468:	0d050493          	addi	s1,a0,208
    8000146c:	15050913          	addi	s2,a0,336
    80001470:	00a79f63          	bne	a5,a0,8000148e <exit+0x46>
    panic("init exiting");
    80001474:	00006517          	auipc	a0,0x6
    80001478:	dac50513          	addi	a0,a0,-596 # 80007220 <etext+0x220>
    8000147c:	016040ef          	jal	80005492 <panic>
      fileclose(f);
    80001480:	70b010ef          	jal	8000338a <fileclose>
      p->ofile[fd] = 0;
    80001484:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001488:	04a1                	addi	s1,s1,8
    8000148a:	01248563          	beq	s1,s2,80001494 <exit+0x4c>
    if(p->ofile[fd]){
    8000148e:	6088                	ld	a0,0(s1)
    80001490:	f965                	bnez	a0,80001480 <exit+0x38>
    80001492:	bfdd                	j	80001488 <exit+0x40>
  begin_op();
    80001494:	2dd010ef          	jal	80002f70 <begin_op>
  iput(p->cwd);
    80001498:	1509b503          	ld	a0,336(s3)
    8000149c:	3c0010ef          	jal	8000285c <iput>
  end_op();
    800014a0:	33b010ef          	jal	80002fda <end_op>
  p->cwd = 0;
    800014a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014a8:	00009497          	auipc	s1,0x9
    800014ac:	e6048493          	addi	s1,s1,-416 # 8000a308 <wait_lock>
    800014b0:	8526                	mv	a0,s1
    800014b2:	30e040ef          	jal	800057c0 <acquire>
  reparent(p);
    800014b6:	854e                	mv	a0,s3
    800014b8:	f3bff0ef          	jal	800013f2 <reparent>
  wakeup(p->parent);
    800014bc:	0389b503          	ld	a0,56(s3)
    800014c0:	ec9ff0ef          	jal	80001388 <wakeup>
  acquire(&p->lock);
    800014c4:	854e                	mv	a0,s3
    800014c6:	2fa040ef          	jal	800057c0 <acquire>
  p->xstate = status;
    800014ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800014ce:	4795                	li	a5,5
    800014d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800014d4:	8526                	mv	a0,s1
    800014d6:	382040ef          	jal	80005858 <release>
  sched();
    800014da:	d7dff0ef          	jal	80001256 <sched>
  panic("zombie exit");
    800014de:	00006517          	auipc	a0,0x6
    800014e2:	d5250513          	addi	a0,a0,-686 # 80007230 <etext+0x230>
    800014e6:	7ad030ef          	jal	80005492 <panic>

00000000800014ea <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800014ea:	7179                	addi	sp,sp,-48
    800014ec:	f406                	sd	ra,40(sp)
    800014ee:	f022                	sd	s0,32(sp)
    800014f0:	ec26                	sd	s1,24(sp)
    800014f2:	e84a                	sd	s2,16(sp)
    800014f4:	e44e                	sd	s3,8(sp)
    800014f6:	1800                	addi	s0,sp,48
    800014f8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800014fa:	00009497          	auipc	s1,0x9
    800014fe:	22648493          	addi	s1,s1,550 # 8000a720 <proc>
    80001502:	0000f997          	auipc	s3,0xf
    80001506:	e1e98993          	addi	s3,s3,-482 # 80010320 <tickslock>
    acquire(&p->lock);
    8000150a:	8526                	mv	a0,s1
    8000150c:	2b4040ef          	jal	800057c0 <acquire>
    if(p->pid == pid){
    80001510:	589c                	lw	a5,48(s1)
    80001512:	01278b63          	beq	a5,s2,80001528 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001516:	8526                	mv	a0,s1
    80001518:	340040ef          	jal	80005858 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000151c:	17048493          	addi	s1,s1,368
    80001520:	ff3495e3          	bne	s1,s3,8000150a <kill+0x20>
  }
  return -1;
    80001524:	557d                	li	a0,-1
    80001526:	a819                	j	8000153c <kill+0x52>
      p->killed = 1;
    80001528:	4785                	li	a5,1
    8000152a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000152c:	4c98                	lw	a4,24(s1)
    8000152e:	4789                	li	a5,2
    80001530:	00f70d63          	beq	a4,a5,8000154a <kill+0x60>
      release(&p->lock);
    80001534:	8526                	mv	a0,s1
    80001536:	322040ef          	jal	80005858 <release>
      return 0;
    8000153a:	4501                	li	a0,0
}
    8000153c:	70a2                	ld	ra,40(sp)
    8000153e:	7402                	ld	s0,32(sp)
    80001540:	64e2                	ld	s1,24(sp)
    80001542:	6942                	ld	s2,16(sp)
    80001544:	69a2                	ld	s3,8(sp)
    80001546:	6145                	addi	sp,sp,48
    80001548:	8082                	ret
        p->state = RUNNABLE;
    8000154a:	478d                	li	a5,3
    8000154c:	cc9c                	sw	a5,24(s1)
    8000154e:	b7dd                	j	80001534 <kill+0x4a>

0000000080001550 <setkilled>:

void
setkilled(struct proc *p)
{
    80001550:	1101                	addi	sp,sp,-32
    80001552:	ec06                	sd	ra,24(sp)
    80001554:	e822                	sd	s0,16(sp)
    80001556:	e426                	sd	s1,8(sp)
    80001558:	1000                	addi	s0,sp,32
    8000155a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000155c:	264040ef          	jal	800057c0 <acquire>
  p->killed = 1;
    80001560:	4785                	li	a5,1
    80001562:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001564:	8526                	mv	a0,s1
    80001566:	2f2040ef          	jal	80005858 <release>
}
    8000156a:	60e2                	ld	ra,24(sp)
    8000156c:	6442                	ld	s0,16(sp)
    8000156e:	64a2                	ld	s1,8(sp)
    80001570:	6105                	addi	sp,sp,32
    80001572:	8082                	ret

0000000080001574 <killed>:

int
killed(struct proc *p)
{
    80001574:	1101                	addi	sp,sp,-32
    80001576:	ec06                	sd	ra,24(sp)
    80001578:	e822                	sd	s0,16(sp)
    8000157a:	e426                	sd	s1,8(sp)
    8000157c:	e04a                	sd	s2,0(sp)
    8000157e:	1000                	addi	s0,sp,32
    80001580:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001582:	23e040ef          	jal	800057c0 <acquire>
  k = p->killed;
    80001586:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000158a:	8526                	mv	a0,s1
    8000158c:	2cc040ef          	jal	80005858 <release>
  return k;
}
    80001590:	854a                	mv	a0,s2
    80001592:	60e2                	ld	ra,24(sp)
    80001594:	6442                	ld	s0,16(sp)
    80001596:	64a2                	ld	s1,8(sp)
    80001598:	6902                	ld	s2,0(sp)
    8000159a:	6105                	addi	sp,sp,32
    8000159c:	8082                	ret

000000008000159e <wait>:
{
    8000159e:	715d                	addi	sp,sp,-80
    800015a0:	e486                	sd	ra,72(sp)
    800015a2:	e0a2                	sd	s0,64(sp)
    800015a4:	fc26                	sd	s1,56(sp)
    800015a6:	f84a                	sd	s2,48(sp)
    800015a8:	f44e                	sd	s3,40(sp)
    800015aa:	f052                	sd	s4,32(sp)
    800015ac:	ec56                	sd	s5,24(sp)
    800015ae:	e85a                	sd	s6,16(sp)
    800015b0:	e45e                	sd	s7,8(sp)
    800015b2:	e062                	sd	s8,0(sp)
    800015b4:	0880                	addi	s0,sp,80
    800015b6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015b8:	faeff0ef          	jal	80000d66 <myproc>
    800015bc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800015be:	00009517          	auipc	a0,0x9
    800015c2:	d4a50513          	addi	a0,a0,-694 # 8000a308 <wait_lock>
    800015c6:	1fa040ef          	jal	800057c0 <acquire>
    havekids = 0;
    800015ca:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800015cc:	4a15                	li	s4,5
        havekids = 1;
    800015ce:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800015d0:	0000f997          	auipc	s3,0xf
    800015d4:	d5098993          	addi	s3,s3,-688 # 80010320 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800015d8:	00009c17          	auipc	s8,0x9
    800015dc:	d30c0c13          	addi	s8,s8,-720 # 8000a308 <wait_lock>
    800015e0:	a871                	j	8000167c <wait+0xde>
          pid = pp->pid;
    800015e2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800015e6:	000b0c63          	beqz	s6,800015fe <wait+0x60>
    800015ea:	4691                	li	a3,4
    800015ec:	02c48613          	addi	a2,s1,44
    800015f0:	85da                	mv	a1,s6
    800015f2:	05093503          	ld	a0,80(s2)
    800015f6:	be2ff0ef          	jal	800009d8 <copyout>
    800015fa:	02054b63          	bltz	a0,80001630 <wait+0x92>
          freeproc(pp);
    800015fe:	8526                	mv	a0,s1
    80001600:	8d9ff0ef          	jal	80000ed8 <freeproc>
          release(&pp->lock);
    80001604:	8526                	mv	a0,s1
    80001606:	252040ef          	jal	80005858 <release>
          release(&wait_lock);
    8000160a:	00009517          	auipc	a0,0x9
    8000160e:	cfe50513          	addi	a0,a0,-770 # 8000a308 <wait_lock>
    80001612:	246040ef          	jal	80005858 <release>
}
    80001616:	854e                	mv	a0,s3
    80001618:	60a6                	ld	ra,72(sp)
    8000161a:	6406                	ld	s0,64(sp)
    8000161c:	74e2                	ld	s1,56(sp)
    8000161e:	7942                	ld	s2,48(sp)
    80001620:	79a2                	ld	s3,40(sp)
    80001622:	7a02                	ld	s4,32(sp)
    80001624:	6ae2                	ld	s5,24(sp)
    80001626:	6b42                	ld	s6,16(sp)
    80001628:	6ba2                	ld	s7,8(sp)
    8000162a:	6c02                	ld	s8,0(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
            release(&pp->lock);
    80001630:	8526                	mv	a0,s1
    80001632:	226040ef          	jal	80005858 <release>
            release(&wait_lock);
    80001636:	00009517          	auipc	a0,0x9
    8000163a:	cd250513          	addi	a0,a0,-814 # 8000a308 <wait_lock>
    8000163e:	21a040ef          	jal	80005858 <release>
            return -1;
    80001642:	59fd                	li	s3,-1
    80001644:	bfc9                	j	80001616 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001646:	17048493          	addi	s1,s1,368
    8000164a:	03348063          	beq	s1,s3,8000166a <wait+0xcc>
      if(pp->parent == p){
    8000164e:	7c9c                	ld	a5,56(s1)
    80001650:	ff279be3          	bne	a5,s2,80001646 <wait+0xa8>
        acquire(&pp->lock);
    80001654:	8526                	mv	a0,s1
    80001656:	16a040ef          	jal	800057c0 <acquire>
        if(pp->state == ZOMBIE){
    8000165a:	4c9c                	lw	a5,24(s1)
    8000165c:	f94783e3          	beq	a5,s4,800015e2 <wait+0x44>
        release(&pp->lock);
    80001660:	8526                	mv	a0,s1
    80001662:	1f6040ef          	jal	80005858 <release>
        havekids = 1;
    80001666:	8756                	mv	a4,s5
    80001668:	bff9                	j	80001646 <wait+0xa8>
    if(!havekids || killed(p)){
    8000166a:	cf19                	beqz	a4,80001688 <wait+0xea>
    8000166c:	854a                	mv	a0,s2
    8000166e:	f07ff0ef          	jal	80001574 <killed>
    80001672:	e919                	bnez	a0,80001688 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001674:	85e2                	mv	a1,s8
    80001676:	854a                	mv	a0,s2
    80001678:	cc5ff0ef          	jal	8000133c <sleep>
    havekids = 0;
    8000167c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000167e:	00009497          	auipc	s1,0x9
    80001682:	0a248493          	addi	s1,s1,162 # 8000a720 <proc>
    80001686:	b7e1                	j	8000164e <wait+0xb0>
      release(&wait_lock);
    80001688:	00009517          	auipc	a0,0x9
    8000168c:	c8050513          	addi	a0,a0,-896 # 8000a308 <wait_lock>
    80001690:	1c8040ef          	jal	80005858 <release>
      return -1;
    80001694:	59fd                	li	s3,-1
    80001696:	b741                	j	80001616 <wait+0x78>

0000000080001698 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001698:	7179                	addi	sp,sp,-48
    8000169a:	f406                	sd	ra,40(sp)
    8000169c:	f022                	sd	s0,32(sp)
    8000169e:	ec26                	sd	s1,24(sp)
    800016a0:	e84a                	sd	s2,16(sp)
    800016a2:	e44e                	sd	s3,8(sp)
    800016a4:	e052                	sd	s4,0(sp)
    800016a6:	1800                	addi	s0,sp,48
    800016a8:	84aa                	mv	s1,a0
    800016aa:	892e                	mv	s2,a1
    800016ac:	89b2                	mv	s3,a2
    800016ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016b0:	eb6ff0ef          	jal	80000d66 <myproc>
  if(user_dst){
    800016b4:	cc99                	beqz	s1,800016d2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800016b6:	86d2                	mv	a3,s4
    800016b8:	864e                	mv	a2,s3
    800016ba:	85ca                	mv	a1,s2
    800016bc:	6928                	ld	a0,80(a0)
    800016be:	b1aff0ef          	jal	800009d8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800016c2:	70a2                	ld	ra,40(sp)
    800016c4:	7402                	ld	s0,32(sp)
    800016c6:	64e2                	ld	s1,24(sp)
    800016c8:	6942                	ld	s2,16(sp)
    800016ca:	69a2                	ld	s3,8(sp)
    800016cc:	6a02                	ld	s4,0(sp)
    800016ce:	6145                	addi	sp,sp,48
    800016d0:	8082                	ret
    memmove((char *)dst, src, len);
    800016d2:	000a061b          	sext.w	a2,s4
    800016d6:	85ce                	mv	a1,s3
    800016d8:	854a                	mv	a0,s2
    800016da:	ad1fe0ef          	jal	800001aa <memmove>
    return 0;
    800016de:	8526                	mv	a0,s1
    800016e0:	b7cd                	j	800016c2 <either_copyout+0x2a>

00000000800016e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800016e2:	7179                	addi	sp,sp,-48
    800016e4:	f406                	sd	ra,40(sp)
    800016e6:	f022                	sd	s0,32(sp)
    800016e8:	ec26                	sd	s1,24(sp)
    800016ea:	e84a                	sd	s2,16(sp)
    800016ec:	e44e                	sd	s3,8(sp)
    800016ee:	e052                	sd	s4,0(sp)
    800016f0:	1800                	addi	s0,sp,48
    800016f2:	892a                	mv	s2,a0
    800016f4:	84ae                	mv	s1,a1
    800016f6:	89b2                	mv	s3,a2
    800016f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016fa:	e6cff0ef          	jal	80000d66 <myproc>
  if(user_src){
    800016fe:	cc99                	beqz	s1,8000171c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001700:	86d2                	mv	a3,s4
    80001702:	864e                	mv	a2,s3
    80001704:	85ca                	mv	a1,s2
    80001706:	6928                	ld	a0,80(a0)
    80001708:	ba6ff0ef          	jal	80000aae <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000170c:	70a2                	ld	ra,40(sp)
    8000170e:	7402                	ld	s0,32(sp)
    80001710:	64e2                	ld	s1,24(sp)
    80001712:	6942                	ld	s2,16(sp)
    80001714:	69a2                	ld	s3,8(sp)
    80001716:	6a02                	ld	s4,0(sp)
    80001718:	6145                	addi	sp,sp,48
    8000171a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000171c:	000a061b          	sext.w	a2,s4
    80001720:	85ce                	mv	a1,s3
    80001722:	854a                	mv	a0,s2
    80001724:	a87fe0ef          	jal	800001aa <memmove>
    return 0;
    80001728:	8526                	mv	a0,s1
    8000172a:	b7cd                	j	8000170c <either_copyin+0x2a>

000000008000172c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000172c:	715d                	addi	sp,sp,-80
    8000172e:	e486                	sd	ra,72(sp)
    80001730:	e0a2                	sd	s0,64(sp)
    80001732:	fc26                	sd	s1,56(sp)
    80001734:	f84a                	sd	s2,48(sp)
    80001736:	f44e                	sd	s3,40(sp)
    80001738:	f052                	sd	s4,32(sp)
    8000173a:	ec56                	sd	s5,24(sp)
    8000173c:	e85a                	sd	s6,16(sp)
    8000173e:	e45e                	sd	s7,8(sp)
    80001740:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001742:	00006517          	auipc	a0,0x6
    80001746:	8d650513          	addi	a0,a0,-1834 # 80007018 <etext+0x18>
    8000174a:	277030ef          	jal	800051c0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000174e:	00009497          	auipc	s1,0x9
    80001752:	12a48493          	addi	s1,s1,298 # 8000a878 <proc+0x158>
    80001756:	0000f917          	auipc	s2,0xf
    8000175a:	d2290913          	addi	s2,s2,-734 # 80010478 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000175e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001760:	00006997          	auipc	s3,0x6
    80001764:	ae098993          	addi	s3,s3,-1312 # 80007240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80001768:	00006a97          	auipc	s5,0x6
    8000176c:	ae0a8a93          	addi	s5,s5,-1312 # 80007248 <etext+0x248>
    printf("\n");
    80001770:	00006a17          	auipc	s4,0x6
    80001774:	8a8a0a13          	addi	s4,s4,-1880 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001778:	00006b97          	auipc	s7,0x6
    8000177c:	018b8b93          	addi	s7,s7,24 # 80007790 <states.0>
    80001780:	a829                	j	8000179a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001782:	ed86a583          	lw	a1,-296(a3)
    80001786:	8556                	mv	a0,s5
    80001788:	239030ef          	jal	800051c0 <printf>
    printf("\n");
    8000178c:	8552                	mv	a0,s4
    8000178e:	233030ef          	jal	800051c0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001792:	17048493          	addi	s1,s1,368
    80001796:	03248263          	beq	s1,s2,800017ba <procdump+0x8e>
    if(p->state == UNUSED)
    8000179a:	86a6                	mv	a3,s1
    8000179c:	ec04a783          	lw	a5,-320(s1)
    800017a0:	dbed                	beqz	a5,80001792 <procdump+0x66>
      state = "???";
    800017a2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017a4:	fcfb6fe3          	bltu	s6,a5,80001782 <procdump+0x56>
    800017a8:	02079713          	slli	a4,a5,0x20
    800017ac:	01d75793          	srli	a5,a4,0x1d
    800017b0:	97de                	add	a5,a5,s7
    800017b2:	6390                	ld	a2,0(a5)
    800017b4:	f679                	bnez	a2,80001782 <procdump+0x56>
      state = "???";
    800017b6:	864e                	mv	a2,s3
    800017b8:	b7e9                	j	80001782 <procdump+0x56>
  }
}
    800017ba:	60a6                	ld	ra,72(sp)
    800017bc:	6406                	ld	s0,64(sp)
    800017be:	74e2                	ld	s1,56(sp)
    800017c0:	7942                	ld	s2,48(sp)
    800017c2:	79a2                	ld	s3,40(sp)
    800017c4:	7a02                	ld	s4,32(sp)
    800017c6:	6ae2                	ld	s5,24(sp)
    800017c8:	6b42                	ld	s6,16(sp)
    800017ca:	6ba2                	ld	s7,8(sp)
    800017cc:	6161                	addi	sp,sp,80
    800017ce:	8082                	ret

00000000800017d0 <swtch>:
    800017d0:	00153023          	sd	ra,0(a0)
    800017d4:	00253423          	sd	sp,8(a0)
    800017d8:	e900                	sd	s0,16(a0)
    800017da:	ed04                	sd	s1,24(a0)
    800017dc:	03253023          	sd	s2,32(a0)
    800017e0:	03353423          	sd	s3,40(a0)
    800017e4:	03453823          	sd	s4,48(a0)
    800017e8:	03553c23          	sd	s5,56(a0)
    800017ec:	05653023          	sd	s6,64(a0)
    800017f0:	05753423          	sd	s7,72(a0)
    800017f4:	05853823          	sd	s8,80(a0)
    800017f8:	05953c23          	sd	s9,88(a0)
    800017fc:	07a53023          	sd	s10,96(a0)
    80001800:	07b53423          	sd	s11,104(a0)
    80001804:	0005b083          	ld	ra,0(a1)
    80001808:	0085b103          	ld	sp,8(a1)
    8000180c:	6980                	ld	s0,16(a1)
    8000180e:	6d84                	ld	s1,24(a1)
    80001810:	0205b903          	ld	s2,32(a1)
    80001814:	0285b983          	ld	s3,40(a1)
    80001818:	0305ba03          	ld	s4,48(a1)
    8000181c:	0385ba83          	ld	s5,56(a1)
    80001820:	0405bb03          	ld	s6,64(a1)
    80001824:	0485bb83          	ld	s7,72(a1)
    80001828:	0505bc03          	ld	s8,80(a1)
    8000182c:	0585bc83          	ld	s9,88(a1)
    80001830:	0605bd03          	ld	s10,96(a1)
    80001834:	0685bd83          	ld	s11,104(a1)
    80001838:	8082                	ret

000000008000183a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000183a:	1141                	addi	sp,sp,-16
    8000183c:	e406                	sd	ra,8(sp)
    8000183e:	e022                	sd	s0,0(sp)
    80001840:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001842:	00006597          	auipc	a1,0x6
    80001846:	a4658593          	addi	a1,a1,-1466 # 80007288 <etext+0x288>
    8000184a:	0000f517          	auipc	a0,0xf
    8000184e:	ad650513          	addi	a0,a0,-1322 # 80010320 <tickslock>
    80001852:	6ef030ef          	jal	80005740 <initlock>
}
    80001856:	60a2                	ld	ra,8(sp)
    80001858:	6402                	ld	s0,0(sp)
    8000185a:	0141                	addi	sp,sp,16
    8000185c:	8082                	ret

000000008000185e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000185e:	1141                	addi	sp,sp,-16
    80001860:	e422                	sd	s0,8(sp)
    80001862:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001864:	00003797          	auipc	a5,0x3
    80001868:	e9c78793          	addi	a5,a5,-356 # 80004700 <kernelvec>
    8000186c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001870:	6422                	ld	s0,8(sp)
    80001872:	0141                	addi	sp,sp,16
    80001874:	8082                	ret

0000000080001876 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001876:	1141                	addi	sp,sp,-16
    80001878:	e406                	sd	ra,8(sp)
    8000187a:	e022                	sd	s0,0(sp)
    8000187c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000187e:	ce8ff0ef          	jal	80000d66 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001882:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001886:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001888:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000188c:	00004697          	auipc	a3,0x4
    80001890:	77468693          	addi	a3,a3,1908 # 80006000 <_trampoline>
    80001894:	00004717          	auipc	a4,0x4
    80001898:	76c70713          	addi	a4,a4,1900 # 80006000 <_trampoline>
    8000189c:	8f15                	sub	a4,a4,a3
    8000189e:	040007b7          	lui	a5,0x4000
    800018a2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800018a4:	07b2                	slli	a5,a5,0xc
    800018a6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018a8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800018ac:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800018ae:	18002673          	csrr	a2,satp
    800018b2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800018b4:	6d30                	ld	a2,88(a0)
    800018b6:	6138                	ld	a4,64(a0)
    800018b8:	6585                	lui	a1,0x1
    800018ba:	972e                	add	a4,a4,a1
    800018bc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800018be:	6d38                	ld	a4,88(a0)
    800018c0:	00000617          	auipc	a2,0x0
    800018c4:	11060613          	addi	a2,a2,272 # 800019d0 <usertrap>
    800018c8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800018ca:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800018cc:	8612                	mv	a2,tp
    800018ce:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800018d0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800018d4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800018d8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800018dc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800018e0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800018e2:	6f18                	ld	a4,24(a4)
    800018e4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800018e8:	6928                	ld	a0,80(a0)
    800018ea:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800018ec:	00004717          	auipc	a4,0x4
    800018f0:	7b070713          	addi	a4,a4,1968 # 8000609c <userret>
    800018f4:	8f15                	sub	a4,a4,a3
    800018f6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018f8:	577d                	li	a4,-1
    800018fa:	177e                	slli	a4,a4,0x3f
    800018fc:	8d59                	or	a0,a0,a4
    800018fe:	9782                	jalr	a5
}
    80001900:	60a2                	ld	ra,8(sp)
    80001902:	6402                	ld	s0,0(sp)
    80001904:	0141                	addi	sp,sp,16
    80001906:	8082                	ret

0000000080001908 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001908:	1101                	addi	sp,sp,-32
    8000190a:	ec06                	sd	ra,24(sp)
    8000190c:	e822                	sd	s0,16(sp)
    8000190e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001910:	c2aff0ef          	jal	80000d3a <cpuid>
    80001914:	cd11                	beqz	a0,80001930 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001916:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000191a:	000f4737          	lui	a4,0xf4
    8000191e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001922:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001924:	14d79073          	csrw	stimecmp,a5
}
    80001928:	60e2                	ld	ra,24(sp)
    8000192a:	6442                	ld	s0,16(sp)
    8000192c:	6105                	addi	sp,sp,32
    8000192e:	8082                	ret
    80001930:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001932:	0000f497          	auipc	s1,0xf
    80001936:	9ee48493          	addi	s1,s1,-1554 # 80010320 <tickslock>
    8000193a:	8526                	mv	a0,s1
    8000193c:	685030ef          	jal	800057c0 <acquire>
    ticks++;
    80001940:	00009517          	auipc	a0,0x9
    80001944:	97850513          	addi	a0,a0,-1672 # 8000a2b8 <ticks>
    80001948:	411c                	lw	a5,0(a0)
    8000194a:	2785                	addiw	a5,a5,1
    8000194c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000194e:	a3bff0ef          	jal	80001388 <wakeup>
    release(&tickslock);
    80001952:	8526                	mv	a0,s1
    80001954:	705030ef          	jal	80005858 <release>
    80001958:	64a2                	ld	s1,8(sp)
    8000195a:	bf75                	j	80001916 <clockintr+0xe>

000000008000195c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000195c:	1101                	addi	sp,sp,-32
    8000195e:	ec06                	sd	ra,24(sp)
    80001960:	e822                	sd	s0,16(sp)
    80001962:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001964:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001968:	57fd                	li	a5,-1
    8000196a:	17fe                	slli	a5,a5,0x3f
    8000196c:	07a5                	addi	a5,a5,9
    8000196e:	00f70c63          	beq	a4,a5,80001986 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001972:	57fd                	li	a5,-1
    80001974:	17fe                	slli	a5,a5,0x3f
    80001976:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001978:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000197a:	04f70763          	beq	a4,a5,800019c8 <devintr+0x6c>
  }
}
    8000197e:	60e2                	ld	ra,24(sp)
    80001980:	6442                	ld	s0,16(sp)
    80001982:	6105                	addi	sp,sp,32
    80001984:	8082                	ret
    80001986:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001988:	625020ef          	jal	800047ac <plic_claim>
    8000198c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000198e:	47a9                	li	a5,10
    80001990:	00f50963          	beq	a0,a5,800019a2 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001994:	4785                	li	a5,1
    80001996:	00f50963          	beq	a0,a5,800019a8 <devintr+0x4c>
    return 1;
    8000199a:	4505                	li	a0,1
    } else if(irq){
    8000199c:	e889                	bnez	s1,800019ae <devintr+0x52>
    8000199e:	64a2                	ld	s1,8(sp)
    800019a0:	bff9                	j	8000197e <devintr+0x22>
      uartintr();
    800019a2:	563030ef          	jal	80005704 <uartintr>
    if(irq)
    800019a6:	a819                	j	800019bc <devintr+0x60>
      virtio_disk_intr();
    800019a8:	2ca030ef          	jal	80004c72 <virtio_disk_intr>
    if(irq)
    800019ac:	a801                	j	800019bc <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800019ae:	85a6                	mv	a1,s1
    800019b0:	00006517          	auipc	a0,0x6
    800019b4:	8e050513          	addi	a0,a0,-1824 # 80007290 <etext+0x290>
    800019b8:	009030ef          	jal	800051c0 <printf>
      plic_complete(irq);
    800019bc:	8526                	mv	a0,s1
    800019be:	60f020ef          	jal	800047cc <plic_complete>
    return 1;
    800019c2:	4505                	li	a0,1
    800019c4:	64a2                	ld	s1,8(sp)
    800019c6:	bf65                	j	8000197e <devintr+0x22>
    clockintr();
    800019c8:	f41ff0ef          	jal	80001908 <clockintr>
    return 2;
    800019cc:	4509                	li	a0,2
    800019ce:	bf45                	j	8000197e <devintr+0x22>

00000000800019d0 <usertrap>:
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	e04a                	sd	s2,0(sp)
    800019da:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019dc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800019e0:	1007f793          	andi	a5,a5,256
    800019e4:	ef85                	bnez	a5,80001a1c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019e6:	00003797          	auipc	a5,0x3
    800019ea:	d1a78793          	addi	a5,a5,-742 # 80004700 <kernelvec>
    800019ee:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800019f2:	b74ff0ef          	jal	80000d66 <myproc>
    800019f6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800019f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800019fa:	14102773          	csrr	a4,sepc
    800019fe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a00:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a04:	47a1                	li	a5,8
    80001a06:	02f70163          	beq	a4,a5,80001a28 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001a0a:	f53ff0ef          	jal	8000195c <devintr>
    80001a0e:	892a                	mv	s2,a0
    80001a10:	c135                	beqz	a0,80001a74 <usertrap+0xa4>
  if(killed(p))
    80001a12:	8526                	mv	a0,s1
    80001a14:	b61ff0ef          	jal	80001574 <killed>
    80001a18:	cd1d                	beqz	a0,80001a56 <usertrap+0x86>
    80001a1a:	a81d                	j	80001a50 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001a1c:	00006517          	auipc	a0,0x6
    80001a20:	89450513          	addi	a0,a0,-1900 # 800072b0 <etext+0x2b0>
    80001a24:	26f030ef          	jal	80005492 <panic>
    if(killed(p))
    80001a28:	b4dff0ef          	jal	80001574 <killed>
    80001a2c:	e121                	bnez	a0,80001a6c <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001a2e:	6cb8                	ld	a4,88(s1)
    80001a30:	6f1c                	ld	a5,24(a4)
    80001a32:	0791                	addi	a5,a5,4
    80001a34:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a3a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a3e:	10079073          	csrw	sstatus,a5
    syscall();
    80001a42:	248000ef          	jal	80001c8a <syscall>
  if(killed(p))
    80001a46:	8526                	mv	a0,s1
    80001a48:	b2dff0ef          	jal	80001574 <killed>
    80001a4c:	c901                	beqz	a0,80001a5c <usertrap+0x8c>
    80001a4e:	4901                	li	s2,0
    exit(-1);
    80001a50:	557d                	li	a0,-1
    80001a52:	9f7ff0ef          	jal	80001448 <exit>
  if(which_dev == 2)
    80001a56:	4789                	li	a5,2
    80001a58:	04f90563          	beq	s2,a5,80001aa2 <usertrap+0xd2>
  usertrapret();
    80001a5c:	e1bff0ef          	jal	80001876 <usertrapret>
}
    80001a60:	60e2                	ld	ra,24(sp)
    80001a62:	6442                	ld	s0,16(sp)
    80001a64:	64a2                	ld	s1,8(sp)
    80001a66:	6902                	ld	s2,0(sp)
    80001a68:	6105                	addi	sp,sp,32
    80001a6a:	8082                	ret
      exit(-1);
    80001a6c:	557d                	li	a0,-1
    80001a6e:	9dbff0ef          	jal	80001448 <exit>
    80001a72:	bf75                	j	80001a2e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a74:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001a78:	5890                	lw	a2,48(s1)
    80001a7a:	00006517          	auipc	a0,0x6
    80001a7e:	85650513          	addi	a0,a0,-1962 # 800072d0 <etext+0x2d0>
    80001a82:	73e030ef          	jal	800051c0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001a8a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001a8e:	00006517          	auipc	a0,0x6
    80001a92:	87250513          	addi	a0,a0,-1934 # 80007300 <etext+0x300>
    80001a96:	72a030ef          	jal	800051c0 <printf>
    setkilled(p);
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	ab5ff0ef          	jal	80001550 <setkilled>
    80001aa0:	b75d                	j	80001a46 <usertrap+0x76>
    yield();
    80001aa2:	86fff0ef          	jal	80001310 <yield>
    80001aa6:	bf5d                	j	80001a5c <usertrap+0x8c>

0000000080001aa8 <kerneltrap>:
{
    80001aa8:	7179                	addi	sp,sp,-48
    80001aaa:	f406                	sd	ra,40(sp)
    80001aac:	f022                	sd	s0,32(sp)
    80001aae:	ec26                	sd	s1,24(sp)
    80001ab0:	e84a                	sd	s2,16(sp)
    80001ab2:	e44e                	sd	s3,8(sp)
    80001ab4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ab6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001aba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001abe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001ac2:	1004f793          	andi	a5,s1,256
    80001ac6:	c795                	beqz	a5,80001af2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ac8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001acc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ace:	eb85                	bnez	a5,80001afe <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001ad0:	e8dff0ef          	jal	8000195c <devintr>
    80001ad4:	c91d                	beqz	a0,80001b0a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001ad6:	4789                	li	a5,2
    80001ad8:	04f50a63          	beq	a0,a5,80001b2c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001adc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ae0:	10049073          	csrw	sstatus,s1
}
    80001ae4:	70a2                	ld	ra,40(sp)
    80001ae6:	7402                	ld	s0,32(sp)
    80001ae8:	64e2                	ld	s1,24(sp)
    80001aea:	6942                	ld	s2,16(sp)
    80001aec:	69a2                	ld	s3,8(sp)
    80001aee:	6145                	addi	sp,sp,48
    80001af0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001af2:	00006517          	auipc	a0,0x6
    80001af6:	83650513          	addi	a0,a0,-1994 # 80007328 <etext+0x328>
    80001afa:	199030ef          	jal	80005492 <panic>
    panic("kerneltrap: interrupts enabled");
    80001afe:	00006517          	auipc	a0,0x6
    80001b02:	85250513          	addi	a0,a0,-1966 # 80007350 <etext+0x350>
    80001b06:	18d030ef          	jal	80005492 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b0a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b0e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001b12:	85ce                	mv	a1,s3
    80001b14:	00006517          	auipc	a0,0x6
    80001b18:	85c50513          	addi	a0,a0,-1956 # 80007370 <etext+0x370>
    80001b1c:	6a4030ef          	jal	800051c0 <printf>
    panic("kerneltrap");
    80001b20:	00006517          	auipc	a0,0x6
    80001b24:	87850513          	addi	a0,a0,-1928 # 80007398 <etext+0x398>
    80001b28:	16b030ef          	jal	80005492 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001b2c:	a3aff0ef          	jal	80000d66 <myproc>
    80001b30:	d555                	beqz	a0,80001adc <kerneltrap+0x34>
    yield();
    80001b32:	fdeff0ef          	jal	80001310 <yield>
    80001b36:	b75d                	j	80001adc <kerneltrap+0x34>

0000000080001b38 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001b38:	1101                	addi	sp,sp,-32
    80001b3a:	ec06                	sd	ra,24(sp)
    80001b3c:	e822                	sd	s0,16(sp)
    80001b3e:	e426                	sd	s1,8(sp)
    80001b40:	1000                	addi	s0,sp,32
    80001b42:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b44:	a22ff0ef          	jal	80000d66 <myproc>
  switch (n) {
    80001b48:	4795                	li	a5,5
    80001b4a:	0497e163          	bltu	a5,s1,80001b8c <argraw+0x54>
    80001b4e:	048a                	slli	s1,s1,0x2
    80001b50:	00006717          	auipc	a4,0x6
    80001b54:	c7070713          	addi	a4,a4,-912 # 800077c0 <states.0+0x30>
    80001b58:	94ba                	add	s1,s1,a4
    80001b5a:	409c                	lw	a5,0(s1)
    80001b5c:	97ba                	add	a5,a5,a4
    80001b5e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001b60:	6d3c                	ld	a5,88(a0)
    80001b62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001b64:	60e2                	ld	ra,24(sp)
    80001b66:	6442                	ld	s0,16(sp)
    80001b68:	64a2                	ld	s1,8(sp)
    80001b6a:	6105                	addi	sp,sp,32
    80001b6c:	8082                	ret
    return p->trapframe->a1;
    80001b6e:	6d3c                	ld	a5,88(a0)
    80001b70:	7fa8                	ld	a0,120(a5)
    80001b72:	bfcd                	j	80001b64 <argraw+0x2c>
    return p->trapframe->a2;
    80001b74:	6d3c                	ld	a5,88(a0)
    80001b76:	63c8                	ld	a0,128(a5)
    80001b78:	b7f5                	j	80001b64 <argraw+0x2c>
    return p->trapframe->a3;
    80001b7a:	6d3c                	ld	a5,88(a0)
    80001b7c:	67c8                	ld	a0,136(a5)
    80001b7e:	b7dd                	j	80001b64 <argraw+0x2c>
    return p->trapframe->a4;
    80001b80:	6d3c                	ld	a5,88(a0)
    80001b82:	6bc8                	ld	a0,144(a5)
    80001b84:	b7c5                	j	80001b64 <argraw+0x2c>
    return p->trapframe->a5;
    80001b86:	6d3c                	ld	a5,88(a0)
    80001b88:	6fc8                	ld	a0,152(a5)
    80001b8a:	bfe9                	j	80001b64 <argraw+0x2c>
  panic("argraw");
    80001b8c:	00006517          	auipc	a0,0x6
    80001b90:	81c50513          	addi	a0,a0,-2020 # 800073a8 <etext+0x3a8>
    80001b94:	0ff030ef          	jal	80005492 <panic>

0000000080001b98 <fetchaddr>:
{
    80001b98:	1101                	addi	sp,sp,-32
    80001b9a:	ec06                	sd	ra,24(sp)
    80001b9c:	e822                	sd	s0,16(sp)
    80001b9e:	e426                	sd	s1,8(sp)
    80001ba0:	e04a                	sd	s2,0(sp)
    80001ba2:	1000                	addi	s0,sp,32
    80001ba4:	84aa                	mv	s1,a0
    80001ba6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ba8:	9beff0ef          	jal	80000d66 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001bac:	653c                	ld	a5,72(a0)
    80001bae:	02f4f663          	bgeu	s1,a5,80001bda <fetchaddr+0x42>
    80001bb2:	00848713          	addi	a4,s1,8
    80001bb6:	02e7e463          	bltu	a5,a4,80001bde <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001bba:	46a1                	li	a3,8
    80001bbc:	8626                	mv	a2,s1
    80001bbe:	85ca                	mv	a1,s2
    80001bc0:	6928                	ld	a0,80(a0)
    80001bc2:	eedfe0ef          	jal	80000aae <copyin>
    80001bc6:	00a03533          	snez	a0,a0
    80001bca:	40a00533          	neg	a0,a0
}
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6902                	ld	s2,0(sp)
    80001bd6:	6105                	addi	sp,sp,32
    80001bd8:	8082                	ret
    return -1;
    80001bda:	557d                	li	a0,-1
    80001bdc:	bfcd                	j	80001bce <fetchaddr+0x36>
    80001bde:	557d                	li	a0,-1
    80001be0:	b7fd                	j	80001bce <fetchaddr+0x36>

0000000080001be2 <fetchstr>:
{
    80001be2:	7179                	addi	sp,sp,-48
    80001be4:	f406                	sd	ra,40(sp)
    80001be6:	f022                	sd	s0,32(sp)
    80001be8:	ec26                	sd	s1,24(sp)
    80001bea:	e84a                	sd	s2,16(sp)
    80001bec:	e44e                	sd	s3,8(sp)
    80001bee:	1800                	addi	s0,sp,48
    80001bf0:	892a                	mv	s2,a0
    80001bf2:	84ae                	mv	s1,a1
    80001bf4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001bf6:	970ff0ef          	jal	80000d66 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001bfa:	86ce                	mv	a3,s3
    80001bfc:	864a                	mv	a2,s2
    80001bfe:	85a6                	mv	a1,s1
    80001c00:	6928                	ld	a0,80(a0)
    80001c02:	f33fe0ef          	jal	80000b34 <copyinstr>
    80001c06:	00054c63          	bltz	a0,80001c1e <fetchstr+0x3c>
  return strlen(buf);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	eb2fe0ef          	jal	800002be <strlen>
}
    80001c10:	70a2                	ld	ra,40(sp)
    80001c12:	7402                	ld	s0,32(sp)
    80001c14:	64e2                	ld	s1,24(sp)
    80001c16:	6942                	ld	s2,16(sp)
    80001c18:	69a2                	ld	s3,8(sp)
    80001c1a:	6145                	addi	sp,sp,48
    80001c1c:	8082                	ret
    return -1;
    80001c1e:	557d                	li	a0,-1
    80001c20:	bfc5                	j	80001c10 <fetchstr+0x2e>

0000000080001c22 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001c22:	1101                	addi	sp,sp,-32
    80001c24:	ec06                	sd	ra,24(sp)
    80001c26:	e822                	sd	s0,16(sp)
    80001c28:	e426                	sd	s1,8(sp)
    80001c2a:	1000                	addi	s0,sp,32
    80001c2c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c2e:	f0bff0ef          	jal	80001b38 <argraw>
    80001c32:	c088                	sw	a0,0(s1)
}
    80001c34:	60e2                	ld	ra,24(sp)
    80001c36:	6442                	ld	s0,16(sp)
    80001c38:	64a2                	ld	s1,8(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret

0000000080001c3e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001c3e:	1101                	addi	sp,sp,-32
    80001c40:	ec06                	sd	ra,24(sp)
    80001c42:	e822                	sd	s0,16(sp)
    80001c44:	e426                	sd	s1,8(sp)
    80001c46:	1000                	addi	s0,sp,32
    80001c48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c4a:	eefff0ef          	jal	80001b38 <argraw>
    80001c4e:	e088                	sd	a0,0(s1)
}
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001c5a:	7179                	addi	sp,sp,-48
    80001c5c:	f406                	sd	ra,40(sp)
    80001c5e:	f022                	sd	s0,32(sp)
    80001c60:	ec26                	sd	s1,24(sp)
    80001c62:	e84a                	sd	s2,16(sp)
    80001c64:	1800                	addi	s0,sp,48
    80001c66:	84ae                	mv	s1,a1
    80001c68:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001c6a:	fd840593          	addi	a1,s0,-40
    80001c6e:	fd1ff0ef          	jal	80001c3e <argaddr>
  return fetchstr(addr, buf, max);
    80001c72:	864a                	mv	a2,s2
    80001c74:	85a6                	mv	a1,s1
    80001c76:	fd843503          	ld	a0,-40(s0)
    80001c7a:	f69ff0ef          	jal	80001be2 <fetchstr>
}
    80001c7e:	70a2                	ld	ra,40(sp)
    80001c80:	7402                	ld	s0,32(sp)
    80001c82:	64e2                	ld	s1,24(sp)
    80001c84:	6942                	ld	s2,16(sp)
    80001c86:	6145                	addi	sp,sp,48
    80001c88:	8082                	ret

0000000080001c8a <syscall>:
[SYS_trace]   sys_trace,
};

void
syscall(void)
{
    80001c8a:	1101                	addi	sp,sp,-32
    80001c8c:	ec06                	sd	ra,24(sp)
    80001c8e:	e822                	sd	s0,16(sp)
    80001c90:	e426                	sd	s1,8(sp)
    80001c92:	e04a                	sd	s2,0(sp)
    80001c94:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001c96:	8d0ff0ef          	jal	80000d66 <myproc>
    80001c9a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001c9c:	05853903          	ld	s2,88(a0)
    80001ca0:	0a893783          	ld	a5,168(s2)
    80001ca4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001ca8:	37fd                	addiw	a5,a5,-1
    80001caa:	475d                	li	a4,23
    80001cac:	00f76f63          	bltu	a4,a5,80001cca <syscall+0x40>
    80001cb0:	00369713          	slli	a4,a3,0x3
    80001cb4:	00006797          	auipc	a5,0x6
    80001cb8:	b2478793          	addi	a5,a5,-1244 # 800077d8 <syscalls>
    80001cbc:	97ba                	add	a5,a5,a4
    80001cbe:	639c                	ld	a5,0(a5)
    80001cc0:	c789                	beqz	a5,80001cca <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001cc2:	9782                	jalr	a5
    80001cc4:	06a93823          	sd	a0,112(s2)
    80001cc8:	a829                	j	80001ce2 <syscall+0x58>

  } else {
    printf("%d %s: unknown sys call %d\n",
    80001cca:	15848613          	addi	a2,s1,344
    80001cce:	588c                	lw	a1,48(s1)
    80001cd0:	00005517          	auipc	a0,0x5
    80001cd4:	6e050513          	addi	a0,a0,1760 # 800073b0 <etext+0x3b0>
    80001cd8:	4e8030ef          	jal	800051c0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001cdc:	6cbc                	ld	a5,88(s1)
    80001cde:	577d                	li	a4,-1
    80001ce0:	fbb8                	sd	a4,112(a5)
  }
}
    80001ce2:	60e2                	ld	ra,24(sp)
    80001ce4:	6442                	ld	s0,16(sp)
    80001ce6:	64a2                	ld	s1,8(sp)
    80001ce8:	6902                	ld	s2,0(sp)
    80001cea:	6105                	addi	sp,sp,32
    80001cec:	8082                	ret

0000000080001cee <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001cee:	1101                	addi	sp,sp,-32
    80001cf0:	ec06                	sd	ra,24(sp)
    80001cf2:	e822                	sd	s0,16(sp)
    80001cf4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001cf6:	fec40593          	addi	a1,s0,-20
    80001cfa:	4501                	li	a0,0
    80001cfc:	f27ff0ef          	jal	80001c22 <argint>
  exit(n);
    80001d00:	fec42503          	lw	a0,-20(s0)
    80001d04:	f44ff0ef          	jal	80001448 <exit>
  return 0;  // not reached
}
    80001d08:	4501                	li	a0,0
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	6105                	addi	sp,sp,32
    80001d10:	8082                	ret

0000000080001d12 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001d12:	1141                	addi	sp,sp,-16
    80001d14:	e406                	sd	ra,8(sp)
    80001d16:	e022                	sd	s0,0(sp)
    80001d18:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001d1a:	84cff0ef          	jal	80000d66 <myproc>
}
    80001d1e:	5908                	lw	a0,48(a0)
    80001d20:	60a2                	ld	ra,8(sp)
    80001d22:	6402                	ld	s0,0(sp)
    80001d24:	0141                	addi	sp,sp,16
    80001d26:	8082                	ret

0000000080001d28 <sys_fork>:

uint64
sys_fork(void)
{
    80001d28:	1141                	addi	sp,sp,-16
    80001d2a:	e406                	sd	ra,8(sp)
    80001d2c:	e022                	sd	s0,0(sp)
    80001d2e:	0800                	addi	s0,sp,16
  return fork();
    80001d30:	b5cff0ef          	jal	8000108c <fork>
}
    80001d34:	60a2                	ld	ra,8(sp)
    80001d36:	6402                	ld	s0,0(sp)
    80001d38:	0141                	addi	sp,sp,16
    80001d3a:	8082                	ret

0000000080001d3c <sys_wait>:

uint64
sys_wait(void)
{
    80001d3c:	1101                	addi	sp,sp,-32
    80001d3e:	ec06                	sd	ra,24(sp)
    80001d40:	e822                	sd	s0,16(sp)
    80001d42:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001d44:	fe840593          	addi	a1,s0,-24
    80001d48:	4501                	li	a0,0
    80001d4a:	ef5ff0ef          	jal	80001c3e <argaddr>
  return wait(p);
    80001d4e:	fe843503          	ld	a0,-24(s0)
    80001d52:	84dff0ef          	jal	8000159e <wait>
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	6105                	addi	sp,sp,32
    80001d5c:	8082                	ret

0000000080001d5e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001d5e:	7179                	addi	sp,sp,-48
    80001d60:	f406                	sd	ra,40(sp)
    80001d62:	f022                	sd	s0,32(sp)
    80001d64:	ec26                	sd	s1,24(sp)
    80001d66:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001d68:	fdc40593          	addi	a1,s0,-36
    80001d6c:	4501                	li	a0,0
    80001d6e:	eb5ff0ef          	jal	80001c22 <argint>
  addr = myproc()->sz;
    80001d72:	ff5fe0ef          	jal	80000d66 <myproc>
    80001d76:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001d78:	fdc42503          	lw	a0,-36(s0)
    80001d7c:	ac0ff0ef          	jal	8000103c <growproc>
    80001d80:	00054863          	bltz	a0,80001d90 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001d84:	8526                	mv	a0,s1
    80001d86:	70a2                	ld	ra,40(sp)
    80001d88:	7402                	ld	s0,32(sp)
    80001d8a:	64e2                	ld	s1,24(sp)
    80001d8c:	6145                	addi	sp,sp,48
    80001d8e:	8082                	ret
    return -1;
    80001d90:	54fd                	li	s1,-1
    80001d92:	bfcd                	j	80001d84 <sys_sbrk+0x26>

0000000080001d94 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001d94:	7139                	addi	sp,sp,-64
    80001d96:	fc06                	sd	ra,56(sp)
    80001d98:	f822                	sd	s0,48(sp)
    80001d9a:	f04a                	sd	s2,32(sp)
    80001d9c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001d9e:	fcc40593          	addi	a1,s0,-52
    80001da2:	4501                	li	a0,0
    80001da4:	e7fff0ef          	jal	80001c22 <argint>
  if(n < 0)
    80001da8:	fcc42783          	lw	a5,-52(s0)
    80001dac:	0607c763          	bltz	a5,80001e1a <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001db0:	0000e517          	auipc	a0,0xe
    80001db4:	57050513          	addi	a0,a0,1392 # 80010320 <tickslock>
    80001db8:	209030ef          	jal	800057c0 <acquire>
  ticks0 = ticks;
    80001dbc:	00008917          	auipc	s2,0x8
    80001dc0:	4fc92903          	lw	s2,1276(s2) # 8000a2b8 <ticks>
  while(ticks - ticks0 < n){
    80001dc4:	fcc42783          	lw	a5,-52(s0)
    80001dc8:	cf8d                	beqz	a5,80001e02 <sys_sleep+0x6e>
    80001dca:	f426                	sd	s1,40(sp)
    80001dcc:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001dce:	0000e997          	auipc	s3,0xe
    80001dd2:	55298993          	addi	s3,s3,1362 # 80010320 <tickslock>
    80001dd6:	00008497          	auipc	s1,0x8
    80001dda:	4e248493          	addi	s1,s1,1250 # 8000a2b8 <ticks>
    if(killed(myproc())){
    80001dde:	f89fe0ef          	jal	80000d66 <myproc>
    80001de2:	f92ff0ef          	jal	80001574 <killed>
    80001de6:	ed0d                	bnez	a0,80001e20 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001de8:	85ce                	mv	a1,s3
    80001dea:	8526                	mv	a0,s1
    80001dec:	d50ff0ef          	jal	8000133c <sleep>
  while(ticks - ticks0 < n){
    80001df0:	409c                	lw	a5,0(s1)
    80001df2:	412787bb          	subw	a5,a5,s2
    80001df6:	fcc42703          	lw	a4,-52(s0)
    80001dfa:	fee7e2e3          	bltu	a5,a4,80001dde <sys_sleep+0x4a>
    80001dfe:	74a2                	ld	s1,40(sp)
    80001e00:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001e02:	0000e517          	auipc	a0,0xe
    80001e06:	51e50513          	addi	a0,a0,1310 # 80010320 <tickslock>
    80001e0a:	24f030ef          	jal	80005858 <release>
  return 0;
    80001e0e:	4501                	li	a0,0
}
    80001e10:	70e2                	ld	ra,56(sp)
    80001e12:	7442                	ld	s0,48(sp)
    80001e14:	7902                	ld	s2,32(sp)
    80001e16:	6121                	addi	sp,sp,64
    80001e18:	8082                	ret
    n = 0;
    80001e1a:	fc042623          	sw	zero,-52(s0)
    80001e1e:	bf49                	j	80001db0 <sys_sleep+0x1c>
      release(&tickslock);
    80001e20:	0000e517          	auipc	a0,0xe
    80001e24:	50050513          	addi	a0,a0,1280 # 80010320 <tickslock>
    80001e28:	231030ef          	jal	80005858 <release>
      return -1;
    80001e2c:	557d                	li	a0,-1
    80001e2e:	74a2                	ld	s1,40(sp)
    80001e30:	69e2                	ld	s3,24(sp)
    80001e32:	bff9                	j	80001e10 <sys_sleep+0x7c>

0000000080001e34 <sys_kill>:

uint64
sys_kill(void)
{
    80001e34:	1101                	addi	sp,sp,-32
    80001e36:	ec06                	sd	ra,24(sp)
    80001e38:	e822                	sd	s0,16(sp)
    80001e3a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001e3c:	fec40593          	addi	a1,s0,-20
    80001e40:	4501                	li	a0,0
    80001e42:	de1ff0ef          	jal	80001c22 <argint>
  return kill(pid);
    80001e46:	fec42503          	lw	a0,-20(s0)
    80001e4a:	ea0ff0ef          	jal	800014ea <kill>
}
    80001e4e:	60e2                	ld	ra,24(sp)
    80001e50:	6442                	ld	s0,16(sp)
    80001e52:	6105                	addi	sp,sp,32
    80001e54:	8082                	ret

0000000080001e56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001e56:	1101                	addi	sp,sp,-32
    80001e58:	ec06                	sd	ra,24(sp)
    80001e5a:	e822                	sd	s0,16(sp)
    80001e5c:	e426                	sd	s1,8(sp)
    80001e5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001e60:	0000e517          	auipc	a0,0xe
    80001e64:	4c050513          	addi	a0,a0,1216 # 80010320 <tickslock>
    80001e68:	159030ef          	jal	800057c0 <acquire>
  xticks = ticks;
    80001e6c:	00008497          	auipc	s1,0x8
    80001e70:	44c4a483          	lw	s1,1100(s1) # 8000a2b8 <ticks>
  release(&tickslock);
    80001e74:	0000e517          	auipc	a0,0xe
    80001e78:	4ac50513          	addi	a0,a0,1196 # 80010320 <tickslock>
    80001e7c:	1dd030ef          	jal	80005858 <release>
  return xticks;
}
    80001e80:	02049513          	slli	a0,s1,0x20
    80001e84:	9101                	srli	a0,a0,0x20
    80001e86:	60e2                	ld	ra,24(sp)
    80001e88:	6442                	ld	s0,16(sp)
    80001e8a:	64a2                	ld	s1,8(sp)
    80001e8c:	6105                	addi	sp,sp,32
    80001e8e:	8082                	ret

0000000080001e90 <sys_hello>:

uint64 sys_hello(void) {
    80001e90:	1141                	addi	sp,sp,-16
    80001e92:	e406                	sd	ra,8(sp)
    80001e94:	e022                	sd	s0,0(sp)
    80001e96:	0800                	addi	s0,sp,16
  printf("Hello, world!\n");
    80001e98:	00005517          	auipc	a0,0x5
    80001e9c:	53850513          	addi	a0,a0,1336 # 800073d0 <etext+0x3d0>
    80001ea0:	320030ef          	jal	800051c0 <printf>
  return 0;
}
    80001ea4:	4501                	li	a0,0
    80001ea6:	60a2                	ld	ra,8(sp)
    80001ea8:	6402                	ld	s0,0(sp)
    80001eaa:	0141                	addi	sp,sp,16
    80001eac:	8082                	ret

0000000080001eae <sys_xv6>:

uint64 sys_xv6(void) {
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	1800                	addi	s0,sp,48
  int n;

  argint(0, &n);
    80001eb6:	fdc40593          	addi	a1,s0,-36
    80001eba:	4501                	li	a0,0
    80001ebc:	d67ff0ef          	jal	80001c22 <argint>

  for (int i = 0; i < n; i++){
    80001ec0:	fdc42783          	lw	a5,-36(s0)
    80001ec4:	02f05363          	blez	a5,80001eea <sys_xv6+0x3c>
    80001ec8:	ec26                	sd	s1,24(sp)
    80001eca:	e84a                	sd	s2,16(sp)
    80001ecc:	4481                	li	s1,0
    printf("Hello_xv6\n");
    80001ece:	00005917          	auipc	s2,0x5
    80001ed2:	51290913          	addi	s2,s2,1298 # 800073e0 <etext+0x3e0>
    80001ed6:	854a                	mv	a0,s2
    80001ed8:	2e8030ef          	jal	800051c0 <printf>
  for (int i = 0; i < n; i++){
    80001edc:	2485                	addiw	s1,s1,1
    80001ede:	fdc42783          	lw	a5,-36(s0)
    80001ee2:	fef4cae3          	blt	s1,a5,80001ed6 <sys_xv6+0x28>
    80001ee6:	64e2                	ld	s1,24(sp)
    80001ee8:	6942                	ld	s2,16(sp)
  }
  return 0;
}
    80001eea:	4501                	li	a0,0
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	6145                	addi	sp,sp,48
    80001ef2:	8082                	ret

0000000080001ef4 <sys_trace>:


uint64 sys_trace(void) {
    80001ef4:	1101                	addi	sp,sp,-32
    80001ef6:	ec06                	sd	ra,24(sp)
    80001ef8:	e822                	sd	s0,16(sp)
    80001efa:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80001efc:	fec40593          	addi	a1,s0,-20
    80001f00:	4501                	li	a0,0
    80001f02:	d21ff0ef          	jal	80001c22 <argint>
  myproc()->trace_mask = mask;
    80001f06:	e61fe0ef          	jal	80000d66 <myproc>
    80001f0a:	fec42783          	lw	a5,-20(s0)
    80001f0e:	16f52423          	sw	a5,360(a0)
  return 0;
    80001f12:	4501                	li	a0,0
    80001f14:	60e2                	ld	ra,24(sp)
    80001f16:	6442                	ld	s0,16(sp)
    80001f18:	6105                	addi	sp,sp,32
    80001f1a:	8082                	ret

0000000080001f1c <binit>:
} bcache;

//initialize cache 
void
binit(void)
{
    80001f1c:	7179                	addi	sp,sp,-48
    80001f1e:	f406                	sd	ra,40(sp)
    80001f20:	f022                	sd	s0,32(sp)
    80001f22:	ec26                	sd	s1,24(sp)
    80001f24:	e84a                	sd	s2,16(sp)
    80001f26:	e44e                	sd	s3,8(sp)
    80001f28:	e052                	sd	s4,0(sp)
    80001f2a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache"); //initialize lock named "bcache"
    80001f2c:	00005597          	auipc	a1,0x5
    80001f30:	4c458593          	addi	a1,a1,1220 # 800073f0 <etext+0x3f0>
    80001f34:	0000e517          	auipc	a0,0xe
    80001f38:	40450513          	addi	a0,a0,1028 # 80010338 <bcache>
    80001f3c:	005030ef          	jal	80005740 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001f40:	00016797          	auipc	a5,0x16
    80001f44:	3f878793          	addi	a5,a5,1016 # 80018338 <bcache+0x8000>
    80001f48:	00016717          	auipc	a4,0x16
    80001f4c:	65870713          	addi	a4,a4,1624 # 800185a0 <bcache+0x8268>
    80001f50:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001f54:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f58:	0000e497          	auipc	s1,0xe
    80001f5c:	3f848493          	addi	s1,s1,1016 # 80010350 <bcache+0x18>
    b->next = bcache.head.next;
    80001f60:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001f62:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001f64:	00005a17          	auipc	s4,0x5
    80001f68:	494a0a13          	addi	s4,s4,1172 # 800073f8 <etext+0x3f8>
    b->next = bcache.head.next;
    80001f6c:	2b893783          	ld	a5,696(s2)
    80001f70:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001f72:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001f76:	85d2                	mv	a1,s4
    80001f78:	01048513          	addi	a0,s1,16
    80001f7c:	248010ef          	jal	800031c4 <initsleeplock>
    bcache.head.next->prev = b;
    80001f80:	2b893783          	ld	a5,696(s2)
    80001f84:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001f86:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f8a:	45848493          	addi	s1,s1,1112
    80001f8e:	fd349fe3          	bne	s1,s3,80001f6c <binit+0x50>
  }
}
    80001f92:	70a2                	ld	ra,40(sp)
    80001f94:	7402                	ld	s0,32(sp)
    80001f96:	64e2                	ld	s1,24(sp)
    80001f98:	6942                	ld	s2,16(sp)
    80001f9a:	69a2                	ld	s3,8(sp)
    80001f9c:	6a02                	ld	s4,0(sp)
    80001f9e:	6145                	addi	sp,sp,48
    80001fa0:	8082                	ret

0000000080001fa2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001fa2:	7179                	addi	sp,sp,-48
    80001fa4:	f406                	sd	ra,40(sp)
    80001fa6:	f022                	sd	s0,32(sp)
    80001fa8:	ec26                	sd	s1,24(sp)
    80001faa:	e84a                	sd	s2,16(sp)
    80001fac:	e44e                	sd	s3,8(sp)
    80001fae:	1800                	addi	s0,sp,48
    80001fb0:	892a                	mv	s2,a0
    80001fb2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80001fb4:	0000e517          	auipc	a0,0xe
    80001fb8:	38450513          	addi	a0,a0,900 # 80010338 <bcache>
    80001fbc:	005030ef          	jal	800057c0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80001fc0:	00016497          	auipc	s1,0x16
    80001fc4:	6304b483          	ld	s1,1584(s1) # 800185f0 <bcache+0x82b8>
    80001fc8:	00016797          	auipc	a5,0x16
    80001fcc:	5d878793          	addi	a5,a5,1496 # 800185a0 <bcache+0x8268>
    80001fd0:	02f48b63          	beq	s1,a5,80002006 <bread+0x64>
    80001fd4:	873e                	mv	a4,a5
    80001fd6:	a021                	j	80001fde <bread+0x3c>
    80001fd8:	68a4                	ld	s1,80(s1)
    80001fda:	02e48663          	beq	s1,a4,80002006 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80001fde:	449c                	lw	a5,8(s1)
    80001fe0:	ff279ce3          	bne	a5,s2,80001fd8 <bread+0x36>
    80001fe4:	44dc                	lw	a5,12(s1)
    80001fe6:	ff3799e3          	bne	a5,s3,80001fd8 <bread+0x36>
      b->refcnt++;
    80001fea:	40bc                	lw	a5,64(s1)
    80001fec:	2785                	addiw	a5,a5,1
    80001fee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80001ff0:	0000e517          	auipc	a0,0xe
    80001ff4:	34850513          	addi	a0,a0,840 # 80010338 <bcache>
    80001ff8:	061030ef          	jal	80005858 <release>
      acquiresleep(&b->lock);
    80001ffc:	01048513          	addi	a0,s1,16
    80002000:	1fa010ef          	jal	800031fa <acquiresleep>
      return b;
    80002004:	a889                	j	80002056 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002006:	00016497          	auipc	s1,0x16
    8000200a:	5e24b483          	ld	s1,1506(s1) # 800185e8 <bcache+0x82b0>
    8000200e:	00016797          	auipc	a5,0x16
    80002012:	59278793          	addi	a5,a5,1426 # 800185a0 <bcache+0x8268>
    80002016:	00f48863          	beq	s1,a5,80002026 <bread+0x84>
    8000201a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000201c:	40bc                	lw	a5,64(s1)
    8000201e:	cb91                	beqz	a5,80002032 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002020:	64a4                	ld	s1,72(s1)
    80002022:	fee49de3          	bne	s1,a4,8000201c <bread+0x7a>
  panic("bget: no buffers"); //if there are no available buffer call panic.
    80002026:	00005517          	auipc	a0,0x5
    8000202a:	3da50513          	addi	a0,a0,986 # 80007400 <etext+0x400>
    8000202e:	464030ef          	jal	80005492 <panic>
      b->dev = dev;
    80002032:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002036:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000203a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000203e:	4785                	li	a5,1
    80002040:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002042:	0000e517          	auipc	a0,0xe
    80002046:	2f650513          	addi	a0,a0,758 # 80010338 <bcache>
    8000204a:	00f030ef          	jal	80005858 <release>
      acquiresleep(&b->lock);
    8000204e:	01048513          	addi	a0,s1,16
    80002052:	1a8010ef          	jal	800031fa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  //check if the data is valid or not
  if(!b->valid) {
    80002056:	409c                	lw	a5,0(s1)
    80002058:	cb89                	beqz	a5,8000206a <bread+0xc8>
    virtio_disk_rw(b, 0); //write data into buffer
    b->valid = 1;
  }
  return b;
}
    8000205a:	8526                	mv	a0,s1
    8000205c:	70a2                	ld	ra,40(sp)
    8000205e:	7402                	ld	s0,32(sp)
    80002060:	64e2                	ld	s1,24(sp)
    80002062:	6942                	ld	s2,16(sp)
    80002064:	69a2                	ld	s3,8(sp)
    80002066:	6145                	addi	sp,sp,48
    80002068:	8082                	ret
    virtio_disk_rw(b, 0); //write data into buffer
    8000206a:	4581                	li	a1,0
    8000206c:	8526                	mv	a0,s1
    8000206e:	1f3020ef          	jal	80004a60 <virtio_disk_rw>
    b->valid = 1;
    80002072:	4785                	li	a5,1
    80002074:	c09c                	sw	a5,0(s1)
  return b;
    80002076:	b7d5                	j	8000205a <bread+0xb8>

0000000080002078 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Synchronize the contents of buffer b with the block on disk.
void
bwrite(struct buf *b)
{
    80002078:	1101                	addi	sp,sp,-32
    8000207a:	ec06                	sd	ra,24(sp)
    8000207c:	e822                	sd	s0,16(sp)
    8000207e:	e426                	sd	s1,8(sp)
    80002080:	1000                	addi	s0,sp,32
    80002082:	84aa                	mv	s1,a0
  //check if buffer is locked by instance process
  if(!holdingsleep(&b->lock))
    80002084:	0541                	addi	a0,a0,16
    80002086:	1f2010ef          	jal	80003278 <holdingsleep>
    8000208a:	c911                	beqz	a0,8000209e <bwrite+0x26>
    panic("bwrite"); //call panic
  virtio_disk_rw(b, 1); // write data into buffer
    8000208c:	4585                	li	a1,1
    8000208e:	8526                	mv	a0,s1
    80002090:	1d1020ef          	jal	80004a60 <virtio_disk_rw>
}
    80002094:	60e2                	ld	ra,24(sp)
    80002096:	6442                	ld	s0,16(sp)
    80002098:	64a2                	ld	s1,8(sp)
    8000209a:	6105                	addi	sp,sp,32
    8000209c:	8082                	ret
    panic("bwrite"); //call panic
    8000209e:	00005517          	auipc	a0,0x5
    800020a2:	37a50513          	addi	a0,a0,890 # 80007418 <etext+0x418>
    800020a6:	3ec030ef          	jal	80005492 <panic>

00000000800020aa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800020aa:	1101                	addi	sp,sp,-32
    800020ac:	ec06                	sd	ra,24(sp)
    800020ae:	e822                	sd	s0,16(sp)
    800020b0:	e426                	sd	s1,8(sp)
    800020b2:	e04a                	sd	s2,0(sp)
    800020b4:	1000                	addi	s0,sp,32
    800020b6:	84aa                	mv	s1,a0
  //check if buffer is lock
  if(!holdingsleep(&b->lock))
    800020b8:	01050913          	addi	s2,a0,16
    800020bc:	854a                	mv	a0,s2
    800020be:	1ba010ef          	jal	80003278 <holdingsleep>
    800020c2:	c135                	beqz	a0,80002126 <brelse+0x7c>
    panic("brelse"); // call panic
  //release lock buffer
  releasesleep(&b->lock);
    800020c4:	854a                	mv	a0,s2
    800020c6:	17a010ef          	jal	80003240 <releasesleep>

  //reduce refcnt
  acquire(&bcache.lock);
    800020ca:	0000e517          	auipc	a0,0xe
    800020ce:	26e50513          	addi	a0,a0,622 # 80010338 <bcache>
    800020d2:	6ee030ef          	jal	800057c0 <acquire>
  b->refcnt--;
    800020d6:	40bc                	lw	a5,64(s1)
    800020d8:	37fd                	addiw	a5,a5,-1
    800020da:	0007871b          	sext.w	a4,a5
    800020de:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800020e0:	e71d                	bnez	a4,8000210e <brelse+0x64>
    // no one is waiting for it and move it to LRU
    b->next->prev = b->prev;
    800020e2:	68b8                	ld	a4,80(s1)
    800020e4:	64bc                	ld	a5,72(s1)
    800020e6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800020e8:	68b8                	ld	a4,80(s1)
    800020ea:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800020ec:	00016797          	auipc	a5,0x16
    800020f0:	24c78793          	addi	a5,a5,588 # 80018338 <bcache+0x8000>
    800020f4:	2b87b703          	ld	a4,696(a5)
    800020f8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800020fa:	00016717          	auipc	a4,0x16
    800020fe:	4a670713          	addi	a4,a4,1190 # 800185a0 <bcache+0x8268>
    80002102:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002104:	2b87b703          	ld	a4,696(a5)
    80002108:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000210a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000210e:	0000e517          	auipc	a0,0xe
    80002112:	22a50513          	addi	a0,a0,554 # 80010338 <bcache>
    80002116:	742030ef          	jal	80005858 <release>
}
    8000211a:	60e2                	ld	ra,24(sp)
    8000211c:	6442                	ld	s0,16(sp)
    8000211e:	64a2                	ld	s1,8(sp)
    80002120:	6902                	ld	s2,0(sp)
    80002122:	6105                	addi	sp,sp,32
    80002124:	8082                	ret
    panic("brelse"); // call panic
    80002126:	00005517          	auipc	a0,0x5
    8000212a:	2fa50513          	addi	a0,a0,762 # 80007420 <etext+0x420>
    8000212e:	364030ef          	jal	80005492 <panic>

0000000080002132 <bpin>:

//pin buffer to prevent buffer from reusing
void
bpin(struct buf *b) {
    80002132:	1101                	addi	sp,sp,-32
    80002134:	ec06                	sd	ra,24(sp)
    80002136:	e822                	sd	s0,16(sp)
    80002138:	e426                	sd	s1,8(sp)
    8000213a:	1000                	addi	s0,sp,32
    8000213c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000213e:	0000e517          	auipc	a0,0xe
    80002142:	1fa50513          	addi	a0,a0,506 # 80010338 <bcache>
    80002146:	67a030ef          	jal	800057c0 <acquire>
  b->refcnt++;
    8000214a:	40bc                	lw	a5,64(s1)
    8000214c:	2785                	addiw	a5,a5,1
    8000214e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002150:	0000e517          	auipc	a0,0xe
    80002154:	1e850513          	addi	a0,a0,488 # 80010338 <bcache>
    80002158:	700030ef          	jal	80005858 <release>
}
    8000215c:	60e2                	ld	ra,24(sp)
    8000215e:	6442                	ld	s0,16(sp)
    80002160:	64a2                	ld	s1,8(sp)
    80002162:	6105                	addi	sp,sp,32
    80002164:	8082                	ret

0000000080002166 <bunpin>:

//unpin buffer
void
bunpin(struct buf *b) {
    80002166:	1101                	addi	sp,sp,-32
    80002168:	ec06                	sd	ra,24(sp)
    8000216a:	e822                	sd	s0,16(sp)
    8000216c:	e426                	sd	s1,8(sp)
    8000216e:	1000                	addi	s0,sp,32
    80002170:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002172:	0000e517          	auipc	a0,0xe
    80002176:	1c650513          	addi	a0,a0,454 # 80010338 <bcache>
    8000217a:	646030ef          	jal	800057c0 <acquire>
  b->refcnt--;
    8000217e:	40bc                	lw	a5,64(s1)
    80002180:	37fd                	addiw	a5,a5,-1
    80002182:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002184:	0000e517          	auipc	a0,0xe
    80002188:	1b450513          	addi	a0,a0,436 # 80010338 <bcache>
    8000218c:	6cc030ef          	jal	80005858 <release>
}
    80002190:	60e2                	ld	ra,24(sp)
    80002192:	6442                	ld	s0,16(sp)
    80002194:	64a2                	ld	s1,8(sp)
    80002196:	6105                	addi	sp,sp,32
    80002198:	8082                	ret

000000008000219a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000219a:	1101                	addi	sp,sp,-32
    8000219c:	ec06                	sd	ra,24(sp)
    8000219e:	e822                	sd	s0,16(sp)
    800021a0:	e426                	sd	s1,8(sp)
    800021a2:	e04a                	sd	s2,0(sp)
    800021a4:	1000                	addi	s0,sp,32
    800021a6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800021a8:	00d5d59b          	srliw	a1,a1,0xd
    800021ac:	00017797          	auipc	a5,0x17
    800021b0:	8687a783          	lw	a5,-1944(a5) # 80018a14 <sb+0x1c>
    800021b4:	9dbd                	addw	a1,a1,a5
    800021b6:	dedff0ef          	jal	80001fa2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800021ba:	0074f713          	andi	a4,s1,7
    800021be:	4785                	li	a5,1
    800021c0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800021c4:	14ce                	slli	s1,s1,0x33
    800021c6:	90d9                	srli	s1,s1,0x36
    800021c8:	00950733          	add	a4,a0,s1
    800021cc:	05874703          	lbu	a4,88(a4)
    800021d0:	00e7f6b3          	and	a3,a5,a4
    800021d4:	c29d                	beqz	a3,800021fa <bfree+0x60>
    800021d6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800021d8:	94aa                	add	s1,s1,a0
    800021da:	fff7c793          	not	a5,a5
    800021de:	8f7d                	and	a4,a4,a5
    800021e0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800021e4:	711000ef          	jal	800030f4 <log_write>
  brelse(bp);
    800021e8:	854a                	mv	a0,s2
    800021ea:	ec1ff0ef          	jal	800020aa <brelse>
}
    800021ee:	60e2                	ld	ra,24(sp)
    800021f0:	6442                	ld	s0,16(sp)
    800021f2:	64a2                	ld	s1,8(sp)
    800021f4:	6902                	ld	s2,0(sp)
    800021f6:	6105                	addi	sp,sp,32
    800021f8:	8082                	ret
    panic("freeing free block");
    800021fa:	00005517          	auipc	a0,0x5
    800021fe:	22e50513          	addi	a0,a0,558 # 80007428 <etext+0x428>
    80002202:	290030ef          	jal	80005492 <panic>

0000000080002206 <balloc>:
{
    80002206:	711d                	addi	sp,sp,-96
    80002208:	ec86                	sd	ra,88(sp)
    8000220a:	e8a2                	sd	s0,80(sp)
    8000220c:	e4a6                	sd	s1,72(sp)
    8000220e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002210:	00016797          	auipc	a5,0x16
    80002214:	7ec7a783          	lw	a5,2028(a5) # 800189fc <sb+0x4>
    80002218:	0e078f63          	beqz	a5,80002316 <balloc+0x110>
    8000221c:	e0ca                	sd	s2,64(sp)
    8000221e:	fc4e                	sd	s3,56(sp)
    80002220:	f852                	sd	s4,48(sp)
    80002222:	f456                	sd	s5,40(sp)
    80002224:	f05a                	sd	s6,32(sp)
    80002226:	ec5e                	sd	s7,24(sp)
    80002228:	e862                	sd	s8,16(sp)
    8000222a:	e466                	sd	s9,8(sp)
    8000222c:	8baa                	mv	s7,a0
    8000222e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002230:	00016b17          	auipc	s6,0x16
    80002234:	7c8b0b13          	addi	s6,s6,1992 # 800189f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002238:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000223a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000223c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000223e:	6c89                	lui	s9,0x2
    80002240:	a0b5                	j	800022ac <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002242:	97ca                	add	a5,a5,s2
    80002244:	8e55                	or	a2,a2,a3
    80002246:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000224a:	854a                	mv	a0,s2
    8000224c:	6a9000ef          	jal	800030f4 <log_write>
        brelse(bp);
    80002250:	854a                	mv	a0,s2
    80002252:	e59ff0ef          	jal	800020aa <brelse>
  bp = bread(dev, bno);
    80002256:	85a6                	mv	a1,s1
    80002258:	855e                	mv	a0,s7
    8000225a:	d49ff0ef          	jal	80001fa2 <bread>
    8000225e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002260:	40000613          	li	a2,1024
    80002264:	4581                	li	a1,0
    80002266:	05850513          	addi	a0,a0,88
    8000226a:	ee5fd0ef          	jal	8000014e <memset>
  log_write(bp);
    8000226e:	854a                	mv	a0,s2
    80002270:	685000ef          	jal	800030f4 <log_write>
  brelse(bp);
    80002274:	854a                	mv	a0,s2
    80002276:	e35ff0ef          	jal	800020aa <brelse>
}
    8000227a:	6906                	ld	s2,64(sp)
    8000227c:	79e2                	ld	s3,56(sp)
    8000227e:	7a42                	ld	s4,48(sp)
    80002280:	7aa2                	ld	s5,40(sp)
    80002282:	7b02                	ld	s6,32(sp)
    80002284:	6be2                	ld	s7,24(sp)
    80002286:	6c42                	ld	s8,16(sp)
    80002288:	6ca2                	ld	s9,8(sp)
}
    8000228a:	8526                	mv	a0,s1
    8000228c:	60e6                	ld	ra,88(sp)
    8000228e:	6446                	ld	s0,80(sp)
    80002290:	64a6                	ld	s1,72(sp)
    80002292:	6125                	addi	sp,sp,96
    80002294:	8082                	ret
    brelse(bp);
    80002296:	854a                	mv	a0,s2
    80002298:	e13ff0ef          	jal	800020aa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000229c:	015c87bb          	addw	a5,s9,s5
    800022a0:	00078a9b          	sext.w	s5,a5
    800022a4:	004b2703          	lw	a4,4(s6)
    800022a8:	04eaff63          	bgeu	s5,a4,80002306 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800022ac:	41fad79b          	sraiw	a5,s5,0x1f
    800022b0:	0137d79b          	srliw	a5,a5,0x13
    800022b4:	015787bb          	addw	a5,a5,s5
    800022b8:	40d7d79b          	sraiw	a5,a5,0xd
    800022bc:	01cb2583          	lw	a1,28(s6)
    800022c0:	9dbd                	addw	a1,a1,a5
    800022c2:	855e                	mv	a0,s7
    800022c4:	cdfff0ef          	jal	80001fa2 <bread>
    800022c8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022ca:	004b2503          	lw	a0,4(s6)
    800022ce:	000a849b          	sext.w	s1,s5
    800022d2:	8762                	mv	a4,s8
    800022d4:	fca4f1e3          	bgeu	s1,a0,80002296 <balloc+0x90>
      m = 1 << (bi % 8);
    800022d8:	00777693          	andi	a3,a4,7
    800022dc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800022e0:	41f7579b          	sraiw	a5,a4,0x1f
    800022e4:	01d7d79b          	srliw	a5,a5,0x1d
    800022e8:	9fb9                	addw	a5,a5,a4
    800022ea:	4037d79b          	sraiw	a5,a5,0x3
    800022ee:	00f90633          	add	a2,s2,a5
    800022f2:	05864603          	lbu	a2,88(a2)
    800022f6:	00c6f5b3          	and	a1,a3,a2
    800022fa:	d5a1                	beqz	a1,80002242 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022fc:	2705                	addiw	a4,a4,1
    800022fe:	2485                	addiw	s1,s1,1
    80002300:	fd471ae3          	bne	a4,s4,800022d4 <balloc+0xce>
    80002304:	bf49                	j	80002296 <balloc+0x90>
    80002306:	6906                	ld	s2,64(sp)
    80002308:	79e2                	ld	s3,56(sp)
    8000230a:	7a42                	ld	s4,48(sp)
    8000230c:	7aa2                	ld	s5,40(sp)
    8000230e:	7b02                	ld	s6,32(sp)
    80002310:	6be2                	ld	s7,24(sp)
    80002312:	6c42                	ld	s8,16(sp)
    80002314:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002316:	00005517          	auipc	a0,0x5
    8000231a:	12a50513          	addi	a0,a0,298 # 80007440 <etext+0x440>
    8000231e:	6a3020ef          	jal	800051c0 <printf>
  return 0;
    80002322:	4481                	li	s1,0
    80002324:	b79d                	j	8000228a <balloc+0x84>

0000000080002326 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002326:	7179                	addi	sp,sp,-48
    80002328:	f406                	sd	ra,40(sp)
    8000232a:	f022                	sd	s0,32(sp)
    8000232c:	ec26                	sd	s1,24(sp)
    8000232e:	e84a                	sd	s2,16(sp)
    80002330:	e44e                	sd	s3,8(sp)
    80002332:	1800                	addi	s0,sp,48
    80002334:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002336:	47ad                	li	a5,11
    80002338:	02b7e663          	bltu	a5,a1,80002364 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000233c:	02059793          	slli	a5,a1,0x20
    80002340:	01e7d593          	srli	a1,a5,0x1e
    80002344:	00b504b3          	add	s1,a0,a1
    80002348:	0504a903          	lw	s2,80(s1)
    8000234c:	06091a63          	bnez	s2,800023c0 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002350:	4108                	lw	a0,0(a0)
    80002352:	eb5ff0ef          	jal	80002206 <balloc>
    80002356:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000235a:	06090363          	beqz	s2,800023c0 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000235e:	0524a823          	sw	s2,80(s1)
    80002362:	a8b9                	j	800023c0 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002364:	ff45849b          	addiw	s1,a1,-12
    80002368:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000236c:	0ff00793          	li	a5,255
    80002370:	06e7ee63          	bltu	a5,a4,800023ec <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002374:	08052903          	lw	s2,128(a0)
    80002378:	00091d63          	bnez	s2,80002392 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000237c:	4108                	lw	a0,0(a0)
    8000237e:	e89ff0ef          	jal	80002206 <balloc>
    80002382:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002386:	02090d63          	beqz	s2,800023c0 <bmap+0x9a>
    8000238a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000238c:	0929a023          	sw	s2,128(s3)
    80002390:	a011                	j	80002394 <bmap+0x6e>
    80002392:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002394:	85ca                	mv	a1,s2
    80002396:	0009a503          	lw	a0,0(s3)
    8000239a:	c09ff0ef          	jal	80001fa2 <bread>
    8000239e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800023a0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800023a4:	02049713          	slli	a4,s1,0x20
    800023a8:	01e75593          	srli	a1,a4,0x1e
    800023ac:	00b784b3          	add	s1,a5,a1
    800023b0:	0004a903          	lw	s2,0(s1)
    800023b4:	00090e63          	beqz	s2,800023d0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800023b8:	8552                	mv	a0,s4
    800023ba:	cf1ff0ef          	jal	800020aa <brelse>
    return addr;
    800023be:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800023c0:	854a                	mv	a0,s2
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6145                	addi	sp,sp,48
    800023ce:	8082                	ret
      addr = balloc(ip->dev);
    800023d0:	0009a503          	lw	a0,0(s3)
    800023d4:	e33ff0ef          	jal	80002206 <balloc>
    800023d8:	0005091b          	sext.w	s2,a0
      if(addr){
    800023dc:	fc090ee3          	beqz	s2,800023b8 <bmap+0x92>
        a[bn] = addr;
    800023e0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800023e4:	8552                	mv	a0,s4
    800023e6:	50f000ef          	jal	800030f4 <log_write>
    800023ea:	b7f9                	j	800023b8 <bmap+0x92>
    800023ec:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800023ee:	00005517          	auipc	a0,0x5
    800023f2:	06a50513          	addi	a0,a0,106 # 80007458 <etext+0x458>
    800023f6:	09c030ef          	jal	80005492 <panic>

00000000800023fa <iget>:
{
    800023fa:	7179                	addi	sp,sp,-48
    800023fc:	f406                	sd	ra,40(sp)
    800023fe:	f022                	sd	s0,32(sp)
    80002400:	ec26                	sd	s1,24(sp)
    80002402:	e84a                	sd	s2,16(sp)
    80002404:	e44e                	sd	s3,8(sp)
    80002406:	e052                	sd	s4,0(sp)
    80002408:	1800                	addi	s0,sp,48
    8000240a:	89aa                	mv	s3,a0
    8000240c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000240e:	00016517          	auipc	a0,0x16
    80002412:	60a50513          	addi	a0,a0,1546 # 80018a18 <itable>
    80002416:	3aa030ef          	jal	800057c0 <acquire>
  empty = 0;
    8000241a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000241c:	00016497          	auipc	s1,0x16
    80002420:	61448493          	addi	s1,s1,1556 # 80018a30 <itable+0x18>
    80002424:	00018697          	auipc	a3,0x18
    80002428:	09c68693          	addi	a3,a3,156 # 8001a4c0 <log>
    8000242c:	a039                	j	8000243a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000242e:	02090963          	beqz	s2,80002460 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002432:	08848493          	addi	s1,s1,136
    80002436:	02d48863          	beq	s1,a3,80002466 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000243a:	449c                	lw	a5,8(s1)
    8000243c:	fef059e3          	blez	a5,8000242e <iget+0x34>
    80002440:	4098                	lw	a4,0(s1)
    80002442:	ff3716e3          	bne	a4,s3,8000242e <iget+0x34>
    80002446:	40d8                	lw	a4,4(s1)
    80002448:	ff4713e3          	bne	a4,s4,8000242e <iget+0x34>
      ip->ref++;
    8000244c:	2785                	addiw	a5,a5,1
    8000244e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002450:	00016517          	auipc	a0,0x16
    80002454:	5c850513          	addi	a0,a0,1480 # 80018a18 <itable>
    80002458:	400030ef          	jal	80005858 <release>
      return ip;
    8000245c:	8926                	mv	s2,s1
    8000245e:	a02d                	j	80002488 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002460:	fbe9                	bnez	a5,80002432 <iget+0x38>
      empty = ip;
    80002462:	8926                	mv	s2,s1
    80002464:	b7f9                	j	80002432 <iget+0x38>
  if(empty == 0)
    80002466:	02090a63          	beqz	s2,8000249a <iget+0xa0>
  ip->dev = dev;
    8000246a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000246e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002472:	4785                	li	a5,1
    80002474:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002478:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000247c:	00016517          	auipc	a0,0x16
    80002480:	59c50513          	addi	a0,a0,1436 # 80018a18 <itable>
    80002484:	3d4030ef          	jal	80005858 <release>
}
    80002488:	854a                	mv	a0,s2
    8000248a:	70a2                	ld	ra,40(sp)
    8000248c:	7402                	ld	s0,32(sp)
    8000248e:	64e2                	ld	s1,24(sp)
    80002490:	6942                	ld	s2,16(sp)
    80002492:	69a2                	ld	s3,8(sp)
    80002494:	6a02                	ld	s4,0(sp)
    80002496:	6145                	addi	sp,sp,48
    80002498:	8082                	ret
    panic("iget: no inodes");
    8000249a:	00005517          	auipc	a0,0x5
    8000249e:	fd650513          	addi	a0,a0,-42 # 80007470 <etext+0x470>
    800024a2:	7f1020ef          	jal	80005492 <panic>

00000000800024a6 <fsinit>:
fsinit(int dev) {
    800024a6:	7179                	addi	sp,sp,-48
    800024a8:	f406                	sd	ra,40(sp)
    800024aa:	f022                	sd	s0,32(sp)
    800024ac:	ec26                	sd	s1,24(sp)
    800024ae:	e84a                	sd	s2,16(sp)
    800024b0:	e44e                	sd	s3,8(sp)
    800024b2:	1800                	addi	s0,sp,48
    800024b4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800024b6:	4585                	li	a1,1
    800024b8:	aebff0ef          	jal	80001fa2 <bread>
    800024bc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800024be:	00016997          	auipc	s3,0x16
    800024c2:	53a98993          	addi	s3,s3,1338 # 800189f8 <sb>
    800024c6:	02000613          	li	a2,32
    800024ca:	05850593          	addi	a1,a0,88
    800024ce:	854e                	mv	a0,s3
    800024d0:	cdbfd0ef          	jal	800001aa <memmove>
  brelse(bp);
    800024d4:	8526                	mv	a0,s1
    800024d6:	bd5ff0ef          	jal	800020aa <brelse>
  if(sb.magic != FSMAGIC)
    800024da:	0009a703          	lw	a4,0(s3)
    800024de:	102037b7          	lui	a5,0x10203
    800024e2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800024e6:	02f71063          	bne	a4,a5,80002506 <fsinit+0x60>
  initlog(dev, &sb);
    800024ea:	00016597          	auipc	a1,0x16
    800024ee:	50e58593          	addi	a1,a1,1294 # 800189f8 <sb>
    800024f2:	854a                	mv	a0,s2
    800024f4:	1f9000ef          	jal	80002eec <initlog>
}
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    panic("invalid file system");
    80002506:	00005517          	auipc	a0,0x5
    8000250a:	f7a50513          	addi	a0,a0,-134 # 80007480 <etext+0x480>
    8000250e:	785020ef          	jal	80005492 <panic>

0000000080002512 <iinit>:
{
    80002512:	7179                	addi	sp,sp,-48
    80002514:	f406                	sd	ra,40(sp)
    80002516:	f022                	sd	s0,32(sp)
    80002518:	ec26                	sd	s1,24(sp)
    8000251a:	e84a                	sd	s2,16(sp)
    8000251c:	e44e                	sd	s3,8(sp)
    8000251e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002520:	00005597          	auipc	a1,0x5
    80002524:	f7858593          	addi	a1,a1,-136 # 80007498 <etext+0x498>
    80002528:	00016517          	auipc	a0,0x16
    8000252c:	4f050513          	addi	a0,a0,1264 # 80018a18 <itable>
    80002530:	210030ef          	jal	80005740 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002534:	00016497          	auipc	s1,0x16
    80002538:	50c48493          	addi	s1,s1,1292 # 80018a40 <itable+0x28>
    8000253c:	00018997          	auipc	s3,0x18
    80002540:	f9498993          	addi	s3,s3,-108 # 8001a4d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002544:	00005917          	auipc	s2,0x5
    80002548:	f5c90913          	addi	s2,s2,-164 # 800074a0 <etext+0x4a0>
    8000254c:	85ca                	mv	a1,s2
    8000254e:	8526                	mv	a0,s1
    80002550:	475000ef          	jal	800031c4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002554:	08848493          	addi	s1,s1,136
    80002558:	ff349ae3          	bne	s1,s3,8000254c <iinit+0x3a>
}
    8000255c:	70a2                	ld	ra,40(sp)
    8000255e:	7402                	ld	s0,32(sp)
    80002560:	64e2                	ld	s1,24(sp)
    80002562:	6942                	ld	s2,16(sp)
    80002564:	69a2                	ld	s3,8(sp)
    80002566:	6145                	addi	sp,sp,48
    80002568:	8082                	ret

000000008000256a <ialloc>:
{
    8000256a:	7139                	addi	sp,sp,-64
    8000256c:	fc06                	sd	ra,56(sp)
    8000256e:	f822                	sd	s0,48(sp)
    80002570:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002572:	00016717          	auipc	a4,0x16
    80002576:	49272703          	lw	a4,1170(a4) # 80018a04 <sb+0xc>
    8000257a:	4785                	li	a5,1
    8000257c:	06e7f063          	bgeu	a5,a4,800025dc <ialloc+0x72>
    80002580:	f426                	sd	s1,40(sp)
    80002582:	f04a                	sd	s2,32(sp)
    80002584:	ec4e                	sd	s3,24(sp)
    80002586:	e852                	sd	s4,16(sp)
    80002588:	e456                	sd	s5,8(sp)
    8000258a:	e05a                	sd	s6,0(sp)
    8000258c:	8aaa                	mv	s5,a0
    8000258e:	8b2e                	mv	s6,a1
    80002590:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002592:	00016a17          	auipc	s4,0x16
    80002596:	466a0a13          	addi	s4,s4,1126 # 800189f8 <sb>
    8000259a:	00495593          	srli	a1,s2,0x4
    8000259e:	018a2783          	lw	a5,24(s4)
    800025a2:	9dbd                	addw	a1,a1,a5
    800025a4:	8556                	mv	a0,s5
    800025a6:	9fdff0ef          	jal	80001fa2 <bread>
    800025aa:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800025ac:	05850993          	addi	s3,a0,88
    800025b0:	00f97793          	andi	a5,s2,15
    800025b4:	079a                	slli	a5,a5,0x6
    800025b6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800025b8:	00099783          	lh	a5,0(s3)
    800025bc:	cb9d                	beqz	a5,800025f2 <ialloc+0x88>
    brelse(bp);
    800025be:	aedff0ef          	jal	800020aa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800025c2:	0905                	addi	s2,s2,1
    800025c4:	00ca2703          	lw	a4,12(s4)
    800025c8:	0009079b          	sext.w	a5,s2
    800025cc:	fce7e7e3          	bltu	a5,a4,8000259a <ialloc+0x30>
    800025d0:	74a2                	ld	s1,40(sp)
    800025d2:	7902                	ld	s2,32(sp)
    800025d4:	69e2                	ld	s3,24(sp)
    800025d6:	6a42                	ld	s4,16(sp)
    800025d8:	6aa2                	ld	s5,8(sp)
    800025da:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800025dc:	00005517          	auipc	a0,0x5
    800025e0:	ecc50513          	addi	a0,a0,-308 # 800074a8 <etext+0x4a8>
    800025e4:	3dd020ef          	jal	800051c0 <printf>
  return 0;
    800025e8:	4501                	li	a0,0
}
    800025ea:	70e2                	ld	ra,56(sp)
    800025ec:	7442                	ld	s0,48(sp)
    800025ee:	6121                	addi	sp,sp,64
    800025f0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800025f2:	04000613          	li	a2,64
    800025f6:	4581                	li	a1,0
    800025f8:	854e                	mv	a0,s3
    800025fa:	b55fd0ef          	jal	8000014e <memset>
      dip->type = type;
    800025fe:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002602:	8526                	mv	a0,s1
    80002604:	2f1000ef          	jal	800030f4 <log_write>
      brelse(bp);
    80002608:	8526                	mv	a0,s1
    8000260a:	aa1ff0ef          	jal	800020aa <brelse>
      return iget(dev, inum);
    8000260e:	0009059b          	sext.w	a1,s2
    80002612:	8556                	mv	a0,s5
    80002614:	de7ff0ef          	jal	800023fa <iget>
    80002618:	74a2                	ld	s1,40(sp)
    8000261a:	7902                	ld	s2,32(sp)
    8000261c:	69e2                	ld	s3,24(sp)
    8000261e:	6a42                	ld	s4,16(sp)
    80002620:	6aa2                	ld	s5,8(sp)
    80002622:	6b02                	ld	s6,0(sp)
    80002624:	b7d9                	j	800025ea <ialloc+0x80>

0000000080002626 <iupdate>:
{
    80002626:	1101                	addi	sp,sp,-32
    80002628:	ec06                	sd	ra,24(sp)
    8000262a:	e822                	sd	s0,16(sp)
    8000262c:	e426                	sd	s1,8(sp)
    8000262e:	e04a                	sd	s2,0(sp)
    80002630:	1000                	addi	s0,sp,32
    80002632:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002634:	415c                	lw	a5,4(a0)
    80002636:	0047d79b          	srliw	a5,a5,0x4
    8000263a:	00016597          	auipc	a1,0x16
    8000263e:	3d65a583          	lw	a1,982(a1) # 80018a10 <sb+0x18>
    80002642:	9dbd                	addw	a1,a1,a5
    80002644:	4108                	lw	a0,0(a0)
    80002646:	95dff0ef          	jal	80001fa2 <bread>
    8000264a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000264c:	05850793          	addi	a5,a0,88
    80002650:	40d8                	lw	a4,4(s1)
    80002652:	8b3d                	andi	a4,a4,15
    80002654:	071a                	slli	a4,a4,0x6
    80002656:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002658:	04449703          	lh	a4,68(s1)
    8000265c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002660:	04649703          	lh	a4,70(s1)
    80002664:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002668:	04849703          	lh	a4,72(s1)
    8000266c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002670:	04a49703          	lh	a4,74(s1)
    80002674:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002678:	44f8                	lw	a4,76(s1)
    8000267a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000267c:	03400613          	li	a2,52
    80002680:	05048593          	addi	a1,s1,80
    80002684:	00c78513          	addi	a0,a5,12
    80002688:	b23fd0ef          	jal	800001aa <memmove>
  log_write(bp);
    8000268c:	854a                	mv	a0,s2
    8000268e:	267000ef          	jal	800030f4 <log_write>
  brelse(bp);
    80002692:	854a                	mv	a0,s2
    80002694:	a17ff0ef          	jal	800020aa <brelse>
}
    80002698:	60e2                	ld	ra,24(sp)
    8000269a:	6442                	ld	s0,16(sp)
    8000269c:	64a2                	ld	s1,8(sp)
    8000269e:	6902                	ld	s2,0(sp)
    800026a0:	6105                	addi	sp,sp,32
    800026a2:	8082                	ret

00000000800026a4 <idup>:
{
    800026a4:	1101                	addi	sp,sp,-32
    800026a6:	ec06                	sd	ra,24(sp)
    800026a8:	e822                	sd	s0,16(sp)
    800026aa:	e426                	sd	s1,8(sp)
    800026ac:	1000                	addi	s0,sp,32
    800026ae:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800026b0:	00016517          	auipc	a0,0x16
    800026b4:	36850513          	addi	a0,a0,872 # 80018a18 <itable>
    800026b8:	108030ef          	jal	800057c0 <acquire>
  ip->ref++;
    800026bc:	449c                	lw	a5,8(s1)
    800026be:	2785                	addiw	a5,a5,1
    800026c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800026c2:	00016517          	auipc	a0,0x16
    800026c6:	35650513          	addi	a0,a0,854 # 80018a18 <itable>
    800026ca:	18e030ef          	jal	80005858 <release>
}
    800026ce:	8526                	mv	a0,s1
    800026d0:	60e2                	ld	ra,24(sp)
    800026d2:	6442                	ld	s0,16(sp)
    800026d4:	64a2                	ld	s1,8(sp)
    800026d6:	6105                	addi	sp,sp,32
    800026d8:	8082                	ret

00000000800026da <ilock>:
{
    800026da:	1101                	addi	sp,sp,-32
    800026dc:	ec06                	sd	ra,24(sp)
    800026de:	e822                	sd	s0,16(sp)
    800026e0:	e426                	sd	s1,8(sp)
    800026e2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800026e4:	cd19                	beqz	a0,80002702 <ilock+0x28>
    800026e6:	84aa                	mv	s1,a0
    800026e8:	451c                	lw	a5,8(a0)
    800026ea:	00f05c63          	blez	a5,80002702 <ilock+0x28>
  acquiresleep(&ip->lock);
    800026ee:	0541                	addi	a0,a0,16
    800026f0:	30b000ef          	jal	800031fa <acquiresleep>
  if(ip->valid == 0){
    800026f4:	40bc                	lw	a5,64(s1)
    800026f6:	cf89                	beqz	a5,80002710 <ilock+0x36>
}
    800026f8:	60e2                	ld	ra,24(sp)
    800026fa:	6442                	ld	s0,16(sp)
    800026fc:	64a2                	ld	s1,8(sp)
    800026fe:	6105                	addi	sp,sp,32
    80002700:	8082                	ret
    80002702:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80002704:	00005517          	auipc	a0,0x5
    80002708:	dbc50513          	addi	a0,a0,-580 # 800074c0 <etext+0x4c0>
    8000270c:	587020ef          	jal	80005492 <panic>
    80002710:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002712:	40dc                	lw	a5,4(s1)
    80002714:	0047d79b          	srliw	a5,a5,0x4
    80002718:	00016597          	auipc	a1,0x16
    8000271c:	2f85a583          	lw	a1,760(a1) # 80018a10 <sb+0x18>
    80002720:	9dbd                	addw	a1,a1,a5
    80002722:	4088                	lw	a0,0(s1)
    80002724:	87fff0ef          	jal	80001fa2 <bread>
    80002728:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000272a:	05850593          	addi	a1,a0,88
    8000272e:	40dc                	lw	a5,4(s1)
    80002730:	8bbd                	andi	a5,a5,15
    80002732:	079a                	slli	a5,a5,0x6
    80002734:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002736:	00059783          	lh	a5,0(a1)
    8000273a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000273e:	00259783          	lh	a5,2(a1)
    80002742:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002746:	00459783          	lh	a5,4(a1)
    8000274a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000274e:	00659783          	lh	a5,6(a1)
    80002752:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002756:	459c                	lw	a5,8(a1)
    80002758:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000275a:	03400613          	li	a2,52
    8000275e:	05b1                	addi	a1,a1,12
    80002760:	05048513          	addi	a0,s1,80
    80002764:	a47fd0ef          	jal	800001aa <memmove>
    brelse(bp);
    80002768:	854a                	mv	a0,s2
    8000276a:	941ff0ef          	jal	800020aa <brelse>
    ip->valid = 1;
    8000276e:	4785                	li	a5,1
    80002770:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002772:	04449783          	lh	a5,68(s1)
    80002776:	c399                	beqz	a5,8000277c <ilock+0xa2>
    80002778:	6902                	ld	s2,0(sp)
    8000277a:	bfbd                	j	800026f8 <ilock+0x1e>
      panic("ilock: no type");
    8000277c:	00005517          	auipc	a0,0x5
    80002780:	d4c50513          	addi	a0,a0,-692 # 800074c8 <etext+0x4c8>
    80002784:	50f020ef          	jal	80005492 <panic>

0000000080002788 <iunlock>:
{
    80002788:	1101                	addi	sp,sp,-32
    8000278a:	ec06                	sd	ra,24(sp)
    8000278c:	e822                	sd	s0,16(sp)
    8000278e:	e426                	sd	s1,8(sp)
    80002790:	e04a                	sd	s2,0(sp)
    80002792:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002794:	c505                	beqz	a0,800027bc <iunlock+0x34>
    80002796:	84aa                	mv	s1,a0
    80002798:	01050913          	addi	s2,a0,16
    8000279c:	854a                	mv	a0,s2
    8000279e:	2db000ef          	jal	80003278 <holdingsleep>
    800027a2:	cd09                	beqz	a0,800027bc <iunlock+0x34>
    800027a4:	449c                	lw	a5,8(s1)
    800027a6:	00f05b63          	blez	a5,800027bc <iunlock+0x34>
  releasesleep(&ip->lock);
    800027aa:	854a                	mv	a0,s2
    800027ac:	295000ef          	jal	80003240 <releasesleep>
}
    800027b0:	60e2                	ld	ra,24(sp)
    800027b2:	6442                	ld	s0,16(sp)
    800027b4:	64a2                	ld	s1,8(sp)
    800027b6:	6902                	ld	s2,0(sp)
    800027b8:	6105                	addi	sp,sp,32
    800027ba:	8082                	ret
    panic("iunlock");
    800027bc:	00005517          	auipc	a0,0x5
    800027c0:	d1c50513          	addi	a0,a0,-740 # 800074d8 <etext+0x4d8>
    800027c4:	4cf020ef          	jal	80005492 <panic>

00000000800027c8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800027c8:	7179                	addi	sp,sp,-48
    800027ca:	f406                	sd	ra,40(sp)
    800027cc:	f022                	sd	s0,32(sp)
    800027ce:	ec26                	sd	s1,24(sp)
    800027d0:	e84a                	sd	s2,16(sp)
    800027d2:	e44e                	sd	s3,8(sp)
    800027d4:	1800                	addi	s0,sp,48
    800027d6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800027d8:	05050493          	addi	s1,a0,80
    800027dc:	08050913          	addi	s2,a0,128
    800027e0:	a021                	j	800027e8 <itrunc+0x20>
    800027e2:	0491                	addi	s1,s1,4
    800027e4:	01248b63          	beq	s1,s2,800027fa <itrunc+0x32>
    if(ip->addrs[i]){
    800027e8:	408c                	lw	a1,0(s1)
    800027ea:	dde5                	beqz	a1,800027e2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800027ec:	0009a503          	lw	a0,0(s3)
    800027f0:	9abff0ef          	jal	8000219a <bfree>
      ip->addrs[i] = 0;
    800027f4:	0004a023          	sw	zero,0(s1)
    800027f8:	b7ed                	j	800027e2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800027fa:	0809a583          	lw	a1,128(s3)
    800027fe:	ed89                	bnez	a1,80002818 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002800:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002804:	854e                	mv	a0,s3
    80002806:	e21ff0ef          	jal	80002626 <iupdate>
}
    8000280a:	70a2                	ld	ra,40(sp)
    8000280c:	7402                	ld	s0,32(sp)
    8000280e:	64e2                	ld	s1,24(sp)
    80002810:	6942                	ld	s2,16(sp)
    80002812:	69a2                	ld	s3,8(sp)
    80002814:	6145                	addi	sp,sp,48
    80002816:	8082                	ret
    80002818:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000281a:	0009a503          	lw	a0,0(s3)
    8000281e:	f84ff0ef          	jal	80001fa2 <bread>
    80002822:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002824:	05850493          	addi	s1,a0,88
    80002828:	45850913          	addi	s2,a0,1112
    8000282c:	a021                	j	80002834 <itrunc+0x6c>
    8000282e:	0491                	addi	s1,s1,4
    80002830:	01248963          	beq	s1,s2,80002842 <itrunc+0x7a>
      if(a[j])
    80002834:	408c                	lw	a1,0(s1)
    80002836:	dde5                	beqz	a1,8000282e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002838:	0009a503          	lw	a0,0(s3)
    8000283c:	95fff0ef          	jal	8000219a <bfree>
    80002840:	b7fd                	j	8000282e <itrunc+0x66>
    brelse(bp);
    80002842:	8552                	mv	a0,s4
    80002844:	867ff0ef          	jal	800020aa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002848:	0809a583          	lw	a1,128(s3)
    8000284c:	0009a503          	lw	a0,0(s3)
    80002850:	94bff0ef          	jal	8000219a <bfree>
    ip->addrs[NDIRECT] = 0;
    80002854:	0809a023          	sw	zero,128(s3)
    80002858:	6a02                	ld	s4,0(sp)
    8000285a:	b75d                	j	80002800 <itrunc+0x38>

000000008000285c <iput>:
{
    8000285c:	1101                	addi	sp,sp,-32
    8000285e:	ec06                	sd	ra,24(sp)
    80002860:	e822                	sd	s0,16(sp)
    80002862:	e426                	sd	s1,8(sp)
    80002864:	1000                	addi	s0,sp,32
    80002866:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002868:	00016517          	auipc	a0,0x16
    8000286c:	1b050513          	addi	a0,a0,432 # 80018a18 <itable>
    80002870:	751020ef          	jal	800057c0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002874:	4498                	lw	a4,8(s1)
    80002876:	4785                	li	a5,1
    80002878:	02f70063          	beq	a4,a5,80002898 <iput+0x3c>
  ip->ref--;
    8000287c:	449c                	lw	a5,8(s1)
    8000287e:	37fd                	addiw	a5,a5,-1
    80002880:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002882:	00016517          	auipc	a0,0x16
    80002886:	19650513          	addi	a0,a0,406 # 80018a18 <itable>
    8000288a:	7cf020ef          	jal	80005858 <release>
}
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6105                	addi	sp,sp,32
    80002896:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002898:	40bc                	lw	a5,64(s1)
    8000289a:	d3ed                	beqz	a5,8000287c <iput+0x20>
    8000289c:	04a49783          	lh	a5,74(s1)
    800028a0:	fff1                	bnez	a5,8000287c <iput+0x20>
    800028a2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800028a4:	01048913          	addi	s2,s1,16
    800028a8:	854a                	mv	a0,s2
    800028aa:	151000ef          	jal	800031fa <acquiresleep>
    release(&itable.lock);
    800028ae:	00016517          	auipc	a0,0x16
    800028b2:	16a50513          	addi	a0,a0,362 # 80018a18 <itable>
    800028b6:	7a3020ef          	jal	80005858 <release>
    itrunc(ip);
    800028ba:	8526                	mv	a0,s1
    800028bc:	f0dff0ef          	jal	800027c8 <itrunc>
    ip->type = 0;
    800028c0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800028c4:	8526                	mv	a0,s1
    800028c6:	d61ff0ef          	jal	80002626 <iupdate>
    ip->valid = 0;
    800028ca:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800028ce:	854a                	mv	a0,s2
    800028d0:	171000ef          	jal	80003240 <releasesleep>
    acquire(&itable.lock);
    800028d4:	00016517          	auipc	a0,0x16
    800028d8:	14450513          	addi	a0,a0,324 # 80018a18 <itable>
    800028dc:	6e5020ef          	jal	800057c0 <acquire>
    800028e0:	6902                	ld	s2,0(sp)
    800028e2:	bf69                	j	8000287c <iput+0x20>

00000000800028e4 <iunlockput>:
{
    800028e4:	1101                	addi	sp,sp,-32
    800028e6:	ec06                	sd	ra,24(sp)
    800028e8:	e822                	sd	s0,16(sp)
    800028ea:	e426                	sd	s1,8(sp)
    800028ec:	1000                	addi	s0,sp,32
    800028ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800028f0:	e99ff0ef          	jal	80002788 <iunlock>
  iput(ip);
    800028f4:	8526                	mv	a0,s1
    800028f6:	f67ff0ef          	jal	8000285c <iput>
}
    800028fa:	60e2                	ld	ra,24(sp)
    800028fc:	6442                	ld	s0,16(sp)
    800028fe:	64a2                	ld	s1,8(sp)
    80002900:	6105                	addi	sp,sp,32
    80002902:	8082                	ret

0000000080002904 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002904:	1141                	addi	sp,sp,-16
    80002906:	e422                	sd	s0,8(sp)
    80002908:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000290a:	411c                	lw	a5,0(a0)
    8000290c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000290e:	415c                	lw	a5,4(a0)
    80002910:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002912:	04451783          	lh	a5,68(a0)
    80002916:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000291a:	04a51783          	lh	a5,74(a0)
    8000291e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002922:	04c56783          	lwu	a5,76(a0)
    80002926:	e99c                	sd	a5,16(a1)
}
    80002928:	6422                	ld	s0,8(sp)
    8000292a:	0141                	addi	sp,sp,16
    8000292c:	8082                	ret

000000008000292e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000292e:	457c                	lw	a5,76(a0)
    80002930:	0ed7eb63          	bltu	a5,a3,80002a26 <readi+0xf8>
{
    80002934:	7159                	addi	sp,sp,-112
    80002936:	f486                	sd	ra,104(sp)
    80002938:	f0a2                	sd	s0,96(sp)
    8000293a:	eca6                	sd	s1,88(sp)
    8000293c:	e0d2                	sd	s4,64(sp)
    8000293e:	fc56                	sd	s5,56(sp)
    80002940:	f85a                	sd	s6,48(sp)
    80002942:	f45e                	sd	s7,40(sp)
    80002944:	1880                	addi	s0,sp,112
    80002946:	8b2a                	mv	s6,a0
    80002948:	8bae                	mv	s7,a1
    8000294a:	8a32                	mv	s4,a2
    8000294c:	84b6                	mv	s1,a3
    8000294e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002950:	9f35                	addw	a4,a4,a3
    return 0;
    80002952:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002954:	0cd76063          	bltu	a4,a3,80002a14 <readi+0xe6>
    80002958:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000295a:	00e7f463          	bgeu	a5,a4,80002962 <readi+0x34>
    n = ip->size - off;
    8000295e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002962:	080a8f63          	beqz	s5,80002a00 <readi+0xd2>
    80002966:	e8ca                	sd	s2,80(sp)
    80002968:	f062                	sd	s8,32(sp)
    8000296a:	ec66                	sd	s9,24(sp)
    8000296c:	e86a                	sd	s10,16(sp)
    8000296e:	e46e                	sd	s11,8(sp)
    80002970:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002972:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002976:	5c7d                	li	s8,-1
    80002978:	a80d                	j	800029aa <readi+0x7c>
    8000297a:	020d1d93          	slli	s11,s10,0x20
    8000297e:	020ddd93          	srli	s11,s11,0x20
    80002982:	05890613          	addi	a2,s2,88
    80002986:	86ee                	mv	a3,s11
    80002988:	963a                	add	a2,a2,a4
    8000298a:	85d2                	mv	a1,s4
    8000298c:	855e                	mv	a0,s7
    8000298e:	d0bfe0ef          	jal	80001698 <either_copyout>
    80002992:	05850763          	beq	a0,s8,800029e0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002996:	854a                	mv	a0,s2
    80002998:	f12ff0ef          	jal	800020aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000299c:	013d09bb          	addw	s3,s10,s3
    800029a0:	009d04bb          	addw	s1,s10,s1
    800029a4:	9a6e                	add	s4,s4,s11
    800029a6:	0559f763          	bgeu	s3,s5,800029f4 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800029aa:	00a4d59b          	srliw	a1,s1,0xa
    800029ae:	855a                	mv	a0,s6
    800029b0:	977ff0ef          	jal	80002326 <bmap>
    800029b4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800029b8:	c5b1                	beqz	a1,80002a04 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800029ba:	000b2503          	lw	a0,0(s6)
    800029be:	de4ff0ef          	jal	80001fa2 <bread>
    800029c2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800029c4:	3ff4f713          	andi	a4,s1,1023
    800029c8:	40ec87bb          	subw	a5,s9,a4
    800029cc:	413a86bb          	subw	a3,s5,s3
    800029d0:	8d3e                	mv	s10,a5
    800029d2:	2781                	sext.w	a5,a5
    800029d4:	0006861b          	sext.w	a2,a3
    800029d8:	faf671e3          	bgeu	a2,a5,8000297a <readi+0x4c>
    800029dc:	8d36                	mv	s10,a3
    800029de:	bf71                	j	8000297a <readi+0x4c>
      brelse(bp);
    800029e0:	854a                	mv	a0,s2
    800029e2:	ec8ff0ef          	jal	800020aa <brelse>
      tot = -1;
    800029e6:	59fd                	li	s3,-1
      break;
    800029e8:	6946                	ld	s2,80(sp)
    800029ea:	7c02                	ld	s8,32(sp)
    800029ec:	6ce2                	ld	s9,24(sp)
    800029ee:	6d42                	ld	s10,16(sp)
    800029f0:	6da2                	ld	s11,8(sp)
    800029f2:	a831                	j	80002a0e <readi+0xe0>
    800029f4:	6946                	ld	s2,80(sp)
    800029f6:	7c02                	ld	s8,32(sp)
    800029f8:	6ce2                	ld	s9,24(sp)
    800029fa:	6d42                	ld	s10,16(sp)
    800029fc:	6da2                	ld	s11,8(sp)
    800029fe:	a801                	j	80002a0e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a00:	89d6                	mv	s3,s5
    80002a02:	a031                	j	80002a0e <readi+0xe0>
    80002a04:	6946                	ld	s2,80(sp)
    80002a06:	7c02                	ld	s8,32(sp)
    80002a08:	6ce2                	ld	s9,24(sp)
    80002a0a:	6d42                	ld	s10,16(sp)
    80002a0c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002a0e:	0009851b          	sext.w	a0,s3
    80002a12:	69a6                	ld	s3,72(sp)
}
    80002a14:	70a6                	ld	ra,104(sp)
    80002a16:	7406                	ld	s0,96(sp)
    80002a18:	64e6                	ld	s1,88(sp)
    80002a1a:	6a06                	ld	s4,64(sp)
    80002a1c:	7ae2                	ld	s5,56(sp)
    80002a1e:	7b42                	ld	s6,48(sp)
    80002a20:	7ba2                	ld	s7,40(sp)
    80002a22:	6165                	addi	sp,sp,112
    80002a24:	8082                	ret
    return 0;
    80002a26:	4501                	li	a0,0
}
    80002a28:	8082                	ret

0000000080002a2a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a2a:	457c                	lw	a5,76(a0)
    80002a2c:	10d7e063          	bltu	a5,a3,80002b2c <writei+0x102>
{
    80002a30:	7159                	addi	sp,sp,-112
    80002a32:	f486                	sd	ra,104(sp)
    80002a34:	f0a2                	sd	s0,96(sp)
    80002a36:	e8ca                	sd	s2,80(sp)
    80002a38:	e0d2                	sd	s4,64(sp)
    80002a3a:	fc56                	sd	s5,56(sp)
    80002a3c:	f85a                	sd	s6,48(sp)
    80002a3e:	f45e                	sd	s7,40(sp)
    80002a40:	1880                	addi	s0,sp,112
    80002a42:	8aaa                	mv	s5,a0
    80002a44:	8bae                	mv	s7,a1
    80002a46:	8a32                	mv	s4,a2
    80002a48:	8936                	mv	s2,a3
    80002a4a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002a4c:	00e687bb          	addw	a5,a3,a4
    80002a50:	0ed7e063          	bltu	a5,a3,80002b30 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002a54:	00043737          	lui	a4,0x43
    80002a58:	0cf76e63          	bltu	a4,a5,80002b34 <writei+0x10a>
    80002a5c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a5e:	0a0b0f63          	beqz	s6,80002b1c <writei+0xf2>
    80002a62:	eca6                	sd	s1,88(sp)
    80002a64:	f062                	sd	s8,32(sp)
    80002a66:	ec66                	sd	s9,24(sp)
    80002a68:	e86a                	sd	s10,16(sp)
    80002a6a:	e46e                	sd	s11,8(sp)
    80002a6c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a6e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002a72:	5c7d                	li	s8,-1
    80002a74:	a825                	j	80002aac <writei+0x82>
    80002a76:	020d1d93          	slli	s11,s10,0x20
    80002a7a:	020ddd93          	srli	s11,s11,0x20
    80002a7e:	05848513          	addi	a0,s1,88
    80002a82:	86ee                	mv	a3,s11
    80002a84:	8652                	mv	a2,s4
    80002a86:	85de                	mv	a1,s7
    80002a88:	953a                	add	a0,a0,a4
    80002a8a:	c59fe0ef          	jal	800016e2 <either_copyin>
    80002a8e:	05850a63          	beq	a0,s8,80002ae2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002a92:	8526                	mv	a0,s1
    80002a94:	660000ef          	jal	800030f4 <log_write>
    brelse(bp);
    80002a98:	8526                	mv	a0,s1
    80002a9a:	e10ff0ef          	jal	800020aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a9e:	013d09bb          	addw	s3,s10,s3
    80002aa2:	012d093b          	addw	s2,s10,s2
    80002aa6:	9a6e                	add	s4,s4,s11
    80002aa8:	0569f063          	bgeu	s3,s6,80002ae8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002aac:	00a9559b          	srliw	a1,s2,0xa
    80002ab0:	8556                	mv	a0,s5
    80002ab2:	875ff0ef          	jal	80002326 <bmap>
    80002ab6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002aba:	c59d                	beqz	a1,80002ae8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002abc:	000aa503          	lw	a0,0(s5)
    80002ac0:	ce2ff0ef          	jal	80001fa2 <bread>
    80002ac4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ac6:	3ff97713          	andi	a4,s2,1023
    80002aca:	40ec87bb          	subw	a5,s9,a4
    80002ace:	413b06bb          	subw	a3,s6,s3
    80002ad2:	8d3e                	mv	s10,a5
    80002ad4:	2781                	sext.w	a5,a5
    80002ad6:	0006861b          	sext.w	a2,a3
    80002ada:	f8f67ee3          	bgeu	a2,a5,80002a76 <writei+0x4c>
    80002ade:	8d36                	mv	s10,a3
    80002ae0:	bf59                	j	80002a76 <writei+0x4c>
      brelse(bp);
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	dc6ff0ef          	jal	800020aa <brelse>
  }

  if(off > ip->size)
    80002ae8:	04caa783          	lw	a5,76(s5)
    80002aec:	0327fa63          	bgeu	a5,s2,80002b20 <writei+0xf6>
    ip->size = off;
    80002af0:	052aa623          	sw	s2,76(s5)
    80002af4:	64e6                	ld	s1,88(sp)
    80002af6:	7c02                	ld	s8,32(sp)
    80002af8:	6ce2                	ld	s9,24(sp)
    80002afa:	6d42                	ld	s10,16(sp)
    80002afc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002afe:	8556                	mv	a0,s5
    80002b00:	b27ff0ef          	jal	80002626 <iupdate>

  return tot;
    80002b04:	0009851b          	sext.w	a0,s3
    80002b08:	69a6                	ld	s3,72(sp)
}
    80002b0a:	70a6                	ld	ra,104(sp)
    80002b0c:	7406                	ld	s0,96(sp)
    80002b0e:	6946                	ld	s2,80(sp)
    80002b10:	6a06                	ld	s4,64(sp)
    80002b12:	7ae2                	ld	s5,56(sp)
    80002b14:	7b42                	ld	s6,48(sp)
    80002b16:	7ba2                	ld	s7,40(sp)
    80002b18:	6165                	addi	sp,sp,112
    80002b1a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b1c:	89da                	mv	s3,s6
    80002b1e:	b7c5                	j	80002afe <writei+0xd4>
    80002b20:	64e6                	ld	s1,88(sp)
    80002b22:	7c02                	ld	s8,32(sp)
    80002b24:	6ce2                	ld	s9,24(sp)
    80002b26:	6d42                	ld	s10,16(sp)
    80002b28:	6da2                	ld	s11,8(sp)
    80002b2a:	bfd1                	j	80002afe <writei+0xd4>
    return -1;
    80002b2c:	557d                	li	a0,-1
}
    80002b2e:	8082                	ret
    return -1;
    80002b30:	557d                	li	a0,-1
    80002b32:	bfe1                	j	80002b0a <writei+0xe0>
    return -1;
    80002b34:	557d                	li	a0,-1
    80002b36:	bfd1                	j	80002b0a <writei+0xe0>

0000000080002b38 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002b38:	1141                	addi	sp,sp,-16
    80002b3a:	e406                	sd	ra,8(sp)
    80002b3c:	e022                	sd	s0,0(sp)
    80002b3e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002b40:	4639                	li	a2,14
    80002b42:	ed8fd0ef          	jal	8000021a <strncmp>
}
    80002b46:	60a2                	ld	ra,8(sp)
    80002b48:	6402                	ld	s0,0(sp)
    80002b4a:	0141                	addi	sp,sp,16
    80002b4c:	8082                	ret

0000000080002b4e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002b4e:	7139                	addi	sp,sp,-64
    80002b50:	fc06                	sd	ra,56(sp)
    80002b52:	f822                	sd	s0,48(sp)
    80002b54:	f426                	sd	s1,40(sp)
    80002b56:	f04a                	sd	s2,32(sp)
    80002b58:	ec4e                	sd	s3,24(sp)
    80002b5a:	e852                	sd	s4,16(sp)
    80002b5c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002b5e:	04451703          	lh	a4,68(a0)
    80002b62:	4785                	li	a5,1
    80002b64:	00f71a63          	bne	a4,a5,80002b78 <dirlookup+0x2a>
    80002b68:	892a                	mv	s2,a0
    80002b6a:	89ae                	mv	s3,a1
    80002b6c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b6e:	457c                	lw	a5,76(a0)
    80002b70:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002b72:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b74:	e39d                	bnez	a5,80002b9a <dirlookup+0x4c>
    80002b76:	a095                	j	80002bda <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002b78:	00005517          	auipc	a0,0x5
    80002b7c:	96850513          	addi	a0,a0,-1688 # 800074e0 <etext+0x4e0>
    80002b80:	113020ef          	jal	80005492 <panic>
      panic("dirlookup read");
    80002b84:	00005517          	auipc	a0,0x5
    80002b88:	97450513          	addi	a0,a0,-1676 # 800074f8 <etext+0x4f8>
    80002b8c:	107020ef          	jal	80005492 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b90:	24c1                	addiw	s1,s1,16
    80002b92:	04c92783          	lw	a5,76(s2)
    80002b96:	04f4f163          	bgeu	s1,a5,80002bd8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002b9a:	4741                	li	a4,16
    80002b9c:	86a6                	mv	a3,s1
    80002b9e:	fc040613          	addi	a2,s0,-64
    80002ba2:	4581                	li	a1,0
    80002ba4:	854a                	mv	a0,s2
    80002ba6:	d89ff0ef          	jal	8000292e <readi>
    80002baa:	47c1                	li	a5,16
    80002bac:	fcf51ce3          	bne	a0,a5,80002b84 <dirlookup+0x36>
    if(de.inum == 0)
    80002bb0:	fc045783          	lhu	a5,-64(s0)
    80002bb4:	dff1                	beqz	a5,80002b90 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002bb6:	fc240593          	addi	a1,s0,-62
    80002bba:	854e                	mv	a0,s3
    80002bbc:	f7dff0ef          	jal	80002b38 <namecmp>
    80002bc0:	f961                	bnez	a0,80002b90 <dirlookup+0x42>
      if(poff)
    80002bc2:	000a0463          	beqz	s4,80002bca <dirlookup+0x7c>
        *poff = off;
    80002bc6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002bca:	fc045583          	lhu	a1,-64(s0)
    80002bce:	00092503          	lw	a0,0(s2)
    80002bd2:	829ff0ef          	jal	800023fa <iget>
    80002bd6:	a011                	j	80002bda <dirlookup+0x8c>
  return 0;
    80002bd8:	4501                	li	a0,0
}
    80002bda:	70e2                	ld	ra,56(sp)
    80002bdc:	7442                	ld	s0,48(sp)
    80002bde:	74a2                	ld	s1,40(sp)
    80002be0:	7902                	ld	s2,32(sp)
    80002be2:	69e2                	ld	s3,24(sp)
    80002be4:	6a42                	ld	s4,16(sp)
    80002be6:	6121                	addi	sp,sp,64
    80002be8:	8082                	ret

0000000080002bea <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002bea:	711d                	addi	sp,sp,-96
    80002bec:	ec86                	sd	ra,88(sp)
    80002bee:	e8a2                	sd	s0,80(sp)
    80002bf0:	e4a6                	sd	s1,72(sp)
    80002bf2:	e0ca                	sd	s2,64(sp)
    80002bf4:	fc4e                	sd	s3,56(sp)
    80002bf6:	f852                	sd	s4,48(sp)
    80002bf8:	f456                	sd	s5,40(sp)
    80002bfa:	f05a                	sd	s6,32(sp)
    80002bfc:	ec5e                	sd	s7,24(sp)
    80002bfe:	e862                	sd	s8,16(sp)
    80002c00:	e466                	sd	s9,8(sp)
    80002c02:	1080                	addi	s0,sp,96
    80002c04:	84aa                	mv	s1,a0
    80002c06:	8b2e                	mv	s6,a1
    80002c08:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002c0a:	00054703          	lbu	a4,0(a0)
    80002c0e:	02f00793          	li	a5,47
    80002c12:	00f70e63          	beq	a4,a5,80002c2e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002c16:	950fe0ef          	jal	80000d66 <myproc>
    80002c1a:	15053503          	ld	a0,336(a0)
    80002c1e:	a87ff0ef          	jal	800026a4 <idup>
    80002c22:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002c24:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002c28:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002c2a:	4b85                	li	s7,1
    80002c2c:	a871                	j	80002cc8 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002c2e:	4585                	li	a1,1
    80002c30:	4505                	li	a0,1
    80002c32:	fc8ff0ef          	jal	800023fa <iget>
    80002c36:	8a2a                	mv	s4,a0
    80002c38:	b7f5                	j	80002c24 <namex+0x3a>
      iunlockput(ip);
    80002c3a:	8552                	mv	a0,s4
    80002c3c:	ca9ff0ef          	jal	800028e4 <iunlockput>
      return 0;
    80002c40:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002c42:	8552                	mv	a0,s4
    80002c44:	60e6                	ld	ra,88(sp)
    80002c46:	6446                	ld	s0,80(sp)
    80002c48:	64a6                	ld	s1,72(sp)
    80002c4a:	6906                	ld	s2,64(sp)
    80002c4c:	79e2                	ld	s3,56(sp)
    80002c4e:	7a42                	ld	s4,48(sp)
    80002c50:	7aa2                	ld	s5,40(sp)
    80002c52:	7b02                	ld	s6,32(sp)
    80002c54:	6be2                	ld	s7,24(sp)
    80002c56:	6c42                	ld	s8,16(sp)
    80002c58:	6ca2                	ld	s9,8(sp)
    80002c5a:	6125                	addi	sp,sp,96
    80002c5c:	8082                	ret
      iunlock(ip);
    80002c5e:	8552                	mv	a0,s4
    80002c60:	b29ff0ef          	jal	80002788 <iunlock>
      return ip;
    80002c64:	bff9                	j	80002c42 <namex+0x58>
      iunlockput(ip);
    80002c66:	8552                	mv	a0,s4
    80002c68:	c7dff0ef          	jal	800028e4 <iunlockput>
      return 0;
    80002c6c:	8a4e                	mv	s4,s3
    80002c6e:	bfd1                	j	80002c42 <namex+0x58>
  len = path - s;
    80002c70:	40998633          	sub	a2,s3,s1
    80002c74:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002c78:	099c5063          	bge	s8,s9,80002cf8 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002c7c:	4639                	li	a2,14
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	8556                	mv	a0,s5
    80002c82:	d28fd0ef          	jal	800001aa <memmove>
    80002c86:	84ce                	mv	s1,s3
  while(*path == '/')
    80002c88:	0004c783          	lbu	a5,0(s1)
    80002c8c:	01279763          	bne	a5,s2,80002c9a <namex+0xb0>
    path++;
    80002c90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002c92:	0004c783          	lbu	a5,0(s1)
    80002c96:	ff278de3          	beq	a5,s2,80002c90 <namex+0xa6>
    ilock(ip);
    80002c9a:	8552                	mv	a0,s4
    80002c9c:	a3fff0ef          	jal	800026da <ilock>
    if(ip->type != T_DIR){
    80002ca0:	044a1783          	lh	a5,68(s4)
    80002ca4:	f9779be3          	bne	a5,s7,80002c3a <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002ca8:	000b0563          	beqz	s6,80002cb2 <namex+0xc8>
    80002cac:	0004c783          	lbu	a5,0(s1)
    80002cb0:	d7dd                	beqz	a5,80002c5e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002cb2:	4601                	li	a2,0
    80002cb4:	85d6                	mv	a1,s5
    80002cb6:	8552                	mv	a0,s4
    80002cb8:	e97ff0ef          	jal	80002b4e <dirlookup>
    80002cbc:	89aa                	mv	s3,a0
    80002cbe:	d545                	beqz	a0,80002c66 <namex+0x7c>
    iunlockput(ip);
    80002cc0:	8552                	mv	a0,s4
    80002cc2:	c23ff0ef          	jal	800028e4 <iunlockput>
    ip = next;
    80002cc6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002cc8:	0004c783          	lbu	a5,0(s1)
    80002ccc:	01279763          	bne	a5,s2,80002cda <namex+0xf0>
    path++;
    80002cd0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002cd2:	0004c783          	lbu	a5,0(s1)
    80002cd6:	ff278de3          	beq	a5,s2,80002cd0 <namex+0xe6>
  if(*path == 0)
    80002cda:	cb8d                	beqz	a5,80002d0c <namex+0x122>
  while(*path != '/' && *path != 0)
    80002cdc:	0004c783          	lbu	a5,0(s1)
    80002ce0:	89a6                	mv	s3,s1
  len = path - s;
    80002ce2:	4c81                	li	s9,0
    80002ce4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002ce6:	01278963          	beq	a5,s2,80002cf8 <namex+0x10e>
    80002cea:	d3d9                	beqz	a5,80002c70 <namex+0x86>
    path++;
    80002cec:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002cee:	0009c783          	lbu	a5,0(s3)
    80002cf2:	ff279ce3          	bne	a5,s2,80002cea <namex+0x100>
    80002cf6:	bfad                	j	80002c70 <namex+0x86>
    memmove(name, s, len);
    80002cf8:	2601                	sext.w	a2,a2
    80002cfa:	85a6                	mv	a1,s1
    80002cfc:	8556                	mv	a0,s5
    80002cfe:	cacfd0ef          	jal	800001aa <memmove>
    name[len] = 0;
    80002d02:	9cd6                	add	s9,s9,s5
    80002d04:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002d08:	84ce                	mv	s1,s3
    80002d0a:	bfbd                	j	80002c88 <namex+0x9e>
  if(nameiparent){
    80002d0c:	f20b0be3          	beqz	s6,80002c42 <namex+0x58>
    iput(ip);
    80002d10:	8552                	mv	a0,s4
    80002d12:	b4bff0ef          	jal	8000285c <iput>
    return 0;
    80002d16:	4a01                	li	s4,0
    80002d18:	b72d                	j	80002c42 <namex+0x58>

0000000080002d1a <dirlink>:
{
    80002d1a:	7139                	addi	sp,sp,-64
    80002d1c:	fc06                	sd	ra,56(sp)
    80002d1e:	f822                	sd	s0,48(sp)
    80002d20:	f04a                	sd	s2,32(sp)
    80002d22:	ec4e                	sd	s3,24(sp)
    80002d24:	e852                	sd	s4,16(sp)
    80002d26:	0080                	addi	s0,sp,64
    80002d28:	892a                	mv	s2,a0
    80002d2a:	8a2e                	mv	s4,a1
    80002d2c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002d2e:	4601                	li	a2,0
    80002d30:	e1fff0ef          	jal	80002b4e <dirlookup>
    80002d34:	e535                	bnez	a0,80002da0 <dirlink+0x86>
    80002d36:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d38:	04c92483          	lw	s1,76(s2)
    80002d3c:	c48d                	beqz	s1,80002d66 <dirlink+0x4c>
    80002d3e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d40:	4741                	li	a4,16
    80002d42:	86a6                	mv	a3,s1
    80002d44:	fc040613          	addi	a2,s0,-64
    80002d48:	4581                	li	a1,0
    80002d4a:	854a                	mv	a0,s2
    80002d4c:	be3ff0ef          	jal	8000292e <readi>
    80002d50:	47c1                	li	a5,16
    80002d52:	04f51b63          	bne	a0,a5,80002da8 <dirlink+0x8e>
    if(de.inum == 0)
    80002d56:	fc045783          	lhu	a5,-64(s0)
    80002d5a:	c791                	beqz	a5,80002d66 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d5c:	24c1                	addiw	s1,s1,16
    80002d5e:	04c92783          	lw	a5,76(s2)
    80002d62:	fcf4efe3          	bltu	s1,a5,80002d40 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002d66:	4639                	li	a2,14
    80002d68:	85d2                	mv	a1,s4
    80002d6a:	fc240513          	addi	a0,s0,-62
    80002d6e:	ce2fd0ef          	jal	80000250 <strncpy>
  de.inum = inum;
    80002d72:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d76:	4741                	li	a4,16
    80002d78:	86a6                	mv	a3,s1
    80002d7a:	fc040613          	addi	a2,s0,-64
    80002d7e:	4581                	li	a1,0
    80002d80:	854a                	mv	a0,s2
    80002d82:	ca9ff0ef          	jal	80002a2a <writei>
    80002d86:	1541                	addi	a0,a0,-16
    80002d88:	00a03533          	snez	a0,a0
    80002d8c:	40a00533          	neg	a0,a0
    80002d90:	74a2                	ld	s1,40(sp)
}
    80002d92:	70e2                	ld	ra,56(sp)
    80002d94:	7442                	ld	s0,48(sp)
    80002d96:	7902                	ld	s2,32(sp)
    80002d98:	69e2                	ld	s3,24(sp)
    80002d9a:	6a42                	ld	s4,16(sp)
    80002d9c:	6121                	addi	sp,sp,64
    80002d9e:	8082                	ret
    iput(ip);
    80002da0:	abdff0ef          	jal	8000285c <iput>
    return -1;
    80002da4:	557d                	li	a0,-1
    80002da6:	b7f5                	j	80002d92 <dirlink+0x78>
      panic("dirlink read");
    80002da8:	00004517          	auipc	a0,0x4
    80002dac:	76050513          	addi	a0,a0,1888 # 80007508 <etext+0x508>
    80002db0:	6e2020ef          	jal	80005492 <panic>

0000000080002db4 <namei>:

struct inode*
namei(char *path)
{
    80002db4:	1101                	addi	sp,sp,-32
    80002db6:	ec06                	sd	ra,24(sp)
    80002db8:	e822                	sd	s0,16(sp)
    80002dba:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002dbc:	fe040613          	addi	a2,s0,-32
    80002dc0:	4581                	li	a1,0
    80002dc2:	e29ff0ef          	jal	80002bea <namex>
}
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	6105                	addi	sp,sp,32
    80002dcc:	8082                	ret

0000000080002dce <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002dce:	1141                	addi	sp,sp,-16
    80002dd0:	e406                	sd	ra,8(sp)
    80002dd2:	e022                	sd	s0,0(sp)
    80002dd4:	0800                	addi	s0,sp,16
    80002dd6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002dd8:	4585                	li	a1,1
    80002dda:	e11ff0ef          	jal	80002bea <namex>
}
    80002dde:	60a2                	ld	ra,8(sp)
    80002de0:	6402                	ld	s0,0(sp)
    80002de2:	0141                	addi	sp,sp,16
    80002de4:	8082                	ret

0000000080002de6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002df2:	00017917          	auipc	s2,0x17
    80002df6:	6ce90913          	addi	s2,s2,1742 # 8001a4c0 <log>
    80002dfa:	01892583          	lw	a1,24(s2)
    80002dfe:	02892503          	lw	a0,40(s2)
    80002e02:	9a0ff0ef          	jal	80001fa2 <bread>
    80002e06:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002e08:	02c92603          	lw	a2,44(s2)
    80002e0c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002e0e:	00c05f63          	blez	a2,80002e2c <write_head+0x46>
    80002e12:	00017717          	auipc	a4,0x17
    80002e16:	6de70713          	addi	a4,a4,1758 # 8001a4f0 <log+0x30>
    80002e1a:	87aa                	mv	a5,a0
    80002e1c:	060a                	slli	a2,a2,0x2
    80002e1e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002e20:	4314                	lw	a3,0(a4)
    80002e22:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002e24:	0711                	addi	a4,a4,4
    80002e26:	0791                	addi	a5,a5,4
    80002e28:	fec79ce3          	bne	a5,a2,80002e20 <write_head+0x3a>
  }
  bwrite(buf);
    80002e2c:	8526                	mv	a0,s1
    80002e2e:	a4aff0ef          	jal	80002078 <bwrite>
  brelse(buf);
    80002e32:	8526                	mv	a0,s1
    80002e34:	a76ff0ef          	jal	800020aa <brelse>
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6902                	ld	s2,0(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e44:	00017797          	auipc	a5,0x17
    80002e48:	6a87a783          	lw	a5,1704(a5) # 8001a4ec <log+0x2c>
    80002e4c:	08f05f63          	blez	a5,80002eea <install_trans+0xa6>
{
    80002e50:	7139                	addi	sp,sp,-64
    80002e52:	fc06                	sd	ra,56(sp)
    80002e54:	f822                	sd	s0,48(sp)
    80002e56:	f426                	sd	s1,40(sp)
    80002e58:	f04a                	sd	s2,32(sp)
    80002e5a:	ec4e                	sd	s3,24(sp)
    80002e5c:	e852                	sd	s4,16(sp)
    80002e5e:	e456                	sd	s5,8(sp)
    80002e60:	e05a                	sd	s6,0(sp)
    80002e62:	0080                	addi	s0,sp,64
    80002e64:	8b2a                	mv	s6,a0
    80002e66:	00017a97          	auipc	s5,0x17
    80002e6a:	68aa8a93          	addi	s5,s5,1674 # 8001a4f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e6e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002e70:	00017997          	auipc	s3,0x17
    80002e74:	65098993          	addi	s3,s3,1616 # 8001a4c0 <log>
    80002e78:	a829                	j	80002e92 <install_trans+0x4e>
    brelse(lbuf);
    80002e7a:	854a                	mv	a0,s2
    80002e7c:	a2eff0ef          	jal	800020aa <brelse>
    brelse(dbuf);
    80002e80:	8526                	mv	a0,s1
    80002e82:	a28ff0ef          	jal	800020aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e86:	2a05                	addiw	s4,s4,1
    80002e88:	0a91                	addi	s5,s5,4
    80002e8a:	02c9a783          	lw	a5,44(s3)
    80002e8e:	04fa5463          	bge	s4,a5,80002ed6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002e92:	0189a583          	lw	a1,24(s3)
    80002e96:	014585bb          	addw	a1,a1,s4
    80002e9a:	2585                	addiw	a1,a1,1
    80002e9c:	0289a503          	lw	a0,40(s3)
    80002ea0:	902ff0ef          	jal	80001fa2 <bread>
    80002ea4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002ea6:	000aa583          	lw	a1,0(s5)
    80002eaa:	0289a503          	lw	a0,40(s3)
    80002eae:	8f4ff0ef          	jal	80001fa2 <bread>
    80002eb2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002eb4:	40000613          	li	a2,1024
    80002eb8:	05890593          	addi	a1,s2,88
    80002ebc:	05850513          	addi	a0,a0,88
    80002ec0:	aeafd0ef          	jal	800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	9b2ff0ef          	jal	80002078 <bwrite>
    if(recovering == 0)
    80002eca:	fa0b18e3          	bnez	s6,80002e7a <install_trans+0x36>
      bunpin(dbuf);
    80002ece:	8526                	mv	a0,s1
    80002ed0:	a96ff0ef          	jal	80002166 <bunpin>
    80002ed4:	b75d                	j	80002e7a <install_trans+0x36>
}
    80002ed6:	70e2                	ld	ra,56(sp)
    80002ed8:	7442                	ld	s0,48(sp)
    80002eda:	74a2                	ld	s1,40(sp)
    80002edc:	7902                	ld	s2,32(sp)
    80002ede:	69e2                	ld	s3,24(sp)
    80002ee0:	6a42                	ld	s4,16(sp)
    80002ee2:	6aa2                	ld	s5,8(sp)
    80002ee4:	6b02                	ld	s6,0(sp)
    80002ee6:	6121                	addi	sp,sp,64
    80002ee8:	8082                	ret
    80002eea:	8082                	ret

0000000080002eec <initlog>:
{
    80002eec:	7179                	addi	sp,sp,-48
    80002eee:	f406                	sd	ra,40(sp)
    80002ef0:	f022                	sd	s0,32(sp)
    80002ef2:	ec26                	sd	s1,24(sp)
    80002ef4:	e84a                	sd	s2,16(sp)
    80002ef6:	e44e                	sd	s3,8(sp)
    80002ef8:	1800                	addi	s0,sp,48
    80002efa:	892a                	mv	s2,a0
    80002efc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002efe:	00017497          	auipc	s1,0x17
    80002f02:	5c248493          	addi	s1,s1,1474 # 8001a4c0 <log>
    80002f06:	00004597          	auipc	a1,0x4
    80002f0a:	61258593          	addi	a1,a1,1554 # 80007518 <etext+0x518>
    80002f0e:	8526                	mv	a0,s1
    80002f10:	031020ef          	jal	80005740 <initlock>
  log.start = sb->logstart;
    80002f14:	0149a583          	lw	a1,20(s3)
    80002f18:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002f1a:	0109a783          	lw	a5,16(s3)
    80002f1e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002f20:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002f24:	854a                	mv	a0,s2
    80002f26:	87cff0ef          	jal	80001fa2 <bread>
  log.lh.n = lh->n;
    80002f2a:	4d30                	lw	a2,88(a0)
    80002f2c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002f2e:	00c05f63          	blez	a2,80002f4c <initlog+0x60>
    80002f32:	87aa                	mv	a5,a0
    80002f34:	00017717          	auipc	a4,0x17
    80002f38:	5bc70713          	addi	a4,a4,1468 # 8001a4f0 <log+0x30>
    80002f3c:	060a                	slli	a2,a2,0x2
    80002f3e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80002f40:	4ff4                	lw	a3,92(a5)
    80002f42:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002f44:	0791                	addi	a5,a5,4
    80002f46:	0711                	addi	a4,a4,4
    80002f48:	fec79ce3          	bne	a5,a2,80002f40 <initlog+0x54>
  brelse(buf);
    80002f4c:	95eff0ef          	jal	800020aa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002f50:	4505                	li	a0,1
    80002f52:	ef3ff0ef          	jal	80002e44 <install_trans>
  log.lh.n = 0;
    80002f56:	00017797          	auipc	a5,0x17
    80002f5a:	5807ab23          	sw	zero,1430(a5) # 8001a4ec <log+0x2c>
  write_head(); // clear the log
    80002f5e:	e89ff0ef          	jal	80002de6 <write_head>
}
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6942                	ld	s2,16(sp)
    80002f6a:	69a2                	ld	s3,8(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret

0000000080002f70 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002f70:	1101                	addi	sp,sp,-32
    80002f72:	ec06                	sd	ra,24(sp)
    80002f74:	e822                	sd	s0,16(sp)
    80002f76:	e426                	sd	s1,8(sp)
    80002f78:	e04a                	sd	s2,0(sp)
    80002f7a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002f7c:	00017517          	auipc	a0,0x17
    80002f80:	54450513          	addi	a0,a0,1348 # 8001a4c0 <log>
    80002f84:	03d020ef          	jal	800057c0 <acquire>
  while(1){
    if(log.committing){
    80002f88:	00017497          	auipc	s1,0x17
    80002f8c:	53848493          	addi	s1,s1,1336 # 8001a4c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002f90:	4979                	li	s2,30
    80002f92:	a029                	j	80002f9c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80002f94:	85a6                	mv	a1,s1
    80002f96:	8526                	mv	a0,s1
    80002f98:	ba4fe0ef          	jal	8000133c <sleep>
    if(log.committing){
    80002f9c:	50dc                	lw	a5,36(s1)
    80002f9e:	fbfd                	bnez	a5,80002f94 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002fa0:	5098                	lw	a4,32(s1)
    80002fa2:	2705                	addiw	a4,a4,1
    80002fa4:	0027179b          	slliw	a5,a4,0x2
    80002fa8:	9fb9                	addw	a5,a5,a4
    80002faa:	0017979b          	slliw	a5,a5,0x1
    80002fae:	54d4                	lw	a3,44(s1)
    80002fb0:	9fb5                	addw	a5,a5,a3
    80002fb2:	00f95763          	bge	s2,a5,80002fc0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80002fb6:	85a6                	mv	a1,s1
    80002fb8:	8526                	mv	a0,s1
    80002fba:	b82fe0ef          	jal	8000133c <sleep>
    80002fbe:	bff9                	j	80002f9c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80002fc0:	00017517          	auipc	a0,0x17
    80002fc4:	50050513          	addi	a0,a0,1280 # 8001a4c0 <log>
    80002fc8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80002fca:	08f020ef          	jal	80005858 <release>
      break;
    }
  }
}
    80002fce:	60e2                	ld	ra,24(sp)
    80002fd0:	6442                	ld	s0,16(sp)
    80002fd2:	64a2                	ld	s1,8(sp)
    80002fd4:	6902                	ld	s2,0(sp)
    80002fd6:	6105                	addi	sp,sp,32
    80002fd8:	8082                	ret

0000000080002fda <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80002fda:	7139                	addi	sp,sp,-64
    80002fdc:	fc06                	sd	ra,56(sp)
    80002fde:	f822                	sd	s0,48(sp)
    80002fe0:	f426                	sd	s1,40(sp)
    80002fe2:	f04a                	sd	s2,32(sp)
    80002fe4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80002fe6:	00017497          	auipc	s1,0x17
    80002fea:	4da48493          	addi	s1,s1,1242 # 8001a4c0 <log>
    80002fee:	8526                	mv	a0,s1
    80002ff0:	7d0020ef          	jal	800057c0 <acquire>
  log.outstanding -= 1;
    80002ff4:	509c                	lw	a5,32(s1)
    80002ff6:	37fd                	addiw	a5,a5,-1
    80002ff8:	0007891b          	sext.w	s2,a5
    80002ffc:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80002ffe:	50dc                	lw	a5,36(s1)
    80003000:	ef9d                	bnez	a5,8000303e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003002:	04091763          	bnez	s2,80003050 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003006:	00017497          	auipc	s1,0x17
    8000300a:	4ba48493          	addi	s1,s1,1210 # 8001a4c0 <log>
    8000300e:	4785                	li	a5,1
    80003010:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003012:	8526                	mv	a0,s1
    80003014:	045020ef          	jal	80005858 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003018:	54dc                	lw	a5,44(s1)
    8000301a:	04f04b63          	bgtz	a5,80003070 <end_op+0x96>
    acquire(&log.lock);
    8000301e:	00017497          	auipc	s1,0x17
    80003022:	4a248493          	addi	s1,s1,1186 # 8001a4c0 <log>
    80003026:	8526                	mv	a0,s1
    80003028:	798020ef          	jal	800057c0 <acquire>
    log.committing = 0;
    8000302c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003030:	8526                	mv	a0,s1
    80003032:	b56fe0ef          	jal	80001388 <wakeup>
    release(&log.lock);
    80003036:	8526                	mv	a0,s1
    80003038:	021020ef          	jal	80005858 <release>
}
    8000303c:	a025                	j	80003064 <end_op+0x8a>
    8000303e:	ec4e                	sd	s3,24(sp)
    80003040:	e852                	sd	s4,16(sp)
    80003042:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003044:	00004517          	auipc	a0,0x4
    80003048:	4dc50513          	addi	a0,a0,1244 # 80007520 <etext+0x520>
    8000304c:	446020ef          	jal	80005492 <panic>
    wakeup(&log);
    80003050:	00017497          	auipc	s1,0x17
    80003054:	47048493          	addi	s1,s1,1136 # 8001a4c0 <log>
    80003058:	8526                	mv	a0,s1
    8000305a:	b2efe0ef          	jal	80001388 <wakeup>
  release(&log.lock);
    8000305e:	8526                	mv	a0,s1
    80003060:	7f8020ef          	jal	80005858 <release>
}
    80003064:	70e2                	ld	ra,56(sp)
    80003066:	7442                	ld	s0,48(sp)
    80003068:	74a2                	ld	s1,40(sp)
    8000306a:	7902                	ld	s2,32(sp)
    8000306c:	6121                	addi	sp,sp,64
    8000306e:	8082                	ret
    80003070:	ec4e                	sd	s3,24(sp)
    80003072:	e852                	sd	s4,16(sp)
    80003074:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003076:	00017a97          	auipc	s5,0x17
    8000307a:	47aa8a93          	addi	s5,s5,1146 # 8001a4f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000307e:	00017a17          	auipc	s4,0x17
    80003082:	442a0a13          	addi	s4,s4,1090 # 8001a4c0 <log>
    80003086:	018a2583          	lw	a1,24(s4)
    8000308a:	012585bb          	addw	a1,a1,s2
    8000308e:	2585                	addiw	a1,a1,1
    80003090:	028a2503          	lw	a0,40(s4)
    80003094:	f0ffe0ef          	jal	80001fa2 <bread>
    80003098:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000309a:	000aa583          	lw	a1,0(s5)
    8000309e:	028a2503          	lw	a0,40(s4)
    800030a2:	f01fe0ef          	jal	80001fa2 <bread>
    800030a6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800030a8:	40000613          	li	a2,1024
    800030ac:	05850593          	addi	a1,a0,88
    800030b0:	05848513          	addi	a0,s1,88
    800030b4:	8f6fd0ef          	jal	800001aa <memmove>
    bwrite(to);  // write the log
    800030b8:	8526                	mv	a0,s1
    800030ba:	fbffe0ef          	jal	80002078 <bwrite>
    brelse(from);
    800030be:	854e                	mv	a0,s3
    800030c0:	febfe0ef          	jal	800020aa <brelse>
    brelse(to);
    800030c4:	8526                	mv	a0,s1
    800030c6:	fe5fe0ef          	jal	800020aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800030ca:	2905                	addiw	s2,s2,1
    800030cc:	0a91                	addi	s5,s5,4
    800030ce:	02ca2783          	lw	a5,44(s4)
    800030d2:	faf94ae3          	blt	s2,a5,80003086 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800030d6:	d11ff0ef          	jal	80002de6 <write_head>
    install_trans(0); // Now install writes to home locations
    800030da:	4501                	li	a0,0
    800030dc:	d69ff0ef          	jal	80002e44 <install_trans>
    log.lh.n = 0;
    800030e0:	00017797          	auipc	a5,0x17
    800030e4:	4007a623          	sw	zero,1036(a5) # 8001a4ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    800030e8:	cffff0ef          	jal	80002de6 <write_head>
    800030ec:	69e2                	ld	s3,24(sp)
    800030ee:	6a42                	ld	s4,16(sp)
    800030f0:	6aa2                	ld	s5,8(sp)
    800030f2:	b735                	j	8000301e <end_op+0x44>

00000000800030f4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800030f4:	1101                	addi	sp,sp,-32
    800030f6:	ec06                	sd	ra,24(sp)
    800030f8:	e822                	sd	s0,16(sp)
    800030fa:	e426                	sd	s1,8(sp)
    800030fc:	e04a                	sd	s2,0(sp)
    800030fe:	1000                	addi	s0,sp,32
    80003100:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003102:	00017917          	auipc	s2,0x17
    80003106:	3be90913          	addi	s2,s2,958 # 8001a4c0 <log>
    8000310a:	854a                	mv	a0,s2
    8000310c:	6b4020ef          	jal	800057c0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003110:	02c92603          	lw	a2,44(s2)
    80003114:	47f5                	li	a5,29
    80003116:	06c7c363          	blt	a5,a2,8000317c <log_write+0x88>
    8000311a:	00017797          	auipc	a5,0x17
    8000311e:	3c27a783          	lw	a5,962(a5) # 8001a4dc <log+0x1c>
    80003122:	37fd                	addiw	a5,a5,-1
    80003124:	04f65c63          	bge	a2,a5,8000317c <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003128:	00017797          	auipc	a5,0x17
    8000312c:	3b87a783          	lw	a5,952(a5) # 8001a4e0 <log+0x20>
    80003130:	04f05c63          	blez	a5,80003188 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003134:	4781                	li	a5,0
    80003136:	04c05f63          	blez	a2,80003194 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000313a:	44cc                	lw	a1,12(s1)
    8000313c:	00017717          	auipc	a4,0x17
    80003140:	3b470713          	addi	a4,a4,948 # 8001a4f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003144:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003146:	4314                	lw	a3,0(a4)
    80003148:	04b68663          	beq	a3,a1,80003194 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000314c:	2785                	addiw	a5,a5,1
    8000314e:	0711                	addi	a4,a4,4
    80003150:	fef61be3          	bne	a2,a5,80003146 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003154:	0621                	addi	a2,a2,8
    80003156:	060a                	slli	a2,a2,0x2
    80003158:	00017797          	auipc	a5,0x17
    8000315c:	36878793          	addi	a5,a5,872 # 8001a4c0 <log>
    80003160:	97b2                	add	a5,a5,a2
    80003162:	44d8                	lw	a4,12(s1)
    80003164:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003166:	8526                	mv	a0,s1
    80003168:	fcbfe0ef          	jal	80002132 <bpin>
    log.lh.n++;
    8000316c:	00017717          	auipc	a4,0x17
    80003170:	35470713          	addi	a4,a4,852 # 8001a4c0 <log>
    80003174:	575c                	lw	a5,44(a4)
    80003176:	2785                	addiw	a5,a5,1
    80003178:	d75c                	sw	a5,44(a4)
    8000317a:	a80d                	j	800031ac <log_write+0xb8>
    panic("too big a transaction");
    8000317c:	00004517          	auipc	a0,0x4
    80003180:	3b450513          	addi	a0,a0,948 # 80007530 <etext+0x530>
    80003184:	30e020ef          	jal	80005492 <panic>
    panic("log_write outside of trans");
    80003188:	00004517          	auipc	a0,0x4
    8000318c:	3c050513          	addi	a0,a0,960 # 80007548 <etext+0x548>
    80003190:	302020ef          	jal	80005492 <panic>
  log.lh.block[i] = b->blockno;
    80003194:	00878693          	addi	a3,a5,8
    80003198:	068a                	slli	a3,a3,0x2
    8000319a:	00017717          	auipc	a4,0x17
    8000319e:	32670713          	addi	a4,a4,806 # 8001a4c0 <log>
    800031a2:	9736                	add	a4,a4,a3
    800031a4:	44d4                	lw	a3,12(s1)
    800031a6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800031a8:	faf60fe3          	beq	a2,a5,80003166 <log_write+0x72>
  }
  release(&log.lock);
    800031ac:	00017517          	auipc	a0,0x17
    800031b0:	31450513          	addi	a0,a0,788 # 8001a4c0 <log>
    800031b4:	6a4020ef          	jal	80005858 <release>
}
    800031b8:	60e2                	ld	ra,24(sp)
    800031ba:	6442                	ld	s0,16(sp)
    800031bc:	64a2                	ld	s1,8(sp)
    800031be:	6902                	ld	s2,0(sp)
    800031c0:	6105                	addi	sp,sp,32
    800031c2:	8082                	ret

00000000800031c4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800031c4:	1101                	addi	sp,sp,-32
    800031c6:	ec06                	sd	ra,24(sp)
    800031c8:	e822                	sd	s0,16(sp)
    800031ca:	e426                	sd	s1,8(sp)
    800031cc:	e04a                	sd	s2,0(sp)
    800031ce:	1000                	addi	s0,sp,32
    800031d0:	84aa                	mv	s1,a0
    800031d2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800031d4:	00004597          	auipc	a1,0x4
    800031d8:	39458593          	addi	a1,a1,916 # 80007568 <etext+0x568>
    800031dc:	0521                	addi	a0,a0,8
    800031de:	562020ef          	jal	80005740 <initlock>
  lk->name = name;
    800031e2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800031e6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800031ea:	0204a423          	sw	zero,40(s1)
}
    800031ee:	60e2                	ld	ra,24(sp)
    800031f0:	6442                	ld	s0,16(sp)
    800031f2:	64a2                	ld	s1,8(sp)
    800031f4:	6902                	ld	s2,0(sp)
    800031f6:	6105                	addi	sp,sp,32
    800031f8:	8082                	ret

00000000800031fa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800031fa:	1101                	addi	sp,sp,-32
    800031fc:	ec06                	sd	ra,24(sp)
    800031fe:	e822                	sd	s0,16(sp)
    80003200:	e426                	sd	s1,8(sp)
    80003202:	e04a                	sd	s2,0(sp)
    80003204:	1000                	addi	s0,sp,32
    80003206:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003208:	00850913          	addi	s2,a0,8
    8000320c:	854a                	mv	a0,s2
    8000320e:	5b2020ef          	jal	800057c0 <acquire>
  while (lk->locked) {
    80003212:	409c                	lw	a5,0(s1)
    80003214:	c799                	beqz	a5,80003222 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003216:	85ca                	mv	a1,s2
    80003218:	8526                	mv	a0,s1
    8000321a:	922fe0ef          	jal	8000133c <sleep>
  while (lk->locked) {
    8000321e:	409c                	lw	a5,0(s1)
    80003220:	fbfd                	bnez	a5,80003216 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003222:	4785                	li	a5,1
    80003224:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003226:	b41fd0ef          	jal	80000d66 <myproc>
    8000322a:	591c                	lw	a5,48(a0)
    8000322c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000322e:	854a                	mv	a0,s2
    80003230:	628020ef          	jal	80005858 <release>
}
    80003234:	60e2                	ld	ra,24(sp)
    80003236:	6442                	ld	s0,16(sp)
    80003238:	64a2                	ld	s1,8(sp)
    8000323a:	6902                	ld	s2,0(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	e426                	sd	s1,8(sp)
    80003248:	e04a                	sd	s2,0(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000324e:	00850913          	addi	s2,a0,8
    80003252:	854a                	mv	a0,s2
    80003254:	56c020ef          	jal	800057c0 <acquire>
  lk->locked = 0;
    80003258:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000325c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003260:	8526                	mv	a0,s1
    80003262:	926fe0ef          	jal	80001388 <wakeup>
  release(&lk->lk);
    80003266:	854a                	mv	a0,s2
    80003268:	5f0020ef          	jal	80005858 <release>
}
    8000326c:	60e2                	ld	ra,24(sp)
    8000326e:	6442                	ld	s0,16(sp)
    80003270:	64a2                	ld	s1,8(sp)
    80003272:	6902                	ld	s2,0(sp)
    80003274:	6105                	addi	sp,sp,32
    80003276:	8082                	ret

0000000080003278 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003278:	7179                	addi	sp,sp,-48
    8000327a:	f406                	sd	ra,40(sp)
    8000327c:	f022                	sd	s0,32(sp)
    8000327e:	ec26                	sd	s1,24(sp)
    80003280:	e84a                	sd	s2,16(sp)
    80003282:	1800                	addi	s0,sp,48
    80003284:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003286:	00850913          	addi	s2,a0,8
    8000328a:	854a                	mv	a0,s2
    8000328c:	534020ef          	jal	800057c0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003290:	409c                	lw	a5,0(s1)
    80003292:	ef81                	bnez	a5,800032aa <holdingsleep+0x32>
    80003294:	4481                	li	s1,0
  release(&lk->lk);
    80003296:	854a                	mv	a0,s2
    80003298:	5c0020ef          	jal	80005858 <release>
  return r;
}
    8000329c:	8526                	mv	a0,s1
    8000329e:	70a2                	ld	ra,40(sp)
    800032a0:	7402                	ld	s0,32(sp)
    800032a2:	64e2                	ld	s1,24(sp)
    800032a4:	6942                	ld	s2,16(sp)
    800032a6:	6145                	addi	sp,sp,48
    800032a8:	8082                	ret
    800032aa:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800032ac:	0284a983          	lw	s3,40(s1)
    800032b0:	ab7fd0ef          	jal	80000d66 <myproc>
    800032b4:	5904                	lw	s1,48(a0)
    800032b6:	413484b3          	sub	s1,s1,s3
    800032ba:	0014b493          	seqz	s1,s1
    800032be:	69a2                	ld	s3,8(sp)
    800032c0:	bfd9                	j	80003296 <holdingsleep+0x1e>

00000000800032c2 <fileinit>:
} ftable;

// initialize file table 
void
fileinit(void)
{
    800032c2:	1141                	addi	sp,sp,-16
    800032c4:	e406                	sd	ra,8(sp)
    800032c6:	e022                	sd	s0,0(sp)
    800032c8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable"); //Initialize spinlock lock for ftable to synchronize access to file table.
    800032ca:	00004597          	auipc	a1,0x4
    800032ce:	2ae58593          	addi	a1,a1,686 # 80007578 <etext+0x578>
    800032d2:	00017517          	auipc	a0,0x17
    800032d6:	33650513          	addi	a0,a0,822 # 8001a608 <ftable>
    800032da:	466020ef          	jal	80005740 <initlock>
}
    800032de:	60a2                	ld	ra,8(sp)
    800032e0:	6402                	ld	s0,0(sp)
    800032e2:	0141                	addi	sp,sp,16
    800032e4:	8082                	ret

00000000800032e6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800032f0:	00017517          	auipc	a0,0x17
    800032f4:	31850513          	addi	a0,a0,792 # 8001a608 <ftable>
    800032f8:	4c8020ef          	jal	800057c0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800032fc:	00017497          	auipc	s1,0x17
    80003300:	32448493          	addi	s1,s1,804 # 8001a620 <ftable+0x18>
    80003304:	00018717          	auipc	a4,0x18
    80003308:	2bc70713          	addi	a4,a4,700 # 8001b5c0 <disk>
    //find file structure that are not used
    if(f->ref == 0){
    8000330c:	40dc                	lw	a5,4(s1)
    8000330e:	cf89                	beqz	a5,80003328 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003310:	02848493          	addi	s1,s1,40
    80003314:	fee49ce3          	bne	s1,a4,8000330c <filealloc+0x26>
      f->ref = 1; // mark that it has been used 
      release(&ftable.lock); // unlock
      return f;
    }
  }
  release(&ftable.lock); //unlock afer finding
    80003318:	00017517          	auipc	a0,0x17
    8000331c:	2f050513          	addi	a0,a0,752 # 8001a608 <ftable>
    80003320:	538020ef          	jal	80005858 <release>
  return 0;
    80003324:	4481                	li	s1,0
    80003326:	a809                	j	80003338 <filealloc+0x52>
      f->ref = 1; // mark that it has been used 
    80003328:	4785                	li	a5,1
    8000332a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock); // unlock
    8000332c:	00017517          	auipc	a0,0x17
    80003330:	2dc50513          	addi	a0,a0,732 # 8001a608 <ftable>
    80003334:	524020ef          	jal	80005858 <release>
}
    80003338:	8526                	mv	a0,s1
    8000333a:	60e2                	ld	ra,24(sp)
    8000333c:	6442                	ld	s0,16(sp)
    8000333e:	64a2                	ld	s1,8(sp)
    80003340:	6105                	addi	sp,sp,32
    80003342:	8082                	ret

0000000080003344 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	e426                	sd	s1,8(sp)
    8000334c:	1000                	addi	s0,sp,32
    8000334e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003350:	00017517          	auipc	a0,0x17
    80003354:	2b850513          	addi	a0,a0,696 # 8001a608 <ftable>
    80003358:	468020ef          	jal	800057c0 <acquire>
  if(f->ref < 1)
    8000335c:	40dc                	lw	a5,4(s1)
    8000335e:	02f05063          	blez	a5,8000337e <filedup+0x3a>
    panic("filedup"); // panic cannot duplicate because it isnot used
  f->ref++; //duplicate
    80003362:	2785                	addiw	a5,a5,1
    80003364:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003366:	00017517          	auipc	a0,0x17
    8000336a:	2a250513          	addi	a0,a0,674 # 8001a608 <ftable>
    8000336e:	4ea020ef          	jal	80005858 <release>
  return f;
}
    80003372:	8526                	mv	a0,s1
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6105                	addi	sp,sp,32
    8000337c:	8082                	ret
    panic("filedup"); // panic cannot duplicate because it isnot used
    8000337e:	00004517          	auipc	a0,0x4
    80003382:	20250513          	addi	a0,a0,514 # 80007580 <etext+0x580>
    80003386:	10c020ef          	jal	80005492 <panic>

000000008000338a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.) and release.
void
fileclose(struct file *f)
{
    8000338a:	7139                	addi	sp,sp,-64
    8000338c:	fc06                	sd	ra,56(sp)
    8000338e:	f822                	sd	s0,48(sp)
    80003390:	f426                	sd	s1,40(sp)
    80003392:	0080                	addi	s0,sp,64
    80003394:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003396:	00017517          	auipc	a0,0x17
    8000339a:	27250513          	addi	a0,a0,626 # 8001a608 <ftable>
    8000339e:	422020ef          	jal	800057c0 <acquire>
  if(f->ref < 1)
    800033a2:	40dc                	lw	a5,4(s1)
    800033a4:	04f05a63          	blez	a5,800033f8 <fileclose+0x6e>
    panic("fileclose"); // panic cannot close because it is not used
  // release 1 duplicate
  if(--f->ref > 0){
    800033a8:	37fd                	addiw	a5,a5,-1
    800033aa:	0007871b          	sext.w	a4,a5
    800033ae:	c0dc                	sw	a5,4(s1)
    800033b0:	04e04e63          	bgtz	a4,8000340c <fileclose+0x82>
    800033b4:	f04a                	sd	s2,32(sp)
    800033b6:	ec4e                	sd	s3,24(sp)
    800033b8:	e852                	sd	s4,16(sp)
    800033ba:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  //if ref = 0 close file.
  ff = *f;
    800033bc:	0004a903          	lw	s2,0(s1)
    800033c0:	0094ca83          	lbu	s5,9(s1)
    800033c4:	0104ba03          	ld	s4,16(s1)
    800033c8:	0184b983          	ld	s3,24(s1)
  //reset member
  f->ref = 0;
    800033cc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800033d0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800033d4:	00017517          	auipc	a0,0x17
    800033d8:	23450513          	addi	a0,a0,564 # 8001a608 <ftable>
    800033dc:	47c020ef          	jal	80005858 <release>

  //close pipe if open pipe
  if(ff.type == FD_PIPE){
    800033e0:	4785                	li	a5,1
    800033e2:	04f90063          	beq	s2,a5,80003422 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800033e6:	3979                	addiw	s2,s2,-2
    800033e8:	4785                	li	a5,1
    800033ea:	0527f563          	bgeu	a5,s2,80003434 <fileclose+0xaa>
    800033ee:	7902                	ld	s2,32(sp)
    800033f0:	69e2                	ld	s3,24(sp)
    800033f2:	6a42                	ld	s4,16(sp)
    800033f4:	6aa2                	ld	s5,8(sp)
    800033f6:	a00d                	j	80003418 <fileclose+0x8e>
    800033f8:	f04a                	sd	s2,32(sp)
    800033fa:	ec4e                	sd	s3,24(sp)
    800033fc:	e852                	sd	s4,16(sp)
    800033fe:	e456                	sd	s5,8(sp)
    panic("fileclose"); // panic cannot close because it is not used
    80003400:	00004517          	auipc	a0,0x4
    80003404:	18850513          	addi	a0,a0,392 # 80007588 <etext+0x588>
    80003408:	08a020ef          	jal	80005492 <panic>
    release(&ftable.lock);
    8000340c:	00017517          	auipc	a0,0x17
    80003410:	1fc50513          	addi	a0,a0,508 # 8001a608 <ftable>
    80003414:	444020ef          	jal	80005858 <release>
    begin_op();
    iput(ff.ip); //release
    end_op();
  }
}
    80003418:	70e2                	ld	ra,56(sp)
    8000341a:	7442                	ld	s0,48(sp)
    8000341c:	74a2                	ld	s1,40(sp)
    8000341e:	6121                	addi	sp,sp,64
    80003420:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003422:	85d6                	mv	a1,s5
    80003424:	8552                	mv	a0,s4
    80003426:	336000ef          	jal	8000375c <pipeclose>
    8000342a:	7902                	ld	s2,32(sp)
    8000342c:	69e2                	ld	s3,24(sp)
    8000342e:	6a42                	ld	s4,16(sp)
    80003430:	6aa2                	ld	s5,8(sp)
    80003432:	b7dd                	j	80003418 <fileclose+0x8e>
    begin_op();
    80003434:	b3dff0ef          	jal	80002f70 <begin_op>
    iput(ff.ip); //release
    80003438:	854e                	mv	a0,s3
    8000343a:	c22ff0ef          	jal	8000285c <iput>
    end_op();
    8000343e:	b9dff0ef          	jal	80002fda <end_op>
    80003442:	7902                	ld	s2,32(sp)
    80003444:	69e2                	ld	s3,24(sp)
    80003446:	6a42                	ld	s4,16(sp)
    80003448:	6aa2                	ld	s5,8(sp)
    8000344a:	b7f9                	j	80003418 <fileclose+0x8e>

000000008000344c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000344c:	715d                	addi	sp,sp,-80
    8000344e:	e486                	sd	ra,72(sp)
    80003450:	e0a2                	sd	s0,64(sp)
    80003452:	fc26                	sd	s1,56(sp)
    80003454:	f44e                	sd	s3,40(sp)
    80003456:	0880                	addi	s0,sp,80
    80003458:	84aa                	mv	s1,a0
    8000345a:	89ae                	mv	s3,a1
  struct proc *p = myproc(); //process structure
    8000345c:	90bfd0ef          	jal	80000d66 <myproc>
  struct stat st; // static structure
  
  //get the metadata if the type is inode or device
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003460:	409c                	lw	a5,0(s1)
    80003462:	37f9                	addiw	a5,a5,-2
    80003464:	4705                	li	a4,1
    80003466:	04f76063          	bltu	a4,a5,800034a6 <filestat+0x5a>
    8000346a:	f84a                	sd	s2,48(sp)
    8000346c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000346e:	6c88                	ld	a0,24(s1)
    80003470:	a6aff0ef          	jal	800026da <ilock>
    stati(f->ip, &st); //get the data
    80003474:	fb840593          	addi	a1,s0,-72
    80003478:	6c88                	ld	a0,24(s1)
    8000347a:	c8aff0ef          	jal	80002904 <stati>
    iunlock(f->ip);
    8000347e:	6c88                	ld	a0,24(s1)
    80003480:	b08ff0ef          	jal	80002788 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0) //Copy the obtained data to the user's memory space
    80003484:	46e1                	li	a3,24
    80003486:	fb840613          	addi	a2,s0,-72
    8000348a:	85ce                	mv	a1,s3
    8000348c:	05093503          	ld	a0,80(s2)
    80003490:	d48fd0ef          	jal	800009d8 <copyout>
    80003494:	41f5551b          	sraiw	a0,a0,0x1f
    80003498:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000349a:	60a6                	ld	ra,72(sp)
    8000349c:	6406                	ld	s0,64(sp)
    8000349e:	74e2                	ld	s1,56(sp)
    800034a0:	79a2                	ld	s3,40(sp)
    800034a2:	6161                	addi	sp,sp,80
    800034a4:	8082                	ret
  return -1;
    800034a6:	557d                	li	a0,-1
    800034a8:	bfcd                	j	8000349a <filestat+0x4e>

00000000800034aa <fileread>:

// Read from file f and copy to address.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800034aa:	7179                	addi	sp,sp,-48
    800034ac:	f406                	sd	ra,40(sp)
    800034ae:	f022                	sd	s0,32(sp)
    800034b0:	e84a                	sd	s2,16(sp)
    800034b2:	1800                	addi	s0,sp,48
  int r = 0;
  // check if file can be read or not
  if(f->readable == 0)
    800034b4:	00854783          	lbu	a5,8(a0)
    800034b8:	cfd1                	beqz	a5,80003554 <fileread+0xaa>
    800034ba:	ec26                	sd	s1,24(sp)
    800034bc:	e44e                	sd	s3,8(sp)
    800034be:	84aa                	mv	s1,a0
    800034c0:	89ae                	mv	s3,a1
    800034c2:	8932                	mv	s2,a2
    return -1;

  //read pipe
  if(f->type == FD_PIPE){
    800034c4:	411c                	lw	a5,0(a0)
    800034c6:	4705                	li	a4,1
    800034c8:	04e78363          	beq	a5,a4,8000350e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  //read device
  } else if(f->type == FD_DEVICE){
    800034cc:	470d                	li	a4,3
    800034ce:	04e78763          	beq	a5,a4,8000351c <fileread+0x72>
    //get the correct device to read from device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  //read inode  
  } else if(f->type == FD_INODE){
    800034d2:	4709                	li	a4,2
    800034d4:	06e79a63          	bne	a5,a4,80003548 <fileread+0x9e>
    ilock(f->ip);
    800034d8:	6d08                	ld	a0,24(a0)
    800034da:	a00ff0ef          	jal	800026da <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800034de:	874a                	mv	a4,s2
    800034e0:	5094                	lw	a3,32(s1)
    800034e2:	864e                	mv	a2,s3
    800034e4:	4585                	li	a1,1
    800034e6:	6c88                	ld	a0,24(s1)
    800034e8:	c46ff0ef          	jal	8000292e <readi>
    800034ec:	892a                	mv	s2,a0
    800034ee:	00a05563          	blez	a0,800034f8 <fileread+0x4e>
      f->off += r;
    800034f2:	509c                	lw	a5,32(s1)
    800034f4:	9fa9                	addw	a5,a5,a0
    800034f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800034f8:	6c88                	ld	a0,24(s1)
    800034fa:	a8eff0ef          	jal	80002788 <iunlock>
    800034fe:	64e2                	ld	s1,24(sp)
    80003500:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003502:	854a                	mv	a0,s2
    80003504:	70a2                	ld	ra,40(sp)
    80003506:	7402                	ld	s0,32(sp)
    80003508:	6942                	ld	s2,16(sp)
    8000350a:	6145                	addi	sp,sp,48
    8000350c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000350e:	6908                	ld	a0,16(a0)
    80003510:	388000ef          	jal	80003898 <piperead>
    80003514:	892a                	mv	s2,a0
    80003516:	64e2                	ld	s1,24(sp)
    80003518:	69a2                	ld	s3,8(sp)
    8000351a:	b7e5                	j	80003502 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000351c:	02451783          	lh	a5,36(a0)
    80003520:	03079693          	slli	a3,a5,0x30
    80003524:	92c1                	srli	a3,a3,0x30
    80003526:	4725                	li	a4,9
    80003528:	02d76863          	bltu	a4,a3,80003558 <fileread+0xae>
    8000352c:	0792                	slli	a5,a5,0x4
    8000352e:	00017717          	auipc	a4,0x17
    80003532:	03a70713          	addi	a4,a4,58 # 8001a568 <devsw>
    80003536:	97ba                	add	a5,a5,a4
    80003538:	639c                	ld	a5,0(a5)
    8000353a:	c39d                	beqz	a5,80003560 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000353c:	4505                	li	a0,1
    8000353e:	9782                	jalr	a5
    80003540:	892a                	mv	s2,a0
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	bf75                	j	80003502 <fileread+0x58>
    panic("fileread");
    80003548:	00004517          	auipc	a0,0x4
    8000354c:	05050513          	addi	a0,a0,80 # 80007598 <etext+0x598>
    80003550:	743010ef          	jal	80005492 <panic>
    return -1;
    80003554:	597d                	li	s2,-1
    80003556:	b775                	j	80003502 <fileread+0x58>
      return -1;
    80003558:	597d                	li	s2,-1
    8000355a:	64e2                	ld	s1,24(sp)
    8000355c:	69a2                	ld	s3,8(sp)
    8000355e:	b755                	j	80003502 <fileread+0x58>
    80003560:	597d                	li	s2,-1
    80003562:	64e2                	ld	s1,24(sp)
    80003564:	69a2                	ld	s3,8(sp)
    80003566:	bf71                	j	80003502 <fileread+0x58>

0000000080003568 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;
  //check if the file can be writen or not
  if(f->writable == 0)
    80003568:	00954783          	lbu	a5,9(a0)
    8000356c:	10078b63          	beqz	a5,80003682 <filewrite+0x11a>
{
    80003570:	715d                	addi	sp,sp,-80
    80003572:	e486                	sd	ra,72(sp)
    80003574:	e0a2                	sd	s0,64(sp)
    80003576:	f84a                	sd	s2,48(sp)
    80003578:	f052                	sd	s4,32(sp)
    8000357a:	e85a                	sd	s6,16(sp)
    8000357c:	0880                	addi	s0,sp,80
    8000357e:	892a                	mv	s2,a0
    80003580:	8b2e                	mv	s6,a1
    80003582:	8a32                	mv	s4,a2
    return -1;

  //write to pipe
  if(f->type == FD_PIPE){
    80003584:	411c                	lw	a5,0(a0)
    80003586:	4705                	li	a4,1
    80003588:	02e78763          	beq	a5,a4,800035b6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000358c:	470d                	li	a4,3
    8000358e:	02e78863          	beq	a5,a4,800035be <filewrite+0x56>
    //find the correct device from the device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003592:	4709                	li	a4,2
    80003594:	0ce79c63          	bne	a5,a4,8000366c <filewrite+0x104>
    80003598:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000359a:	0ac05863          	blez	a2,8000364a <filewrite+0xe2>
    8000359e:	fc26                	sd	s1,56(sp)
    800035a0:	ec56                	sd	s5,24(sp)
    800035a2:	e45e                	sd	s7,8(sp)
    800035a4:	e062                	sd	s8,0(sp)
    int i = 0;
    800035a6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800035a8:	6b85                	lui	s7,0x1
    800035aa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800035ae:	6c05                	lui	s8,0x1
    800035b0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800035b4:	a8b5                	j	80003630 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800035b6:	6908                	ld	a0,16(a0)
    800035b8:	1fc000ef          	jal	800037b4 <pipewrite>
    800035bc:	a04d                	j	8000365e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800035be:	02451783          	lh	a5,36(a0)
    800035c2:	03079693          	slli	a3,a5,0x30
    800035c6:	92c1                	srli	a3,a3,0x30
    800035c8:	4725                	li	a4,9
    800035ca:	0ad76e63          	bltu	a4,a3,80003686 <filewrite+0x11e>
    800035ce:	0792                	slli	a5,a5,0x4
    800035d0:	00017717          	auipc	a4,0x17
    800035d4:	f9870713          	addi	a4,a4,-104 # 8001a568 <devsw>
    800035d8:	97ba                	add	a5,a5,a4
    800035da:	679c                	ld	a5,8(a5)
    800035dc:	c7dd                	beqz	a5,8000368a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800035de:	4505                	li	a0,1
    800035e0:	9782                	jalr	a5
    800035e2:	a8b5                	j	8000365e <filewrite+0xf6>
      if(n1 > max)
    800035e4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800035e8:	989ff0ef          	jal	80002f70 <begin_op>
      ilock(f->ip);
    800035ec:	01893503          	ld	a0,24(s2)
    800035f0:	8eaff0ef          	jal	800026da <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800035f4:	8756                	mv	a4,s5
    800035f6:	02092683          	lw	a3,32(s2)
    800035fa:	01698633          	add	a2,s3,s6
    800035fe:	4585                	li	a1,1
    80003600:	01893503          	ld	a0,24(s2)
    80003604:	c26ff0ef          	jal	80002a2a <writei>
    80003608:	84aa                	mv	s1,a0
    8000360a:	00a05763          	blez	a0,80003618 <filewrite+0xb0>
        f->off += r;
    8000360e:	02092783          	lw	a5,32(s2)
    80003612:	9fa9                	addw	a5,a5,a0
    80003614:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003618:	01893503          	ld	a0,24(s2)
    8000361c:	96cff0ef          	jal	80002788 <iunlock>
      end_op();
    80003620:	9bbff0ef          	jal	80002fda <end_op>

      if(r != n1){
    80003624:	029a9563          	bne	s5,s1,8000364e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003628:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000362c:	0149da63          	bge	s3,s4,80003640 <filewrite+0xd8>
      int n1 = n - i;
    80003630:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003634:	0004879b          	sext.w	a5,s1
    80003638:	fafbd6e3          	bge	s7,a5,800035e4 <filewrite+0x7c>
    8000363c:	84e2                	mv	s1,s8
    8000363e:	b75d                	j	800035e4 <filewrite+0x7c>
    80003640:	74e2                	ld	s1,56(sp)
    80003642:	6ae2                	ld	s5,24(sp)
    80003644:	6ba2                	ld	s7,8(sp)
    80003646:	6c02                	ld	s8,0(sp)
    80003648:	a039                	j	80003656 <filewrite+0xee>
    int i = 0;
    8000364a:	4981                	li	s3,0
    8000364c:	a029                	j	80003656 <filewrite+0xee>
    8000364e:	74e2                	ld	s1,56(sp)
    80003650:	6ae2                	ld	s5,24(sp)
    80003652:	6ba2                	ld	s7,8(sp)
    80003654:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003656:	033a1c63          	bne	s4,s3,8000368e <filewrite+0x126>
    8000365a:	8552                	mv	a0,s4
    8000365c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000365e:	60a6                	ld	ra,72(sp)
    80003660:	6406                	ld	s0,64(sp)
    80003662:	7942                	ld	s2,48(sp)
    80003664:	7a02                	ld	s4,32(sp)
    80003666:	6b42                	ld	s6,16(sp)
    80003668:	6161                	addi	sp,sp,80
    8000366a:	8082                	ret
    8000366c:	fc26                	sd	s1,56(sp)
    8000366e:	f44e                	sd	s3,40(sp)
    80003670:	ec56                	sd	s5,24(sp)
    80003672:	e45e                	sd	s7,8(sp)
    80003674:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003676:	00004517          	auipc	a0,0x4
    8000367a:	f3250513          	addi	a0,a0,-206 # 800075a8 <etext+0x5a8>
    8000367e:	615010ef          	jal	80005492 <panic>
    return -1;
    80003682:	557d                	li	a0,-1
}
    80003684:	8082                	ret
      return -1;
    80003686:	557d                	li	a0,-1
    80003688:	bfd9                	j	8000365e <filewrite+0xf6>
    8000368a:	557d                	li	a0,-1
    8000368c:	bfc9                	j	8000365e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000368e:	557d                	li	a0,-1
    80003690:	79a2                	ld	s3,40(sp)
    80003692:	b7f1                	j	8000365e <filewrite+0xf6>

0000000080003694 <pipealloc>:
};

//nitializes a pipe, and returns two file descriptors: one for read and one for write 
int
pipealloc(struct file **f0, struct file **f1)
{
    80003694:	7179                	addi	sp,sp,-48
    80003696:	f406                	sd	ra,40(sp)
    80003698:	f022                	sd	s0,32(sp)
    8000369a:	ec26                	sd	s1,24(sp)
    8000369c:	e052                	sd	s4,0(sp)
    8000369e:	1800                	addi	s0,sp,48
    800036a0:	84aa                	mv	s1,a0
    800036a2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  //initialize file descriptors
  pi = 0;
  *f0 = *f1 = 0;
    800036a4:	0005b023          	sd	zero,0(a1)
    800036a8:	00053023          	sd	zero,0(a0)
  //allocate descriptors
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800036ac:	c3bff0ef          	jal	800032e6 <filealloc>
    800036b0:	e088                	sd	a0,0(s1)
    800036b2:	c549                	beqz	a0,8000373c <pipealloc+0xa8>
    800036b4:	c33ff0ef          	jal	800032e6 <filealloc>
    800036b8:	00aa3023          	sd	a0,0(s4)
    800036bc:	cd25                	beqz	a0,80003734 <pipealloc+0xa0>
    800036be:	e84a                	sd	s2,16(sp)
    goto bad;
  //allocate for pipe
  if((pi = (struct pipe*)kalloc()) == 0)
    800036c0:	a3ffc0ef          	jal	800000fe <kalloc>
    800036c4:	892a                	mv	s2,a0
    800036c6:	c12d                	beqz	a0,80003728 <pipealloc+0x94>
    800036c8:	e44e                	sd	s3,8(sp)
    goto bad;
  //set up values
  pi->readopen = 1;
    800036ca:	4985                	li	s3,1
    800036cc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800036d0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800036d4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800036d8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe"); // init lock
    800036dc:	00004597          	auipc	a1,0x4
    800036e0:	edc58593          	addi	a1,a1,-292 # 800075b8 <etext+0x5b8>
    800036e4:	05c020ef          	jal	80005740 <initlock>
  //set up values and link file with pipe
  (*f0)->type = FD_PIPE;
    800036e8:	609c                	ld	a5,0(s1)
    800036ea:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800036ee:	609c                	ld	a5,0(s1)
    800036f0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800036f4:	609c                	ld	a5,0(s1)
    800036f6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800036fa:	609c                	ld	a5,0(s1)
    800036fc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003700:	000a3783          	ld	a5,0(s4)
    80003704:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003708:	000a3783          	ld	a5,0(s4)
    8000370c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003710:	000a3783          	ld	a5,0(s4)
    80003714:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003718:	000a3783          	ld	a5,0(s4)
    8000371c:	0127b823          	sd	s2,16(a5)
  return 0;
    80003720:	4501                	li	a0,0
    80003722:	6942                	ld	s2,16(sp)
    80003724:	69a2                	ld	s3,8(sp)
    80003726:	a01d                	j	8000374c <pipealloc+0xb8>

//exception
 bad:
  if(pi)
    kfree((char*)pi); //deallocate pipe
  if(*f0)
    80003728:	6088                	ld	a0,0(s1)
    8000372a:	c119                	beqz	a0,80003730 <pipealloc+0x9c>
    8000372c:	6942                	ld	s2,16(sp)
    8000372e:	a029                	j	80003738 <pipealloc+0xa4>
    80003730:	6942                	ld	s2,16(sp)
    80003732:	a029                	j	8000373c <pipealloc+0xa8>
    80003734:	6088                	ld	a0,0(s1)
    80003736:	c10d                	beqz	a0,80003758 <pipealloc+0xc4>
    fileclose(*f0); //close file and release
    80003738:	c53ff0ef          	jal	8000338a <fileclose>
  if(*f1)
    8000373c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003740:	557d                	li	a0,-1
  if(*f1)
    80003742:	c789                	beqz	a5,8000374c <pipealloc+0xb8>
    fileclose(*f1);
    80003744:	853e                	mv	a0,a5
    80003746:	c45ff0ef          	jal	8000338a <fileclose>
  return -1;
    8000374a:	557d                	li	a0,-1
}
    8000374c:	70a2                	ld	ra,40(sp)
    8000374e:	7402                	ld	s0,32(sp)
    80003750:	64e2                	ld	s1,24(sp)
    80003752:	6a02                	ld	s4,0(sp)
    80003754:	6145                	addi	sp,sp,48
    80003756:	8082                	ret
  return -1;
    80003758:	557d                	li	a0,-1
    8000375a:	bfcd                	j	8000374c <pipealloc+0xb8>

000000008000375c <pipeclose>:
//Close one end of the pipe (read or write). If both ends are closed, release the pipe's memory.
// writable = 1 => writable = 0
// writable = 0 => readable = 0
void
pipeclose(struct pipe *pi, int writable)
{
    8000375c:	1101                	addi	sp,sp,-32
    8000375e:	ec06                	sd	ra,24(sp)
    80003760:	e822                	sd	s0,16(sp)
    80003762:	e426                	sd	s1,8(sp)
    80003764:	e04a                	sd	s2,0(sp)
    80003766:	1000                	addi	s0,sp,32
    80003768:	84aa                	mv	s1,a0
    8000376a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000376c:	054020ef          	jal	800057c0 <acquire>
  if(writable){
    80003770:	02090763          	beqz	s2,8000379e <pipeclose+0x42>
    pi->writeopen = 0;
    80003774:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread); // wake the reader up when the writer close
    80003778:	21848513          	addi	a0,s1,536
    8000377c:	c0dfd0ef          	jal	80001388 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite); // wake the write up when the reader close
  }
  // if all are close, release the memory
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003780:	2204b783          	ld	a5,544(s1)
    80003784:	e785                	bnez	a5,800037ac <pipeclose+0x50>
    release(&pi->lock); // release lock
    80003786:	8526                	mv	a0,s1
    80003788:	0d0020ef          	jal	80005858 <release>
    kfree((char*)pi); // deallocate
    8000378c:	8526                	mv	a0,s1
    8000378e:	88ffc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003792:	60e2                	ld	ra,24(sp)
    80003794:	6442                	ld	s0,16(sp)
    80003796:	64a2                	ld	s1,8(sp)
    80003798:	6902                	ld	s2,0(sp)
    8000379a:	6105                	addi	sp,sp,32
    8000379c:	8082                	ret
    pi->readopen = 0;
    8000379e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite); // wake the write up when the reader close
    800037a2:	21c48513          	addi	a0,s1,540
    800037a6:	be3fd0ef          	jal	80001388 <wakeup>
    800037aa:	bfd9                	j	80003780 <pipeclose+0x24>
    release(&pi->lock);
    800037ac:	8526                	mv	a0,s1
    800037ae:	0aa020ef          	jal	80005858 <release>
}
    800037b2:	b7c5                	j	80003792 <pipeclose+0x36>

00000000800037b4 <pipewrite>:

//Writes data from the process's memory to the pipe.
int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800037b4:	711d                	addi	sp,sp,-96
    800037b6:	ec86                	sd	ra,88(sp)
    800037b8:	e8a2                	sd	s0,80(sp)
    800037ba:	e4a6                	sd	s1,72(sp)
    800037bc:	e0ca                	sd	s2,64(sp)
    800037be:	fc4e                	sd	s3,56(sp)
    800037c0:	f852                	sd	s4,48(sp)
    800037c2:	f456                	sd	s5,40(sp)
    800037c4:	1080                	addi	s0,sp,96
    800037c6:	84aa                	mv	s1,a0
    800037c8:	8aae                	mv	s5,a1
    800037ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800037cc:	d9afd0ef          	jal	80000d66 <myproc>
    800037d0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800037d2:	8526                	mv	a0,s1
    800037d4:	7ed010ef          	jal	800057c0 <acquire>
  while(i < n){
    800037d8:	0b405a63          	blez	s4,8000388c <pipewrite+0xd8>
    800037dc:	f05a                	sd	s6,32(sp)
    800037de:	ec5e                	sd	s7,24(sp)
    800037e0:	e862                	sd	s8,16(sp)
  int i = 0;
    800037e2:	4901                	li	s2,0
      wakeup(&pi->nread); //wake up reader
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    } else {
      char ch;
      //read each byte from the process's memory (copyin) and write to the pipe's circular buffer
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800037e4:	5b7d                	li	s6,-1
      wakeup(&pi->nread); //wake up reader
    800037e6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    800037ea:	21c48b93          	addi	s7,s1,540
    800037ee:	a81d                	j	80003824 <pipewrite+0x70>
      release(&pi->lock);
    800037f0:	8526                	mv	a0,s1
    800037f2:	066020ef          	jal	80005858 <release>
      return -1;
    800037f6:	597d                	li	s2,-1
    800037f8:	7b02                	ld	s6,32(sp)
    800037fa:	6be2                	ld	s7,24(sp)
    800037fc:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800037fe:	854a                	mv	a0,s2
    80003800:	60e6                	ld	ra,88(sp)
    80003802:	6446                	ld	s0,80(sp)
    80003804:	64a6                	ld	s1,72(sp)
    80003806:	6906                	ld	s2,64(sp)
    80003808:	79e2                	ld	s3,56(sp)
    8000380a:	7a42                	ld	s4,48(sp)
    8000380c:	7aa2                	ld	s5,40(sp)
    8000380e:	6125                	addi	sp,sp,96
    80003810:	8082                	ret
      wakeup(&pi->nread); //wake up reader
    80003812:	8562                	mv	a0,s8
    80003814:	b75fd0ef          	jal	80001388 <wakeup>
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    80003818:	85a6                	mv	a1,s1
    8000381a:	855e                	mv	a0,s7
    8000381c:	b21fd0ef          	jal	8000133c <sleep>
  while(i < n){
    80003820:	05495b63          	bge	s2,s4,80003876 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003824:	2204a783          	lw	a5,544(s1)
    80003828:	d7e1                	beqz	a5,800037f0 <pipewrite+0x3c>
    8000382a:	854e                	mv	a0,s3
    8000382c:	d49fd0ef          	jal	80001574 <killed>
    80003830:	f161                	bnez	a0,800037f0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full cannot write more
    80003832:	2184a783          	lw	a5,536(s1)
    80003836:	21c4a703          	lw	a4,540(s1)
    8000383a:	2007879b          	addiw	a5,a5,512
    8000383e:	fcf70ae3          	beq	a4,a5,80003812 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003842:	4685                	li	a3,1
    80003844:	01590633          	add	a2,s2,s5
    80003848:	faf40593          	addi	a1,s0,-81
    8000384c:	0509b503          	ld	a0,80(s3)
    80003850:	a5efd0ef          	jal	80000aae <copyin>
    80003854:	03650e63          	beq	a0,s6,80003890 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003858:	21c4a783          	lw	a5,540(s1)
    8000385c:	0017871b          	addiw	a4,a5,1
    80003860:	20e4ae23          	sw	a4,540(s1)
    80003864:	1ff7f793          	andi	a5,a5,511
    80003868:	97a6                	add	a5,a5,s1
    8000386a:	faf44703          	lbu	a4,-81(s0)
    8000386e:	00e78c23          	sb	a4,24(a5)
      i++;
    80003872:	2905                	addiw	s2,s2,1
    80003874:	b775                	j	80003820 <pipewrite+0x6c>
    80003876:	7b02                	ld	s6,32(sp)
    80003878:	6be2                	ld	s7,24(sp)
    8000387a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000387c:	21848513          	addi	a0,s1,536
    80003880:	b09fd0ef          	jal	80001388 <wakeup>
  release(&pi->lock);
    80003884:	8526                	mv	a0,s1
    80003886:	7d3010ef          	jal	80005858 <release>
  return i;
    8000388a:	bf95                	j	800037fe <pipewrite+0x4a>
  int i = 0;
    8000388c:	4901                	li	s2,0
    8000388e:	b7fd                	j	8000387c <pipewrite+0xc8>
    80003890:	7b02                	ld	s6,32(sp)
    80003892:	6be2                	ld	s7,24(sp)
    80003894:	6c42                	ld	s8,16(sp)
    80003896:	b7dd                	j	8000387c <pipewrite+0xc8>

0000000080003898 <piperead>:

//Read data from the pipe into the process's memory.
int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003898:	715d                	addi	sp,sp,-80
    8000389a:	e486                	sd	ra,72(sp)
    8000389c:	e0a2                	sd	s0,64(sp)
    8000389e:	fc26                	sd	s1,56(sp)
    800038a0:	f84a                	sd	s2,48(sp)
    800038a2:	f44e                	sd	s3,40(sp)
    800038a4:	f052                	sd	s4,32(sp)
    800038a6:	ec56                	sd	s5,24(sp)
    800038a8:	0880                	addi	s0,sp,80
    800038aa:	84aa                	mv	s1,a0
    800038ac:	892e                	mv	s2,a1
    800038ae:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800038b0:	cb6fd0ef          	jal	80000d66 <myproc>
    800038b4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800038b6:	8526                	mv	a0,s1
    800038b8:	709010ef          	jal	800057c0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038bc:	2184a703          	lw	a4,536(s1)
    800038c0:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    //waiting
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038c4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038c8:	02f71563          	bne	a4,a5,800038f2 <piperead+0x5a>
    800038cc:	2244a783          	lw	a5,548(s1)
    800038d0:	cb85                	beqz	a5,80003900 <piperead+0x68>
    if(killed(pr)){
    800038d2:	8552                	mv	a0,s4
    800038d4:	ca1fd0ef          	jal	80001574 <killed>
    800038d8:	ed19                	bnez	a0,800038f6 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038da:	85a6                	mv	a1,s1
    800038dc:	854e                	mv	a0,s3
    800038de:	a5ffd0ef          	jal	8000133c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038e2:	2184a703          	lw	a4,536(s1)
    800038e6:	21c4a783          	lw	a5,540(s1)
    800038ea:	fef701e3          	beq	a4,a5,800038cc <piperead+0x34>
    800038ee:	e85a                	sd	s6,16(sp)
    800038f0:	a809                	j	80003902 <piperead+0x6a>
    800038f2:	e85a                	sd	s6,16(sp)
    800038f4:	a039                	j	80003902 <piperead+0x6a>
      release(&pi->lock);
    800038f6:	8526                	mv	a0,s1
    800038f8:	761010ef          	jal	80005858 <release>
      return -1;
    800038fc:	59fd                	li	s3,-1
    800038fe:	a8b1                	j	8000395a <piperead+0xc2>
    80003900:	e85a                	sd	s6,16(sp)
  }
  //Read each byte from the pipe's circular buffer and write it to the process's memory (copyout).
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003902:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    //increasing nread after reading
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003904:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003906:	05505263          	blez	s5,8000394a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000390a:	2184a783          	lw	a5,536(s1)
    8000390e:	21c4a703          	lw	a4,540(s1)
    80003912:	02f70c63          	beq	a4,a5,8000394a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003916:	0017871b          	addiw	a4,a5,1
    8000391a:	20e4ac23          	sw	a4,536(s1)
    8000391e:	1ff7f793          	andi	a5,a5,511
    80003922:	97a6                	add	a5,a5,s1
    80003924:	0187c783          	lbu	a5,24(a5)
    80003928:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000392c:	4685                	li	a3,1
    8000392e:	fbf40613          	addi	a2,s0,-65
    80003932:	85ca                	mv	a1,s2
    80003934:	050a3503          	ld	a0,80(s4)
    80003938:	8a0fd0ef          	jal	800009d8 <copyout>
    8000393c:	01650763          	beq	a0,s6,8000394a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003940:	2985                	addiw	s3,s3,1
    80003942:	0905                	addi	s2,s2,1
    80003944:	fd3a93e3          	bne	s5,s3,8000390a <piperead+0x72>
    80003948:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000394a:	21c48513          	addi	a0,s1,540
    8000394e:	a3bfd0ef          	jal	80001388 <wakeup>
  release(&pi->lock);
    80003952:	8526                	mv	a0,s1
    80003954:	705010ef          	jal	80005858 <release>
    80003958:	6b42                	ld	s6,16(sp)
  return i;
}
    8000395a:	854e                	mv	a0,s3
    8000395c:	60a6                	ld	ra,72(sp)
    8000395e:	6406                	ld	s0,64(sp)
    80003960:	74e2                	ld	s1,56(sp)
    80003962:	7942                	ld	s2,48(sp)
    80003964:	79a2                	ld	s3,40(sp)
    80003966:	7a02                	ld	s4,32(sp)
    80003968:	6ae2                	ld	s5,24(sp)
    8000396a:	6161                	addi	sp,sp,80
    8000396c:	8082                	ret

000000008000396e <flags2perm>:
//Load file contents into memory
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

//convert ELF flag into type of access  
int flags2perm(int flags)
{
    8000396e:	1141                	addi	sp,sp,-16
    80003970:	e422                	sd	s0,8(sp)
    80003972:	0800                	addi	s0,sp,16
    80003974:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003976:	8905                	andi	a0,a0,1
    80003978:	050e                	slli	a0,a0,0x3
      perm = PTE_X; //execute access
    if(flags & 0x2)
    8000397a:	8b89                	andi	a5,a5,2
    8000397c:	c399                	beqz	a5,80003982 <flags2perm+0x14>
      perm |= PTE_W; //write access
    8000397e:	00456513          	ori	a0,a0,4
    return perm;
}
    80003982:	6422                	ld	s0,8(sp)
    80003984:	0141                	addi	sp,sp,16
    80003986:	8082                	ret

0000000080003988 <exec>:

//execute file
int
exec(char *path, char **argv)
{
    80003988:	df010113          	addi	sp,sp,-528
    8000398c:	20113423          	sd	ra,520(sp)
    80003990:	20813023          	sd	s0,512(sp)
    80003994:	ffa6                	sd	s1,504(sp)
    80003996:	fbca                	sd	s2,496(sp)
    80003998:	0c00                	addi	s0,sp,528
    8000399a:	892a                	mv	s2,a0
    8000399c:	dea43c23          	sd	a0,-520(s0)
    800039a0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800039a4:	bc2fd0ef          	jal	80000d66 <myproc>
    800039a8:	84aa                	mv	s1,a0

// open execute file
  begin_op(); //begin a transaction of file system
    800039aa:	dc6ff0ef          	jal	80002f70 <begin_op>

  if((ip = namei(path)) == 0){ //find inode 
    800039ae:	854a                	mv	a0,s2
    800039b0:	c04ff0ef          	jal	80002db4 <namei>
    800039b4:	c931                	beqz	a0,80003a08 <exec+0x80>
    800039b6:	f3d2                	sd	s4,480(sp)
    800039b8:	8a2a                	mv	s4,a0
    end_op(); // end transaction
    return -1;
  }
  ilock(ip); //lock inode to make sure that inode can not be modified during executing
    800039ba:	d21fe0ef          	jal	800026da <ilock>

  //read and check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) //read
    800039be:	04000713          	li	a4,64
    800039c2:	4681                	li	a3,0
    800039c4:	e5040613          	addi	a2,s0,-432
    800039c8:	4581                	li	a1,0
    800039ca:	8552                	mv	a0,s4
    800039cc:	f63fe0ef          	jal	8000292e <readi>
    800039d0:	04000793          	li	a5,64
    800039d4:	00f51a63          	bne	a0,a5,800039e8 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC) //check
    800039d8:	e5042703          	lw	a4,-432(s0)
    800039dc:	464c47b7          	lui	a5,0x464c4
    800039e0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800039e4:	02f70663          	beq	a4,a5,80003a10 <exec+0x88>
//handle the unvalid
 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800039e8:	8552                	mv	a0,s4
    800039ea:	efbfe0ef          	jal	800028e4 <iunlockput>
    end_op();
    800039ee:	decff0ef          	jal	80002fda <end_op>
  }
  return -1;
    800039f2:	557d                	li	a0,-1
    800039f4:	7a1e                	ld	s4,480(sp)
}
    800039f6:	20813083          	ld	ra,520(sp)
    800039fa:	20013403          	ld	s0,512(sp)
    800039fe:	74fe                	ld	s1,504(sp)
    80003a00:	795e                	ld	s2,496(sp)
    80003a02:	21010113          	addi	sp,sp,528
    80003a06:	8082                	ret
    end_op(); // end transaction
    80003a08:	dd2ff0ef          	jal	80002fda <end_op>
    return -1;
    80003a0c:	557d                	li	a0,-1
    80003a0e:	b7e5                	j	800039f6 <exec+0x6e>
    80003a10:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0) //create new pagetable for executing
    80003a12:	8526                	mv	a0,s1
    80003a14:	bfafd0ef          	jal	80000e0e <proc_pagetable>
    80003a18:	8b2a                	mv	s6,a0
    80003a1a:	2c050b63          	beqz	a0,80003cf0 <exec+0x368>
    80003a1e:	f7ce                	sd	s3,488(sp)
    80003a20:	efd6                	sd	s5,472(sp)
    80003a22:	e7de                	sd	s7,456(sp)
    80003a24:	e3e2                	sd	s8,448(sp)
    80003a26:	ff66                	sd	s9,440(sp)
    80003a28:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a2a:	e7042d03          	lw	s10,-400(s0)
    80003a2e:	e8845783          	lhu	a5,-376(s0)
    80003a32:	12078963          	beqz	a5,80003b64 <exec+0x1dc>
    80003a36:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003a38:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a3a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003a3c:	6c85                	lui	s9,0x1
    80003a3e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003a42:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003a46:	6a85                	lui	s5,0x1
    80003a48:	a085                	j	80003aa8 <exec+0x120>
      panic("loadseg: address should exist");
    80003a4a:	00004517          	auipc	a0,0x4
    80003a4e:	b7650513          	addi	a0,a0,-1162 # 800075c0 <etext+0x5c0>
    80003a52:	241010ef          	jal	80005492 <panic>
    if(sz - i < PGSIZE)
    80003a56:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003a58:	8726                	mv	a4,s1
    80003a5a:	012c06bb          	addw	a3,s8,s2
    80003a5e:	4581                	li	a1,0
    80003a60:	8552                	mv	a0,s4
    80003a62:	ecdfe0ef          	jal	8000292e <readi>
    80003a66:	2501                	sext.w	a0,a0
    80003a68:	24a49a63          	bne	s1,a0,80003cbc <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003a6c:	012a893b          	addw	s2,s5,s2
    80003a70:	03397363          	bgeu	s2,s3,80003a96 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003a74:	02091593          	slli	a1,s2,0x20
    80003a78:	9181                	srli	a1,a1,0x20
    80003a7a:	95de                	add	a1,a1,s7
    80003a7c:	855a                	mv	a0,s6
    80003a7e:	9dffc0ef          	jal	8000045c <walkaddr>
    80003a82:	862a                	mv	a2,a0
    if(pa == 0)
    80003a84:	d179                	beqz	a0,80003a4a <exec+0xc2>
    if(sz - i < PGSIZE)
    80003a86:	412984bb          	subw	s1,s3,s2
    80003a8a:	0004879b          	sext.w	a5,s1
    80003a8e:	fcfcf4e3          	bgeu	s9,a5,80003a56 <exec+0xce>
    80003a92:	84d6                	mv	s1,s5
    80003a94:	b7c9                	j	80003a56 <exec+0xce>
    sz = sz1;
    80003a96:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a9a:	2d85                	addiw	s11,s11,1
    80003a9c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003aa0:	e8845783          	lhu	a5,-376(s0)
    80003aa4:	08fdd063          	bge	s11,a5,80003b24 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003aa8:	2d01                	sext.w	s10,s10
    80003aaa:	03800713          	li	a4,56
    80003aae:	86ea                	mv	a3,s10
    80003ab0:	e1840613          	addi	a2,s0,-488
    80003ab4:	4581                	li	a1,0
    80003ab6:	8552                	mv	a0,s4
    80003ab8:	e77fe0ef          	jal	8000292e <readi>
    80003abc:	03800793          	li	a5,56
    80003ac0:	1cf51663          	bne	a0,a5,80003c8c <exec+0x304>
    if(ph.type != ELF_PROG_LOAD) //checks if a segment is the type to load into memory 
    80003ac4:	e1842783          	lw	a5,-488(s0)
    80003ac8:	4705                	li	a4,1
    80003aca:	fce798e3          	bne	a5,a4,80003a9a <exec+0x112>
    if(ph.memsz < ph.filesz) //memory size >= file size
    80003ace:	e4043483          	ld	s1,-448(s0)
    80003ad2:	e3843783          	ld	a5,-456(s0)
    80003ad6:	1af4ef63          	bltu	s1,a5,80003c94 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr) //address must align to the page size
    80003ada:	e2843783          	ld	a5,-472(s0)
    80003ade:	94be                	add	s1,s1,a5
    80003ae0:	1af4ee63          	bltu	s1,a5,80003c9c <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003ae4:	df043703          	ld	a4,-528(s0)
    80003ae8:	8ff9                	and	a5,a5,a4
    80003aea:	1a079d63          	bnez	a5,80003ca4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)//allocate memory for segment
    80003aee:	e1c42503          	lw	a0,-484(s0)
    80003af2:	e7dff0ef          	jal	8000396e <flags2perm>
    80003af6:	86aa                	mv	a3,a0
    80003af8:	8626                	mv	a2,s1
    80003afa:	85ca                	mv	a1,s2
    80003afc:	855a                	mv	a0,s6
    80003afe:	cc7fc0ef          	jal	800007c4 <uvmalloc>
    80003b02:	e0a43423          	sd	a0,-504(s0)
    80003b06:	1a050363          	beqz	a0,80003cac <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0) //Load file contents into memory
    80003b0a:	e2843b83          	ld	s7,-472(s0)
    80003b0e:	e2042c03          	lw	s8,-480(s0)
    80003b12:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003b16:	00098463          	beqz	s3,80003b1e <exec+0x196>
    80003b1a:	4901                	li	s2,0
    80003b1c:	bfa1                	j	80003a74 <exec+0xec>
    sz = sz1;
    80003b1e:	e0843903          	ld	s2,-504(s0)
    80003b22:	bfa5                	j	80003a9a <exec+0x112>
    80003b24:	7dba                	ld	s11,424(sp)
  iunlockput(ip); //unlock ip
    80003b26:	8552                	mv	a0,s4
    80003b28:	dbdfe0ef          	jal	800028e4 <iunlockput>
  end_op(); // end transaction
    80003b2c:	caeff0ef          	jal	80002fda <end_op>
  p = myproc();
    80003b30:	a36fd0ef          	jal	80000d66 <myproc>
    80003b34:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003b36:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz); //round the value
    80003b3a:	6985                	lui	s3,0x1
    80003b3c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003b3e:	99ca                	add	s3,s3,s2
    80003b40:	77fd                	lui	a5,0xfffff
    80003b42:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0) //allocate stack space in memory.
    80003b46:	4691                	li	a3,4
    80003b48:	660d                	lui	a2,0x3
    80003b4a:	964e                	add	a2,a2,s3
    80003b4c:	85ce                	mv	a1,s3
    80003b4e:	855a                	mv	a0,s6
    80003b50:	c75fc0ef          	jal	800007c4 <uvmalloc>
    80003b54:	892a                	mv	s2,a0
    80003b56:	e0a43423          	sd	a0,-504(s0)
    80003b5a:	e519                	bnez	a0,80003b68 <exec+0x1e0>
  if(pagetable)
    80003b5c:	e1343423          	sd	s3,-504(s0)
    80003b60:	4a01                	li	s4,0
    80003b62:	aab1                	j	80003cbe <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b64:	4901                	li	s2,0
    80003b66:	b7c1                	j	80003b26 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE); //makes the first page inaccessible, acting as a "stack guard".
    80003b68:	75f5                	lui	a1,0xffffd
    80003b6a:	95aa                	add	a1,a1,a0
    80003b6c:	855a                	mv	a0,s6
    80003b6e:	e41fc0ef          	jal	800009ae <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003b72:	7bf9                	lui	s7,0xffffe
    80003b74:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003b76:	e0043783          	ld	a5,-512(s0)
    80003b7a:	6388                	ld	a0,0(a5)
    80003b7c:	cd39                	beqz	a0,80003bda <exec+0x252>
    80003b7e:	e9040993          	addi	s3,s0,-368
    80003b82:	f9040c13          	addi	s8,s0,-112
    80003b86:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003b88:	f36fc0ef          	jal	800002be <strlen>
    80003b8c:	0015079b          	addiw	a5,a0,1
    80003b90:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003b94:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003b98:	11796e63          	bltu	s2,s7,80003cb4 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003b9c:	e0043d03          	ld	s10,-512(s0)
    80003ba0:	000d3a03          	ld	s4,0(s10)
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	f18fc0ef          	jal	800002be <strlen>
    80003baa:	0015069b          	addiw	a3,a0,1
    80003bae:	8652                	mv	a2,s4
    80003bb0:	85ca                	mv	a1,s2
    80003bb2:	855a                	mv	a0,s6
    80003bb4:	e25fc0ef          	jal	800009d8 <copyout>
    80003bb8:	10054063          	bltz	a0,80003cb8 <exec+0x330>
    ustack[argc] = sp;
    80003bbc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003bc0:	0485                	addi	s1,s1,1
    80003bc2:	008d0793          	addi	a5,s10,8
    80003bc6:	e0f43023          	sd	a5,-512(s0)
    80003bca:	008d3503          	ld	a0,8(s10)
    80003bce:	c909                	beqz	a0,80003be0 <exec+0x258>
    if(argc >= MAXARG)
    80003bd0:	09a1                	addi	s3,s3,8
    80003bd2:	fb899be3          	bne	s3,s8,80003b88 <exec+0x200>
  ip = 0;
    80003bd6:	4a01                	li	s4,0
    80003bd8:	a0dd                	j	80003cbe <exec+0x336>
  sp = sz;
    80003bda:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003bde:	4481                	li	s1,0
  ustack[argc] = 0;
    80003be0:	00349793          	slli	a5,s1,0x3
    80003be4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb790>
    80003be8:	97a2                	add	a5,a5,s0
    80003bea:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003bee:	00148693          	addi	a3,s1,1
    80003bf2:	068e                	slli	a3,a3,0x3
    80003bf4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003bf8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003bfc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003c00:	f5796ee3          	bltu	s2,s7,80003b5c <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003c04:	e9040613          	addi	a2,s0,-368
    80003c08:	85ca                	mv	a1,s2
    80003c0a:	855a                	mv	a0,s6
    80003c0c:	dcdfc0ef          	jal	800009d8 <copyout>
    80003c10:	0e054263          	bltz	a0,80003cf4 <exec+0x36c>
  p->trapframe->a1 = sp;
    80003c14:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003c18:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003c1c:	df843783          	ld	a5,-520(s0)
    80003c20:	0007c703          	lbu	a4,0(a5)
    80003c24:	cf11                	beqz	a4,80003c40 <exec+0x2b8>
    80003c26:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003c28:	02f00693          	li	a3,47
    80003c2c:	a039                	j	80003c3a <exec+0x2b2>
      last = s+1;
    80003c2e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003c32:	0785                	addi	a5,a5,1
    80003c34:	fff7c703          	lbu	a4,-1(a5)
    80003c38:	c701                	beqz	a4,80003c40 <exec+0x2b8>
    if(*s == '/')
    80003c3a:	fed71ce3          	bne	a4,a3,80003c32 <exec+0x2aa>
    80003c3e:	bfc5                	j	80003c2e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003c40:	4641                	li	a2,16
    80003c42:	df843583          	ld	a1,-520(s0)
    80003c46:	158a8513          	addi	a0,s5,344
    80003c4a:	e42fc0ef          	jal	8000028c <safestrcpy>
  oldpagetable = p->pagetable;
    80003c4e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003c52:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003c56:	e0843783          	ld	a5,-504(s0)
    80003c5a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003c5e:	058ab783          	ld	a5,88(s5)
    80003c62:	e6843703          	ld	a4,-408(s0)
    80003c66:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003c68:	058ab783          	ld	a5,88(s5)
    80003c6c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); //deallocate the old page table
    80003c70:	85e6                	mv	a1,s9
    80003c72:	a20fd0ef          	jal	80000e92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003c76:	0004851b          	sext.w	a0,s1
    80003c7a:	79be                	ld	s3,488(sp)
    80003c7c:	7a1e                	ld	s4,480(sp)
    80003c7e:	6afe                	ld	s5,472(sp)
    80003c80:	6b5e                	ld	s6,464(sp)
    80003c82:	6bbe                	ld	s7,456(sp)
    80003c84:	6c1e                	ld	s8,448(sp)
    80003c86:	7cfa                	ld	s9,440(sp)
    80003c88:	7d5a                	ld	s10,432(sp)
    80003c8a:	b3b5                	j	800039f6 <exec+0x6e>
    80003c8c:	e1243423          	sd	s2,-504(s0)
    80003c90:	7dba                	ld	s11,424(sp)
    80003c92:	a035                	j	80003cbe <exec+0x336>
    80003c94:	e1243423          	sd	s2,-504(s0)
    80003c98:	7dba                	ld	s11,424(sp)
    80003c9a:	a015                	j	80003cbe <exec+0x336>
    80003c9c:	e1243423          	sd	s2,-504(s0)
    80003ca0:	7dba                	ld	s11,424(sp)
    80003ca2:	a831                	j	80003cbe <exec+0x336>
    80003ca4:	e1243423          	sd	s2,-504(s0)
    80003ca8:	7dba                	ld	s11,424(sp)
    80003caa:	a811                	j	80003cbe <exec+0x336>
    80003cac:	e1243423          	sd	s2,-504(s0)
    80003cb0:	7dba                	ld	s11,424(sp)
    80003cb2:	a031                	j	80003cbe <exec+0x336>
  ip = 0;
    80003cb4:	4a01                	li	s4,0
    80003cb6:	a021                	j	80003cbe <exec+0x336>
    80003cb8:	4a01                	li	s4,0
  if(pagetable)
    80003cba:	a011                	j	80003cbe <exec+0x336>
    80003cbc:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003cbe:	e0843583          	ld	a1,-504(s0)
    80003cc2:	855a                	mv	a0,s6
    80003cc4:	9cefd0ef          	jal	80000e92 <proc_freepagetable>
  return -1;
    80003cc8:	557d                	li	a0,-1
  if(ip){
    80003cca:	000a1b63          	bnez	s4,80003ce0 <exec+0x358>
    80003cce:	79be                	ld	s3,488(sp)
    80003cd0:	7a1e                	ld	s4,480(sp)
    80003cd2:	6afe                	ld	s5,472(sp)
    80003cd4:	6b5e                	ld	s6,464(sp)
    80003cd6:	6bbe                	ld	s7,456(sp)
    80003cd8:	6c1e                	ld	s8,448(sp)
    80003cda:	7cfa                	ld	s9,440(sp)
    80003cdc:	7d5a                	ld	s10,432(sp)
    80003cde:	bb21                	j	800039f6 <exec+0x6e>
    80003ce0:	79be                	ld	s3,488(sp)
    80003ce2:	6afe                	ld	s5,472(sp)
    80003ce4:	6b5e                	ld	s6,464(sp)
    80003ce6:	6bbe                	ld	s7,456(sp)
    80003ce8:	6c1e                	ld	s8,448(sp)
    80003cea:	7cfa                	ld	s9,440(sp)
    80003cec:	7d5a                	ld	s10,432(sp)
    80003cee:	b9ed                	j	800039e8 <exec+0x60>
    80003cf0:	6b5e                	ld	s6,464(sp)
    80003cf2:	b9dd                	j	800039e8 <exec+0x60>
  sz = sz1;
    80003cf4:	e0843983          	ld	s3,-504(s0)
    80003cf8:	b595                	j	80003b5c <exec+0x1d4>

0000000080003cfa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003cfa:	7179                	addi	sp,sp,-48
    80003cfc:	f406                	sd	ra,40(sp)
    80003cfe:	f022                	sd	s0,32(sp)
    80003d00:	ec26                	sd	s1,24(sp)
    80003d02:	e84a                	sd	s2,16(sp)
    80003d04:	1800                	addi	s0,sp,48
    80003d06:	892e                	mv	s2,a1
    80003d08:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003d0a:	fdc40593          	addi	a1,s0,-36
    80003d0e:	f15fd0ef          	jal	80001c22 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003d12:	fdc42703          	lw	a4,-36(s0)
    80003d16:	47bd                	li	a5,15
    80003d18:	02e7e963          	bltu	a5,a4,80003d4a <argfd+0x50>
    80003d1c:	84afd0ef          	jal	80000d66 <myproc>
    80003d20:	fdc42703          	lw	a4,-36(s0)
    80003d24:	01a70793          	addi	a5,a4,26
    80003d28:	078e                	slli	a5,a5,0x3
    80003d2a:	953e                	add	a0,a0,a5
    80003d2c:	611c                	ld	a5,0(a0)
    80003d2e:	c385                	beqz	a5,80003d4e <argfd+0x54>
    return -1;
  if(pfd)
    80003d30:	00090463          	beqz	s2,80003d38 <argfd+0x3e>
    *pfd = fd;
    80003d34:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003d38:	4501                	li	a0,0
  if(pf)
    80003d3a:	c091                	beqz	s1,80003d3e <argfd+0x44>
    *pf = f;
    80003d3c:	e09c                	sd	a5,0(s1)
}
    80003d3e:	70a2                	ld	ra,40(sp)
    80003d40:	7402                	ld	s0,32(sp)
    80003d42:	64e2                	ld	s1,24(sp)
    80003d44:	6942                	ld	s2,16(sp)
    80003d46:	6145                	addi	sp,sp,48
    80003d48:	8082                	ret
    return -1;
    80003d4a:	557d                	li	a0,-1
    80003d4c:	bfcd                	j	80003d3e <argfd+0x44>
    80003d4e:	557d                	li	a0,-1
    80003d50:	b7fd                	j	80003d3e <argfd+0x44>

0000000080003d52 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003d52:	1101                	addi	sp,sp,-32
    80003d54:	ec06                	sd	ra,24(sp)
    80003d56:	e822                	sd	s0,16(sp)
    80003d58:	e426                	sd	s1,8(sp)
    80003d5a:	1000                	addi	s0,sp,32
    80003d5c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003d5e:	808fd0ef          	jal	80000d66 <myproc>
    80003d62:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003d64:	0d050793          	addi	a5,a0,208
    80003d68:	4501                	li	a0,0
    80003d6a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003d6c:	6398                	ld	a4,0(a5)
    80003d6e:	cb19                	beqz	a4,80003d84 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003d70:	2505                	addiw	a0,a0,1
    80003d72:	07a1                	addi	a5,a5,8
    80003d74:	fed51ce3          	bne	a0,a3,80003d6c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003d78:	557d                	li	a0,-1
}
    80003d7a:	60e2                	ld	ra,24(sp)
    80003d7c:	6442                	ld	s0,16(sp)
    80003d7e:	64a2                	ld	s1,8(sp)
    80003d80:	6105                	addi	sp,sp,32
    80003d82:	8082                	ret
      p->ofile[fd] = f;
    80003d84:	01a50793          	addi	a5,a0,26
    80003d88:	078e                	slli	a5,a5,0x3
    80003d8a:	963e                	add	a2,a2,a5
    80003d8c:	e204                	sd	s1,0(a2)
      return fd;
    80003d8e:	b7f5                	j	80003d7a <fdalloc+0x28>

0000000080003d90 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003d90:	715d                	addi	sp,sp,-80
    80003d92:	e486                	sd	ra,72(sp)
    80003d94:	e0a2                	sd	s0,64(sp)
    80003d96:	fc26                	sd	s1,56(sp)
    80003d98:	f84a                	sd	s2,48(sp)
    80003d9a:	f44e                	sd	s3,40(sp)
    80003d9c:	ec56                	sd	s5,24(sp)
    80003d9e:	e85a                	sd	s6,16(sp)
    80003da0:	0880                	addi	s0,sp,80
    80003da2:	8b2e                	mv	s6,a1
    80003da4:	89b2                	mv	s3,a2
    80003da6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003da8:	fb040593          	addi	a1,s0,-80
    80003dac:	822ff0ef          	jal	80002dce <nameiparent>
    80003db0:	84aa                	mv	s1,a0
    80003db2:	10050a63          	beqz	a0,80003ec6 <create+0x136>
    return 0;

  ilock(dp);
    80003db6:	925fe0ef          	jal	800026da <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dba:	4601                	li	a2,0
    80003dbc:	fb040593          	addi	a1,s0,-80
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	d8dfe0ef          	jal	80002b4e <dirlookup>
    80003dc6:	8aaa                	mv	s5,a0
    80003dc8:	c129                	beqz	a0,80003e0a <create+0x7a>
    iunlockput(dp);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	b19fe0ef          	jal	800028e4 <iunlockput>
    ilock(ip);
    80003dd0:	8556                	mv	a0,s5
    80003dd2:	909fe0ef          	jal	800026da <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003dd6:	4789                	li	a5,2
    80003dd8:	02fb1463          	bne	s6,a5,80003e00 <create+0x70>
    80003ddc:	044ad783          	lhu	a5,68(s5)
    80003de0:	37f9                	addiw	a5,a5,-2
    80003de2:	17c2                	slli	a5,a5,0x30
    80003de4:	93c1                	srli	a5,a5,0x30
    80003de6:	4705                	li	a4,1
    80003de8:	00f76c63          	bltu	a4,a5,80003e00 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003dec:	8556                	mv	a0,s5
    80003dee:	60a6                	ld	ra,72(sp)
    80003df0:	6406                	ld	s0,64(sp)
    80003df2:	74e2                	ld	s1,56(sp)
    80003df4:	7942                	ld	s2,48(sp)
    80003df6:	79a2                	ld	s3,40(sp)
    80003df8:	6ae2                	ld	s5,24(sp)
    80003dfa:	6b42                	ld	s6,16(sp)
    80003dfc:	6161                	addi	sp,sp,80
    80003dfe:	8082                	ret
    iunlockput(ip);
    80003e00:	8556                	mv	a0,s5
    80003e02:	ae3fe0ef          	jal	800028e4 <iunlockput>
    return 0;
    80003e06:	4a81                	li	s5,0
    80003e08:	b7d5                	j	80003dec <create+0x5c>
    80003e0a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003e0c:	85da                	mv	a1,s6
    80003e0e:	4088                	lw	a0,0(s1)
    80003e10:	f5afe0ef          	jal	8000256a <ialloc>
    80003e14:	8a2a                	mv	s4,a0
    80003e16:	cd15                	beqz	a0,80003e52 <create+0xc2>
  ilock(ip);
    80003e18:	8c3fe0ef          	jal	800026da <ilock>
  ip->major = major;
    80003e1c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003e20:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003e24:	4905                	li	s2,1
    80003e26:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003e2a:	8552                	mv	a0,s4
    80003e2c:	ffafe0ef          	jal	80002626 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003e30:	032b0763          	beq	s6,s2,80003e5e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e34:	004a2603          	lw	a2,4(s4)
    80003e38:	fb040593          	addi	a1,s0,-80
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	eddfe0ef          	jal	80002d1a <dirlink>
    80003e42:	06054563          	bltz	a0,80003eac <create+0x11c>
  iunlockput(dp);
    80003e46:	8526                	mv	a0,s1
    80003e48:	a9dfe0ef          	jal	800028e4 <iunlockput>
  return ip;
    80003e4c:	8ad2                	mv	s5,s4
    80003e4e:	7a02                	ld	s4,32(sp)
    80003e50:	bf71                	j	80003dec <create+0x5c>
    iunlockput(dp);
    80003e52:	8526                	mv	a0,s1
    80003e54:	a91fe0ef          	jal	800028e4 <iunlockput>
    return 0;
    80003e58:	8ad2                	mv	s5,s4
    80003e5a:	7a02                	ld	s4,32(sp)
    80003e5c:	bf41                	j	80003dec <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003e5e:	004a2603          	lw	a2,4(s4)
    80003e62:	00003597          	auipc	a1,0x3
    80003e66:	77e58593          	addi	a1,a1,1918 # 800075e0 <etext+0x5e0>
    80003e6a:	8552                	mv	a0,s4
    80003e6c:	eaffe0ef          	jal	80002d1a <dirlink>
    80003e70:	02054e63          	bltz	a0,80003eac <create+0x11c>
    80003e74:	40d0                	lw	a2,4(s1)
    80003e76:	00003597          	auipc	a1,0x3
    80003e7a:	77258593          	addi	a1,a1,1906 # 800075e8 <etext+0x5e8>
    80003e7e:	8552                	mv	a0,s4
    80003e80:	e9bfe0ef          	jal	80002d1a <dirlink>
    80003e84:	02054463          	bltz	a0,80003eac <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e88:	004a2603          	lw	a2,4(s4)
    80003e8c:	fb040593          	addi	a1,s0,-80
    80003e90:	8526                	mv	a0,s1
    80003e92:	e89fe0ef          	jal	80002d1a <dirlink>
    80003e96:	00054b63          	bltz	a0,80003eac <create+0x11c>
    dp->nlink++;  // for ".."
    80003e9a:	04a4d783          	lhu	a5,74(s1)
    80003e9e:	2785                	addiw	a5,a5,1
    80003ea0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	f80fe0ef          	jal	80002626 <iupdate>
    80003eaa:	bf71                	j	80003e46 <create+0xb6>
  ip->nlink = 0;
    80003eac:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003eb0:	8552                	mv	a0,s4
    80003eb2:	f74fe0ef          	jal	80002626 <iupdate>
  iunlockput(ip);
    80003eb6:	8552                	mv	a0,s4
    80003eb8:	a2dfe0ef          	jal	800028e4 <iunlockput>
  iunlockput(dp);
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	a27fe0ef          	jal	800028e4 <iunlockput>
  return 0;
    80003ec2:	7a02                	ld	s4,32(sp)
    80003ec4:	b725                	j	80003dec <create+0x5c>
    return 0;
    80003ec6:	8aaa                	mv	s5,a0
    80003ec8:	b715                	j	80003dec <create+0x5c>

0000000080003eca <sys_dup>:
{
    80003eca:	7179                	addi	sp,sp,-48
    80003ecc:	f406                	sd	ra,40(sp)
    80003ece:	f022                	sd	s0,32(sp)
    80003ed0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003ed2:	fd840613          	addi	a2,s0,-40
    80003ed6:	4581                	li	a1,0
    80003ed8:	4501                	li	a0,0
    80003eda:	e21ff0ef          	jal	80003cfa <argfd>
    return -1;
    80003ede:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003ee0:	02054363          	bltz	a0,80003f06 <sys_dup+0x3c>
    80003ee4:	ec26                	sd	s1,24(sp)
    80003ee6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80003ee8:	fd843903          	ld	s2,-40(s0)
    80003eec:	854a                	mv	a0,s2
    80003eee:	e65ff0ef          	jal	80003d52 <fdalloc>
    80003ef2:	84aa                	mv	s1,a0
    return -1;
    80003ef4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003ef6:	00054d63          	bltz	a0,80003f10 <sys_dup+0x46>
  filedup(f);
    80003efa:	854a                	mv	a0,s2
    80003efc:	c48ff0ef          	jal	80003344 <filedup>
  return fd;
    80003f00:	87a6                	mv	a5,s1
    80003f02:	64e2                	ld	s1,24(sp)
    80003f04:	6942                	ld	s2,16(sp)
}
    80003f06:	853e                	mv	a0,a5
    80003f08:	70a2                	ld	ra,40(sp)
    80003f0a:	7402                	ld	s0,32(sp)
    80003f0c:	6145                	addi	sp,sp,48
    80003f0e:	8082                	ret
    80003f10:	64e2                	ld	s1,24(sp)
    80003f12:	6942                	ld	s2,16(sp)
    80003f14:	bfcd                	j	80003f06 <sys_dup+0x3c>

0000000080003f16 <sys_read>:
{
    80003f16:	7179                	addi	sp,sp,-48
    80003f18:	f406                	sd	ra,40(sp)
    80003f1a:	f022                	sd	s0,32(sp)
    80003f1c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f1e:	fd840593          	addi	a1,s0,-40
    80003f22:	4505                	li	a0,1
    80003f24:	d1bfd0ef          	jal	80001c3e <argaddr>
  argint(2, &n);
    80003f28:	fe440593          	addi	a1,s0,-28
    80003f2c:	4509                	li	a0,2
    80003f2e:	cf5fd0ef          	jal	80001c22 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f32:	fe840613          	addi	a2,s0,-24
    80003f36:	4581                	li	a1,0
    80003f38:	4501                	li	a0,0
    80003f3a:	dc1ff0ef          	jal	80003cfa <argfd>
    80003f3e:	87aa                	mv	a5,a0
    return -1;
    80003f40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f42:	0007ca63          	bltz	a5,80003f56 <sys_read+0x40>
  return fileread(f, p, n);
    80003f46:	fe442603          	lw	a2,-28(s0)
    80003f4a:	fd843583          	ld	a1,-40(s0)
    80003f4e:	fe843503          	ld	a0,-24(s0)
    80003f52:	d58ff0ef          	jal	800034aa <fileread>
}
    80003f56:	70a2                	ld	ra,40(sp)
    80003f58:	7402                	ld	s0,32(sp)
    80003f5a:	6145                	addi	sp,sp,48
    80003f5c:	8082                	ret

0000000080003f5e <sys_write>:
{
    80003f5e:	7179                	addi	sp,sp,-48
    80003f60:	f406                	sd	ra,40(sp)
    80003f62:	f022                	sd	s0,32(sp)
    80003f64:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f66:	fd840593          	addi	a1,s0,-40
    80003f6a:	4505                	li	a0,1
    80003f6c:	cd3fd0ef          	jal	80001c3e <argaddr>
  argint(2, &n);
    80003f70:	fe440593          	addi	a1,s0,-28
    80003f74:	4509                	li	a0,2
    80003f76:	cadfd0ef          	jal	80001c22 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f7a:	fe840613          	addi	a2,s0,-24
    80003f7e:	4581                	li	a1,0
    80003f80:	4501                	li	a0,0
    80003f82:	d79ff0ef          	jal	80003cfa <argfd>
    80003f86:	87aa                	mv	a5,a0
    return -1;
    80003f88:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f8a:	0007ca63          	bltz	a5,80003f9e <sys_write+0x40>
  return filewrite(f, p, n);
    80003f8e:	fe442603          	lw	a2,-28(s0)
    80003f92:	fd843583          	ld	a1,-40(s0)
    80003f96:	fe843503          	ld	a0,-24(s0)
    80003f9a:	dceff0ef          	jal	80003568 <filewrite>
}
    80003f9e:	70a2                	ld	ra,40(sp)
    80003fa0:	7402                	ld	s0,32(sp)
    80003fa2:	6145                	addi	sp,sp,48
    80003fa4:	8082                	ret

0000000080003fa6 <sys_close>:
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003fae:	fe040613          	addi	a2,s0,-32
    80003fb2:	fec40593          	addi	a1,s0,-20
    80003fb6:	4501                	li	a0,0
    80003fb8:	d43ff0ef          	jal	80003cfa <argfd>
    return -1;
    80003fbc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003fbe:	02054063          	bltz	a0,80003fde <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003fc2:	da5fc0ef          	jal	80000d66 <myproc>
    80003fc6:	fec42783          	lw	a5,-20(s0)
    80003fca:	07e9                	addi	a5,a5,26
    80003fcc:	078e                	slli	a5,a5,0x3
    80003fce:	953e                	add	a0,a0,a5
    80003fd0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80003fd4:	fe043503          	ld	a0,-32(s0)
    80003fd8:	bb2ff0ef          	jal	8000338a <fileclose>
  return 0;
    80003fdc:	4781                	li	a5,0
}
    80003fde:	853e                	mv	a0,a5
    80003fe0:	60e2                	ld	ra,24(sp)
    80003fe2:	6442                	ld	s0,16(sp)
    80003fe4:	6105                	addi	sp,sp,32
    80003fe6:	8082                	ret

0000000080003fe8 <sys_fstat>:
{
    80003fe8:	1101                	addi	sp,sp,-32
    80003fea:	ec06                	sd	ra,24(sp)
    80003fec:	e822                	sd	s0,16(sp)
    80003fee:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80003ff0:	fe040593          	addi	a1,s0,-32
    80003ff4:	4505                	li	a0,1
    80003ff6:	c49fd0ef          	jal	80001c3e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80003ffa:	fe840613          	addi	a2,s0,-24
    80003ffe:	4581                	li	a1,0
    80004000:	4501                	li	a0,0
    80004002:	cf9ff0ef          	jal	80003cfa <argfd>
    80004006:	87aa                	mv	a5,a0
    return -1;
    80004008:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000400a:	0007c863          	bltz	a5,8000401a <sys_fstat+0x32>
  return filestat(f, st);
    8000400e:	fe043583          	ld	a1,-32(s0)
    80004012:	fe843503          	ld	a0,-24(s0)
    80004016:	c36ff0ef          	jal	8000344c <filestat>
}
    8000401a:	60e2                	ld	ra,24(sp)
    8000401c:	6442                	ld	s0,16(sp)
    8000401e:	6105                	addi	sp,sp,32
    80004020:	8082                	ret

0000000080004022 <sys_link>:
{
    80004022:	7169                	addi	sp,sp,-304
    80004024:	f606                	sd	ra,296(sp)
    80004026:	f222                	sd	s0,288(sp)
    80004028:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000402a:	08000613          	li	a2,128
    8000402e:	ed040593          	addi	a1,s0,-304
    80004032:	4501                	li	a0,0
    80004034:	c27fd0ef          	jal	80001c5a <argstr>
    return -1;
    80004038:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000403a:	0c054e63          	bltz	a0,80004116 <sys_link+0xf4>
    8000403e:	08000613          	li	a2,128
    80004042:	f5040593          	addi	a1,s0,-176
    80004046:	4505                	li	a0,1
    80004048:	c13fd0ef          	jal	80001c5a <argstr>
    return -1;
    8000404c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000404e:	0c054463          	bltz	a0,80004116 <sys_link+0xf4>
    80004052:	ee26                	sd	s1,280(sp)
  begin_op();
    80004054:	f1dfe0ef          	jal	80002f70 <begin_op>
  if((ip = namei(old)) == 0){
    80004058:	ed040513          	addi	a0,s0,-304
    8000405c:	d59fe0ef          	jal	80002db4 <namei>
    80004060:	84aa                	mv	s1,a0
    80004062:	c53d                	beqz	a0,800040d0 <sys_link+0xae>
  ilock(ip);
    80004064:	e76fe0ef          	jal	800026da <ilock>
  if(ip->type == T_DIR){
    80004068:	04449703          	lh	a4,68(s1)
    8000406c:	4785                	li	a5,1
    8000406e:	06f70663          	beq	a4,a5,800040da <sys_link+0xb8>
    80004072:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004074:	04a4d783          	lhu	a5,74(s1)
    80004078:	2785                	addiw	a5,a5,1
    8000407a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000407e:	8526                	mv	a0,s1
    80004080:	da6fe0ef          	jal	80002626 <iupdate>
  iunlock(ip);
    80004084:	8526                	mv	a0,s1
    80004086:	f02fe0ef          	jal	80002788 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000408a:	fd040593          	addi	a1,s0,-48
    8000408e:	f5040513          	addi	a0,s0,-176
    80004092:	d3dfe0ef          	jal	80002dce <nameiparent>
    80004096:	892a                	mv	s2,a0
    80004098:	cd21                	beqz	a0,800040f0 <sys_link+0xce>
  ilock(dp);
    8000409a:	e40fe0ef          	jal	800026da <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000409e:	00092703          	lw	a4,0(s2)
    800040a2:	409c                	lw	a5,0(s1)
    800040a4:	04f71363          	bne	a4,a5,800040ea <sys_link+0xc8>
    800040a8:	40d0                	lw	a2,4(s1)
    800040aa:	fd040593          	addi	a1,s0,-48
    800040ae:	854a                	mv	a0,s2
    800040b0:	c6bfe0ef          	jal	80002d1a <dirlink>
    800040b4:	02054b63          	bltz	a0,800040ea <sys_link+0xc8>
  iunlockput(dp);
    800040b8:	854a                	mv	a0,s2
    800040ba:	82bfe0ef          	jal	800028e4 <iunlockput>
  iput(ip);
    800040be:	8526                	mv	a0,s1
    800040c0:	f9cfe0ef          	jal	8000285c <iput>
  end_op();
    800040c4:	f17fe0ef          	jal	80002fda <end_op>
  return 0;
    800040c8:	4781                	li	a5,0
    800040ca:	64f2                	ld	s1,280(sp)
    800040cc:	6952                	ld	s2,272(sp)
    800040ce:	a0a1                	j	80004116 <sys_link+0xf4>
    end_op();
    800040d0:	f0bfe0ef          	jal	80002fda <end_op>
    return -1;
    800040d4:	57fd                	li	a5,-1
    800040d6:	64f2                	ld	s1,280(sp)
    800040d8:	a83d                	j	80004116 <sys_link+0xf4>
    iunlockput(ip);
    800040da:	8526                	mv	a0,s1
    800040dc:	809fe0ef          	jal	800028e4 <iunlockput>
    end_op();
    800040e0:	efbfe0ef          	jal	80002fda <end_op>
    return -1;
    800040e4:	57fd                	li	a5,-1
    800040e6:	64f2                	ld	s1,280(sp)
    800040e8:	a03d                	j	80004116 <sys_link+0xf4>
    iunlockput(dp);
    800040ea:	854a                	mv	a0,s2
    800040ec:	ff8fe0ef          	jal	800028e4 <iunlockput>
  ilock(ip);
    800040f0:	8526                	mv	a0,s1
    800040f2:	de8fe0ef          	jal	800026da <ilock>
  ip->nlink--;
    800040f6:	04a4d783          	lhu	a5,74(s1)
    800040fa:	37fd                	addiw	a5,a5,-1
    800040fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004100:	8526                	mv	a0,s1
    80004102:	d24fe0ef          	jal	80002626 <iupdate>
  iunlockput(ip);
    80004106:	8526                	mv	a0,s1
    80004108:	fdcfe0ef          	jal	800028e4 <iunlockput>
  end_op();
    8000410c:	ecffe0ef          	jal	80002fda <end_op>
  return -1;
    80004110:	57fd                	li	a5,-1
    80004112:	64f2                	ld	s1,280(sp)
    80004114:	6952                	ld	s2,272(sp)
}
    80004116:	853e                	mv	a0,a5
    80004118:	70b2                	ld	ra,296(sp)
    8000411a:	7412                	ld	s0,288(sp)
    8000411c:	6155                	addi	sp,sp,304
    8000411e:	8082                	ret

0000000080004120 <sys_unlink>:
{
    80004120:	7151                	addi	sp,sp,-240
    80004122:	f586                	sd	ra,232(sp)
    80004124:	f1a2                	sd	s0,224(sp)
    80004126:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004128:	08000613          	li	a2,128
    8000412c:	f3040593          	addi	a1,s0,-208
    80004130:	4501                	li	a0,0
    80004132:	b29fd0ef          	jal	80001c5a <argstr>
    80004136:	16054063          	bltz	a0,80004296 <sys_unlink+0x176>
    8000413a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000413c:	e35fe0ef          	jal	80002f70 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004140:	fb040593          	addi	a1,s0,-80
    80004144:	f3040513          	addi	a0,s0,-208
    80004148:	c87fe0ef          	jal	80002dce <nameiparent>
    8000414c:	84aa                	mv	s1,a0
    8000414e:	c945                	beqz	a0,800041fe <sys_unlink+0xde>
  ilock(dp);
    80004150:	d8afe0ef          	jal	800026da <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004154:	00003597          	auipc	a1,0x3
    80004158:	48c58593          	addi	a1,a1,1164 # 800075e0 <etext+0x5e0>
    8000415c:	fb040513          	addi	a0,s0,-80
    80004160:	9d9fe0ef          	jal	80002b38 <namecmp>
    80004164:	10050e63          	beqz	a0,80004280 <sys_unlink+0x160>
    80004168:	00003597          	auipc	a1,0x3
    8000416c:	48058593          	addi	a1,a1,1152 # 800075e8 <etext+0x5e8>
    80004170:	fb040513          	addi	a0,s0,-80
    80004174:	9c5fe0ef          	jal	80002b38 <namecmp>
    80004178:	10050463          	beqz	a0,80004280 <sys_unlink+0x160>
    8000417c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000417e:	f2c40613          	addi	a2,s0,-212
    80004182:	fb040593          	addi	a1,s0,-80
    80004186:	8526                	mv	a0,s1
    80004188:	9c7fe0ef          	jal	80002b4e <dirlookup>
    8000418c:	892a                	mv	s2,a0
    8000418e:	0e050863          	beqz	a0,8000427e <sys_unlink+0x15e>
  ilock(ip);
    80004192:	d48fe0ef          	jal	800026da <ilock>
  if(ip->nlink < 1)
    80004196:	04a91783          	lh	a5,74(s2)
    8000419a:	06f05763          	blez	a5,80004208 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000419e:	04491703          	lh	a4,68(s2)
    800041a2:	4785                	li	a5,1
    800041a4:	06f70963          	beq	a4,a5,80004216 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800041a8:	4641                	li	a2,16
    800041aa:	4581                	li	a1,0
    800041ac:	fc040513          	addi	a0,s0,-64
    800041b0:	f9ffb0ef          	jal	8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041b4:	4741                	li	a4,16
    800041b6:	f2c42683          	lw	a3,-212(s0)
    800041ba:	fc040613          	addi	a2,s0,-64
    800041be:	4581                	li	a1,0
    800041c0:	8526                	mv	a0,s1
    800041c2:	869fe0ef          	jal	80002a2a <writei>
    800041c6:	47c1                	li	a5,16
    800041c8:	08f51b63          	bne	a0,a5,8000425e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800041cc:	04491703          	lh	a4,68(s2)
    800041d0:	4785                	li	a5,1
    800041d2:	08f70d63          	beq	a4,a5,8000426c <sys_unlink+0x14c>
  iunlockput(dp);
    800041d6:	8526                	mv	a0,s1
    800041d8:	f0cfe0ef          	jal	800028e4 <iunlockput>
  ip->nlink--;
    800041dc:	04a95783          	lhu	a5,74(s2)
    800041e0:	37fd                	addiw	a5,a5,-1
    800041e2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800041e6:	854a                	mv	a0,s2
    800041e8:	c3efe0ef          	jal	80002626 <iupdate>
  iunlockput(ip);
    800041ec:	854a                	mv	a0,s2
    800041ee:	ef6fe0ef          	jal	800028e4 <iunlockput>
  end_op();
    800041f2:	de9fe0ef          	jal	80002fda <end_op>
  return 0;
    800041f6:	4501                	li	a0,0
    800041f8:	64ee                	ld	s1,216(sp)
    800041fa:	694e                	ld	s2,208(sp)
    800041fc:	a849                	j	8000428e <sys_unlink+0x16e>
    end_op();
    800041fe:	dddfe0ef          	jal	80002fda <end_op>
    return -1;
    80004202:	557d                	li	a0,-1
    80004204:	64ee                	ld	s1,216(sp)
    80004206:	a061                	j	8000428e <sys_unlink+0x16e>
    80004208:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000420a:	00003517          	auipc	a0,0x3
    8000420e:	3e650513          	addi	a0,a0,998 # 800075f0 <etext+0x5f0>
    80004212:	280010ef          	jal	80005492 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004216:	04c92703          	lw	a4,76(s2)
    8000421a:	02000793          	li	a5,32
    8000421e:	f8e7f5e3          	bgeu	a5,a4,800041a8 <sys_unlink+0x88>
    80004222:	e5ce                	sd	s3,200(sp)
    80004224:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004228:	4741                	li	a4,16
    8000422a:	86ce                	mv	a3,s3
    8000422c:	f1840613          	addi	a2,s0,-232
    80004230:	4581                	li	a1,0
    80004232:	854a                	mv	a0,s2
    80004234:	efafe0ef          	jal	8000292e <readi>
    80004238:	47c1                	li	a5,16
    8000423a:	00f51c63          	bne	a0,a5,80004252 <sys_unlink+0x132>
    if(de.inum != 0)
    8000423e:	f1845783          	lhu	a5,-232(s0)
    80004242:	efa1                	bnez	a5,8000429a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004244:	29c1                	addiw	s3,s3,16
    80004246:	04c92783          	lw	a5,76(s2)
    8000424a:	fcf9efe3          	bltu	s3,a5,80004228 <sys_unlink+0x108>
    8000424e:	69ae                	ld	s3,200(sp)
    80004250:	bfa1                	j	800041a8 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004252:	00003517          	auipc	a0,0x3
    80004256:	3b650513          	addi	a0,a0,950 # 80007608 <etext+0x608>
    8000425a:	238010ef          	jal	80005492 <panic>
    8000425e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004260:	00003517          	auipc	a0,0x3
    80004264:	3c050513          	addi	a0,a0,960 # 80007620 <etext+0x620>
    80004268:	22a010ef          	jal	80005492 <panic>
    dp->nlink--;
    8000426c:	04a4d783          	lhu	a5,74(s1)
    80004270:	37fd                	addiw	a5,a5,-1
    80004272:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004276:	8526                	mv	a0,s1
    80004278:	baefe0ef          	jal	80002626 <iupdate>
    8000427c:	bfa9                	j	800041d6 <sys_unlink+0xb6>
    8000427e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004280:	8526                	mv	a0,s1
    80004282:	e62fe0ef          	jal	800028e4 <iunlockput>
  end_op();
    80004286:	d55fe0ef          	jal	80002fda <end_op>
  return -1;
    8000428a:	557d                	li	a0,-1
    8000428c:	64ee                	ld	s1,216(sp)
}
    8000428e:	70ae                	ld	ra,232(sp)
    80004290:	740e                	ld	s0,224(sp)
    80004292:	616d                	addi	sp,sp,240
    80004294:	8082                	ret
    return -1;
    80004296:	557d                	li	a0,-1
    80004298:	bfdd                	j	8000428e <sys_unlink+0x16e>
    iunlockput(ip);
    8000429a:	854a                	mv	a0,s2
    8000429c:	e48fe0ef          	jal	800028e4 <iunlockput>
    goto bad;
    800042a0:	694e                	ld	s2,208(sp)
    800042a2:	69ae                	ld	s3,200(sp)
    800042a4:	bff1                	j	80004280 <sys_unlink+0x160>

00000000800042a6 <sys_open>:

uint64
sys_open(void)
{
    800042a6:	7131                	addi	sp,sp,-192
    800042a8:	fd06                	sd	ra,184(sp)
    800042aa:	f922                	sd	s0,176(sp)
    800042ac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800042ae:	f4c40593          	addi	a1,s0,-180
    800042b2:	4505                	li	a0,1
    800042b4:	96ffd0ef          	jal	80001c22 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800042b8:	08000613          	li	a2,128
    800042bc:	f5040593          	addi	a1,s0,-176
    800042c0:	4501                	li	a0,0
    800042c2:	999fd0ef          	jal	80001c5a <argstr>
    800042c6:	87aa                	mv	a5,a0
    return -1;
    800042c8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800042ca:	0a07c263          	bltz	a5,8000436e <sys_open+0xc8>
    800042ce:	f526                	sd	s1,168(sp)

  begin_op();
    800042d0:	ca1fe0ef          	jal	80002f70 <begin_op>

  if(omode & O_CREATE){
    800042d4:	f4c42783          	lw	a5,-180(s0)
    800042d8:	2007f793          	andi	a5,a5,512
    800042dc:	c3d5                	beqz	a5,80004380 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800042de:	4681                	li	a3,0
    800042e0:	4601                	li	a2,0
    800042e2:	4589                	li	a1,2
    800042e4:	f5040513          	addi	a0,s0,-176
    800042e8:	aa9ff0ef          	jal	80003d90 <create>
    800042ec:	84aa                	mv	s1,a0
    if(ip == 0){
    800042ee:	c541                	beqz	a0,80004376 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800042f0:	04449703          	lh	a4,68(s1)
    800042f4:	478d                	li	a5,3
    800042f6:	00f71763          	bne	a4,a5,80004304 <sys_open+0x5e>
    800042fa:	0464d703          	lhu	a4,70(s1)
    800042fe:	47a5                	li	a5,9
    80004300:	0ae7ed63          	bltu	a5,a4,800043ba <sys_open+0x114>
    80004304:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004306:	fe1fe0ef          	jal	800032e6 <filealloc>
    8000430a:	892a                	mv	s2,a0
    8000430c:	c179                	beqz	a0,800043d2 <sys_open+0x12c>
    8000430e:	ed4e                	sd	s3,152(sp)
    80004310:	a43ff0ef          	jal	80003d52 <fdalloc>
    80004314:	89aa                	mv	s3,a0
    80004316:	0a054a63          	bltz	a0,800043ca <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000431a:	04449703          	lh	a4,68(s1)
    8000431e:	478d                	li	a5,3
    80004320:	0cf70263          	beq	a4,a5,800043e4 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004324:	4789                	li	a5,2
    80004326:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000432a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000432e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004332:	f4c42783          	lw	a5,-180(s0)
    80004336:	0017c713          	xori	a4,a5,1
    8000433a:	8b05                	andi	a4,a4,1
    8000433c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004340:	0037f713          	andi	a4,a5,3
    80004344:	00e03733          	snez	a4,a4
    80004348:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000434c:	4007f793          	andi	a5,a5,1024
    80004350:	c791                	beqz	a5,8000435c <sys_open+0xb6>
    80004352:	04449703          	lh	a4,68(s1)
    80004356:	4789                	li	a5,2
    80004358:	08f70d63          	beq	a4,a5,800043f2 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000435c:	8526                	mv	a0,s1
    8000435e:	c2afe0ef          	jal	80002788 <iunlock>
  end_op();
    80004362:	c79fe0ef          	jal	80002fda <end_op>

  return fd;
    80004366:	854e                	mv	a0,s3
    80004368:	74aa                	ld	s1,168(sp)
    8000436a:	790a                	ld	s2,160(sp)
    8000436c:	69ea                	ld	s3,152(sp)
}
    8000436e:	70ea                	ld	ra,184(sp)
    80004370:	744a                	ld	s0,176(sp)
    80004372:	6129                	addi	sp,sp,192
    80004374:	8082                	ret
      end_op();
    80004376:	c65fe0ef          	jal	80002fda <end_op>
      return -1;
    8000437a:	557d                	li	a0,-1
    8000437c:	74aa                	ld	s1,168(sp)
    8000437e:	bfc5                	j	8000436e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004380:	f5040513          	addi	a0,s0,-176
    80004384:	a31fe0ef          	jal	80002db4 <namei>
    80004388:	84aa                	mv	s1,a0
    8000438a:	c11d                	beqz	a0,800043b0 <sys_open+0x10a>
    ilock(ip);
    8000438c:	b4efe0ef          	jal	800026da <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004390:	04449703          	lh	a4,68(s1)
    80004394:	4785                	li	a5,1
    80004396:	f4f71de3          	bne	a4,a5,800042f0 <sys_open+0x4a>
    8000439a:	f4c42783          	lw	a5,-180(s0)
    8000439e:	d3bd                	beqz	a5,80004304 <sys_open+0x5e>
      iunlockput(ip);
    800043a0:	8526                	mv	a0,s1
    800043a2:	d42fe0ef          	jal	800028e4 <iunlockput>
      end_op();
    800043a6:	c35fe0ef          	jal	80002fda <end_op>
      return -1;
    800043aa:	557d                	li	a0,-1
    800043ac:	74aa                	ld	s1,168(sp)
    800043ae:	b7c1                	j	8000436e <sys_open+0xc8>
      end_op();
    800043b0:	c2bfe0ef          	jal	80002fda <end_op>
      return -1;
    800043b4:	557d                	li	a0,-1
    800043b6:	74aa                	ld	s1,168(sp)
    800043b8:	bf5d                	j	8000436e <sys_open+0xc8>
    iunlockput(ip);
    800043ba:	8526                	mv	a0,s1
    800043bc:	d28fe0ef          	jal	800028e4 <iunlockput>
    end_op();
    800043c0:	c1bfe0ef          	jal	80002fda <end_op>
    return -1;
    800043c4:	557d                	li	a0,-1
    800043c6:	74aa                	ld	s1,168(sp)
    800043c8:	b75d                	j	8000436e <sys_open+0xc8>
      fileclose(f);
    800043ca:	854a                	mv	a0,s2
    800043cc:	fbffe0ef          	jal	8000338a <fileclose>
    800043d0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800043d2:	8526                	mv	a0,s1
    800043d4:	d10fe0ef          	jal	800028e4 <iunlockput>
    end_op();
    800043d8:	c03fe0ef          	jal	80002fda <end_op>
    return -1;
    800043dc:	557d                	li	a0,-1
    800043de:	74aa                	ld	s1,168(sp)
    800043e0:	790a                	ld	s2,160(sp)
    800043e2:	b771                	j	8000436e <sys_open+0xc8>
    f->type = FD_DEVICE;
    800043e4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800043e8:	04649783          	lh	a5,70(s1)
    800043ec:	02f91223          	sh	a5,36(s2)
    800043f0:	bf3d                	j	8000432e <sys_open+0x88>
    itrunc(ip);
    800043f2:	8526                	mv	a0,s1
    800043f4:	bd4fe0ef          	jal	800027c8 <itrunc>
    800043f8:	b795                	j	8000435c <sys_open+0xb6>

00000000800043fa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800043fa:	7175                	addi	sp,sp,-144
    800043fc:	e506                	sd	ra,136(sp)
    800043fe:	e122                	sd	s0,128(sp)
    80004400:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004402:	b6ffe0ef          	jal	80002f70 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004406:	08000613          	li	a2,128
    8000440a:	f7040593          	addi	a1,s0,-144
    8000440e:	4501                	li	a0,0
    80004410:	84bfd0ef          	jal	80001c5a <argstr>
    80004414:	02054363          	bltz	a0,8000443a <sys_mkdir+0x40>
    80004418:	4681                	li	a3,0
    8000441a:	4601                	li	a2,0
    8000441c:	4585                	li	a1,1
    8000441e:	f7040513          	addi	a0,s0,-144
    80004422:	96fff0ef          	jal	80003d90 <create>
    80004426:	c911                	beqz	a0,8000443a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004428:	cbcfe0ef          	jal	800028e4 <iunlockput>
  end_op();
    8000442c:	baffe0ef          	jal	80002fda <end_op>
  return 0;
    80004430:	4501                	li	a0,0
}
    80004432:	60aa                	ld	ra,136(sp)
    80004434:	640a                	ld	s0,128(sp)
    80004436:	6149                	addi	sp,sp,144
    80004438:	8082                	ret
    end_op();
    8000443a:	ba1fe0ef          	jal	80002fda <end_op>
    return -1;
    8000443e:	557d                	li	a0,-1
    80004440:	bfcd                	j	80004432 <sys_mkdir+0x38>

0000000080004442 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004442:	7135                	addi	sp,sp,-160
    80004444:	ed06                	sd	ra,152(sp)
    80004446:	e922                	sd	s0,144(sp)
    80004448:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000444a:	b27fe0ef          	jal	80002f70 <begin_op>
  argint(1, &major);
    8000444e:	f6c40593          	addi	a1,s0,-148
    80004452:	4505                	li	a0,1
    80004454:	fcefd0ef          	jal	80001c22 <argint>
  argint(2, &minor);
    80004458:	f6840593          	addi	a1,s0,-152
    8000445c:	4509                	li	a0,2
    8000445e:	fc4fd0ef          	jal	80001c22 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004462:	08000613          	li	a2,128
    80004466:	f7040593          	addi	a1,s0,-144
    8000446a:	4501                	li	a0,0
    8000446c:	feefd0ef          	jal	80001c5a <argstr>
    80004470:	02054563          	bltz	a0,8000449a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004474:	f6841683          	lh	a3,-152(s0)
    80004478:	f6c41603          	lh	a2,-148(s0)
    8000447c:	458d                	li	a1,3
    8000447e:	f7040513          	addi	a0,s0,-144
    80004482:	90fff0ef          	jal	80003d90 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004486:	c911                	beqz	a0,8000449a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004488:	c5cfe0ef          	jal	800028e4 <iunlockput>
  end_op();
    8000448c:	b4ffe0ef          	jal	80002fda <end_op>
  return 0;
    80004490:	4501                	li	a0,0
}
    80004492:	60ea                	ld	ra,152(sp)
    80004494:	644a                	ld	s0,144(sp)
    80004496:	610d                	addi	sp,sp,160
    80004498:	8082                	ret
    end_op();
    8000449a:	b41fe0ef          	jal	80002fda <end_op>
    return -1;
    8000449e:	557d                	li	a0,-1
    800044a0:	bfcd                	j	80004492 <sys_mknod+0x50>

00000000800044a2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800044a2:	7135                	addi	sp,sp,-160
    800044a4:	ed06                	sd	ra,152(sp)
    800044a6:	e922                	sd	s0,144(sp)
    800044a8:	e14a                	sd	s2,128(sp)
    800044aa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800044ac:	8bbfc0ef          	jal	80000d66 <myproc>
    800044b0:	892a                	mv	s2,a0
  
  begin_op();
    800044b2:	abffe0ef          	jal	80002f70 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800044b6:	08000613          	li	a2,128
    800044ba:	f6040593          	addi	a1,s0,-160
    800044be:	4501                	li	a0,0
    800044c0:	f9afd0ef          	jal	80001c5a <argstr>
    800044c4:	04054363          	bltz	a0,8000450a <sys_chdir+0x68>
    800044c8:	e526                	sd	s1,136(sp)
    800044ca:	f6040513          	addi	a0,s0,-160
    800044ce:	8e7fe0ef          	jal	80002db4 <namei>
    800044d2:	84aa                	mv	s1,a0
    800044d4:	c915                	beqz	a0,80004508 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800044d6:	a04fe0ef          	jal	800026da <ilock>
  if(ip->type != T_DIR){
    800044da:	04449703          	lh	a4,68(s1)
    800044de:	4785                	li	a5,1
    800044e0:	02f71963          	bne	a4,a5,80004512 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800044e4:	8526                	mv	a0,s1
    800044e6:	aa2fe0ef          	jal	80002788 <iunlock>
  iput(p->cwd);
    800044ea:	15093503          	ld	a0,336(s2)
    800044ee:	b6efe0ef          	jal	8000285c <iput>
  end_op();
    800044f2:	ae9fe0ef          	jal	80002fda <end_op>
  p->cwd = ip;
    800044f6:	14993823          	sd	s1,336(s2)
  return 0;
    800044fa:	4501                	li	a0,0
    800044fc:	64aa                	ld	s1,136(sp)
}
    800044fe:	60ea                	ld	ra,152(sp)
    80004500:	644a                	ld	s0,144(sp)
    80004502:	690a                	ld	s2,128(sp)
    80004504:	610d                	addi	sp,sp,160
    80004506:	8082                	ret
    80004508:	64aa                	ld	s1,136(sp)
    end_op();
    8000450a:	ad1fe0ef          	jal	80002fda <end_op>
    return -1;
    8000450e:	557d                	li	a0,-1
    80004510:	b7fd                	j	800044fe <sys_chdir+0x5c>
    iunlockput(ip);
    80004512:	8526                	mv	a0,s1
    80004514:	bd0fe0ef          	jal	800028e4 <iunlockput>
    end_op();
    80004518:	ac3fe0ef          	jal	80002fda <end_op>
    return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	64aa                	ld	s1,136(sp)
    80004520:	bff9                	j	800044fe <sys_chdir+0x5c>

0000000080004522 <sys_exec>:

uint64
sys_exec(void)
{
    80004522:	7121                	addi	sp,sp,-448
    80004524:	ff06                	sd	ra,440(sp)
    80004526:	fb22                	sd	s0,432(sp)
    80004528:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000452a:	e4840593          	addi	a1,s0,-440
    8000452e:	4505                	li	a0,1
    80004530:	f0efd0ef          	jal	80001c3e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004534:	08000613          	li	a2,128
    80004538:	f5040593          	addi	a1,s0,-176
    8000453c:	4501                	li	a0,0
    8000453e:	f1cfd0ef          	jal	80001c5a <argstr>
    80004542:	87aa                	mv	a5,a0
    return -1;
    80004544:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004546:	0c07c463          	bltz	a5,8000460e <sys_exec+0xec>
    8000454a:	f726                	sd	s1,424(sp)
    8000454c:	f34a                	sd	s2,416(sp)
    8000454e:	ef4e                	sd	s3,408(sp)
    80004550:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004552:	10000613          	li	a2,256
    80004556:	4581                	li	a1,0
    80004558:	e5040513          	addi	a0,s0,-432
    8000455c:	bf3fb0ef          	jal	8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004560:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004564:	89a6                	mv	s3,s1
    80004566:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004568:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000456c:	00391513          	slli	a0,s2,0x3
    80004570:	e4040593          	addi	a1,s0,-448
    80004574:	e4843783          	ld	a5,-440(s0)
    80004578:	953e                	add	a0,a0,a5
    8000457a:	e1efd0ef          	jal	80001b98 <fetchaddr>
    8000457e:	02054663          	bltz	a0,800045aa <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004582:	e4043783          	ld	a5,-448(s0)
    80004586:	c3a9                	beqz	a5,800045c8 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004588:	b77fb0ef          	jal	800000fe <kalloc>
    8000458c:	85aa                	mv	a1,a0
    8000458e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004592:	cd01                	beqz	a0,800045aa <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004594:	6605                	lui	a2,0x1
    80004596:	e4043503          	ld	a0,-448(s0)
    8000459a:	e48fd0ef          	jal	80001be2 <fetchstr>
    8000459e:	00054663          	bltz	a0,800045aa <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800045a2:	0905                	addi	s2,s2,1
    800045a4:	09a1                	addi	s3,s3,8
    800045a6:	fd4913e3          	bne	s2,s4,8000456c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045aa:	f5040913          	addi	s2,s0,-176
    800045ae:	6088                	ld	a0,0(s1)
    800045b0:	c931                	beqz	a0,80004604 <sys_exec+0xe2>
    kfree(argv[i]);
    800045b2:	a6bfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045b6:	04a1                	addi	s1,s1,8
    800045b8:	ff249be3          	bne	s1,s2,800045ae <sys_exec+0x8c>
  return -1;
    800045bc:	557d                	li	a0,-1
    800045be:	74ba                	ld	s1,424(sp)
    800045c0:	791a                	ld	s2,416(sp)
    800045c2:	69fa                	ld	s3,408(sp)
    800045c4:	6a5a                	ld	s4,400(sp)
    800045c6:	a0a1                	j	8000460e <sys_exec+0xec>
      argv[i] = 0;
    800045c8:	0009079b          	sext.w	a5,s2
    800045cc:	078e                	slli	a5,a5,0x3
    800045ce:	fd078793          	addi	a5,a5,-48
    800045d2:	97a2                	add	a5,a5,s0
    800045d4:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800045d8:	e5040593          	addi	a1,s0,-432
    800045dc:	f5040513          	addi	a0,s0,-176
    800045e0:	ba8ff0ef          	jal	80003988 <exec>
    800045e4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045e6:	f5040993          	addi	s3,s0,-176
    800045ea:	6088                	ld	a0,0(s1)
    800045ec:	c511                	beqz	a0,800045f8 <sys_exec+0xd6>
    kfree(argv[i]);
    800045ee:	a2ffb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045f2:	04a1                	addi	s1,s1,8
    800045f4:	ff349be3          	bne	s1,s3,800045ea <sys_exec+0xc8>
  return ret;
    800045f8:	854a                	mv	a0,s2
    800045fa:	74ba                	ld	s1,424(sp)
    800045fc:	791a                	ld	s2,416(sp)
    800045fe:	69fa                	ld	s3,408(sp)
    80004600:	6a5a                	ld	s4,400(sp)
    80004602:	a031                	j	8000460e <sys_exec+0xec>
  return -1;
    80004604:	557d                	li	a0,-1
    80004606:	74ba                	ld	s1,424(sp)
    80004608:	791a                	ld	s2,416(sp)
    8000460a:	69fa                	ld	s3,408(sp)
    8000460c:	6a5a                	ld	s4,400(sp)
}
    8000460e:	70fa                	ld	ra,440(sp)
    80004610:	745a                	ld	s0,432(sp)
    80004612:	6139                	addi	sp,sp,448
    80004614:	8082                	ret

0000000080004616 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004616:	7139                	addi	sp,sp,-64
    80004618:	fc06                	sd	ra,56(sp)
    8000461a:	f822                	sd	s0,48(sp)
    8000461c:	f426                	sd	s1,40(sp)
    8000461e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004620:	f46fc0ef          	jal	80000d66 <myproc>
    80004624:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004626:	fd840593          	addi	a1,s0,-40
    8000462a:	4501                	li	a0,0
    8000462c:	e12fd0ef          	jal	80001c3e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004630:	fc840593          	addi	a1,s0,-56
    80004634:	fd040513          	addi	a0,s0,-48
    80004638:	85cff0ef          	jal	80003694 <pipealloc>
    return -1;
    8000463c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000463e:	0a054463          	bltz	a0,800046e6 <sys_pipe+0xd0>
  fd0 = -1;
    80004642:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004646:	fd043503          	ld	a0,-48(s0)
    8000464a:	f08ff0ef          	jal	80003d52 <fdalloc>
    8000464e:	fca42223          	sw	a0,-60(s0)
    80004652:	08054163          	bltz	a0,800046d4 <sys_pipe+0xbe>
    80004656:	fc843503          	ld	a0,-56(s0)
    8000465a:	ef8ff0ef          	jal	80003d52 <fdalloc>
    8000465e:	fca42023          	sw	a0,-64(s0)
    80004662:	06054063          	bltz	a0,800046c2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004666:	4691                	li	a3,4
    80004668:	fc440613          	addi	a2,s0,-60
    8000466c:	fd843583          	ld	a1,-40(s0)
    80004670:	68a8                	ld	a0,80(s1)
    80004672:	b66fc0ef          	jal	800009d8 <copyout>
    80004676:	00054e63          	bltz	a0,80004692 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000467a:	4691                	li	a3,4
    8000467c:	fc040613          	addi	a2,s0,-64
    80004680:	fd843583          	ld	a1,-40(s0)
    80004684:	0591                	addi	a1,a1,4
    80004686:	68a8                	ld	a0,80(s1)
    80004688:	b50fc0ef          	jal	800009d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000468c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000468e:	04055c63          	bgez	a0,800046e6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004692:	fc442783          	lw	a5,-60(s0)
    80004696:	07e9                	addi	a5,a5,26
    80004698:	078e                	slli	a5,a5,0x3
    8000469a:	97a6                	add	a5,a5,s1
    8000469c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800046a0:	fc042783          	lw	a5,-64(s0)
    800046a4:	07e9                	addi	a5,a5,26
    800046a6:	078e                	slli	a5,a5,0x3
    800046a8:	94be                	add	s1,s1,a5
    800046aa:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800046ae:	fd043503          	ld	a0,-48(s0)
    800046b2:	cd9fe0ef          	jal	8000338a <fileclose>
    fileclose(wf);
    800046b6:	fc843503          	ld	a0,-56(s0)
    800046ba:	cd1fe0ef          	jal	8000338a <fileclose>
    return -1;
    800046be:	57fd                	li	a5,-1
    800046c0:	a01d                	j	800046e6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800046c2:	fc442783          	lw	a5,-60(s0)
    800046c6:	0007c763          	bltz	a5,800046d4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800046ca:	07e9                	addi	a5,a5,26
    800046cc:	078e                	slli	a5,a5,0x3
    800046ce:	97a6                	add	a5,a5,s1
    800046d0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800046d4:	fd043503          	ld	a0,-48(s0)
    800046d8:	cb3fe0ef          	jal	8000338a <fileclose>
    fileclose(wf);
    800046dc:	fc843503          	ld	a0,-56(s0)
    800046e0:	cabfe0ef          	jal	8000338a <fileclose>
    return -1;
    800046e4:	57fd                	li	a5,-1
}
    800046e6:	853e                	mv	a0,a5
    800046e8:	70e2                	ld	ra,56(sp)
    800046ea:	7442                	ld	s0,48(sp)
    800046ec:	74a2                	ld	s1,40(sp)
    800046ee:	6121                	addi	sp,sp,64
    800046f0:	8082                	ret
	...

0000000080004700 <kernelvec>:
    80004700:	7111                	addi	sp,sp,-256
    80004702:	e006                	sd	ra,0(sp)
    80004704:	e40a                	sd	sp,8(sp)
    80004706:	e80e                	sd	gp,16(sp)
    80004708:	ec12                	sd	tp,24(sp)
    8000470a:	f016                	sd	t0,32(sp)
    8000470c:	f41a                	sd	t1,40(sp)
    8000470e:	f81e                	sd	t2,48(sp)
    80004710:	e4aa                	sd	a0,72(sp)
    80004712:	e8ae                	sd	a1,80(sp)
    80004714:	ecb2                	sd	a2,88(sp)
    80004716:	f0b6                	sd	a3,96(sp)
    80004718:	f4ba                	sd	a4,104(sp)
    8000471a:	f8be                	sd	a5,112(sp)
    8000471c:	fcc2                	sd	a6,120(sp)
    8000471e:	e146                	sd	a7,128(sp)
    80004720:	edf2                	sd	t3,216(sp)
    80004722:	f1f6                	sd	t4,224(sp)
    80004724:	f5fa                	sd	t5,232(sp)
    80004726:	f9fe                	sd	t6,240(sp)
    80004728:	b80fd0ef          	jal	80001aa8 <kerneltrap>
    8000472c:	6082                	ld	ra,0(sp)
    8000472e:	6122                	ld	sp,8(sp)
    80004730:	61c2                	ld	gp,16(sp)
    80004732:	7282                	ld	t0,32(sp)
    80004734:	7322                	ld	t1,40(sp)
    80004736:	73c2                	ld	t2,48(sp)
    80004738:	6526                	ld	a0,72(sp)
    8000473a:	65c6                	ld	a1,80(sp)
    8000473c:	6666                	ld	a2,88(sp)
    8000473e:	7686                	ld	a3,96(sp)
    80004740:	7726                	ld	a4,104(sp)
    80004742:	77c6                	ld	a5,112(sp)
    80004744:	7866                	ld	a6,120(sp)
    80004746:	688a                	ld	a7,128(sp)
    80004748:	6e6e                	ld	t3,216(sp)
    8000474a:	7e8e                	ld	t4,224(sp)
    8000474c:	7f2e                	ld	t5,232(sp)
    8000474e:	7fce                	ld	t6,240(sp)
    80004750:	6111                	addi	sp,sp,256
    80004752:	10200073          	sret
	...

000000008000475e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000475e:	1141                	addi	sp,sp,-16
    80004760:	e422                	sd	s0,8(sp)
    80004762:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004764:	0c0007b7          	lui	a5,0xc000
    80004768:	4705                	li	a4,1
    8000476a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000476c:	0c0007b7          	lui	a5,0xc000
    80004770:	c3d8                	sw	a4,4(a5)
}
    80004772:	6422                	ld	s0,8(sp)
    80004774:	0141                	addi	sp,sp,16
    80004776:	8082                	ret

0000000080004778 <plicinithart>:

void
plicinithart(void)
{
    80004778:	1141                	addi	sp,sp,-16
    8000477a:	e406                	sd	ra,8(sp)
    8000477c:	e022                	sd	s0,0(sp)
    8000477e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004780:	dbafc0ef          	jal	80000d3a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004784:	0085171b          	slliw	a4,a0,0x8
    80004788:	0c0027b7          	lui	a5,0xc002
    8000478c:	97ba                	add	a5,a5,a4
    8000478e:	40200713          	li	a4,1026
    80004792:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004796:	00d5151b          	slliw	a0,a0,0xd
    8000479a:	0c2017b7          	lui	a5,0xc201
    8000479e:	97aa                	add	a5,a5,a0
    800047a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800047a4:	60a2                	ld	ra,8(sp)
    800047a6:	6402                	ld	s0,0(sp)
    800047a8:	0141                	addi	sp,sp,16
    800047aa:	8082                	ret

00000000800047ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800047ac:	1141                	addi	sp,sp,-16
    800047ae:	e406                	sd	ra,8(sp)
    800047b0:	e022                	sd	s0,0(sp)
    800047b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800047b4:	d86fc0ef          	jal	80000d3a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800047b8:	00d5151b          	slliw	a0,a0,0xd
    800047bc:	0c2017b7          	lui	a5,0xc201
    800047c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800047c2:	43c8                	lw	a0,4(a5)
    800047c4:	60a2                	ld	ra,8(sp)
    800047c6:	6402                	ld	s0,0(sp)
    800047c8:	0141                	addi	sp,sp,16
    800047ca:	8082                	ret

00000000800047cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800047cc:	1101                	addi	sp,sp,-32
    800047ce:	ec06                	sd	ra,24(sp)
    800047d0:	e822                	sd	s0,16(sp)
    800047d2:	e426                	sd	s1,8(sp)
    800047d4:	1000                	addi	s0,sp,32
    800047d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800047d8:	d62fc0ef          	jal	80000d3a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800047dc:	00d5151b          	slliw	a0,a0,0xd
    800047e0:	0c2017b7          	lui	a5,0xc201
    800047e4:	97aa                	add	a5,a5,a0
    800047e6:	c3c4                	sw	s1,4(a5)
}
    800047e8:	60e2                	ld	ra,24(sp)
    800047ea:	6442                	ld	s0,16(sp)
    800047ec:	64a2                	ld	s1,8(sp)
    800047ee:	6105                	addi	sp,sp,32
    800047f0:	8082                	ret

00000000800047f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800047f2:	1141                	addi	sp,sp,-16
    800047f4:	e406                	sd	ra,8(sp)
    800047f6:	e022                	sd	s0,0(sp)
    800047f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800047fa:	479d                	li	a5,7
    800047fc:	04a7ca63          	blt	a5,a0,80004850 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004800:	00017797          	auipc	a5,0x17
    80004804:	dc078793          	addi	a5,a5,-576 # 8001b5c0 <disk>
    80004808:	97aa                	add	a5,a5,a0
    8000480a:	0187c783          	lbu	a5,24(a5)
    8000480e:	e7b9                	bnez	a5,8000485c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004810:	00451693          	slli	a3,a0,0x4
    80004814:	00017797          	auipc	a5,0x17
    80004818:	dac78793          	addi	a5,a5,-596 # 8001b5c0 <disk>
    8000481c:	6398                	ld	a4,0(a5)
    8000481e:	9736                	add	a4,a4,a3
    80004820:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004824:	6398                	ld	a4,0(a5)
    80004826:	9736                	add	a4,a4,a3
    80004828:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000482c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004830:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004834:	97aa                	add	a5,a5,a0
    80004836:	4705                	li	a4,1
    80004838:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000483c:	00017517          	auipc	a0,0x17
    80004840:	d9c50513          	addi	a0,a0,-612 # 8001b5d8 <disk+0x18>
    80004844:	b45fc0ef          	jal	80001388 <wakeup>
}
    80004848:	60a2                	ld	ra,8(sp)
    8000484a:	6402                	ld	s0,0(sp)
    8000484c:	0141                	addi	sp,sp,16
    8000484e:	8082                	ret
    panic("free_desc 1");
    80004850:	00003517          	auipc	a0,0x3
    80004854:	de050513          	addi	a0,a0,-544 # 80007630 <etext+0x630>
    80004858:	43b000ef          	jal	80005492 <panic>
    panic("free_desc 2");
    8000485c:	00003517          	auipc	a0,0x3
    80004860:	de450513          	addi	a0,a0,-540 # 80007640 <etext+0x640>
    80004864:	42f000ef          	jal	80005492 <panic>

0000000080004868 <virtio_disk_init>:
{
    80004868:	1101                	addi	sp,sp,-32
    8000486a:	ec06                	sd	ra,24(sp)
    8000486c:	e822                	sd	s0,16(sp)
    8000486e:	e426                	sd	s1,8(sp)
    80004870:	e04a                	sd	s2,0(sp)
    80004872:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004874:	00003597          	auipc	a1,0x3
    80004878:	ddc58593          	addi	a1,a1,-548 # 80007650 <etext+0x650>
    8000487c:	00017517          	auipc	a0,0x17
    80004880:	e6c50513          	addi	a0,a0,-404 # 8001b6e8 <disk+0x128>
    80004884:	6bd000ef          	jal	80005740 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004888:	100017b7          	lui	a5,0x10001
    8000488c:	4398                	lw	a4,0(a5)
    8000488e:	2701                	sext.w	a4,a4
    80004890:	747277b7          	lui	a5,0x74727
    80004894:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004898:	18f71063          	bne	a4,a5,80004a18 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000489c:	100017b7          	lui	a5,0x10001
    800048a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800048a2:	439c                	lw	a5,0(a5)
    800048a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800048a6:	4709                	li	a4,2
    800048a8:	16e79863          	bne	a5,a4,80004a18 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048ac:	100017b7          	lui	a5,0x10001
    800048b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800048b2:	439c                	lw	a5,0(a5)
    800048b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800048b6:	16e79163          	bne	a5,a4,80004a18 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800048ba:	100017b7          	lui	a5,0x10001
    800048be:	47d8                	lw	a4,12(a5)
    800048c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048c2:	554d47b7          	lui	a5,0x554d4
    800048c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800048ca:	14f71763          	bne	a4,a5,80004a18 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800048ce:	100017b7          	lui	a5,0x10001
    800048d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800048d6:	4705                	li	a4,1
    800048d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048da:	470d                	li	a4,3
    800048dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800048de:	10001737          	lui	a4,0x10001
    800048e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800048e4:	c7ffe737          	lui	a4,0xc7ffe
    800048e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdaf5f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800048ec:	8ef9                	and	a3,a3,a4
    800048ee:	10001737          	lui	a4,0x10001
    800048f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048f4:	472d                	li	a4,11
    800048f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800048fc:	439c                	lw	a5,0(a5)
    800048fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004902:	8ba1                	andi	a5,a5,8
    80004904:	12078063          	beqz	a5,80004a24 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004908:	100017b7          	lui	a5,0x10001
    8000490c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004910:	100017b7          	lui	a5,0x10001
    80004914:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004918:	439c                	lw	a5,0(a5)
    8000491a:	2781                	sext.w	a5,a5
    8000491c:	10079a63          	bnez	a5,80004a30 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004920:	100017b7          	lui	a5,0x10001
    80004924:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004928:	439c                	lw	a5,0(a5)
    8000492a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000492c:	10078863          	beqz	a5,80004a3c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004930:	471d                	li	a4,7
    80004932:	10f77b63          	bgeu	a4,a5,80004a48 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004936:	fc8fb0ef          	jal	800000fe <kalloc>
    8000493a:	00017497          	auipc	s1,0x17
    8000493e:	c8648493          	addi	s1,s1,-890 # 8001b5c0 <disk>
    80004942:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004944:	fbafb0ef          	jal	800000fe <kalloc>
    80004948:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000494a:	fb4fb0ef          	jal	800000fe <kalloc>
    8000494e:	87aa                	mv	a5,a0
    80004950:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004952:	6088                	ld	a0,0(s1)
    80004954:	10050063          	beqz	a0,80004a54 <virtio_disk_init+0x1ec>
    80004958:	00017717          	auipc	a4,0x17
    8000495c:	c7073703          	ld	a4,-912(a4) # 8001b5c8 <disk+0x8>
    80004960:	0e070a63          	beqz	a4,80004a54 <virtio_disk_init+0x1ec>
    80004964:	0e078863          	beqz	a5,80004a54 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004968:	6605                	lui	a2,0x1
    8000496a:	4581                	li	a1,0
    8000496c:	fe2fb0ef          	jal	8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    80004970:	00017497          	auipc	s1,0x17
    80004974:	c5048493          	addi	s1,s1,-944 # 8001b5c0 <disk>
    80004978:	6605                	lui	a2,0x1
    8000497a:	4581                	li	a1,0
    8000497c:	6488                	ld	a0,8(s1)
    8000497e:	fd0fb0ef          	jal	8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    80004982:	6605                	lui	a2,0x1
    80004984:	4581                	li	a1,0
    80004986:	6888                	ld	a0,16(s1)
    80004988:	fc6fb0ef          	jal	8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000498c:	100017b7          	lui	a5,0x10001
    80004990:	4721                	li	a4,8
    80004992:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004994:	4098                	lw	a4,0(s1)
    80004996:	100017b7          	lui	a5,0x10001
    8000499a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000499e:	40d8                	lw	a4,4(s1)
    800049a0:	100017b7          	lui	a5,0x10001
    800049a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800049a8:	649c                	ld	a5,8(s1)
    800049aa:	0007869b          	sext.w	a3,a5
    800049ae:	10001737          	lui	a4,0x10001
    800049b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800049b6:	9781                	srai	a5,a5,0x20
    800049b8:	10001737          	lui	a4,0x10001
    800049bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800049c0:	689c                	ld	a5,16(s1)
    800049c2:	0007869b          	sext.w	a3,a5
    800049c6:	10001737          	lui	a4,0x10001
    800049ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800049ce:	9781                	srai	a5,a5,0x20
    800049d0:	10001737          	lui	a4,0x10001
    800049d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800049d8:	10001737          	lui	a4,0x10001
    800049dc:	4785                	li	a5,1
    800049de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800049e0:	00f48c23          	sb	a5,24(s1)
    800049e4:	00f48ca3          	sb	a5,25(s1)
    800049e8:	00f48d23          	sb	a5,26(s1)
    800049ec:	00f48da3          	sb	a5,27(s1)
    800049f0:	00f48e23          	sb	a5,28(s1)
    800049f4:	00f48ea3          	sb	a5,29(s1)
    800049f8:	00f48f23          	sb	a5,30(s1)
    800049fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004a00:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a04:	100017b7          	lui	a5,0x10001
    80004a08:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004a0c:	60e2                	ld	ra,24(sp)
    80004a0e:	6442                	ld	s0,16(sp)
    80004a10:	64a2                	ld	s1,8(sp)
    80004a12:	6902                	ld	s2,0(sp)
    80004a14:	6105                	addi	sp,sp,32
    80004a16:	8082                	ret
    panic("could not find virtio disk");
    80004a18:	00003517          	auipc	a0,0x3
    80004a1c:	c4850513          	addi	a0,a0,-952 # 80007660 <etext+0x660>
    80004a20:	273000ef          	jal	80005492 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004a24:	00003517          	auipc	a0,0x3
    80004a28:	c5c50513          	addi	a0,a0,-932 # 80007680 <etext+0x680>
    80004a2c:	267000ef          	jal	80005492 <panic>
    panic("virtio disk should not be ready");
    80004a30:	00003517          	auipc	a0,0x3
    80004a34:	c7050513          	addi	a0,a0,-912 # 800076a0 <etext+0x6a0>
    80004a38:	25b000ef          	jal	80005492 <panic>
    panic("virtio disk has no queue 0");
    80004a3c:	00003517          	auipc	a0,0x3
    80004a40:	c8450513          	addi	a0,a0,-892 # 800076c0 <etext+0x6c0>
    80004a44:	24f000ef          	jal	80005492 <panic>
    panic("virtio disk max queue too short");
    80004a48:	00003517          	auipc	a0,0x3
    80004a4c:	c9850513          	addi	a0,a0,-872 # 800076e0 <etext+0x6e0>
    80004a50:	243000ef          	jal	80005492 <panic>
    panic("virtio disk kalloc");
    80004a54:	00003517          	auipc	a0,0x3
    80004a58:	cac50513          	addi	a0,a0,-852 # 80007700 <etext+0x700>
    80004a5c:	237000ef          	jal	80005492 <panic>

0000000080004a60 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004a60:	7159                	addi	sp,sp,-112
    80004a62:	f486                	sd	ra,104(sp)
    80004a64:	f0a2                	sd	s0,96(sp)
    80004a66:	eca6                	sd	s1,88(sp)
    80004a68:	e8ca                	sd	s2,80(sp)
    80004a6a:	e4ce                	sd	s3,72(sp)
    80004a6c:	e0d2                	sd	s4,64(sp)
    80004a6e:	fc56                	sd	s5,56(sp)
    80004a70:	f85a                	sd	s6,48(sp)
    80004a72:	f45e                	sd	s7,40(sp)
    80004a74:	f062                	sd	s8,32(sp)
    80004a76:	ec66                	sd	s9,24(sp)
    80004a78:	1880                	addi	s0,sp,112
    80004a7a:	8a2a                	mv	s4,a0
    80004a7c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004a7e:	00c52c83          	lw	s9,12(a0)
    80004a82:	001c9c9b          	slliw	s9,s9,0x1
    80004a86:	1c82                	slli	s9,s9,0x20
    80004a88:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004a8c:	00017517          	auipc	a0,0x17
    80004a90:	c5c50513          	addi	a0,a0,-932 # 8001b6e8 <disk+0x128>
    80004a94:	52d000ef          	jal	800057c0 <acquire>
  for(int i = 0; i < 3; i++){
    80004a98:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004a9a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004a9c:	00017b17          	auipc	s6,0x17
    80004aa0:	b24b0b13          	addi	s6,s6,-1244 # 8001b5c0 <disk>
  for(int i = 0; i < 3; i++){
    80004aa4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004aa6:	00017c17          	auipc	s8,0x17
    80004aaa:	c42c0c13          	addi	s8,s8,-958 # 8001b6e8 <disk+0x128>
    80004aae:	a8b9                	j	80004b0c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004ab0:	00fb0733          	add	a4,s6,a5
    80004ab4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004ab8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004aba:	0207c563          	bltz	a5,80004ae4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004abe:	2905                	addiw	s2,s2,1
    80004ac0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004ac2:	05590963          	beq	s2,s5,80004b14 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004ac6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004ac8:	00017717          	auipc	a4,0x17
    80004acc:	af870713          	addi	a4,a4,-1288 # 8001b5c0 <disk>
    80004ad0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004ad2:	01874683          	lbu	a3,24(a4)
    80004ad6:	fee9                	bnez	a3,80004ab0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004ad8:	2785                	addiw	a5,a5,1
    80004ada:	0705                	addi	a4,a4,1
    80004adc:	fe979be3          	bne	a5,s1,80004ad2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004ae0:	57fd                	li	a5,-1
    80004ae2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004ae4:	01205d63          	blez	s2,80004afe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004ae8:	f9042503          	lw	a0,-112(s0)
    80004aec:	d07ff0ef          	jal	800047f2 <free_desc>
      for(int j = 0; j < i; j++)
    80004af0:	4785                	li	a5,1
    80004af2:	0127d663          	bge	a5,s2,80004afe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004af6:	f9442503          	lw	a0,-108(s0)
    80004afa:	cf9ff0ef          	jal	800047f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004afe:	85e2                	mv	a1,s8
    80004b00:	00017517          	auipc	a0,0x17
    80004b04:	ad850513          	addi	a0,a0,-1320 # 8001b5d8 <disk+0x18>
    80004b08:	835fc0ef          	jal	8000133c <sleep>
  for(int i = 0; i < 3; i++){
    80004b0c:	f9040613          	addi	a2,s0,-112
    80004b10:	894e                	mv	s2,s3
    80004b12:	bf55                	j	80004ac6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b14:	f9042503          	lw	a0,-112(s0)
    80004b18:	00451693          	slli	a3,a0,0x4

  if(write)
    80004b1c:	00017797          	auipc	a5,0x17
    80004b20:	aa478793          	addi	a5,a5,-1372 # 8001b5c0 <disk>
    80004b24:	00a50713          	addi	a4,a0,10
    80004b28:	0712                	slli	a4,a4,0x4
    80004b2a:	973e                	add	a4,a4,a5
    80004b2c:	01703633          	snez	a2,s7
    80004b30:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004b32:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004b36:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b3a:	6398                	ld	a4,0(a5)
    80004b3c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b3e:	0a868613          	addi	a2,a3,168
    80004b42:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b44:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004b46:	6390                	ld	a2,0(a5)
    80004b48:	00d605b3          	add	a1,a2,a3
    80004b4c:	4741                	li	a4,16
    80004b4e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004b50:	4805                	li	a6,1
    80004b52:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004b56:	f9442703          	lw	a4,-108(s0)
    80004b5a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004b5e:	0712                	slli	a4,a4,0x4
    80004b60:	963a                	add	a2,a2,a4
    80004b62:	058a0593          	addi	a1,s4,88
    80004b66:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004b68:	0007b883          	ld	a7,0(a5)
    80004b6c:	9746                	add	a4,a4,a7
    80004b6e:	40000613          	li	a2,1024
    80004b72:	c710                	sw	a2,8(a4)
  if(write)
    80004b74:	001bb613          	seqz	a2,s7
    80004b78:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004b7c:	00166613          	ori	a2,a2,1
    80004b80:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004b84:	f9842583          	lw	a1,-104(s0)
    80004b88:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004b8c:	00250613          	addi	a2,a0,2
    80004b90:	0612                	slli	a2,a2,0x4
    80004b92:	963e                	add	a2,a2,a5
    80004b94:	577d                	li	a4,-1
    80004b96:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004b9a:	0592                	slli	a1,a1,0x4
    80004b9c:	98ae                	add	a7,a7,a1
    80004b9e:	03068713          	addi	a4,a3,48
    80004ba2:	973e                	add	a4,a4,a5
    80004ba4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004ba8:	6398                	ld	a4,0(a5)
    80004baa:	972e                	add	a4,a4,a1
    80004bac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004bb0:	4689                	li	a3,2
    80004bb2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004bb6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004bba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004bbe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004bc2:	6794                	ld	a3,8(a5)
    80004bc4:	0026d703          	lhu	a4,2(a3)
    80004bc8:	8b1d                	andi	a4,a4,7
    80004bca:	0706                	slli	a4,a4,0x1
    80004bcc:	96ba                	add	a3,a3,a4
    80004bce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004bd2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004bd6:	6798                	ld	a4,8(a5)
    80004bd8:	00275783          	lhu	a5,2(a4)
    80004bdc:	2785                	addiw	a5,a5,1
    80004bde:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004be2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004be6:	100017b7          	lui	a5,0x10001
    80004bea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004bee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004bf2:	00017917          	auipc	s2,0x17
    80004bf6:	af690913          	addi	s2,s2,-1290 # 8001b6e8 <disk+0x128>
  while(b->disk == 1) {
    80004bfa:	4485                	li	s1,1
    80004bfc:	01079a63          	bne	a5,a6,80004c10 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004c00:	85ca                	mv	a1,s2
    80004c02:	8552                	mv	a0,s4
    80004c04:	f38fc0ef          	jal	8000133c <sleep>
  while(b->disk == 1) {
    80004c08:	004a2783          	lw	a5,4(s4)
    80004c0c:	fe978ae3          	beq	a5,s1,80004c00 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004c10:	f9042903          	lw	s2,-112(s0)
    80004c14:	00290713          	addi	a4,s2,2
    80004c18:	0712                	slli	a4,a4,0x4
    80004c1a:	00017797          	auipc	a5,0x17
    80004c1e:	9a678793          	addi	a5,a5,-1626 # 8001b5c0 <disk>
    80004c22:	97ba                	add	a5,a5,a4
    80004c24:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004c28:	00017997          	auipc	s3,0x17
    80004c2c:	99898993          	addi	s3,s3,-1640 # 8001b5c0 <disk>
    80004c30:	00491713          	slli	a4,s2,0x4
    80004c34:	0009b783          	ld	a5,0(s3)
    80004c38:	97ba                	add	a5,a5,a4
    80004c3a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004c3e:	854a                	mv	a0,s2
    80004c40:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004c44:	bafff0ef          	jal	800047f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004c48:	8885                	andi	s1,s1,1
    80004c4a:	f0fd                	bnez	s1,80004c30 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004c4c:	00017517          	auipc	a0,0x17
    80004c50:	a9c50513          	addi	a0,a0,-1380 # 8001b6e8 <disk+0x128>
    80004c54:	405000ef          	jal	80005858 <release>
}
    80004c58:	70a6                	ld	ra,104(sp)
    80004c5a:	7406                	ld	s0,96(sp)
    80004c5c:	64e6                	ld	s1,88(sp)
    80004c5e:	6946                	ld	s2,80(sp)
    80004c60:	69a6                	ld	s3,72(sp)
    80004c62:	6a06                	ld	s4,64(sp)
    80004c64:	7ae2                	ld	s5,56(sp)
    80004c66:	7b42                	ld	s6,48(sp)
    80004c68:	7ba2                	ld	s7,40(sp)
    80004c6a:	7c02                	ld	s8,32(sp)
    80004c6c:	6ce2                	ld	s9,24(sp)
    80004c6e:	6165                	addi	sp,sp,112
    80004c70:	8082                	ret

0000000080004c72 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004c72:	1101                	addi	sp,sp,-32
    80004c74:	ec06                	sd	ra,24(sp)
    80004c76:	e822                	sd	s0,16(sp)
    80004c78:	e426                	sd	s1,8(sp)
    80004c7a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004c7c:	00017497          	auipc	s1,0x17
    80004c80:	94448493          	addi	s1,s1,-1724 # 8001b5c0 <disk>
    80004c84:	00017517          	auipc	a0,0x17
    80004c88:	a6450513          	addi	a0,a0,-1436 # 8001b6e8 <disk+0x128>
    80004c8c:	335000ef          	jal	800057c0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004c90:	100017b7          	lui	a5,0x10001
    80004c94:	53b8                	lw	a4,96(a5)
    80004c96:	8b0d                	andi	a4,a4,3
    80004c98:	100017b7          	lui	a5,0x10001
    80004c9c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004c9e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004ca2:	689c                	ld	a5,16(s1)
    80004ca4:	0204d703          	lhu	a4,32(s1)
    80004ca8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004cac:	04f70663          	beq	a4,a5,80004cf8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004cb0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004cb4:	6898                	ld	a4,16(s1)
    80004cb6:	0204d783          	lhu	a5,32(s1)
    80004cba:	8b9d                	andi	a5,a5,7
    80004cbc:	078e                	slli	a5,a5,0x3
    80004cbe:	97ba                	add	a5,a5,a4
    80004cc0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004cc2:	00278713          	addi	a4,a5,2
    80004cc6:	0712                	slli	a4,a4,0x4
    80004cc8:	9726                	add	a4,a4,s1
    80004cca:	01074703          	lbu	a4,16(a4)
    80004cce:	e321                	bnez	a4,80004d0e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004cd0:	0789                	addi	a5,a5,2
    80004cd2:	0792                	slli	a5,a5,0x4
    80004cd4:	97a6                	add	a5,a5,s1
    80004cd6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004cd8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004cdc:	eacfc0ef          	jal	80001388 <wakeup>

    disk.used_idx += 1;
    80004ce0:	0204d783          	lhu	a5,32(s1)
    80004ce4:	2785                	addiw	a5,a5,1
    80004ce6:	17c2                	slli	a5,a5,0x30
    80004ce8:	93c1                	srli	a5,a5,0x30
    80004cea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004cee:	6898                	ld	a4,16(s1)
    80004cf0:	00275703          	lhu	a4,2(a4)
    80004cf4:	faf71ee3          	bne	a4,a5,80004cb0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004cf8:	00017517          	auipc	a0,0x17
    80004cfc:	9f050513          	addi	a0,a0,-1552 # 8001b6e8 <disk+0x128>
    80004d00:	359000ef          	jal	80005858 <release>
}
    80004d04:	60e2                	ld	ra,24(sp)
    80004d06:	6442                	ld	s0,16(sp)
    80004d08:	64a2                	ld	s1,8(sp)
    80004d0a:	6105                	addi	sp,sp,32
    80004d0c:	8082                	ret
      panic("virtio_disk_intr status");
    80004d0e:	00003517          	auipc	a0,0x3
    80004d12:	a0a50513          	addi	a0,a0,-1526 # 80007718 <etext+0x718>
    80004d16:	77c000ef          	jal	80005492 <panic>

0000000080004d1a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004d1a:	1141                	addi	sp,sp,-16
    80004d1c:	e422                	sd	s0,8(sp)
    80004d1e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004d20:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004d24:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004d28:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004d2c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004d30:	577d                	li	a4,-1
    80004d32:	177e                	slli	a4,a4,0x3f
    80004d34:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004d36:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004d3a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004d3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004d42:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004d46:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004d4a:	000f4737          	lui	a4,0xf4
    80004d4e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004d52:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004d54:	14d79073          	csrw	stimecmp,a5
}
    80004d58:	6422                	ld	s0,8(sp)
    80004d5a:	0141                	addi	sp,sp,16
    80004d5c:	8082                	ret

0000000080004d5e <start>:
{
    80004d5e:	1141                	addi	sp,sp,-16
    80004d60:	e406                	sd	ra,8(sp)
    80004d62:	e022                	sd	s0,0(sp)
    80004d64:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004d66:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004d6a:	7779                	lui	a4,0xffffe
    80004d6c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdafff>
    80004d70:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004d72:	6705                	lui	a4,0x1
    80004d74:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004d78:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004d7a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004d7e:	ffffb797          	auipc	a5,0xffffb
    80004d82:	56a78793          	addi	a5,a5,1386 # 800002e8 <main>
    80004d86:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004d8a:	4781                	li	a5,0
    80004d8c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004d90:	67c1                	lui	a5,0x10
    80004d92:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004d94:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004d98:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004d9c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004da0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004da4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004da8:	57fd                	li	a5,-1
    80004daa:	83a9                	srli	a5,a5,0xa
    80004dac:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004db0:	47bd                	li	a5,15
    80004db2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004db6:	f65ff0ef          	jal	80004d1a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004dba:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004dbe:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004dc0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004dc2:	30200073          	mret
}
    80004dc6:	60a2                	ld	ra,8(sp)
    80004dc8:	6402                	ld	s0,0(sp)
    80004dca:	0141                	addi	sp,sp,16
    80004dcc:	8082                	ret

0000000080004dce <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004dce:	715d                	addi	sp,sp,-80
    80004dd0:	e486                	sd	ra,72(sp)
    80004dd2:	e0a2                	sd	s0,64(sp)
    80004dd4:	f84a                	sd	s2,48(sp)
    80004dd6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004dd8:	04c05263          	blez	a2,80004e1c <consolewrite+0x4e>
    80004ddc:	fc26                	sd	s1,56(sp)
    80004dde:	f44e                	sd	s3,40(sp)
    80004de0:	f052                	sd	s4,32(sp)
    80004de2:	ec56                	sd	s5,24(sp)
    80004de4:	8a2a                	mv	s4,a0
    80004de6:	84ae                	mv	s1,a1
    80004de8:	89b2                	mv	s3,a2
    80004dea:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004dec:	5afd                	li	s5,-1
    80004dee:	4685                	li	a3,1
    80004df0:	8626                	mv	a2,s1
    80004df2:	85d2                	mv	a1,s4
    80004df4:	fbf40513          	addi	a0,s0,-65
    80004df8:	8ebfc0ef          	jal	800016e2 <either_copyin>
    80004dfc:	03550263          	beq	a0,s5,80004e20 <consolewrite+0x52>
      break;
    uartputc(c);
    80004e00:	fbf44503          	lbu	a0,-65(s0)
    80004e04:	035000ef          	jal	80005638 <uartputc>
  for(i = 0; i < n; i++){
    80004e08:	2905                	addiw	s2,s2,1
    80004e0a:	0485                	addi	s1,s1,1
    80004e0c:	ff2991e3          	bne	s3,s2,80004dee <consolewrite+0x20>
    80004e10:	894e                	mv	s2,s3
    80004e12:	74e2                	ld	s1,56(sp)
    80004e14:	79a2                	ld	s3,40(sp)
    80004e16:	7a02                	ld	s4,32(sp)
    80004e18:	6ae2                	ld	s5,24(sp)
    80004e1a:	a039                	j	80004e28 <consolewrite+0x5a>
    80004e1c:	4901                	li	s2,0
    80004e1e:	a029                	j	80004e28 <consolewrite+0x5a>
    80004e20:	74e2                	ld	s1,56(sp)
    80004e22:	79a2                	ld	s3,40(sp)
    80004e24:	7a02                	ld	s4,32(sp)
    80004e26:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80004e28:	854a                	mv	a0,s2
    80004e2a:	60a6                	ld	ra,72(sp)
    80004e2c:	6406                	ld	s0,64(sp)
    80004e2e:	7942                	ld	s2,48(sp)
    80004e30:	6161                	addi	sp,sp,80
    80004e32:	8082                	ret

0000000080004e34 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004e34:	711d                	addi	sp,sp,-96
    80004e36:	ec86                	sd	ra,88(sp)
    80004e38:	e8a2                	sd	s0,80(sp)
    80004e3a:	e4a6                	sd	s1,72(sp)
    80004e3c:	e0ca                	sd	s2,64(sp)
    80004e3e:	fc4e                	sd	s3,56(sp)
    80004e40:	f852                	sd	s4,48(sp)
    80004e42:	f456                	sd	s5,40(sp)
    80004e44:	f05a                	sd	s6,32(sp)
    80004e46:	1080                	addi	s0,sp,96
    80004e48:	8aaa                	mv	s5,a0
    80004e4a:	8a2e                	mv	s4,a1
    80004e4c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004e4e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004e52:	0001f517          	auipc	a0,0x1f
    80004e56:	8ae50513          	addi	a0,a0,-1874 # 80023700 <cons>
    80004e5a:	167000ef          	jal	800057c0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004e5e:	0001f497          	auipc	s1,0x1f
    80004e62:	8a248493          	addi	s1,s1,-1886 # 80023700 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004e66:	0001f917          	auipc	s2,0x1f
    80004e6a:	93290913          	addi	s2,s2,-1742 # 80023798 <cons+0x98>
  while(n > 0){
    80004e6e:	0b305d63          	blez	s3,80004f28 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004e72:	0984a783          	lw	a5,152(s1)
    80004e76:	09c4a703          	lw	a4,156(s1)
    80004e7a:	0af71263          	bne	a4,a5,80004f1e <consoleread+0xea>
      if(killed(myproc())){
    80004e7e:	ee9fb0ef          	jal	80000d66 <myproc>
    80004e82:	ef2fc0ef          	jal	80001574 <killed>
    80004e86:	e12d                	bnez	a0,80004ee8 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004e88:	85a6                	mv	a1,s1
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	cb0fc0ef          	jal	8000133c <sleep>
    while(cons.r == cons.w){
    80004e90:	0984a783          	lw	a5,152(s1)
    80004e94:	09c4a703          	lw	a4,156(s1)
    80004e98:	fef703e3          	beq	a4,a5,80004e7e <consoleread+0x4a>
    80004e9c:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004e9e:	0001f717          	auipc	a4,0x1f
    80004ea2:	86270713          	addi	a4,a4,-1950 # 80023700 <cons>
    80004ea6:	0017869b          	addiw	a3,a5,1
    80004eaa:	08d72c23          	sw	a3,152(a4)
    80004eae:	07f7f693          	andi	a3,a5,127
    80004eb2:	9736                	add	a4,a4,a3
    80004eb4:	01874703          	lbu	a4,24(a4)
    80004eb8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004ebc:	4691                	li	a3,4
    80004ebe:	04db8663          	beq	s7,a3,80004f0a <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80004ec2:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004ec6:	4685                	li	a3,1
    80004ec8:	faf40613          	addi	a2,s0,-81
    80004ecc:	85d2                	mv	a1,s4
    80004ece:	8556                	mv	a0,s5
    80004ed0:	fc8fc0ef          	jal	80001698 <either_copyout>
    80004ed4:	57fd                	li	a5,-1
    80004ed6:	04f50863          	beq	a0,a5,80004f26 <consoleread+0xf2>
      break;

    dst++;
    80004eda:	0a05                	addi	s4,s4,1
    --n;
    80004edc:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80004ede:	47a9                	li	a5,10
    80004ee0:	04fb8d63          	beq	s7,a5,80004f3a <consoleread+0x106>
    80004ee4:	6be2                	ld	s7,24(sp)
    80004ee6:	b761                	j	80004e6e <consoleread+0x3a>
        release(&cons.lock);
    80004ee8:	0001f517          	auipc	a0,0x1f
    80004eec:	81850513          	addi	a0,a0,-2024 # 80023700 <cons>
    80004ef0:	169000ef          	jal	80005858 <release>
        return -1;
    80004ef4:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80004ef6:	60e6                	ld	ra,88(sp)
    80004ef8:	6446                	ld	s0,80(sp)
    80004efa:	64a6                	ld	s1,72(sp)
    80004efc:	6906                	ld	s2,64(sp)
    80004efe:	79e2                	ld	s3,56(sp)
    80004f00:	7a42                	ld	s4,48(sp)
    80004f02:	7aa2                	ld	s5,40(sp)
    80004f04:	7b02                	ld	s6,32(sp)
    80004f06:	6125                	addi	sp,sp,96
    80004f08:	8082                	ret
      if(n < target){
    80004f0a:	0009871b          	sext.w	a4,s3
    80004f0e:	01677a63          	bgeu	a4,s6,80004f22 <consoleread+0xee>
        cons.r--;
    80004f12:	0001f717          	auipc	a4,0x1f
    80004f16:	88f72323          	sw	a5,-1914(a4) # 80023798 <cons+0x98>
    80004f1a:	6be2                	ld	s7,24(sp)
    80004f1c:	a031                	j	80004f28 <consoleread+0xf4>
    80004f1e:	ec5e                	sd	s7,24(sp)
    80004f20:	bfbd                	j	80004e9e <consoleread+0x6a>
    80004f22:	6be2                	ld	s7,24(sp)
    80004f24:	a011                	j	80004f28 <consoleread+0xf4>
    80004f26:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80004f28:	0001e517          	auipc	a0,0x1e
    80004f2c:	7d850513          	addi	a0,a0,2008 # 80023700 <cons>
    80004f30:	129000ef          	jal	80005858 <release>
  return target - n;
    80004f34:	413b053b          	subw	a0,s6,s3
    80004f38:	bf7d                	j	80004ef6 <consoleread+0xc2>
    80004f3a:	6be2                	ld	s7,24(sp)
    80004f3c:	b7f5                	j	80004f28 <consoleread+0xf4>

0000000080004f3e <consputc>:
{
    80004f3e:	1141                	addi	sp,sp,-16
    80004f40:	e406                	sd	ra,8(sp)
    80004f42:	e022                	sd	s0,0(sp)
    80004f44:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004f46:	10000793          	li	a5,256
    80004f4a:	00f50863          	beq	a0,a5,80004f5a <consputc+0x1c>
    uartputc_sync(c);
    80004f4e:	604000ef          	jal	80005552 <uartputc_sync>
}
    80004f52:	60a2                	ld	ra,8(sp)
    80004f54:	6402                	ld	s0,0(sp)
    80004f56:	0141                	addi	sp,sp,16
    80004f58:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004f5a:	4521                	li	a0,8
    80004f5c:	5f6000ef          	jal	80005552 <uartputc_sync>
    80004f60:	02000513          	li	a0,32
    80004f64:	5ee000ef          	jal	80005552 <uartputc_sync>
    80004f68:	4521                	li	a0,8
    80004f6a:	5e8000ef          	jal	80005552 <uartputc_sync>
    80004f6e:	b7d5                	j	80004f52 <consputc+0x14>

0000000080004f70 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004f70:	1101                	addi	sp,sp,-32
    80004f72:	ec06                	sd	ra,24(sp)
    80004f74:	e822                	sd	s0,16(sp)
    80004f76:	e426                	sd	s1,8(sp)
    80004f78:	1000                	addi	s0,sp,32
    80004f7a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004f7c:	0001e517          	auipc	a0,0x1e
    80004f80:	78450513          	addi	a0,a0,1924 # 80023700 <cons>
    80004f84:	03d000ef          	jal	800057c0 <acquire>

  switch(c){
    80004f88:	47d5                	li	a5,21
    80004f8a:	08f48f63          	beq	s1,a5,80005028 <consoleintr+0xb8>
    80004f8e:	0297c563          	blt	a5,s1,80004fb8 <consoleintr+0x48>
    80004f92:	47a1                	li	a5,8
    80004f94:	0ef48463          	beq	s1,a5,8000507c <consoleintr+0x10c>
    80004f98:	47c1                	li	a5,16
    80004f9a:	10f49563          	bne	s1,a5,800050a4 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    80004f9e:	f8efc0ef          	jal	8000172c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80004fa2:	0001e517          	auipc	a0,0x1e
    80004fa6:	75e50513          	addi	a0,a0,1886 # 80023700 <cons>
    80004faa:	0af000ef          	jal	80005858 <release>
}
    80004fae:	60e2                	ld	ra,24(sp)
    80004fb0:	6442                	ld	s0,16(sp)
    80004fb2:	64a2                	ld	s1,8(sp)
    80004fb4:	6105                	addi	sp,sp,32
    80004fb6:	8082                	ret
  switch(c){
    80004fb8:	07f00793          	li	a5,127
    80004fbc:	0cf48063          	beq	s1,a5,8000507c <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004fc0:	0001e717          	auipc	a4,0x1e
    80004fc4:	74070713          	addi	a4,a4,1856 # 80023700 <cons>
    80004fc8:	0a072783          	lw	a5,160(a4)
    80004fcc:	09872703          	lw	a4,152(a4)
    80004fd0:	9f99                	subw	a5,a5,a4
    80004fd2:	07f00713          	li	a4,127
    80004fd6:	fcf766e3          	bltu	a4,a5,80004fa2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80004fda:	47b5                	li	a5,13
    80004fdc:	0cf48763          	beq	s1,a5,800050aa <consoleintr+0x13a>
      consputc(c);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	f5dff0ef          	jal	80004f3e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004fe6:	0001e797          	auipc	a5,0x1e
    80004fea:	71a78793          	addi	a5,a5,1818 # 80023700 <cons>
    80004fee:	0a07a683          	lw	a3,160(a5)
    80004ff2:	0016871b          	addiw	a4,a3,1
    80004ff6:	0007061b          	sext.w	a2,a4
    80004ffa:	0ae7a023          	sw	a4,160(a5)
    80004ffe:	07f6f693          	andi	a3,a3,127
    80005002:	97b6                	add	a5,a5,a3
    80005004:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005008:	47a9                	li	a5,10
    8000500a:	0cf48563          	beq	s1,a5,800050d4 <consoleintr+0x164>
    8000500e:	4791                	li	a5,4
    80005010:	0cf48263          	beq	s1,a5,800050d4 <consoleintr+0x164>
    80005014:	0001e797          	auipc	a5,0x1e
    80005018:	7847a783          	lw	a5,1924(a5) # 80023798 <cons+0x98>
    8000501c:	9f1d                	subw	a4,a4,a5
    8000501e:	08000793          	li	a5,128
    80005022:	f8f710e3          	bne	a4,a5,80004fa2 <consoleintr+0x32>
    80005026:	a07d                	j	800050d4 <consoleintr+0x164>
    80005028:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000502a:	0001e717          	auipc	a4,0x1e
    8000502e:	6d670713          	addi	a4,a4,1750 # 80023700 <cons>
    80005032:	0a072783          	lw	a5,160(a4)
    80005036:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000503a:	0001e497          	auipc	s1,0x1e
    8000503e:	6c648493          	addi	s1,s1,1734 # 80023700 <cons>
    while(cons.e != cons.w &&
    80005042:	4929                	li	s2,10
    80005044:	02f70863          	beq	a4,a5,80005074 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005048:	37fd                	addiw	a5,a5,-1
    8000504a:	07f7f713          	andi	a4,a5,127
    8000504e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005050:	01874703          	lbu	a4,24(a4)
    80005054:	03270263          	beq	a4,s2,80005078 <consoleintr+0x108>
      cons.e--;
    80005058:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000505c:	10000513          	li	a0,256
    80005060:	edfff0ef          	jal	80004f3e <consputc>
    while(cons.e != cons.w &&
    80005064:	0a04a783          	lw	a5,160(s1)
    80005068:	09c4a703          	lw	a4,156(s1)
    8000506c:	fcf71ee3          	bne	a4,a5,80005048 <consoleintr+0xd8>
    80005070:	6902                	ld	s2,0(sp)
    80005072:	bf05                	j	80004fa2 <consoleintr+0x32>
    80005074:	6902                	ld	s2,0(sp)
    80005076:	b735                	j	80004fa2 <consoleintr+0x32>
    80005078:	6902                	ld	s2,0(sp)
    8000507a:	b725                	j	80004fa2 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000507c:	0001e717          	auipc	a4,0x1e
    80005080:	68470713          	addi	a4,a4,1668 # 80023700 <cons>
    80005084:	0a072783          	lw	a5,160(a4)
    80005088:	09c72703          	lw	a4,156(a4)
    8000508c:	f0f70be3          	beq	a4,a5,80004fa2 <consoleintr+0x32>
      cons.e--;
    80005090:	37fd                	addiw	a5,a5,-1
    80005092:	0001e717          	auipc	a4,0x1e
    80005096:	70f72723          	sw	a5,1806(a4) # 800237a0 <cons+0xa0>
      consputc(BACKSPACE);
    8000509a:	10000513          	li	a0,256
    8000509e:	ea1ff0ef          	jal	80004f3e <consputc>
    800050a2:	b701                	j	80004fa2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800050a4:	ee048fe3          	beqz	s1,80004fa2 <consoleintr+0x32>
    800050a8:	bf21                	j	80004fc0 <consoleintr+0x50>
      consputc(c);
    800050aa:	4529                	li	a0,10
    800050ac:	e93ff0ef          	jal	80004f3e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800050b0:	0001e797          	auipc	a5,0x1e
    800050b4:	65078793          	addi	a5,a5,1616 # 80023700 <cons>
    800050b8:	0a07a703          	lw	a4,160(a5)
    800050bc:	0017069b          	addiw	a3,a4,1
    800050c0:	0006861b          	sext.w	a2,a3
    800050c4:	0ad7a023          	sw	a3,160(a5)
    800050c8:	07f77713          	andi	a4,a4,127
    800050cc:	97ba                	add	a5,a5,a4
    800050ce:	4729                	li	a4,10
    800050d0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800050d4:	0001e797          	auipc	a5,0x1e
    800050d8:	6cc7a423          	sw	a2,1736(a5) # 8002379c <cons+0x9c>
        wakeup(&cons.r);
    800050dc:	0001e517          	auipc	a0,0x1e
    800050e0:	6bc50513          	addi	a0,a0,1724 # 80023798 <cons+0x98>
    800050e4:	aa4fc0ef          	jal	80001388 <wakeup>
    800050e8:	bd6d                	j	80004fa2 <consoleintr+0x32>

00000000800050ea <consoleinit>:

void
consoleinit(void)
{
    800050ea:	1141                	addi	sp,sp,-16
    800050ec:	e406                	sd	ra,8(sp)
    800050ee:	e022                	sd	s0,0(sp)
    800050f0:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800050f2:	00002597          	auipc	a1,0x2
    800050f6:	63e58593          	addi	a1,a1,1598 # 80007730 <etext+0x730>
    800050fa:	0001e517          	auipc	a0,0x1e
    800050fe:	60650513          	addi	a0,a0,1542 # 80023700 <cons>
    80005102:	63e000ef          	jal	80005740 <initlock>

  uartinit();
    80005106:	3f4000ef          	jal	800054fa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000510a:	00015797          	auipc	a5,0x15
    8000510e:	45e78793          	addi	a5,a5,1118 # 8001a568 <devsw>
    80005112:	00000717          	auipc	a4,0x0
    80005116:	d2270713          	addi	a4,a4,-734 # 80004e34 <consoleread>
    8000511a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000511c:	00000717          	auipc	a4,0x0
    80005120:	cb270713          	addi	a4,a4,-846 # 80004dce <consolewrite>
    80005124:	ef98                	sd	a4,24(a5)
}
    80005126:	60a2                	ld	ra,8(sp)
    80005128:	6402                	ld	s0,0(sp)
    8000512a:	0141                	addi	sp,sp,16
    8000512c:	8082                	ret

000000008000512e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000512e:	7179                	addi	sp,sp,-48
    80005130:	f406                	sd	ra,40(sp)
    80005132:	f022                	sd	s0,32(sp)
    80005134:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005136:	c219                	beqz	a2,8000513c <printint+0xe>
    80005138:	08054063          	bltz	a0,800051b8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000513c:	4881                	li	a7,0
    8000513e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005142:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005144:	00002617          	auipc	a2,0x2
    80005148:	75c60613          	addi	a2,a2,1884 # 800078a0 <digits>
    8000514c:	883e                	mv	a6,a5
    8000514e:	2785                	addiw	a5,a5,1
    80005150:	02b57733          	remu	a4,a0,a1
    80005154:	9732                	add	a4,a4,a2
    80005156:	00074703          	lbu	a4,0(a4)
    8000515a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000515e:	872a                	mv	a4,a0
    80005160:	02b55533          	divu	a0,a0,a1
    80005164:	0685                	addi	a3,a3,1
    80005166:	feb773e3          	bgeu	a4,a1,8000514c <printint+0x1e>

  if(sign)
    8000516a:	00088a63          	beqz	a7,8000517e <printint+0x50>
    buf[i++] = '-';
    8000516e:	1781                	addi	a5,a5,-32
    80005170:	97a2                	add	a5,a5,s0
    80005172:	02d00713          	li	a4,45
    80005176:	fee78823          	sb	a4,-16(a5)
    8000517a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000517e:	02f05963          	blez	a5,800051b0 <printint+0x82>
    80005182:	ec26                	sd	s1,24(sp)
    80005184:	e84a                	sd	s2,16(sp)
    80005186:	fd040713          	addi	a4,s0,-48
    8000518a:	00f704b3          	add	s1,a4,a5
    8000518e:	fff70913          	addi	s2,a4,-1
    80005192:	993e                	add	s2,s2,a5
    80005194:	37fd                	addiw	a5,a5,-1
    80005196:	1782                	slli	a5,a5,0x20
    80005198:	9381                	srli	a5,a5,0x20
    8000519a:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000519e:	fff4c503          	lbu	a0,-1(s1)
    800051a2:	d9dff0ef          	jal	80004f3e <consputc>
  while(--i >= 0)
    800051a6:	14fd                	addi	s1,s1,-1
    800051a8:	ff249be3          	bne	s1,s2,8000519e <printint+0x70>
    800051ac:	64e2                	ld	s1,24(sp)
    800051ae:	6942                	ld	s2,16(sp)
}
    800051b0:	70a2                	ld	ra,40(sp)
    800051b2:	7402                	ld	s0,32(sp)
    800051b4:	6145                	addi	sp,sp,48
    800051b6:	8082                	ret
    x = -xx;
    800051b8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800051bc:	4885                	li	a7,1
    x = -xx;
    800051be:	b741                	j	8000513e <printint+0x10>

00000000800051c0 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800051c0:	7155                	addi	sp,sp,-208
    800051c2:	e506                	sd	ra,136(sp)
    800051c4:	e122                	sd	s0,128(sp)
    800051c6:	f0d2                	sd	s4,96(sp)
    800051c8:	0900                	addi	s0,sp,144
    800051ca:	8a2a                	mv	s4,a0
    800051cc:	e40c                	sd	a1,8(s0)
    800051ce:	e810                	sd	a2,16(s0)
    800051d0:	ec14                	sd	a3,24(s0)
    800051d2:	f018                	sd	a4,32(s0)
    800051d4:	f41c                	sd	a5,40(s0)
    800051d6:	03043823          	sd	a6,48(s0)
    800051da:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800051de:	0001e797          	auipc	a5,0x1e
    800051e2:	5e27a783          	lw	a5,1506(a5) # 800237c0 <pr+0x18>
    800051e6:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800051ea:	e3a1                	bnez	a5,8000522a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800051ec:	00840793          	addi	a5,s0,8
    800051f0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800051f4:	00054503          	lbu	a0,0(a0)
    800051f8:	26050763          	beqz	a0,80005466 <printf+0x2a6>
    800051fc:	fca6                	sd	s1,120(sp)
    800051fe:	f8ca                	sd	s2,112(sp)
    80005200:	f4ce                	sd	s3,104(sp)
    80005202:	ecd6                	sd	s5,88(sp)
    80005204:	e8da                	sd	s6,80(sp)
    80005206:	e0e2                	sd	s8,64(sp)
    80005208:	fc66                	sd	s9,56(sp)
    8000520a:	f86a                	sd	s10,48(sp)
    8000520c:	f46e                	sd	s11,40(sp)
    8000520e:	4981                	li	s3,0
    if(cx != '%'){
    80005210:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005214:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005218:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000521c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005220:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005224:	07000d93          	li	s11,112
    80005228:	a815                	j	8000525c <printf+0x9c>
    acquire(&pr.lock);
    8000522a:	0001e517          	auipc	a0,0x1e
    8000522e:	57e50513          	addi	a0,a0,1406 # 800237a8 <pr>
    80005232:	58e000ef          	jal	800057c0 <acquire>
  va_start(ap, fmt);
    80005236:	00840793          	addi	a5,s0,8
    8000523a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000523e:	000a4503          	lbu	a0,0(s4)
    80005242:	fd4d                	bnez	a0,800051fc <printf+0x3c>
    80005244:	a481                	j	80005484 <printf+0x2c4>
      consputc(cx);
    80005246:	cf9ff0ef          	jal	80004f3e <consputc>
      continue;
    8000524a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000524c:	0014899b          	addiw	s3,s1,1
    80005250:	013a07b3          	add	a5,s4,s3
    80005254:	0007c503          	lbu	a0,0(a5)
    80005258:	1e050b63          	beqz	a0,8000544e <printf+0x28e>
    if(cx != '%'){
    8000525c:	ff5515e3          	bne	a0,s5,80005246 <printf+0x86>
    i++;
    80005260:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005264:	009a07b3          	add	a5,s4,s1
    80005268:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000526c:	1e090163          	beqz	s2,8000544e <printf+0x28e>
    80005270:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005274:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80005276:	c789                	beqz	a5,80005280 <printf+0xc0>
    80005278:	009a0733          	add	a4,s4,s1
    8000527c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005280:	03690763          	beq	s2,s6,800052ae <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80005284:	05890163          	beq	s2,s8,800052c6 <printf+0x106>
    } else if(c0 == 'u'){
    80005288:	0d990b63          	beq	s2,s9,8000535e <printf+0x19e>
    } else if(c0 == 'x'){
    8000528c:	13a90163          	beq	s2,s10,800053ae <printf+0x1ee>
    } else if(c0 == 'p'){
    80005290:	13b90b63          	beq	s2,s11,800053c6 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80005294:	07300793          	li	a5,115
    80005298:	16f90a63          	beq	s2,a5,8000540c <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000529c:	1b590463          	beq	s2,s5,80005444 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800052a0:	8556                	mv	a0,s5
    800052a2:	c9dff0ef          	jal	80004f3e <consputc>
      consputc(c0);
    800052a6:	854a                	mv	a0,s2
    800052a8:	c97ff0ef          	jal	80004f3e <consputc>
    800052ac:	b745                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800052ae:	f8843783          	ld	a5,-120(s0)
    800052b2:	00878713          	addi	a4,a5,8
    800052b6:	f8e43423          	sd	a4,-120(s0)
    800052ba:	4605                	li	a2,1
    800052bc:	45a9                	li	a1,10
    800052be:	4388                	lw	a0,0(a5)
    800052c0:	e6fff0ef          	jal	8000512e <printint>
    800052c4:	b761                	j	8000524c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800052c6:	03678663          	beq	a5,s6,800052f2 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800052ca:	05878263          	beq	a5,s8,8000530e <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800052ce:	0b978463          	beq	a5,s9,80005376 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800052d2:	fda797e3          	bne	a5,s10,800052a0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800052d6:	f8843783          	ld	a5,-120(s0)
    800052da:	00878713          	addi	a4,a5,8
    800052de:	f8e43423          	sd	a4,-120(s0)
    800052e2:	4601                	li	a2,0
    800052e4:	45c1                	li	a1,16
    800052e6:	6388                	ld	a0,0(a5)
    800052e8:	e47ff0ef          	jal	8000512e <printint>
      i += 1;
    800052ec:	0029849b          	addiw	s1,s3,2
    800052f0:	bfb1                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800052f2:	f8843783          	ld	a5,-120(s0)
    800052f6:	00878713          	addi	a4,a5,8
    800052fa:	f8e43423          	sd	a4,-120(s0)
    800052fe:	4605                	li	a2,1
    80005300:	45a9                	li	a1,10
    80005302:	6388                	ld	a0,0(a5)
    80005304:	e2bff0ef          	jal	8000512e <printint>
      i += 1;
    80005308:	0029849b          	addiw	s1,s3,2
    8000530c:	b781                	j	8000524c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000530e:	06400793          	li	a5,100
    80005312:	02f68863          	beq	a3,a5,80005342 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005316:	07500793          	li	a5,117
    8000531a:	06f68c63          	beq	a3,a5,80005392 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000531e:	07800793          	li	a5,120
    80005322:	f6f69fe3          	bne	a3,a5,800052a0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005326:	f8843783          	ld	a5,-120(s0)
    8000532a:	00878713          	addi	a4,a5,8
    8000532e:	f8e43423          	sd	a4,-120(s0)
    80005332:	4601                	li	a2,0
    80005334:	45c1                	li	a1,16
    80005336:	6388                	ld	a0,0(a5)
    80005338:	df7ff0ef          	jal	8000512e <printint>
      i += 2;
    8000533c:	0039849b          	addiw	s1,s3,3
    80005340:	b731                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005342:	f8843783          	ld	a5,-120(s0)
    80005346:	00878713          	addi	a4,a5,8
    8000534a:	f8e43423          	sd	a4,-120(s0)
    8000534e:	4605                	li	a2,1
    80005350:	45a9                	li	a1,10
    80005352:	6388                	ld	a0,0(a5)
    80005354:	ddbff0ef          	jal	8000512e <printint>
      i += 2;
    80005358:	0039849b          	addiw	s1,s3,3
    8000535c:	bdc5                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000535e:	f8843783          	ld	a5,-120(s0)
    80005362:	00878713          	addi	a4,a5,8
    80005366:	f8e43423          	sd	a4,-120(s0)
    8000536a:	4601                	li	a2,0
    8000536c:	45a9                	li	a1,10
    8000536e:	4388                	lw	a0,0(a5)
    80005370:	dbfff0ef          	jal	8000512e <printint>
    80005374:	bde1                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005376:	f8843783          	ld	a5,-120(s0)
    8000537a:	00878713          	addi	a4,a5,8
    8000537e:	f8e43423          	sd	a4,-120(s0)
    80005382:	4601                	li	a2,0
    80005384:	45a9                	li	a1,10
    80005386:	6388                	ld	a0,0(a5)
    80005388:	da7ff0ef          	jal	8000512e <printint>
      i += 1;
    8000538c:	0029849b          	addiw	s1,s3,2
    80005390:	bd75                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005392:	f8843783          	ld	a5,-120(s0)
    80005396:	00878713          	addi	a4,a5,8
    8000539a:	f8e43423          	sd	a4,-120(s0)
    8000539e:	4601                	li	a2,0
    800053a0:	45a9                	li	a1,10
    800053a2:	6388                	ld	a0,0(a5)
    800053a4:	d8bff0ef          	jal	8000512e <printint>
      i += 2;
    800053a8:	0039849b          	addiw	s1,s3,3
    800053ac:	b545                	j	8000524c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800053ae:	f8843783          	ld	a5,-120(s0)
    800053b2:	00878713          	addi	a4,a5,8
    800053b6:	f8e43423          	sd	a4,-120(s0)
    800053ba:	4601                	li	a2,0
    800053bc:	45c1                	li	a1,16
    800053be:	4388                	lw	a0,0(a5)
    800053c0:	d6fff0ef          	jal	8000512e <printint>
    800053c4:	b561                	j	8000524c <printf+0x8c>
    800053c6:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800053c8:	f8843783          	ld	a5,-120(s0)
    800053cc:	00878713          	addi	a4,a5,8
    800053d0:	f8e43423          	sd	a4,-120(s0)
    800053d4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800053d8:	03000513          	li	a0,48
    800053dc:	b63ff0ef          	jal	80004f3e <consputc>
  consputc('x');
    800053e0:	07800513          	li	a0,120
    800053e4:	b5bff0ef          	jal	80004f3e <consputc>
    800053e8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800053ea:	00002b97          	auipc	s7,0x2
    800053ee:	4b6b8b93          	addi	s7,s7,1206 # 800078a0 <digits>
    800053f2:	03c9d793          	srli	a5,s3,0x3c
    800053f6:	97de                	add	a5,a5,s7
    800053f8:	0007c503          	lbu	a0,0(a5)
    800053fc:	b43ff0ef          	jal	80004f3e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005400:	0992                	slli	s3,s3,0x4
    80005402:	397d                	addiw	s2,s2,-1
    80005404:	fe0917e3          	bnez	s2,800053f2 <printf+0x232>
    80005408:	6ba6                	ld	s7,72(sp)
    8000540a:	b589                	j	8000524c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000540c:	f8843783          	ld	a5,-120(s0)
    80005410:	00878713          	addi	a4,a5,8
    80005414:	f8e43423          	sd	a4,-120(s0)
    80005418:	0007b903          	ld	s2,0(a5)
    8000541c:	00090d63          	beqz	s2,80005436 <printf+0x276>
      for(; *s; s++)
    80005420:	00094503          	lbu	a0,0(s2)
    80005424:	e20504e3          	beqz	a0,8000524c <printf+0x8c>
        consputc(*s);
    80005428:	b17ff0ef          	jal	80004f3e <consputc>
      for(; *s; s++)
    8000542c:	0905                	addi	s2,s2,1
    8000542e:	00094503          	lbu	a0,0(s2)
    80005432:	f97d                	bnez	a0,80005428 <printf+0x268>
    80005434:	bd21                	j	8000524c <printf+0x8c>
        s = "(null)";
    80005436:	00002917          	auipc	s2,0x2
    8000543a:	30290913          	addi	s2,s2,770 # 80007738 <etext+0x738>
      for(; *s; s++)
    8000543e:	02800513          	li	a0,40
    80005442:	b7dd                	j	80005428 <printf+0x268>
      consputc('%');
    80005444:	02500513          	li	a0,37
    80005448:	af7ff0ef          	jal	80004f3e <consputc>
    8000544c:	b501                	j	8000524c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000544e:	f7843783          	ld	a5,-136(s0)
    80005452:	e385                	bnez	a5,80005472 <printf+0x2b2>
    80005454:	74e6                	ld	s1,120(sp)
    80005456:	7946                	ld	s2,112(sp)
    80005458:	79a6                	ld	s3,104(sp)
    8000545a:	6ae6                	ld	s5,88(sp)
    8000545c:	6b46                	ld	s6,80(sp)
    8000545e:	6c06                	ld	s8,64(sp)
    80005460:	7ce2                	ld	s9,56(sp)
    80005462:	7d42                	ld	s10,48(sp)
    80005464:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80005466:	4501                	li	a0,0
    80005468:	60aa                	ld	ra,136(sp)
    8000546a:	640a                	ld	s0,128(sp)
    8000546c:	7a06                	ld	s4,96(sp)
    8000546e:	6169                	addi	sp,sp,208
    80005470:	8082                	ret
    80005472:	74e6                	ld	s1,120(sp)
    80005474:	7946                	ld	s2,112(sp)
    80005476:	79a6                	ld	s3,104(sp)
    80005478:	6ae6                	ld	s5,88(sp)
    8000547a:	6b46                	ld	s6,80(sp)
    8000547c:	6c06                	ld	s8,64(sp)
    8000547e:	7ce2                	ld	s9,56(sp)
    80005480:	7d42                	ld	s10,48(sp)
    80005482:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80005484:	0001e517          	auipc	a0,0x1e
    80005488:	32450513          	addi	a0,a0,804 # 800237a8 <pr>
    8000548c:	3cc000ef          	jal	80005858 <release>
    80005490:	bfd9                	j	80005466 <printf+0x2a6>

0000000080005492 <panic>:

void
panic(char *s)
{
    80005492:	1101                	addi	sp,sp,-32
    80005494:	ec06                	sd	ra,24(sp)
    80005496:	e822                	sd	s0,16(sp)
    80005498:	e426                	sd	s1,8(sp)
    8000549a:	1000                	addi	s0,sp,32
    8000549c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000549e:	0001e797          	auipc	a5,0x1e
    800054a2:	3207a123          	sw	zero,802(a5) # 800237c0 <pr+0x18>
  printf("panic: ");
    800054a6:	00002517          	auipc	a0,0x2
    800054aa:	29a50513          	addi	a0,a0,666 # 80007740 <etext+0x740>
    800054ae:	d13ff0ef          	jal	800051c0 <printf>
  printf("%s\n", s);
    800054b2:	85a6                	mv	a1,s1
    800054b4:	00002517          	auipc	a0,0x2
    800054b8:	29450513          	addi	a0,a0,660 # 80007748 <etext+0x748>
    800054bc:	d05ff0ef          	jal	800051c0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800054c0:	4785                	li	a5,1
    800054c2:	00005717          	auipc	a4,0x5
    800054c6:	def72d23          	sw	a5,-518(a4) # 8000a2bc <panicked>
  for(;;)
    800054ca:	a001                	j	800054ca <panic+0x38>

00000000800054cc <printfinit>:
    ;
}

void
printfinit(void)
{
    800054cc:	1101                	addi	sp,sp,-32
    800054ce:	ec06                	sd	ra,24(sp)
    800054d0:	e822                	sd	s0,16(sp)
    800054d2:	e426                	sd	s1,8(sp)
    800054d4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800054d6:	0001e497          	auipc	s1,0x1e
    800054da:	2d248493          	addi	s1,s1,722 # 800237a8 <pr>
    800054de:	00002597          	auipc	a1,0x2
    800054e2:	27258593          	addi	a1,a1,626 # 80007750 <etext+0x750>
    800054e6:	8526                	mv	a0,s1
    800054e8:	258000ef          	jal	80005740 <initlock>
  pr.locking = 1;
    800054ec:	4785                	li	a5,1
    800054ee:	cc9c                	sw	a5,24(s1)
}
    800054f0:	60e2                	ld	ra,24(sp)
    800054f2:	6442                	ld	s0,16(sp)
    800054f4:	64a2                	ld	s1,8(sp)
    800054f6:	6105                	addi	sp,sp,32
    800054f8:	8082                	ret

00000000800054fa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800054fa:	1141                	addi	sp,sp,-16
    800054fc:	e406                	sd	ra,8(sp)
    800054fe:	e022                	sd	s0,0(sp)
    80005500:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005502:	100007b7          	lui	a5,0x10000
    80005506:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000550a:	10000737          	lui	a4,0x10000
    8000550e:	f8000693          	li	a3,-128
    80005512:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005516:	468d                	li	a3,3
    80005518:	10000637          	lui	a2,0x10000
    8000551c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005520:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005524:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005528:	10000737          	lui	a4,0x10000
    8000552c:	461d                	li	a2,7
    8000552e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005532:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005536:	00002597          	auipc	a1,0x2
    8000553a:	22258593          	addi	a1,a1,546 # 80007758 <etext+0x758>
    8000553e:	0001e517          	auipc	a0,0x1e
    80005542:	28a50513          	addi	a0,a0,650 # 800237c8 <uart_tx_lock>
    80005546:	1fa000ef          	jal	80005740 <initlock>
}
    8000554a:	60a2                	ld	ra,8(sp)
    8000554c:	6402                	ld	s0,0(sp)
    8000554e:	0141                	addi	sp,sp,16
    80005550:	8082                	ret

0000000080005552 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005552:	1101                	addi	sp,sp,-32
    80005554:	ec06                	sd	ra,24(sp)
    80005556:	e822                	sd	s0,16(sp)
    80005558:	e426                	sd	s1,8(sp)
    8000555a:	1000                	addi	s0,sp,32
    8000555c:	84aa                	mv	s1,a0
  push_off();
    8000555e:	222000ef          	jal	80005780 <push_off>

  if(panicked){
    80005562:	00005797          	auipc	a5,0x5
    80005566:	d5a7a783          	lw	a5,-678(a5) # 8000a2bc <panicked>
    8000556a:	e795                	bnez	a5,80005596 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000556c:	10000737          	lui	a4,0x10000
    80005570:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005572:	00074783          	lbu	a5,0(a4)
    80005576:	0207f793          	andi	a5,a5,32
    8000557a:	dfe5                	beqz	a5,80005572 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000557c:	0ff4f513          	zext.b	a0,s1
    80005580:	100007b7          	lui	a5,0x10000
    80005584:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005588:	27c000ef          	jal	80005804 <pop_off>
}
    8000558c:	60e2                	ld	ra,24(sp)
    8000558e:	6442                	ld	s0,16(sp)
    80005590:	64a2                	ld	s1,8(sp)
    80005592:	6105                	addi	sp,sp,32
    80005594:	8082                	ret
    for(;;)
    80005596:	a001                	j	80005596 <uartputc_sync+0x44>

0000000080005598 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005598:	00005797          	auipc	a5,0x5
    8000559c:	d287b783          	ld	a5,-728(a5) # 8000a2c0 <uart_tx_r>
    800055a0:	00005717          	auipc	a4,0x5
    800055a4:	d2873703          	ld	a4,-728(a4) # 8000a2c8 <uart_tx_w>
    800055a8:	08f70263          	beq	a4,a5,8000562c <uartstart+0x94>
{
    800055ac:	7139                	addi	sp,sp,-64
    800055ae:	fc06                	sd	ra,56(sp)
    800055b0:	f822                	sd	s0,48(sp)
    800055b2:	f426                	sd	s1,40(sp)
    800055b4:	f04a                	sd	s2,32(sp)
    800055b6:	ec4e                	sd	s3,24(sp)
    800055b8:	e852                	sd	s4,16(sp)
    800055ba:	e456                	sd	s5,8(sp)
    800055bc:	e05a                	sd	s6,0(sp)
    800055be:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800055c0:	10000937          	lui	s2,0x10000
    800055c4:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800055c6:	0001ea97          	auipc	s5,0x1e
    800055ca:	202a8a93          	addi	s5,s5,514 # 800237c8 <uart_tx_lock>
    uart_tx_r += 1;
    800055ce:	00005497          	auipc	s1,0x5
    800055d2:	cf248493          	addi	s1,s1,-782 # 8000a2c0 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800055d6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800055da:	00005997          	auipc	s3,0x5
    800055de:	cee98993          	addi	s3,s3,-786 # 8000a2c8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800055e2:	00094703          	lbu	a4,0(s2)
    800055e6:	02077713          	andi	a4,a4,32
    800055ea:	c71d                	beqz	a4,80005618 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800055ec:	01f7f713          	andi	a4,a5,31
    800055f0:	9756                	add	a4,a4,s5
    800055f2:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800055f6:	0785                	addi	a5,a5,1
    800055f8:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800055fa:	8526                	mv	a0,s1
    800055fc:	d8dfb0ef          	jal	80001388 <wakeup>
    WriteReg(THR, c);
    80005600:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80005604:	609c                	ld	a5,0(s1)
    80005606:	0009b703          	ld	a4,0(s3)
    8000560a:	fcf71ce3          	bne	a4,a5,800055e2 <uartstart+0x4a>
      ReadReg(ISR);
    8000560e:	100007b7          	lui	a5,0x10000
    80005612:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005614:	0007c783          	lbu	a5,0(a5)
  }
}
    80005618:	70e2                	ld	ra,56(sp)
    8000561a:	7442                	ld	s0,48(sp)
    8000561c:	74a2                	ld	s1,40(sp)
    8000561e:	7902                	ld	s2,32(sp)
    80005620:	69e2                	ld	s3,24(sp)
    80005622:	6a42                	ld	s4,16(sp)
    80005624:	6aa2                	ld	s5,8(sp)
    80005626:	6b02                	ld	s6,0(sp)
    80005628:	6121                	addi	sp,sp,64
    8000562a:	8082                	ret
      ReadReg(ISR);
    8000562c:	100007b7          	lui	a5,0x10000
    80005630:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005632:	0007c783          	lbu	a5,0(a5)
      return;
    80005636:	8082                	ret

0000000080005638 <uartputc>:
{
    80005638:	7179                	addi	sp,sp,-48
    8000563a:	f406                	sd	ra,40(sp)
    8000563c:	f022                	sd	s0,32(sp)
    8000563e:	ec26                	sd	s1,24(sp)
    80005640:	e84a                	sd	s2,16(sp)
    80005642:	e44e                	sd	s3,8(sp)
    80005644:	e052                	sd	s4,0(sp)
    80005646:	1800                	addi	s0,sp,48
    80005648:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000564a:	0001e517          	auipc	a0,0x1e
    8000564e:	17e50513          	addi	a0,a0,382 # 800237c8 <uart_tx_lock>
    80005652:	16e000ef          	jal	800057c0 <acquire>
  if(panicked){
    80005656:	00005797          	auipc	a5,0x5
    8000565a:	c667a783          	lw	a5,-922(a5) # 8000a2bc <panicked>
    8000565e:	efbd                	bnez	a5,800056dc <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005660:	00005717          	auipc	a4,0x5
    80005664:	c6873703          	ld	a4,-920(a4) # 8000a2c8 <uart_tx_w>
    80005668:	00005797          	auipc	a5,0x5
    8000566c:	c587b783          	ld	a5,-936(a5) # 8000a2c0 <uart_tx_r>
    80005670:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005674:	0001e997          	auipc	s3,0x1e
    80005678:	15498993          	addi	s3,s3,340 # 800237c8 <uart_tx_lock>
    8000567c:	00005497          	auipc	s1,0x5
    80005680:	c4448493          	addi	s1,s1,-956 # 8000a2c0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005684:	00005917          	auipc	s2,0x5
    80005688:	c4490913          	addi	s2,s2,-956 # 8000a2c8 <uart_tx_w>
    8000568c:	00e79d63          	bne	a5,a4,800056a6 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005690:	85ce                	mv	a1,s3
    80005692:	8526                	mv	a0,s1
    80005694:	ca9fb0ef          	jal	8000133c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005698:	00093703          	ld	a4,0(s2)
    8000569c:	609c                	ld	a5,0(s1)
    8000569e:	02078793          	addi	a5,a5,32
    800056a2:	fee787e3          	beq	a5,a4,80005690 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800056a6:	0001e497          	auipc	s1,0x1e
    800056aa:	12248493          	addi	s1,s1,290 # 800237c8 <uart_tx_lock>
    800056ae:	01f77793          	andi	a5,a4,31
    800056b2:	97a6                	add	a5,a5,s1
    800056b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800056b8:	0705                	addi	a4,a4,1
    800056ba:	00005797          	auipc	a5,0x5
    800056be:	c0e7b723          	sd	a4,-1010(a5) # 8000a2c8 <uart_tx_w>
  uartstart();
    800056c2:	ed7ff0ef          	jal	80005598 <uartstart>
  release(&uart_tx_lock);
    800056c6:	8526                	mv	a0,s1
    800056c8:	190000ef          	jal	80005858 <release>
}
    800056cc:	70a2                	ld	ra,40(sp)
    800056ce:	7402                	ld	s0,32(sp)
    800056d0:	64e2                	ld	s1,24(sp)
    800056d2:	6942                	ld	s2,16(sp)
    800056d4:	69a2                	ld	s3,8(sp)
    800056d6:	6a02                	ld	s4,0(sp)
    800056d8:	6145                	addi	sp,sp,48
    800056da:	8082                	ret
    for(;;)
    800056dc:	a001                	j	800056dc <uartputc+0xa4>

00000000800056de <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800056de:	1141                	addi	sp,sp,-16
    800056e0:	e422                	sd	s0,8(sp)
    800056e2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800056e4:	100007b7          	lui	a5,0x10000
    800056e8:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800056ea:	0007c783          	lbu	a5,0(a5)
    800056ee:	8b85                	andi	a5,a5,1
    800056f0:	cb81                	beqz	a5,80005700 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800056f2:	100007b7          	lui	a5,0x10000
    800056f6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800056fa:	6422                	ld	s0,8(sp)
    800056fc:	0141                	addi	sp,sp,16
    800056fe:	8082                	ret
    return -1;
    80005700:	557d                	li	a0,-1
    80005702:	bfe5                	j	800056fa <uartgetc+0x1c>

0000000080005704 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005704:	1101                	addi	sp,sp,-32
    80005706:	ec06                	sd	ra,24(sp)
    80005708:	e822                	sd	s0,16(sp)
    8000570a:	e426                	sd	s1,8(sp)
    8000570c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000570e:	54fd                	li	s1,-1
    80005710:	a019                	j	80005716 <uartintr+0x12>
      break;
    consoleintr(c);
    80005712:	85fff0ef          	jal	80004f70 <consoleintr>
    int c = uartgetc();
    80005716:	fc9ff0ef          	jal	800056de <uartgetc>
    if(c == -1)
    8000571a:	fe951ce3          	bne	a0,s1,80005712 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000571e:	0001e497          	auipc	s1,0x1e
    80005722:	0aa48493          	addi	s1,s1,170 # 800237c8 <uart_tx_lock>
    80005726:	8526                	mv	a0,s1
    80005728:	098000ef          	jal	800057c0 <acquire>
  uartstart();
    8000572c:	e6dff0ef          	jal	80005598 <uartstart>
  release(&uart_tx_lock);
    80005730:	8526                	mv	a0,s1
    80005732:	126000ef          	jal	80005858 <release>
}
    80005736:	60e2                	ld	ra,24(sp)
    80005738:	6442                	ld	s0,16(sp)
    8000573a:	64a2                	ld	s1,8(sp)
    8000573c:	6105                	addi	sp,sp,32
    8000573e:	8082                	ret

0000000080005740 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005740:	1141                	addi	sp,sp,-16
    80005742:	e422                	sd	s0,8(sp)
    80005744:	0800                	addi	s0,sp,16
  lk->name = name;
    80005746:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005748:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000574c:	00053823          	sd	zero,16(a0)
}
    80005750:	6422                	ld	s0,8(sp)
    80005752:	0141                	addi	sp,sp,16
    80005754:	8082                	ret

0000000080005756 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005756:	411c                	lw	a5,0(a0)
    80005758:	e399                	bnez	a5,8000575e <holding+0x8>
    8000575a:	4501                	li	a0,0
  return r;
}
    8000575c:	8082                	ret
{
    8000575e:	1101                	addi	sp,sp,-32
    80005760:	ec06                	sd	ra,24(sp)
    80005762:	e822                	sd	s0,16(sp)
    80005764:	e426                	sd	s1,8(sp)
    80005766:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005768:	6904                	ld	s1,16(a0)
    8000576a:	de0fb0ef          	jal	80000d4a <mycpu>
    8000576e:	40a48533          	sub	a0,s1,a0
    80005772:	00153513          	seqz	a0,a0
}
    80005776:	60e2                	ld	ra,24(sp)
    80005778:	6442                	ld	s0,16(sp)
    8000577a:	64a2                	ld	s1,8(sp)
    8000577c:	6105                	addi	sp,sp,32
    8000577e:	8082                	ret

0000000080005780 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005780:	1101                	addi	sp,sp,-32
    80005782:	ec06                	sd	ra,24(sp)
    80005784:	e822                	sd	s0,16(sp)
    80005786:	e426                	sd	s1,8(sp)
    80005788:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000578a:	100024f3          	csrr	s1,sstatus
    8000578e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005792:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005794:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005798:	db2fb0ef          	jal	80000d4a <mycpu>
    8000579c:	5d3c                	lw	a5,120(a0)
    8000579e:	cb99                	beqz	a5,800057b4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800057a0:	daafb0ef          	jal	80000d4a <mycpu>
    800057a4:	5d3c                	lw	a5,120(a0)
    800057a6:	2785                	addiw	a5,a5,1
    800057a8:	dd3c                	sw	a5,120(a0)
}
    800057aa:	60e2                	ld	ra,24(sp)
    800057ac:	6442                	ld	s0,16(sp)
    800057ae:	64a2                	ld	s1,8(sp)
    800057b0:	6105                	addi	sp,sp,32
    800057b2:	8082                	ret
    mycpu()->intena = old;
    800057b4:	d96fb0ef          	jal	80000d4a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800057b8:	8085                	srli	s1,s1,0x1
    800057ba:	8885                	andi	s1,s1,1
    800057bc:	dd64                	sw	s1,124(a0)
    800057be:	b7cd                	j	800057a0 <push_off+0x20>

00000000800057c0 <acquire>:
{
    800057c0:	1101                	addi	sp,sp,-32
    800057c2:	ec06                	sd	ra,24(sp)
    800057c4:	e822                	sd	s0,16(sp)
    800057c6:	e426                	sd	s1,8(sp)
    800057c8:	1000                	addi	s0,sp,32
    800057ca:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800057cc:	fb5ff0ef          	jal	80005780 <push_off>
  if(holding(lk))
    800057d0:	8526                	mv	a0,s1
    800057d2:	f85ff0ef          	jal	80005756 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800057d6:	4705                	li	a4,1
  if(holding(lk))
    800057d8:	e105                	bnez	a0,800057f8 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800057da:	87ba                	mv	a5,a4
    800057dc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800057e0:	2781                	sext.w	a5,a5
    800057e2:	ffe5                	bnez	a5,800057da <acquire+0x1a>
  __sync_synchronize();
    800057e4:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800057e8:	d62fb0ef          	jal	80000d4a <mycpu>
    800057ec:	e888                	sd	a0,16(s1)
}
    800057ee:	60e2                	ld	ra,24(sp)
    800057f0:	6442                	ld	s0,16(sp)
    800057f2:	64a2                	ld	s1,8(sp)
    800057f4:	6105                	addi	sp,sp,32
    800057f6:	8082                	ret
    panic("acquire");
    800057f8:	00002517          	auipc	a0,0x2
    800057fc:	f6850513          	addi	a0,a0,-152 # 80007760 <etext+0x760>
    80005800:	c93ff0ef          	jal	80005492 <panic>

0000000080005804 <pop_off>:

void
pop_off(void)
{
    80005804:	1141                	addi	sp,sp,-16
    80005806:	e406                	sd	ra,8(sp)
    80005808:	e022                	sd	s0,0(sp)
    8000580a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000580c:	d3efb0ef          	jal	80000d4a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005810:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005814:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005816:	e78d                	bnez	a5,80005840 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005818:	5d3c                	lw	a5,120(a0)
    8000581a:	02f05963          	blez	a5,8000584c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    8000581e:	37fd                	addiw	a5,a5,-1
    80005820:	0007871b          	sext.w	a4,a5
    80005824:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005826:	eb09                	bnez	a4,80005838 <pop_off+0x34>
    80005828:	5d7c                	lw	a5,124(a0)
    8000582a:	c799                	beqz	a5,80005838 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000582c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005830:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005834:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005838:	60a2                	ld	ra,8(sp)
    8000583a:	6402                	ld	s0,0(sp)
    8000583c:	0141                	addi	sp,sp,16
    8000583e:	8082                	ret
    panic("pop_off - interruptible");
    80005840:	00002517          	auipc	a0,0x2
    80005844:	f2850513          	addi	a0,a0,-216 # 80007768 <etext+0x768>
    80005848:	c4bff0ef          	jal	80005492 <panic>
    panic("pop_off");
    8000584c:	00002517          	auipc	a0,0x2
    80005850:	f3450513          	addi	a0,a0,-204 # 80007780 <etext+0x780>
    80005854:	c3fff0ef          	jal	80005492 <panic>

0000000080005858 <release>:
{
    80005858:	1101                	addi	sp,sp,-32
    8000585a:	ec06                	sd	ra,24(sp)
    8000585c:	e822                	sd	s0,16(sp)
    8000585e:	e426                	sd	s1,8(sp)
    80005860:	1000                	addi	s0,sp,32
    80005862:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005864:	ef3ff0ef          	jal	80005756 <holding>
    80005868:	c105                	beqz	a0,80005888 <release+0x30>
  lk->cpu = 0;
    8000586a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000586e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005872:	0310000f          	fence	rw,w
    80005876:	0004a023          	sw	zero,0(s1)
  pop_off();
    8000587a:	f8bff0ef          	jal	80005804 <pop_off>
}
    8000587e:	60e2                	ld	ra,24(sp)
    80005880:	6442                	ld	s0,16(sp)
    80005882:	64a2                	ld	s1,8(sp)
    80005884:	6105                	addi	sp,sp,32
    80005886:	8082                	ret
    panic("release");
    80005888:	00002517          	auipc	a0,0x2
    8000588c:	f0050513          	addi	a0,a0,-256 # 80007788 <etext+0x788>
    80005890:	c03ff0ef          	jal	80005492 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
