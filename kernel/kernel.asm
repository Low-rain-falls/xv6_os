
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	25013103          	ld	sp,592(sp) # 8000a250 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	519040ef          	jal	80004d2e <start>

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
    80000034:	5a078793          	addi	a5,a5,1440 # 800235d0 <end>
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
    80000050:	25490913          	addi	s2,s2,596 # 8000a2a0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	73a050ef          	jal	80005790 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	7c2050ef          	jal	80005828 <release>
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
    8000007e:	3e4050ef          	jal	80005462 <panic>

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
    800000de:	1c650513          	addi	a0,a0,454 # 8000a2a0 <kmem>
    800000e2:	62e050ef          	jal	80005710 <initlock>
  freerange(end, (void*)PHYSTOP); //release a range of page from "end" to phystop = put a range to free list pf page
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00023517          	auipc	a0,0x23
    800000ee:	4e650513          	addi	a0,a0,1254 # 800235d0 <end>
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
    8000010c:	19848493          	addi	s1,s1,408 # 8000a2a0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	67e050ef          	jal	80005790 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	18450513          	addi	a0,a0,388 # 8000a2a0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	702050ef          	jal	80005828 <release>

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
    80000144:	16050513          	addi	a0,a0,352 # 8000a2a0 <kmem>
    80000148:	6e0050ef          	jal	80005828 <release>
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
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdba31>
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
    800002f8:	f7c70713          	addi	a4,a4,-132 # 8000a270 <started>
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
    80000316:	67b040ef          	jal	80005190 <printf>
    kvminithart();    // turn on paging
    8000031a:	080000ef          	jal	8000039a <kvminithart>
    trapinithart();   // install kernel trap vector
    8000031e:	538010ef          	jal	80001856 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000322:	426040ef          	jal	80004748 <plicinithart>
  }

  scheduler();        
    80000326:	675000ef          	jal	8000119a <scheduler>
    consoleinit();
    8000032a:	591040ef          	jal	800050ba <consoleinit>
    printfinit();
    8000032e:	16e050ef          	jal	8000549c <printfinit>
    printf("\n");
    80000332:	00007517          	auipc	a0,0x7
    80000336:	ce650513          	addi	a0,a0,-794 # 80007018 <etext+0x18>
    8000033a:	657040ef          	jal	80005190 <printf>
    printf("xv6 kernel is booting\n");
    8000033e:	00007517          	auipc	a0,0x7
    80000342:	ce250513          	addi	a0,a0,-798 # 80007020 <etext+0x20>
    80000346:	64b040ef          	jal	80005190 <printf>
    printf("\n");
    8000034a:	00007517          	auipc	a0,0x7
    8000034e:	cce50513          	addi	a0,a0,-818 # 80007018 <etext+0x18>
    80000352:	63f040ef          	jal	80005190 <printf>
    kinit();         // physical page allocator
    80000356:	d75ff0ef          	jal	800000ca <kinit>
    kvminit();       // create kernel page table
    8000035a:	2ca000ef          	jal	80000624 <kvminit>
    kvminithart();   // turn on paging
    8000035e:	03c000ef          	jal	8000039a <kvminithart>
    procinit();      // process table
    80000362:	123000ef          	jal	80000c84 <procinit>
    trapinit();      // trap vectors
    80000366:	4cc010ef          	jal	80001832 <trapinit>
    trapinithart();  // install kernel trap vector
    8000036a:	4ec010ef          	jal	80001856 <trapinithart>
    plicinit();      // set up interrupt controller
    8000036e:	3c0040ef          	jal	8000472e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000372:	3d6040ef          	jal	80004748 <plicinithart>
    binit();         // buffer cache
    80000376:	377010ef          	jal	80001eec <binit>
    iinit();         // inode table
    8000037a:	168020ef          	jal	800024e2 <iinit>
    fileinit();      // file table
    8000037e:	715020ef          	jal	80003292 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000382:	4b6040ef          	jal	80004838 <virtio_disk_init>
    userinit();      // first user process
    80000386:	449000ef          	jal	80000fce <userinit>
    __sync_synchronize();
    8000038a:	0330000f          	fence	rw,rw
    started = 1;
    8000038e:	4785                	li	a5,1
    80000390:	0000a717          	auipc	a4,0xa
    80000394:	eef72023          	sw	a5,-288(a4) # 8000a270 <started>
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
    800003a8:	ed47b783          	ld	a5,-300(a5) # 8000a278 <kernel_pagetable>
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
    800003f0:	072050ef          	jal	80005462 <panic>
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
    80000416:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdba27>
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
    80000506:	75d040ef          	jal	80005462 <panic>
    panic("mappages: size not aligned");
    8000050a:	00007517          	auipc	a0,0x7
    8000050e:	b6e50513          	addi	a0,a0,-1170 # 80007078 <etext+0x78>
    80000512:	751040ef          	jal	80005462 <panic>
    panic("mappages: size");
    80000516:	00007517          	auipc	a0,0x7
    8000051a:	b8250513          	addi	a0,a0,-1150 # 80007098 <etext+0x98>
    8000051e:	745040ef          	jal	80005462 <panic>
      panic("mappages: remap");
    80000522:	00007517          	auipc	a0,0x7
    80000526:	b8650513          	addi	a0,a0,-1146 # 800070a8 <etext+0xa8>
    8000052a:	739040ef          	jal	80005462 <panic>
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
    8000056e:	6f5040ef          	jal	80005462 <panic>

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
    80000634:	c4a7b423          	sd	a0,-952(a5) # 8000a278 <kernel_pagetable>
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
    80000688:	5db040ef          	jal	80005462 <panic>
      panic("uvmunmap: walk");
    8000068c:	00007517          	auipc	a0,0x7
    80000690:	a4c50513          	addi	a0,a0,-1460 # 800070d8 <etext+0xd8>
    80000694:	5cf040ef          	jal	80005462 <panic>
      panic("uvmunmap: not mapped");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a5050513          	addi	a0,a0,-1456 # 800070e8 <etext+0xe8>
    800006a0:	5c3040ef          	jal	80005462 <panic>
      panic("uvmunmap: not a leaf");
    800006a4:	00007517          	auipc	a0,0x7
    800006a8:	a5c50513          	addi	a0,a0,-1444 # 80007100 <etext+0x100>
    800006ac:	5b7040ef          	jal	80005462 <panic>
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
    8000077c:	4e7040ef          	jal	80005462 <panic>

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
    800008b0:	3b3040ef          	jal	80005462 <panic>
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
    8000096e:	2f5040ef          	jal	80005462 <panic>
      panic("uvmcopy: page not present");
    80000972:	00006517          	auipc	a0,0x6
    80000976:	7f650513          	addi	a0,a0,2038 # 80007168 <etext+0x168>
    8000097a:	2e9040ef          	jal	80005462 <panic>
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
    800009d4:	28f040ef          	jal	80005462 <panic>

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
    80000c06:	aee48493          	addi	s1,s1,-1298 # 8000a6f0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c0a:	8b26                	mv	s6,s1
    80000c0c:	04fa5937          	lui	s2,0x4fa5
    80000c10:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000c14:	0932                	slli	s2,s2,0xc
    80000c16:	fa590913          	addi	s2,s2,-91
    80000c1a:	0932                	slli	s2,s2,0xc
    80000c1c:	fa590913          	addi	s2,s2,-91
    80000c20:	0932                	slli	s2,s2,0xc
    80000c22:	fa590913          	addi	s2,s2,-91
    80000c26:	040009b7          	lui	s3,0x4000
    80000c2a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c2c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c2e:	0000fa97          	auipc	s5,0xf
    80000c32:	4c2a8a93          	addi	s5,s5,1218 # 800100f0 <tickslock>
    char *pa = kalloc();
    80000c36:	cc8ff0ef          	jal	800000fe <kalloc>
    80000c3a:	862a                	mv	a2,a0
    if(pa == 0)
    80000c3c:	cd15                	beqz	a0,80000c78 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c3e:	416485b3          	sub	a1,s1,s6
    80000c42:	858d                	srai	a1,a1,0x3
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
    80000c5c:	16848493          	addi	s1,s1,360
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
    80000c80:	7e2040ef          	jal	80005462 <panic>

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
    80000ca4:	62050513          	addi	a0,a0,1568 # 8000a2c0 <pid_lock>
    80000ca8:	269040ef          	jal	80005710 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cac:	00006597          	auipc	a1,0x6
    80000cb0:	4fc58593          	addi	a1,a1,1276 # 800071a8 <etext+0x1a8>
    80000cb4:	00009517          	auipc	a0,0x9
    80000cb8:	62450513          	addi	a0,a0,1572 # 8000a2d8 <wait_lock>
    80000cbc:	255040ef          	jal	80005710 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cc0:	0000a497          	auipc	s1,0xa
    80000cc4:	a3048493          	addi	s1,s1,-1488 # 8000a6f0 <proc>
      initlock(&p->lock, "proc");
    80000cc8:	00006b17          	auipc	s6,0x6
    80000ccc:	4f0b0b13          	addi	s6,s6,1264 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cd0:	8aa6                	mv	s5,s1
    80000cd2:	04fa5937          	lui	s2,0x4fa5
    80000cd6:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80000cda:	0932                	slli	s2,s2,0xc
    80000cdc:	fa590913          	addi	s2,s2,-91
    80000ce0:	0932                	slli	s2,s2,0xc
    80000ce2:	fa590913          	addi	s2,s2,-91
    80000ce6:	0932                	slli	s2,s2,0xc
    80000ce8:	fa590913          	addi	s2,s2,-91
    80000cec:	040009b7          	lui	s3,0x4000
    80000cf0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000cf2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf4:	0000fa17          	auipc	s4,0xf
    80000cf8:	3fca0a13          	addi	s4,s4,1020 # 800100f0 <tickslock>
      initlock(&p->lock, "proc");
    80000cfc:	85da                	mv	a1,s6
    80000cfe:	8526                	mv	a0,s1
    80000d00:	211040ef          	jal	80005710 <initlock>
      p->state = UNUSED;
    80000d04:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d08:	415487b3          	sub	a5,s1,s5
    80000d0c:	878d                	srai	a5,a5,0x3
    80000d0e:	032787b3          	mul	a5,a5,s2
    80000d12:	2785                	addiw	a5,a5,1
    80000d14:	00d7979b          	slliw	a5,a5,0xd
    80000d18:	40f987b3          	sub	a5,s3,a5
    80000d1c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d1e:	16848493          	addi	s1,s1,360
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
    80000d5a:	59a50513          	addi	a0,a0,1434 # 8000a2f0 <cpus>
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
    80000d70:	1e1040ef          	jal	80005750 <push_off>
    80000d74:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d76:	2781                	sext.w	a5,a5
    80000d78:	079e                	slli	a5,a5,0x7
    80000d7a:	00009717          	auipc	a4,0x9
    80000d7e:	54670713          	addi	a4,a4,1350 # 8000a2c0 <pid_lock>
    80000d82:	97ba                	add	a5,a5,a4
    80000d84:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d86:	24f040ef          	jal	800057d4 <pop_off>
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
    80000da2:	287040ef          	jal	80005828 <release>

  if (first) {
    80000da6:	00009797          	auipc	a5,0x9
    80000daa:	45a7a783          	lw	a5,1114(a5) # 8000a200 <first.1>
    80000dae:	e799                	bnez	a5,80000dbc <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000db0:	2bf000ef          	jal	8000186e <usertrapret>
}
    80000db4:	60a2                	ld	ra,8(sp)
    80000db6:	6402                	ld	s0,0(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
    fsinit(ROOTDEV);
    80000dbc:	4505                	li	a0,1
    80000dbe:	6b8010ef          	jal	80002476 <fsinit>
    first = 0;
    80000dc2:	00009797          	auipc	a5,0x9
    80000dc6:	4207af23          	sw	zero,1086(a5) # 8000a200 <first.1>
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
    80000de0:	4e490913          	addi	s2,s2,1252 # 8000a2c0 <pid_lock>
    80000de4:	854a                	mv	a0,s2
    80000de6:	1ab040ef          	jal	80005790 <acquire>
  pid = nextpid;
    80000dea:	00009797          	auipc	a5,0x9
    80000dee:	41a78793          	addi	a5,a5,1050 # 8000a204 <nextpid>
    80000df2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000df4:	0014871b          	addiw	a4,s1,1
    80000df8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000dfa:	854a                	mv	a0,s2
    80000dfc:	22d040ef          	jal	80005828 <release>
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
    80000f38:	7bc48493          	addi	s1,s1,1980 # 8000a6f0 <proc>
    80000f3c:	0000f917          	auipc	s2,0xf
    80000f40:	1b490913          	addi	s2,s2,436 # 800100f0 <tickslock>
    acquire(&p->lock);
    80000f44:	8526                	mv	a0,s1
    80000f46:	04b040ef          	jal	80005790 <acquire>
    if(p->state == UNUSED) {
    80000f4a:	4c9c                	lw	a5,24(s1)
    80000f4c:	cb91                	beqz	a5,80000f60 <allocproc+0x38>
      release(&p->lock);
    80000f4e:	8526                	mv	a0,s1
    80000f50:	0d9040ef          	jal	80005828 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f54:	16848493          	addi	s1,s1,360
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
    80000fb6:	073040ef          	jal	80005828 <release>
    return 0;
    80000fba:	84ca                	mv	s1,s2
    80000fbc:	b7d5                	j	80000fa0 <allocproc+0x78>
    freeproc(p);
    80000fbe:	8526                	mv	a0,s1
    80000fc0:	f19ff0ef          	jal	80000ed8 <freeproc>
    release(&p->lock);
    80000fc4:	8526                	mv	a0,s1
    80000fc6:	063040ef          	jal	80005828 <release>
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
    80000fe2:	2aa7b123          	sd	a0,674(a5) # 8000a280 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80000fe6:	03400613          	li	a2,52
    80000fea:	00009597          	auipc	a1,0x9
    80000fee:	22658593          	addi	a1,a1,550 # 8000a210 <initcode>
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
    80001020:	565010ef          	jal	80002d84 <namei>
    80001024:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001028:	478d                	li	a5,3
    8000102a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000102c:	8526                	mv	a0,s1
    8000102e:	7fa040ef          	jal	80005828 <release>
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
    800010a2:	0e050a63          	beqz	a0,80001196 <fork+0x10a>
    800010a6:	e852                	sd	s4,16(sp)
    800010a8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010aa:	048ab603          	ld	a2,72(s5)
    800010ae:	692c                	ld	a1,80(a0)
    800010b0:	050ab503          	ld	a0,80(s5)
    800010b4:	849ff0ef          	jal	800008fc <uvmcopy>
    800010b8:	04054a63          	bltz	a0,8000110c <fork+0x80>
    800010bc:	f426                	sd	s1,40(sp)
    800010be:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    800010c0:	048ab783          	ld	a5,72(s5)
    800010c4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800010c8:	058ab683          	ld	a3,88(s5)
    800010cc:	87b6                	mv	a5,a3
    800010ce:	058a3703          	ld	a4,88(s4)
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
  np->trapframe->a0 = 0;
    800010f6:	058a3783          	ld	a5,88(s4)
    800010fa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800010fe:	0d0a8493          	addi	s1,s5,208
    80001102:	0d0a0913          	addi	s2,s4,208
    80001106:	150a8993          	addi	s3,s5,336
    8000110a:	a831                	j	80001126 <fork+0x9a>
    freeproc(np);
    8000110c:	8552                	mv	a0,s4
    8000110e:	dcbff0ef          	jal	80000ed8 <freeproc>
    release(&np->lock);
    80001112:	8552                	mv	a0,s4
    80001114:	714040ef          	jal	80005828 <release>
    return -1;
    80001118:	597d                	li	s2,-1
    8000111a:	6a42                	ld	s4,16(sp)
    8000111c:	a0b5                	j	80001188 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    8000111e:	04a1                	addi	s1,s1,8
    80001120:	0921                	addi	s2,s2,8
    80001122:	01348963          	beq	s1,s3,80001134 <fork+0xa8>
    if(p->ofile[i])
    80001126:	6088                	ld	a0,0(s1)
    80001128:	d97d                	beqz	a0,8000111e <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    8000112a:	1ea020ef          	jal	80003314 <filedup>
    8000112e:	00a93023          	sd	a0,0(s2)
    80001132:	b7f5                	j	8000111e <fork+0x92>
  np->cwd = idup(p->cwd);
    80001134:	150ab503          	ld	a0,336(s5)
    80001138:	53c010ef          	jal	80002674 <idup>
    8000113c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001140:	4641                	li	a2,16
    80001142:	158a8593          	addi	a1,s5,344
    80001146:	158a0513          	addi	a0,s4,344
    8000114a:	942ff0ef          	jal	8000028c <safestrcpy>
  pid = np->pid;
    8000114e:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001152:	8552                	mv	a0,s4
    80001154:	6d4040ef          	jal	80005828 <release>
  acquire(&wait_lock);
    80001158:	00009497          	auipc	s1,0x9
    8000115c:	18048493          	addi	s1,s1,384 # 8000a2d8 <wait_lock>
    80001160:	8526                	mv	a0,s1
    80001162:	62e040ef          	jal	80005790 <acquire>
  np->parent = p;
    80001166:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000116a:	8526                	mv	a0,s1
    8000116c:	6bc040ef          	jal	80005828 <release>
  acquire(&np->lock);
    80001170:	8552                	mv	a0,s4
    80001172:	61e040ef          	jal	80005790 <acquire>
  np->state = RUNNABLE;
    80001176:	478d                	li	a5,3
    80001178:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000117c:	8552                	mv	a0,s4
    8000117e:	6aa040ef          	jal	80005828 <release>
  return pid;
    80001182:	74a2                	ld	s1,40(sp)
    80001184:	69e2                	ld	s3,24(sp)
    80001186:	6a42                	ld	s4,16(sp)
}
    80001188:	854a                	mv	a0,s2
    8000118a:	70e2                	ld	ra,56(sp)
    8000118c:	7442                	ld	s0,48(sp)
    8000118e:	7902                	ld	s2,32(sp)
    80001190:	6aa2                	ld	s5,8(sp)
    80001192:	6121                	addi	sp,sp,64
    80001194:	8082                	ret
    return -1;
    80001196:	597d                	li	s2,-1
    80001198:	bfc5                	j	80001188 <fork+0xfc>

000000008000119a <scheduler>:
{
    8000119a:	715d                	addi	sp,sp,-80
    8000119c:	e486                	sd	ra,72(sp)
    8000119e:	e0a2                	sd	s0,64(sp)
    800011a0:	fc26                	sd	s1,56(sp)
    800011a2:	f84a                	sd	s2,48(sp)
    800011a4:	f44e                	sd	s3,40(sp)
    800011a6:	f052                	sd	s4,32(sp)
    800011a8:	ec56                	sd	s5,24(sp)
    800011aa:	e85a                	sd	s6,16(sp)
    800011ac:	e45e                	sd	s7,8(sp)
    800011ae:	e062                	sd	s8,0(sp)
    800011b0:	0880                	addi	s0,sp,80
    800011b2:	8792                	mv	a5,tp
  int id = r_tp();
    800011b4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800011b6:	00779b13          	slli	s6,a5,0x7
    800011ba:	00009717          	auipc	a4,0x9
    800011be:	10670713          	addi	a4,a4,262 # 8000a2c0 <pid_lock>
    800011c2:	975a                	add	a4,a4,s6
    800011c4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800011c8:	00009717          	auipc	a4,0x9
    800011cc:	13070713          	addi	a4,a4,304 # 8000a2f8 <cpus+0x8>
    800011d0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800011d2:	4c11                	li	s8,4
        c->proc = p;
    800011d4:	079e                	slli	a5,a5,0x7
    800011d6:	00009a17          	auipc	s4,0x9
    800011da:	0eaa0a13          	addi	s4,s4,234 # 8000a2c0 <pid_lock>
    800011de:	9a3e                	add	s4,s4,a5
        found = 1;
    800011e0:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800011e2:	0000f997          	auipc	s3,0xf
    800011e6:	f0e98993          	addi	s3,s3,-242 # 800100f0 <tickslock>
    800011ea:	a0a9                	j	80001234 <scheduler+0x9a>
      release(&p->lock);
    800011ec:	8526                	mv	a0,s1
    800011ee:	63a040ef          	jal	80005828 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800011f2:	16848493          	addi	s1,s1,360
    800011f6:	03348563          	beq	s1,s3,80001220 <scheduler+0x86>
      acquire(&p->lock);
    800011fa:	8526                	mv	a0,s1
    800011fc:	594040ef          	jal	80005790 <acquire>
      if(p->state == RUNNABLE) {
    80001200:	4c9c                	lw	a5,24(s1)
    80001202:	ff2795e3          	bne	a5,s2,800011ec <scheduler+0x52>
        p->state = RUNNING;
    80001206:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000120a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000120e:	06048593          	addi	a1,s1,96
    80001212:	855a                	mv	a0,s6
    80001214:	5b4000ef          	jal	800017c8 <swtch>
        c->proc = 0;
    80001218:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000121c:	8ade                	mv	s5,s7
    8000121e:	b7f9                	j	800011ec <scheduler+0x52>
    if(found == 0) {
    80001220:	000a9a63          	bnez	s5,80001234 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001224:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001228:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000122c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001230:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001234:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001238:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000123c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001240:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001242:	00009497          	auipc	s1,0x9
    80001246:	4ae48493          	addi	s1,s1,1198 # 8000a6f0 <proc>
      if(p->state == RUNNABLE) {
    8000124a:	490d                	li	s2,3
    8000124c:	b77d                	j	800011fa <scheduler+0x60>

000000008000124e <sched>:
{
    8000124e:	7179                	addi	sp,sp,-48
    80001250:	f406                	sd	ra,40(sp)
    80001252:	f022                	sd	s0,32(sp)
    80001254:	ec26                	sd	s1,24(sp)
    80001256:	e84a                	sd	s2,16(sp)
    80001258:	e44e                	sd	s3,8(sp)
    8000125a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000125c:	b0bff0ef          	jal	80000d66 <myproc>
    80001260:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001262:	4c4040ef          	jal	80005726 <holding>
    80001266:	c92d                	beqz	a0,800012d8 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001268:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000126a:	2781                	sext.w	a5,a5
    8000126c:	079e                	slli	a5,a5,0x7
    8000126e:	00009717          	auipc	a4,0x9
    80001272:	05270713          	addi	a4,a4,82 # 8000a2c0 <pid_lock>
    80001276:	97ba                	add	a5,a5,a4
    80001278:	0a87a703          	lw	a4,168(a5)
    8000127c:	4785                	li	a5,1
    8000127e:	06f71363          	bne	a4,a5,800012e4 <sched+0x96>
  if(p->state == RUNNING)
    80001282:	4c98                	lw	a4,24(s1)
    80001284:	4791                	li	a5,4
    80001286:	06f70563          	beq	a4,a5,800012f0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000128a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000128e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001290:	e7b5                	bnez	a5,800012fc <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001292:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001294:	00009917          	auipc	s2,0x9
    80001298:	02c90913          	addi	s2,s2,44 # 8000a2c0 <pid_lock>
    8000129c:	2781                	sext.w	a5,a5
    8000129e:	079e                	slli	a5,a5,0x7
    800012a0:	97ca                	add	a5,a5,s2
    800012a2:	0ac7a983          	lw	s3,172(a5)
    800012a6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012a8:	2781                	sext.w	a5,a5
    800012aa:	079e                	slli	a5,a5,0x7
    800012ac:	00009597          	auipc	a1,0x9
    800012b0:	04c58593          	addi	a1,a1,76 # 8000a2f8 <cpus+0x8>
    800012b4:	95be                	add	a1,a1,a5
    800012b6:	06048513          	addi	a0,s1,96
    800012ba:	50e000ef          	jal	800017c8 <swtch>
    800012be:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800012c0:	2781                	sext.w	a5,a5
    800012c2:	079e                	slli	a5,a5,0x7
    800012c4:	993e                	add	s2,s2,a5
    800012c6:	0b392623          	sw	s3,172(s2)
}
    800012ca:	70a2                	ld	ra,40(sp)
    800012cc:	7402                	ld	s0,32(sp)
    800012ce:	64e2                	ld	s1,24(sp)
    800012d0:	6942                	ld	s2,16(sp)
    800012d2:	69a2                	ld	s3,8(sp)
    800012d4:	6145                	addi	sp,sp,48
    800012d6:	8082                	ret
    panic("sched p->lock");
    800012d8:	00006517          	auipc	a0,0x6
    800012dc:	f0050513          	addi	a0,a0,-256 # 800071d8 <etext+0x1d8>
    800012e0:	182040ef          	jal	80005462 <panic>
    panic("sched locks");
    800012e4:	00006517          	auipc	a0,0x6
    800012e8:	f0450513          	addi	a0,a0,-252 # 800071e8 <etext+0x1e8>
    800012ec:	176040ef          	jal	80005462 <panic>
    panic("sched running");
    800012f0:	00006517          	auipc	a0,0x6
    800012f4:	f0850513          	addi	a0,a0,-248 # 800071f8 <etext+0x1f8>
    800012f8:	16a040ef          	jal	80005462 <panic>
    panic("sched interruptible");
    800012fc:	00006517          	auipc	a0,0x6
    80001300:	f0c50513          	addi	a0,a0,-244 # 80007208 <etext+0x208>
    80001304:	15e040ef          	jal	80005462 <panic>

0000000080001308 <yield>:
{
    80001308:	1101                	addi	sp,sp,-32
    8000130a:	ec06                	sd	ra,24(sp)
    8000130c:	e822                	sd	s0,16(sp)
    8000130e:	e426                	sd	s1,8(sp)
    80001310:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001312:	a55ff0ef          	jal	80000d66 <myproc>
    80001316:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001318:	478040ef          	jal	80005790 <acquire>
  p->state = RUNNABLE;
    8000131c:	478d                	li	a5,3
    8000131e:	cc9c                	sw	a5,24(s1)
  sched();
    80001320:	f2fff0ef          	jal	8000124e <sched>
  release(&p->lock);
    80001324:	8526                	mv	a0,s1
    80001326:	502040ef          	jal	80005828 <release>
}
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	1800                	addi	s0,sp,48
    80001342:	89aa                	mv	s3,a0
    80001344:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001346:	a21ff0ef          	jal	80000d66 <myproc>
    8000134a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000134c:	444040ef          	jal	80005790 <acquire>
  release(lk);
    80001350:	854a                	mv	a0,s2
    80001352:	4d6040ef          	jal	80005828 <release>

  // Go to sleep.
  p->chan = chan;
    80001356:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000135a:	4789                	li	a5,2
    8000135c:	cc9c                	sw	a5,24(s1)

  sched();
    8000135e:	ef1ff0ef          	jal	8000124e <sched>

  // Tidy up.
  p->chan = 0;
    80001362:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001366:	8526                	mv	a0,s1
    80001368:	4c0040ef          	jal	80005828 <release>
  acquire(lk);
    8000136c:	854a                	mv	a0,s2
    8000136e:	422040ef          	jal	80005790 <acquire>
}
    80001372:	70a2                	ld	ra,40(sp)
    80001374:	7402                	ld	s0,32(sp)
    80001376:	64e2                	ld	s1,24(sp)
    80001378:	6942                	ld	s2,16(sp)
    8000137a:	69a2                	ld	s3,8(sp)
    8000137c:	6145                	addi	sp,sp,48
    8000137e:	8082                	ret

0000000080001380 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001380:	7139                	addi	sp,sp,-64
    80001382:	fc06                	sd	ra,56(sp)
    80001384:	f822                	sd	s0,48(sp)
    80001386:	f426                	sd	s1,40(sp)
    80001388:	f04a                	sd	s2,32(sp)
    8000138a:	ec4e                	sd	s3,24(sp)
    8000138c:	e852                	sd	s4,16(sp)
    8000138e:	e456                	sd	s5,8(sp)
    80001390:	0080                	addi	s0,sp,64
    80001392:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001394:	00009497          	auipc	s1,0x9
    80001398:	35c48493          	addi	s1,s1,860 # 8000a6f0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000139c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000139e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013a0:	0000f917          	auipc	s2,0xf
    800013a4:	d5090913          	addi	s2,s2,-688 # 800100f0 <tickslock>
    800013a8:	a801                	j	800013b8 <wakeup+0x38>
      }
      release(&p->lock);
    800013aa:	8526                	mv	a0,s1
    800013ac:	47c040ef          	jal	80005828 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013b0:	16848493          	addi	s1,s1,360
    800013b4:	03248263          	beq	s1,s2,800013d8 <wakeup+0x58>
    if(p != myproc()){
    800013b8:	9afff0ef          	jal	80000d66 <myproc>
    800013bc:	fea48ae3          	beq	s1,a0,800013b0 <wakeup+0x30>
      acquire(&p->lock);
    800013c0:	8526                	mv	a0,s1
    800013c2:	3ce040ef          	jal	80005790 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800013c6:	4c9c                	lw	a5,24(s1)
    800013c8:	ff3791e3          	bne	a5,s3,800013aa <wakeup+0x2a>
    800013cc:	709c                	ld	a5,32(s1)
    800013ce:	fd479ee3          	bne	a5,s4,800013aa <wakeup+0x2a>
        p->state = RUNNABLE;
    800013d2:	0154ac23          	sw	s5,24(s1)
    800013d6:	bfd1                	j	800013aa <wakeup+0x2a>
    }
  }
}
    800013d8:	70e2                	ld	ra,56(sp)
    800013da:	7442                	ld	s0,48(sp)
    800013dc:	74a2                	ld	s1,40(sp)
    800013de:	7902                	ld	s2,32(sp)
    800013e0:	69e2                	ld	s3,24(sp)
    800013e2:	6a42                	ld	s4,16(sp)
    800013e4:	6aa2                	ld	s5,8(sp)
    800013e6:	6121                	addi	sp,sp,64
    800013e8:	8082                	ret

00000000800013ea <reparent>:
{
    800013ea:	7179                	addi	sp,sp,-48
    800013ec:	f406                	sd	ra,40(sp)
    800013ee:	f022                	sd	s0,32(sp)
    800013f0:	ec26                	sd	s1,24(sp)
    800013f2:	e84a                	sd	s2,16(sp)
    800013f4:	e44e                	sd	s3,8(sp)
    800013f6:	e052                	sd	s4,0(sp)
    800013f8:	1800                	addi	s0,sp,48
    800013fa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013fc:	00009497          	auipc	s1,0x9
    80001400:	2f448493          	addi	s1,s1,756 # 8000a6f0 <proc>
      pp->parent = initproc;
    80001404:	00009a17          	auipc	s4,0x9
    80001408:	e7ca0a13          	addi	s4,s4,-388 # 8000a280 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000140c:	0000f997          	auipc	s3,0xf
    80001410:	ce498993          	addi	s3,s3,-796 # 800100f0 <tickslock>
    80001414:	a029                	j	8000141e <reparent+0x34>
    80001416:	16848493          	addi	s1,s1,360
    8000141a:	01348b63          	beq	s1,s3,80001430 <reparent+0x46>
    if(pp->parent == p){
    8000141e:	7c9c                	ld	a5,56(s1)
    80001420:	ff279be3          	bne	a5,s2,80001416 <reparent+0x2c>
      pp->parent = initproc;
    80001424:	000a3503          	ld	a0,0(s4)
    80001428:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000142a:	f57ff0ef          	jal	80001380 <wakeup>
    8000142e:	b7e5                	j	80001416 <reparent+0x2c>
}
    80001430:	70a2                	ld	ra,40(sp)
    80001432:	7402                	ld	s0,32(sp)
    80001434:	64e2                	ld	s1,24(sp)
    80001436:	6942                	ld	s2,16(sp)
    80001438:	69a2                	ld	s3,8(sp)
    8000143a:	6a02                	ld	s4,0(sp)
    8000143c:	6145                	addi	sp,sp,48
    8000143e:	8082                	ret

0000000080001440 <exit>:
{
    80001440:	7179                	addi	sp,sp,-48
    80001442:	f406                	sd	ra,40(sp)
    80001444:	f022                	sd	s0,32(sp)
    80001446:	ec26                	sd	s1,24(sp)
    80001448:	e84a                	sd	s2,16(sp)
    8000144a:	e44e                	sd	s3,8(sp)
    8000144c:	e052                	sd	s4,0(sp)
    8000144e:	1800                	addi	s0,sp,48
    80001450:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001452:	915ff0ef          	jal	80000d66 <myproc>
    80001456:	89aa                	mv	s3,a0
  if(p == initproc)
    80001458:	00009797          	auipc	a5,0x9
    8000145c:	e287b783          	ld	a5,-472(a5) # 8000a280 <initproc>
    80001460:	0d050493          	addi	s1,a0,208
    80001464:	15050913          	addi	s2,a0,336
    80001468:	00a79f63          	bne	a5,a0,80001486 <exit+0x46>
    panic("init exiting");
    8000146c:	00006517          	auipc	a0,0x6
    80001470:	db450513          	addi	a0,a0,-588 # 80007220 <etext+0x220>
    80001474:	7ef030ef          	jal	80005462 <panic>
      fileclose(f);
    80001478:	6e3010ef          	jal	8000335a <fileclose>
      p->ofile[fd] = 0;
    8000147c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001480:	04a1                	addi	s1,s1,8
    80001482:	01248563          	beq	s1,s2,8000148c <exit+0x4c>
    if(p->ofile[fd]){
    80001486:	6088                	ld	a0,0(s1)
    80001488:	f965                	bnez	a0,80001478 <exit+0x38>
    8000148a:	bfdd                	j	80001480 <exit+0x40>
  begin_op();
    8000148c:	2b5010ef          	jal	80002f40 <begin_op>
  iput(p->cwd);
    80001490:	1509b503          	ld	a0,336(s3)
    80001494:	398010ef          	jal	8000282c <iput>
  end_op();
    80001498:	313010ef          	jal	80002faa <end_op>
  p->cwd = 0;
    8000149c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014a0:	00009497          	auipc	s1,0x9
    800014a4:	e3848493          	addi	s1,s1,-456 # 8000a2d8 <wait_lock>
    800014a8:	8526                	mv	a0,s1
    800014aa:	2e6040ef          	jal	80005790 <acquire>
  reparent(p);
    800014ae:	854e                	mv	a0,s3
    800014b0:	f3bff0ef          	jal	800013ea <reparent>
  wakeup(p->parent);
    800014b4:	0389b503          	ld	a0,56(s3)
    800014b8:	ec9ff0ef          	jal	80001380 <wakeup>
  acquire(&p->lock);
    800014bc:	854e                	mv	a0,s3
    800014be:	2d2040ef          	jal	80005790 <acquire>
  p->xstate = status;
    800014c2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800014c6:	4795                	li	a5,5
    800014c8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800014cc:	8526                	mv	a0,s1
    800014ce:	35a040ef          	jal	80005828 <release>
  sched();
    800014d2:	d7dff0ef          	jal	8000124e <sched>
  panic("zombie exit");
    800014d6:	00006517          	auipc	a0,0x6
    800014da:	d5a50513          	addi	a0,a0,-678 # 80007230 <etext+0x230>
    800014de:	785030ef          	jal	80005462 <panic>

00000000800014e2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800014e2:	7179                	addi	sp,sp,-48
    800014e4:	f406                	sd	ra,40(sp)
    800014e6:	f022                	sd	s0,32(sp)
    800014e8:	ec26                	sd	s1,24(sp)
    800014ea:	e84a                	sd	s2,16(sp)
    800014ec:	e44e                	sd	s3,8(sp)
    800014ee:	1800                	addi	s0,sp,48
    800014f0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800014f2:	00009497          	auipc	s1,0x9
    800014f6:	1fe48493          	addi	s1,s1,510 # 8000a6f0 <proc>
    800014fa:	0000f997          	auipc	s3,0xf
    800014fe:	bf698993          	addi	s3,s3,-1034 # 800100f0 <tickslock>
    acquire(&p->lock);
    80001502:	8526                	mv	a0,s1
    80001504:	28c040ef          	jal	80005790 <acquire>
    if(p->pid == pid){
    80001508:	589c                	lw	a5,48(s1)
    8000150a:	01278b63          	beq	a5,s2,80001520 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000150e:	8526                	mv	a0,s1
    80001510:	318040ef          	jal	80005828 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001514:	16848493          	addi	s1,s1,360
    80001518:	ff3495e3          	bne	s1,s3,80001502 <kill+0x20>
  }
  return -1;
    8000151c:	557d                	li	a0,-1
    8000151e:	a819                	j	80001534 <kill+0x52>
      p->killed = 1;
    80001520:	4785                	li	a5,1
    80001522:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001524:	4c98                	lw	a4,24(s1)
    80001526:	4789                	li	a5,2
    80001528:	00f70d63          	beq	a4,a5,80001542 <kill+0x60>
      release(&p->lock);
    8000152c:	8526                	mv	a0,s1
    8000152e:	2fa040ef          	jal	80005828 <release>
      return 0;
    80001532:	4501                	li	a0,0
}
    80001534:	70a2                	ld	ra,40(sp)
    80001536:	7402                	ld	s0,32(sp)
    80001538:	64e2                	ld	s1,24(sp)
    8000153a:	6942                	ld	s2,16(sp)
    8000153c:	69a2                	ld	s3,8(sp)
    8000153e:	6145                	addi	sp,sp,48
    80001540:	8082                	ret
        p->state = RUNNABLE;
    80001542:	478d                	li	a5,3
    80001544:	cc9c                	sw	a5,24(s1)
    80001546:	b7dd                	j	8000152c <kill+0x4a>

0000000080001548 <setkilled>:

void
setkilled(struct proc *p)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001554:	23c040ef          	jal	80005790 <acquire>
  p->killed = 1;
    80001558:	4785                	li	a5,1
    8000155a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000155c:	8526                	mv	a0,s1
    8000155e:	2ca040ef          	jal	80005828 <release>
}
    80001562:	60e2                	ld	ra,24(sp)
    80001564:	6442                	ld	s0,16(sp)
    80001566:	64a2                	ld	s1,8(sp)
    80001568:	6105                	addi	sp,sp,32
    8000156a:	8082                	ret

000000008000156c <killed>:

int
killed(struct proc *p)
{
    8000156c:	1101                	addi	sp,sp,-32
    8000156e:	ec06                	sd	ra,24(sp)
    80001570:	e822                	sd	s0,16(sp)
    80001572:	e426                	sd	s1,8(sp)
    80001574:	e04a                	sd	s2,0(sp)
    80001576:	1000                	addi	s0,sp,32
    80001578:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000157a:	216040ef          	jal	80005790 <acquire>
  k = p->killed;
    8000157e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001582:	8526                	mv	a0,s1
    80001584:	2a4040ef          	jal	80005828 <release>
  return k;
}
    80001588:	854a                	mv	a0,s2
    8000158a:	60e2                	ld	ra,24(sp)
    8000158c:	6442                	ld	s0,16(sp)
    8000158e:	64a2                	ld	s1,8(sp)
    80001590:	6902                	ld	s2,0(sp)
    80001592:	6105                	addi	sp,sp,32
    80001594:	8082                	ret

0000000080001596 <wait>:
{
    80001596:	715d                	addi	sp,sp,-80
    80001598:	e486                	sd	ra,72(sp)
    8000159a:	e0a2                	sd	s0,64(sp)
    8000159c:	fc26                	sd	s1,56(sp)
    8000159e:	f84a                	sd	s2,48(sp)
    800015a0:	f44e                	sd	s3,40(sp)
    800015a2:	f052                	sd	s4,32(sp)
    800015a4:	ec56                	sd	s5,24(sp)
    800015a6:	e85a                	sd	s6,16(sp)
    800015a8:	e45e                	sd	s7,8(sp)
    800015aa:	e062                	sd	s8,0(sp)
    800015ac:	0880                	addi	s0,sp,80
    800015ae:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015b0:	fb6ff0ef          	jal	80000d66 <myproc>
    800015b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800015b6:	00009517          	auipc	a0,0x9
    800015ba:	d2250513          	addi	a0,a0,-734 # 8000a2d8 <wait_lock>
    800015be:	1d2040ef          	jal	80005790 <acquire>
    havekids = 0;
    800015c2:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800015c4:	4a15                	li	s4,5
        havekids = 1;
    800015c6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800015c8:	0000f997          	auipc	s3,0xf
    800015cc:	b2898993          	addi	s3,s3,-1240 # 800100f0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800015d0:	00009c17          	auipc	s8,0x9
    800015d4:	d08c0c13          	addi	s8,s8,-760 # 8000a2d8 <wait_lock>
    800015d8:	a871                	j	80001674 <wait+0xde>
          pid = pp->pid;
    800015da:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800015de:	000b0c63          	beqz	s6,800015f6 <wait+0x60>
    800015e2:	4691                	li	a3,4
    800015e4:	02c48613          	addi	a2,s1,44
    800015e8:	85da                	mv	a1,s6
    800015ea:	05093503          	ld	a0,80(s2)
    800015ee:	beaff0ef          	jal	800009d8 <copyout>
    800015f2:	02054b63          	bltz	a0,80001628 <wait+0x92>
          freeproc(pp);
    800015f6:	8526                	mv	a0,s1
    800015f8:	8e1ff0ef          	jal	80000ed8 <freeproc>
          release(&pp->lock);
    800015fc:	8526                	mv	a0,s1
    800015fe:	22a040ef          	jal	80005828 <release>
          release(&wait_lock);
    80001602:	00009517          	auipc	a0,0x9
    80001606:	cd650513          	addi	a0,a0,-810 # 8000a2d8 <wait_lock>
    8000160a:	21e040ef          	jal	80005828 <release>
}
    8000160e:	854e                	mv	a0,s3
    80001610:	60a6                	ld	ra,72(sp)
    80001612:	6406                	ld	s0,64(sp)
    80001614:	74e2                	ld	s1,56(sp)
    80001616:	7942                	ld	s2,48(sp)
    80001618:	79a2                	ld	s3,40(sp)
    8000161a:	7a02                	ld	s4,32(sp)
    8000161c:	6ae2                	ld	s5,24(sp)
    8000161e:	6b42                	ld	s6,16(sp)
    80001620:	6ba2                	ld	s7,8(sp)
    80001622:	6c02                	ld	s8,0(sp)
    80001624:	6161                	addi	sp,sp,80
    80001626:	8082                	ret
            release(&pp->lock);
    80001628:	8526                	mv	a0,s1
    8000162a:	1fe040ef          	jal	80005828 <release>
            release(&wait_lock);
    8000162e:	00009517          	auipc	a0,0x9
    80001632:	caa50513          	addi	a0,a0,-854 # 8000a2d8 <wait_lock>
    80001636:	1f2040ef          	jal	80005828 <release>
            return -1;
    8000163a:	59fd                	li	s3,-1
    8000163c:	bfc9                	j	8000160e <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000163e:	16848493          	addi	s1,s1,360
    80001642:	03348063          	beq	s1,s3,80001662 <wait+0xcc>
      if(pp->parent == p){
    80001646:	7c9c                	ld	a5,56(s1)
    80001648:	ff279be3          	bne	a5,s2,8000163e <wait+0xa8>
        acquire(&pp->lock);
    8000164c:	8526                	mv	a0,s1
    8000164e:	142040ef          	jal	80005790 <acquire>
        if(pp->state == ZOMBIE){
    80001652:	4c9c                	lw	a5,24(s1)
    80001654:	f94783e3          	beq	a5,s4,800015da <wait+0x44>
        release(&pp->lock);
    80001658:	8526                	mv	a0,s1
    8000165a:	1ce040ef          	jal	80005828 <release>
        havekids = 1;
    8000165e:	8756                	mv	a4,s5
    80001660:	bff9                	j	8000163e <wait+0xa8>
    if(!havekids || killed(p)){
    80001662:	cf19                	beqz	a4,80001680 <wait+0xea>
    80001664:	854a                	mv	a0,s2
    80001666:	f07ff0ef          	jal	8000156c <killed>
    8000166a:	e919                	bnez	a0,80001680 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000166c:	85e2                	mv	a1,s8
    8000166e:	854a                	mv	a0,s2
    80001670:	cc5ff0ef          	jal	80001334 <sleep>
    havekids = 0;
    80001674:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001676:	00009497          	auipc	s1,0x9
    8000167a:	07a48493          	addi	s1,s1,122 # 8000a6f0 <proc>
    8000167e:	b7e1                	j	80001646 <wait+0xb0>
      release(&wait_lock);
    80001680:	00009517          	auipc	a0,0x9
    80001684:	c5850513          	addi	a0,a0,-936 # 8000a2d8 <wait_lock>
    80001688:	1a0040ef          	jal	80005828 <release>
      return -1;
    8000168c:	59fd                	li	s3,-1
    8000168e:	b741                	j	8000160e <wait+0x78>

0000000080001690 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001690:	7179                	addi	sp,sp,-48
    80001692:	f406                	sd	ra,40(sp)
    80001694:	f022                	sd	s0,32(sp)
    80001696:	ec26                	sd	s1,24(sp)
    80001698:	e84a                	sd	s2,16(sp)
    8000169a:	e44e                	sd	s3,8(sp)
    8000169c:	e052                	sd	s4,0(sp)
    8000169e:	1800                	addi	s0,sp,48
    800016a0:	84aa                	mv	s1,a0
    800016a2:	892e                	mv	s2,a1
    800016a4:	89b2                	mv	s3,a2
    800016a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016a8:	ebeff0ef          	jal	80000d66 <myproc>
  if(user_dst){
    800016ac:	cc99                	beqz	s1,800016ca <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800016ae:	86d2                	mv	a3,s4
    800016b0:	864e                	mv	a2,s3
    800016b2:	85ca                	mv	a1,s2
    800016b4:	6928                	ld	a0,80(a0)
    800016b6:	b22ff0ef          	jal	800009d8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800016ba:	70a2                	ld	ra,40(sp)
    800016bc:	7402                	ld	s0,32(sp)
    800016be:	64e2                	ld	s1,24(sp)
    800016c0:	6942                	ld	s2,16(sp)
    800016c2:	69a2                	ld	s3,8(sp)
    800016c4:	6a02                	ld	s4,0(sp)
    800016c6:	6145                	addi	sp,sp,48
    800016c8:	8082                	ret
    memmove((char *)dst, src, len);
    800016ca:	000a061b          	sext.w	a2,s4
    800016ce:	85ce                	mv	a1,s3
    800016d0:	854a                	mv	a0,s2
    800016d2:	ad9fe0ef          	jal	800001aa <memmove>
    return 0;
    800016d6:	8526                	mv	a0,s1
    800016d8:	b7cd                	j	800016ba <either_copyout+0x2a>

00000000800016da <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800016da:	7179                	addi	sp,sp,-48
    800016dc:	f406                	sd	ra,40(sp)
    800016de:	f022                	sd	s0,32(sp)
    800016e0:	ec26                	sd	s1,24(sp)
    800016e2:	e84a                	sd	s2,16(sp)
    800016e4:	e44e                	sd	s3,8(sp)
    800016e6:	e052                	sd	s4,0(sp)
    800016e8:	1800                	addi	s0,sp,48
    800016ea:	892a                	mv	s2,a0
    800016ec:	84ae                	mv	s1,a1
    800016ee:	89b2                	mv	s3,a2
    800016f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016f2:	e74ff0ef          	jal	80000d66 <myproc>
  if(user_src){
    800016f6:	cc99                	beqz	s1,80001714 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800016f8:	86d2                	mv	a3,s4
    800016fa:	864e                	mv	a2,s3
    800016fc:	85ca                	mv	a1,s2
    800016fe:	6928                	ld	a0,80(a0)
    80001700:	baeff0ef          	jal	80000aae <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001704:	70a2                	ld	ra,40(sp)
    80001706:	7402                	ld	s0,32(sp)
    80001708:	64e2                	ld	s1,24(sp)
    8000170a:	6942                	ld	s2,16(sp)
    8000170c:	69a2                	ld	s3,8(sp)
    8000170e:	6a02                	ld	s4,0(sp)
    80001710:	6145                	addi	sp,sp,48
    80001712:	8082                	ret
    memmove(dst, (char*)src, len);
    80001714:	000a061b          	sext.w	a2,s4
    80001718:	85ce                	mv	a1,s3
    8000171a:	854a                	mv	a0,s2
    8000171c:	a8ffe0ef          	jal	800001aa <memmove>
    return 0;
    80001720:	8526                	mv	a0,s1
    80001722:	b7cd                	j	80001704 <either_copyin+0x2a>

0000000080001724 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001724:	715d                	addi	sp,sp,-80
    80001726:	e486                	sd	ra,72(sp)
    80001728:	e0a2                	sd	s0,64(sp)
    8000172a:	fc26                	sd	s1,56(sp)
    8000172c:	f84a                	sd	s2,48(sp)
    8000172e:	f44e                	sd	s3,40(sp)
    80001730:	f052                	sd	s4,32(sp)
    80001732:	ec56                	sd	s5,24(sp)
    80001734:	e85a                	sd	s6,16(sp)
    80001736:	e45e                	sd	s7,8(sp)
    80001738:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000173a:	00006517          	auipc	a0,0x6
    8000173e:	8de50513          	addi	a0,a0,-1826 # 80007018 <etext+0x18>
    80001742:	24f030ef          	jal	80005190 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001746:	00009497          	auipc	s1,0x9
    8000174a:	10248493          	addi	s1,s1,258 # 8000a848 <proc+0x158>
    8000174e:	0000f917          	auipc	s2,0xf
    80001752:	afa90913          	addi	s2,s2,-1286 # 80010248 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001756:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001758:	00006997          	auipc	s3,0x6
    8000175c:	ae898993          	addi	s3,s3,-1304 # 80007240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80001760:	00006a97          	auipc	s5,0x6
    80001764:	ae8a8a93          	addi	s5,s5,-1304 # 80007248 <etext+0x248>
    printf("\n");
    80001768:	00006a17          	auipc	s4,0x6
    8000176c:	8b0a0a13          	addi	s4,s4,-1872 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001770:	00006b97          	auipc	s7,0x6
    80001774:	020b8b93          	addi	s7,s7,32 # 80007790 <states.0>
    80001778:	a829                	j	80001792 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000177a:	ed86a583          	lw	a1,-296(a3)
    8000177e:	8556                	mv	a0,s5
    80001780:	211030ef          	jal	80005190 <printf>
    printf("\n");
    80001784:	8552                	mv	a0,s4
    80001786:	20b030ef          	jal	80005190 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000178a:	16848493          	addi	s1,s1,360
    8000178e:	03248263          	beq	s1,s2,800017b2 <procdump+0x8e>
    if(p->state == UNUSED)
    80001792:	86a6                	mv	a3,s1
    80001794:	ec04a783          	lw	a5,-320(s1)
    80001798:	dbed                	beqz	a5,8000178a <procdump+0x66>
      state = "???";
    8000179a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000179c:	fcfb6fe3          	bltu	s6,a5,8000177a <procdump+0x56>
    800017a0:	02079713          	slli	a4,a5,0x20
    800017a4:	01d75793          	srli	a5,a4,0x1d
    800017a8:	97de                	add	a5,a5,s7
    800017aa:	6390                	ld	a2,0(a5)
    800017ac:	f679                	bnez	a2,8000177a <procdump+0x56>
      state = "???";
    800017ae:	864e                	mv	a2,s3
    800017b0:	b7e9                	j	8000177a <procdump+0x56>
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret

00000000800017c8 <swtch>:
    800017c8:	00153023          	sd	ra,0(a0)
    800017cc:	00253423          	sd	sp,8(a0)
    800017d0:	e900                	sd	s0,16(a0)
    800017d2:	ed04                	sd	s1,24(a0)
    800017d4:	03253023          	sd	s2,32(a0)
    800017d8:	03353423          	sd	s3,40(a0)
    800017dc:	03453823          	sd	s4,48(a0)
    800017e0:	03553c23          	sd	s5,56(a0)
    800017e4:	05653023          	sd	s6,64(a0)
    800017e8:	05753423          	sd	s7,72(a0)
    800017ec:	05853823          	sd	s8,80(a0)
    800017f0:	05953c23          	sd	s9,88(a0)
    800017f4:	07a53023          	sd	s10,96(a0)
    800017f8:	07b53423          	sd	s11,104(a0)
    800017fc:	0005b083          	ld	ra,0(a1)
    80001800:	0085b103          	ld	sp,8(a1)
    80001804:	6980                	ld	s0,16(a1)
    80001806:	6d84                	ld	s1,24(a1)
    80001808:	0205b903          	ld	s2,32(a1)
    8000180c:	0285b983          	ld	s3,40(a1)
    80001810:	0305ba03          	ld	s4,48(a1)
    80001814:	0385ba83          	ld	s5,56(a1)
    80001818:	0405bb03          	ld	s6,64(a1)
    8000181c:	0485bb83          	ld	s7,72(a1)
    80001820:	0505bc03          	ld	s8,80(a1)
    80001824:	0585bc83          	ld	s9,88(a1)
    80001828:	0605bd03          	ld	s10,96(a1)
    8000182c:	0685bd83          	ld	s11,104(a1)
    80001830:	8082                	ret

0000000080001832 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001832:	1141                	addi	sp,sp,-16
    80001834:	e406                	sd	ra,8(sp)
    80001836:	e022                	sd	s0,0(sp)
    80001838:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000183a:	00006597          	auipc	a1,0x6
    8000183e:	a4e58593          	addi	a1,a1,-1458 # 80007288 <etext+0x288>
    80001842:	0000f517          	auipc	a0,0xf
    80001846:	8ae50513          	addi	a0,a0,-1874 # 800100f0 <tickslock>
    8000184a:	6c7030ef          	jal	80005710 <initlock>
}
    8000184e:	60a2                	ld	ra,8(sp)
    80001850:	6402                	ld	s0,0(sp)
    80001852:	0141                	addi	sp,sp,16
    80001854:	8082                	ret

0000000080001856 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001856:	1141                	addi	sp,sp,-16
    80001858:	e422                	sd	s0,8(sp)
    8000185a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000185c:	00003797          	auipc	a5,0x3
    80001860:	e7478793          	addi	a5,a5,-396 # 800046d0 <kernelvec>
    80001864:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001868:	6422                	ld	s0,8(sp)
    8000186a:	0141                	addi	sp,sp,16
    8000186c:	8082                	ret

000000008000186e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000186e:	1141                	addi	sp,sp,-16
    80001870:	e406                	sd	ra,8(sp)
    80001872:	e022                	sd	s0,0(sp)
    80001874:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001876:	cf0ff0ef          	jal	80000d66 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000187a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000187e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001880:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001884:	00004697          	auipc	a3,0x4
    80001888:	77c68693          	addi	a3,a3,1916 # 80006000 <_trampoline>
    8000188c:	00004717          	auipc	a4,0x4
    80001890:	77470713          	addi	a4,a4,1908 # 80006000 <_trampoline>
    80001894:	8f15                	sub	a4,a4,a3
    80001896:	040007b7          	lui	a5,0x4000
    8000189a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000189c:	07b2                	slli	a5,a5,0xc
    8000189e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018a0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800018a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800018a6:	18002673          	csrr	a2,satp
    800018aa:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800018ac:	6d30                	ld	a2,88(a0)
    800018ae:	6138                	ld	a4,64(a0)
    800018b0:	6585                	lui	a1,0x1
    800018b2:	972e                	add	a4,a4,a1
    800018b4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800018b6:	6d38                	ld	a4,88(a0)
    800018b8:	00000617          	auipc	a2,0x0
    800018bc:	11060613          	addi	a2,a2,272 # 800019c8 <usertrap>
    800018c0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800018c2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800018c4:	8612                	mv	a2,tp
    800018c6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800018c8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800018cc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800018d0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800018d4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800018d8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800018da:	6f18                	ld	a4,24(a4)
    800018dc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800018e0:	6928                	ld	a0,80(a0)
    800018e2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800018e4:	00004717          	auipc	a4,0x4
    800018e8:	7b870713          	addi	a4,a4,1976 # 8000609c <userret>
    800018ec:	8f15                	sub	a4,a4,a3
    800018ee:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800018f0:	577d                	li	a4,-1
    800018f2:	177e                	slli	a4,a4,0x3f
    800018f4:	8d59                	or	a0,a0,a4
    800018f6:	9782                	jalr	a5
}
    800018f8:	60a2                	ld	ra,8(sp)
    800018fa:	6402                	ld	s0,0(sp)
    800018fc:	0141                	addi	sp,sp,16
    800018fe:	8082                	ret

0000000080001900 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001900:	1101                	addi	sp,sp,-32
    80001902:	ec06                	sd	ra,24(sp)
    80001904:	e822                	sd	s0,16(sp)
    80001906:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001908:	c32ff0ef          	jal	80000d3a <cpuid>
    8000190c:	cd11                	beqz	a0,80001928 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000190e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001912:	000f4737          	lui	a4,0xf4
    80001916:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000191a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000191c:	14d79073          	csrw	stimecmp,a5
}
    80001920:	60e2                	ld	ra,24(sp)
    80001922:	6442                	ld	s0,16(sp)
    80001924:	6105                	addi	sp,sp,32
    80001926:	8082                	ret
    80001928:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000192a:	0000e497          	auipc	s1,0xe
    8000192e:	7c648493          	addi	s1,s1,1990 # 800100f0 <tickslock>
    80001932:	8526                	mv	a0,s1
    80001934:	65d030ef          	jal	80005790 <acquire>
    ticks++;
    80001938:	00009517          	auipc	a0,0x9
    8000193c:	95050513          	addi	a0,a0,-1712 # 8000a288 <ticks>
    80001940:	411c                	lw	a5,0(a0)
    80001942:	2785                	addiw	a5,a5,1
    80001944:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001946:	a3bff0ef          	jal	80001380 <wakeup>
    release(&tickslock);
    8000194a:	8526                	mv	a0,s1
    8000194c:	6dd030ef          	jal	80005828 <release>
    80001950:	64a2                	ld	s1,8(sp)
    80001952:	bf75                	j	8000190e <clockintr+0xe>

0000000080001954 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001954:	1101                	addi	sp,sp,-32
    80001956:	ec06                	sd	ra,24(sp)
    80001958:	e822                	sd	s0,16(sp)
    8000195a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000195c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001960:	57fd                	li	a5,-1
    80001962:	17fe                	slli	a5,a5,0x3f
    80001964:	07a5                	addi	a5,a5,9
    80001966:	00f70c63          	beq	a4,a5,8000197e <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000196a:	57fd                	li	a5,-1
    8000196c:	17fe                	slli	a5,a5,0x3f
    8000196e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001970:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001972:	04f70763          	beq	a4,a5,800019c0 <devintr+0x6c>
  }
}
    80001976:	60e2                	ld	ra,24(sp)
    80001978:	6442                	ld	s0,16(sp)
    8000197a:	6105                	addi	sp,sp,32
    8000197c:	8082                	ret
    8000197e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001980:	5fd020ef          	jal	8000477c <plic_claim>
    80001984:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001986:	47a9                	li	a5,10
    80001988:	00f50963          	beq	a0,a5,8000199a <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000198c:	4785                	li	a5,1
    8000198e:	00f50963          	beq	a0,a5,800019a0 <devintr+0x4c>
    return 1;
    80001992:	4505                	li	a0,1
    } else if(irq){
    80001994:	e889                	bnez	s1,800019a6 <devintr+0x52>
    80001996:	64a2                	ld	s1,8(sp)
    80001998:	bff9                	j	80001976 <devintr+0x22>
      uartintr();
    8000199a:	53b030ef          	jal	800056d4 <uartintr>
    if(irq)
    8000199e:	a819                	j	800019b4 <devintr+0x60>
      virtio_disk_intr();
    800019a0:	2a2030ef          	jal	80004c42 <virtio_disk_intr>
    if(irq)
    800019a4:	a801                	j	800019b4 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800019a6:	85a6                	mv	a1,s1
    800019a8:	00006517          	auipc	a0,0x6
    800019ac:	8e850513          	addi	a0,a0,-1816 # 80007290 <etext+0x290>
    800019b0:	7e0030ef          	jal	80005190 <printf>
      plic_complete(irq);
    800019b4:	8526                	mv	a0,s1
    800019b6:	5e7020ef          	jal	8000479c <plic_complete>
    return 1;
    800019ba:	4505                	li	a0,1
    800019bc:	64a2                	ld	s1,8(sp)
    800019be:	bf65                	j	80001976 <devintr+0x22>
    clockintr();
    800019c0:	f41ff0ef          	jal	80001900 <clockintr>
    return 2;
    800019c4:	4509                	li	a0,2
    800019c6:	bf45                	j	80001976 <devintr+0x22>

00000000800019c8 <usertrap>:
{
    800019c8:	1101                	addi	sp,sp,-32
    800019ca:	ec06                	sd	ra,24(sp)
    800019cc:	e822                	sd	s0,16(sp)
    800019ce:	e426                	sd	s1,8(sp)
    800019d0:	e04a                	sd	s2,0(sp)
    800019d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019d4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800019d8:	1007f793          	andi	a5,a5,256
    800019dc:	ef85                	bnez	a5,80001a14 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019de:	00003797          	auipc	a5,0x3
    800019e2:	cf278793          	addi	a5,a5,-782 # 800046d0 <kernelvec>
    800019e6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800019ea:	b7cff0ef          	jal	80000d66 <myproc>
    800019ee:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800019f0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800019f2:	14102773          	csrr	a4,sepc
    800019f6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019f8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800019fc:	47a1                	li	a5,8
    800019fe:	02f70163          	beq	a4,a5,80001a20 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001a02:	f53ff0ef          	jal	80001954 <devintr>
    80001a06:	892a                	mv	s2,a0
    80001a08:	c135                	beqz	a0,80001a6c <usertrap+0xa4>
  if(killed(p))
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	b61ff0ef          	jal	8000156c <killed>
    80001a10:	cd1d                	beqz	a0,80001a4e <usertrap+0x86>
    80001a12:	a81d                	j	80001a48 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001a14:	00006517          	auipc	a0,0x6
    80001a18:	89c50513          	addi	a0,a0,-1892 # 800072b0 <etext+0x2b0>
    80001a1c:	247030ef          	jal	80005462 <panic>
    if(killed(p))
    80001a20:	b4dff0ef          	jal	8000156c <killed>
    80001a24:	e121                	bnez	a0,80001a64 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001a26:	6cb8                	ld	a4,88(s1)
    80001a28:	6f1c                	ld	a5,24(a4)
    80001a2a:	0791                	addi	a5,a5,4
    80001a2c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a32:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a36:	10079073          	csrw	sstatus,a5
    syscall();
    80001a3a:	248000ef          	jal	80001c82 <syscall>
  if(killed(p))
    80001a3e:	8526                	mv	a0,s1
    80001a40:	b2dff0ef          	jal	8000156c <killed>
    80001a44:	c901                	beqz	a0,80001a54 <usertrap+0x8c>
    80001a46:	4901                	li	s2,0
    exit(-1);
    80001a48:	557d                	li	a0,-1
    80001a4a:	9f7ff0ef          	jal	80001440 <exit>
  if(which_dev == 2)
    80001a4e:	4789                	li	a5,2
    80001a50:	04f90563          	beq	s2,a5,80001a9a <usertrap+0xd2>
  usertrapret();
    80001a54:	e1bff0ef          	jal	8000186e <usertrapret>
}
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6902                	ld	s2,0(sp)
    80001a60:	6105                	addi	sp,sp,32
    80001a62:	8082                	ret
      exit(-1);
    80001a64:	557d                	li	a0,-1
    80001a66:	9dbff0ef          	jal	80001440 <exit>
    80001a6a:	bf75                	j	80001a26 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a6c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001a70:	5890                	lw	a2,48(s1)
    80001a72:	00006517          	auipc	a0,0x6
    80001a76:	85e50513          	addi	a0,a0,-1954 # 800072d0 <etext+0x2d0>
    80001a7a:	716030ef          	jal	80005190 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a7e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001a82:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001a86:	00006517          	auipc	a0,0x6
    80001a8a:	87a50513          	addi	a0,a0,-1926 # 80007300 <etext+0x300>
    80001a8e:	702030ef          	jal	80005190 <printf>
    setkilled(p);
    80001a92:	8526                	mv	a0,s1
    80001a94:	ab5ff0ef          	jal	80001548 <setkilled>
    80001a98:	b75d                	j	80001a3e <usertrap+0x76>
    yield();
    80001a9a:	86fff0ef          	jal	80001308 <yield>
    80001a9e:	bf5d                	j	80001a54 <usertrap+0x8c>

0000000080001aa0 <kerneltrap>:
{
    80001aa0:	7179                	addi	sp,sp,-48
    80001aa2:	f406                	sd	ra,40(sp)
    80001aa4:	f022                	sd	s0,32(sp)
    80001aa6:	ec26                	sd	s1,24(sp)
    80001aa8:	e84a                	sd	s2,16(sp)
    80001aaa:	e44e                	sd	s3,8(sp)
    80001aac:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001aae:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ab2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ab6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001aba:	1004f793          	andi	a5,s1,256
    80001abe:	c795                	beqz	a5,80001aea <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ac0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ac4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ac6:	eb85                	bnez	a5,80001af6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001ac8:	e8dff0ef          	jal	80001954 <devintr>
    80001acc:	c91d                	beqz	a0,80001b02 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001ace:	4789                	li	a5,2
    80001ad0:	04f50a63          	beq	a0,a5,80001b24 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ad4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ad8:	10049073          	csrw	sstatus,s1
}
    80001adc:	70a2                	ld	ra,40(sp)
    80001ade:	7402                	ld	s0,32(sp)
    80001ae0:	64e2                	ld	s1,24(sp)
    80001ae2:	6942                	ld	s2,16(sp)
    80001ae4:	69a2                	ld	s3,8(sp)
    80001ae6:	6145                	addi	sp,sp,48
    80001ae8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001aea:	00006517          	auipc	a0,0x6
    80001aee:	83e50513          	addi	a0,a0,-1986 # 80007328 <etext+0x328>
    80001af2:	171030ef          	jal	80005462 <panic>
    panic("kerneltrap: interrupts enabled");
    80001af6:	00006517          	auipc	a0,0x6
    80001afa:	85a50513          	addi	a0,a0,-1958 # 80007350 <etext+0x350>
    80001afe:	165030ef          	jal	80005462 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b02:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b06:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001b0a:	85ce                	mv	a1,s3
    80001b0c:	00006517          	auipc	a0,0x6
    80001b10:	86450513          	addi	a0,a0,-1948 # 80007370 <etext+0x370>
    80001b14:	67c030ef          	jal	80005190 <printf>
    panic("kerneltrap");
    80001b18:	00006517          	auipc	a0,0x6
    80001b1c:	88050513          	addi	a0,a0,-1920 # 80007398 <etext+0x398>
    80001b20:	143030ef          	jal	80005462 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001b24:	a42ff0ef          	jal	80000d66 <myproc>
    80001b28:	d555                	beqz	a0,80001ad4 <kerneltrap+0x34>
    yield();
    80001b2a:	fdeff0ef          	jal	80001308 <yield>
    80001b2e:	b75d                	j	80001ad4 <kerneltrap+0x34>

0000000080001b30 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	1000                	addi	s0,sp,32
    80001b3a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b3c:	a2aff0ef          	jal	80000d66 <myproc>
  switch (n) {
    80001b40:	4795                	li	a5,5
    80001b42:	0497e163          	bltu	a5,s1,80001b84 <argraw+0x54>
    80001b46:	048a                	slli	s1,s1,0x2
    80001b48:	00006717          	auipc	a4,0x6
    80001b4c:	c7870713          	addi	a4,a4,-904 # 800077c0 <states.0+0x30>
    80001b50:	94ba                	add	s1,s1,a4
    80001b52:	409c                	lw	a5,0(s1)
    80001b54:	97ba                	add	a5,a5,a4
    80001b56:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001b58:	6d3c                	ld	a5,88(a0)
    80001b5a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001b5c:	60e2                	ld	ra,24(sp)
    80001b5e:	6442                	ld	s0,16(sp)
    80001b60:	64a2                	ld	s1,8(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret
    return p->trapframe->a1;
    80001b66:	6d3c                	ld	a5,88(a0)
    80001b68:	7fa8                	ld	a0,120(a5)
    80001b6a:	bfcd                	j	80001b5c <argraw+0x2c>
    return p->trapframe->a2;
    80001b6c:	6d3c                	ld	a5,88(a0)
    80001b6e:	63c8                	ld	a0,128(a5)
    80001b70:	b7f5                	j	80001b5c <argraw+0x2c>
    return p->trapframe->a3;
    80001b72:	6d3c                	ld	a5,88(a0)
    80001b74:	67c8                	ld	a0,136(a5)
    80001b76:	b7dd                	j	80001b5c <argraw+0x2c>
    return p->trapframe->a4;
    80001b78:	6d3c                	ld	a5,88(a0)
    80001b7a:	6bc8                	ld	a0,144(a5)
    80001b7c:	b7c5                	j	80001b5c <argraw+0x2c>
    return p->trapframe->a5;
    80001b7e:	6d3c                	ld	a5,88(a0)
    80001b80:	6fc8                	ld	a0,152(a5)
    80001b82:	bfe9                	j	80001b5c <argraw+0x2c>
  panic("argraw");
    80001b84:	00006517          	auipc	a0,0x6
    80001b88:	82450513          	addi	a0,a0,-2012 # 800073a8 <etext+0x3a8>
    80001b8c:	0d7030ef          	jal	80005462 <panic>

0000000080001b90 <fetchaddr>:
{
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	addi	s0,sp,32
    80001b9c:	84aa                	mv	s1,a0
    80001b9e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ba0:	9c6ff0ef          	jal	80000d66 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001ba4:	653c                	ld	a5,72(a0)
    80001ba6:	02f4f663          	bgeu	s1,a5,80001bd2 <fetchaddr+0x42>
    80001baa:	00848713          	addi	a4,s1,8
    80001bae:	02e7e463          	bltu	a5,a4,80001bd6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001bb2:	46a1                	li	a3,8
    80001bb4:	8626                	mv	a2,s1
    80001bb6:	85ca                	mv	a1,s2
    80001bb8:	6928                	ld	a0,80(a0)
    80001bba:	ef5fe0ef          	jal	80000aae <copyin>
    80001bbe:	00a03533          	snez	a0,a0
    80001bc2:	40a00533          	neg	a0,a0
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6902                	ld	s2,0(sp)
    80001bce:	6105                	addi	sp,sp,32
    80001bd0:	8082                	ret
    return -1;
    80001bd2:	557d                	li	a0,-1
    80001bd4:	bfcd                	j	80001bc6 <fetchaddr+0x36>
    80001bd6:	557d                	li	a0,-1
    80001bd8:	b7fd                	j	80001bc6 <fetchaddr+0x36>

0000000080001bda <fetchstr>:
{
    80001bda:	7179                	addi	sp,sp,-48
    80001bdc:	f406                	sd	ra,40(sp)
    80001bde:	f022                	sd	s0,32(sp)
    80001be0:	ec26                	sd	s1,24(sp)
    80001be2:	e84a                	sd	s2,16(sp)
    80001be4:	e44e                	sd	s3,8(sp)
    80001be6:	1800                	addi	s0,sp,48
    80001be8:	892a                	mv	s2,a0
    80001bea:	84ae                	mv	s1,a1
    80001bec:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001bee:	978ff0ef          	jal	80000d66 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001bf2:	86ce                	mv	a3,s3
    80001bf4:	864a                	mv	a2,s2
    80001bf6:	85a6                	mv	a1,s1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f3bfe0ef          	jal	80000b34 <copyinstr>
    80001bfe:	00054c63          	bltz	a0,80001c16 <fetchstr+0x3c>
  return strlen(buf);
    80001c02:	8526                	mv	a0,s1
    80001c04:	ebafe0ef          	jal	800002be <strlen>
}
    80001c08:	70a2                	ld	ra,40(sp)
    80001c0a:	7402                	ld	s0,32(sp)
    80001c0c:	64e2                	ld	s1,24(sp)
    80001c0e:	6942                	ld	s2,16(sp)
    80001c10:	69a2                	ld	s3,8(sp)
    80001c12:	6145                	addi	sp,sp,48
    80001c14:	8082                	ret
    return -1;
    80001c16:	557d                	li	a0,-1
    80001c18:	bfc5                	j	80001c08 <fetchstr+0x2e>

0000000080001c1a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001c1a:	1101                	addi	sp,sp,-32
    80001c1c:	ec06                	sd	ra,24(sp)
    80001c1e:	e822                	sd	s0,16(sp)
    80001c20:	e426                	sd	s1,8(sp)
    80001c22:	1000                	addi	s0,sp,32
    80001c24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c26:	f0bff0ef          	jal	80001b30 <argraw>
    80001c2a:	c088                	sw	a0,0(s1)
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret

0000000080001c36 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001c36:	1101                	addi	sp,sp,-32
    80001c38:	ec06                	sd	ra,24(sp)
    80001c3a:	e822                	sd	s0,16(sp)
    80001c3c:	e426                	sd	s1,8(sp)
    80001c3e:	1000                	addi	s0,sp,32
    80001c40:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c42:	eefff0ef          	jal	80001b30 <argraw>
    80001c46:	e088                	sd	a0,0(s1)
}
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6105                	addi	sp,sp,32
    80001c50:	8082                	ret

0000000080001c52 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001c52:	7179                	addi	sp,sp,-48
    80001c54:	f406                	sd	ra,40(sp)
    80001c56:	f022                	sd	s0,32(sp)
    80001c58:	ec26                	sd	s1,24(sp)
    80001c5a:	e84a                	sd	s2,16(sp)
    80001c5c:	1800                	addi	s0,sp,48
    80001c5e:	84ae                	mv	s1,a1
    80001c60:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001c62:	fd840593          	addi	a1,s0,-40
    80001c66:	fd1ff0ef          	jal	80001c36 <argaddr>
  return fetchstr(addr, buf, max);
    80001c6a:	864a                	mv	a2,s2
    80001c6c:	85a6                	mv	a1,s1
    80001c6e:	fd843503          	ld	a0,-40(s0)
    80001c72:	f69ff0ef          	jal	80001bda <fetchstr>
}
    80001c76:	70a2                	ld	ra,40(sp)
    80001c78:	7402                	ld	s0,32(sp)
    80001c7a:	64e2                	ld	s1,24(sp)
    80001c7c:	6942                	ld	s2,16(sp)
    80001c7e:	6145                	addi	sp,sp,48
    80001c80:	8082                	ret

0000000080001c82 <syscall>:
[SYS_xv6]     sys_xv6,
};

void
syscall(void)
{
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	e04a                	sd	s2,0(sp)
    80001c8c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001c8e:	8d8ff0ef          	jal	80000d66 <myproc>
    80001c92:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001c94:	05853903          	ld	s2,88(a0)
    80001c98:	0a893783          	ld	a5,168(s2)
    80001c9c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001ca0:	37fd                	addiw	a5,a5,-1
    80001ca2:	4759                	li	a4,22
    80001ca4:	00f76f63          	bltu	a4,a5,80001cc2 <syscall+0x40>
    80001ca8:	00369713          	slli	a4,a3,0x3
    80001cac:	00006797          	auipc	a5,0x6
    80001cb0:	b2c78793          	addi	a5,a5,-1236 # 800077d8 <syscalls>
    80001cb4:	97ba                	add	a5,a5,a4
    80001cb6:	639c                	ld	a5,0(a5)
    80001cb8:	c789                	beqz	a5,80001cc2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001cba:	9782                	jalr	a5
    80001cbc:	06a93823          	sd	a0,112(s2)
    80001cc0:	a829                	j	80001cda <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001cc2:	15848613          	addi	a2,s1,344
    80001cc6:	588c                	lw	a1,48(s1)
    80001cc8:	00005517          	auipc	a0,0x5
    80001ccc:	6e850513          	addi	a0,a0,1768 # 800073b0 <etext+0x3b0>
    80001cd0:	4c0030ef          	jal	80005190 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001cd4:	6cbc                	ld	a5,88(s1)
    80001cd6:	577d                	li	a4,-1
    80001cd8:	fbb8                	sd	a4,112(a5)
  }
}
    80001cda:	60e2                	ld	ra,24(sp)
    80001cdc:	6442                	ld	s0,16(sp)
    80001cde:	64a2                	ld	s1,8(sp)
    80001ce0:	6902                	ld	s2,0(sp)
    80001ce2:	6105                	addi	sp,sp,32
    80001ce4:	8082                	ret

0000000080001ce6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001cee:	fec40593          	addi	a1,s0,-20
    80001cf2:	4501                	li	a0,0
    80001cf4:	f27ff0ef          	jal	80001c1a <argint>
  exit(n);
    80001cf8:	fec42503          	lw	a0,-20(s0)
    80001cfc:	f44ff0ef          	jal	80001440 <exit>
  return 0;  // not reached
}
    80001d00:	4501                	li	a0,0
    80001d02:	60e2                	ld	ra,24(sp)
    80001d04:	6442                	ld	s0,16(sp)
    80001d06:	6105                	addi	sp,sp,32
    80001d08:	8082                	ret

0000000080001d0a <sys_getpid>:

uint64
sys_getpid(void)
{
    80001d0a:	1141                	addi	sp,sp,-16
    80001d0c:	e406                	sd	ra,8(sp)
    80001d0e:	e022                	sd	s0,0(sp)
    80001d10:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001d12:	854ff0ef          	jal	80000d66 <myproc>
}
    80001d16:	5908                	lw	a0,48(a0)
    80001d18:	60a2                	ld	ra,8(sp)
    80001d1a:	6402                	ld	s0,0(sp)
    80001d1c:	0141                	addi	sp,sp,16
    80001d1e:	8082                	ret

0000000080001d20 <sys_fork>:

uint64
sys_fork(void)
{
    80001d20:	1141                	addi	sp,sp,-16
    80001d22:	e406                	sd	ra,8(sp)
    80001d24:	e022                	sd	s0,0(sp)
    80001d26:	0800                	addi	s0,sp,16
  return fork();
    80001d28:	b64ff0ef          	jal	8000108c <fork>
}
    80001d2c:	60a2                	ld	ra,8(sp)
    80001d2e:	6402                	ld	s0,0(sp)
    80001d30:	0141                	addi	sp,sp,16
    80001d32:	8082                	ret

0000000080001d34 <sys_wait>:

uint64
sys_wait(void)
{
    80001d34:	1101                	addi	sp,sp,-32
    80001d36:	ec06                	sd	ra,24(sp)
    80001d38:	e822                	sd	s0,16(sp)
    80001d3a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001d3c:	fe840593          	addi	a1,s0,-24
    80001d40:	4501                	li	a0,0
    80001d42:	ef5ff0ef          	jal	80001c36 <argaddr>
  return wait(p);
    80001d46:	fe843503          	ld	a0,-24(s0)
    80001d4a:	84dff0ef          	jal	80001596 <wait>
}
    80001d4e:	60e2                	ld	ra,24(sp)
    80001d50:	6442                	ld	s0,16(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret

0000000080001d56 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001d56:	7179                	addi	sp,sp,-48
    80001d58:	f406                	sd	ra,40(sp)
    80001d5a:	f022                	sd	s0,32(sp)
    80001d5c:	ec26                	sd	s1,24(sp)
    80001d5e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001d60:	fdc40593          	addi	a1,s0,-36
    80001d64:	4501                	li	a0,0
    80001d66:	eb5ff0ef          	jal	80001c1a <argint>
  addr = myproc()->sz;
    80001d6a:	ffdfe0ef          	jal	80000d66 <myproc>
    80001d6e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001d70:	fdc42503          	lw	a0,-36(s0)
    80001d74:	ac8ff0ef          	jal	8000103c <growproc>
    80001d78:	00054863          	bltz	a0,80001d88 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	70a2                	ld	ra,40(sp)
    80001d80:	7402                	ld	s0,32(sp)
    80001d82:	64e2                	ld	s1,24(sp)
    80001d84:	6145                	addi	sp,sp,48
    80001d86:	8082                	ret
    return -1;
    80001d88:	54fd                	li	s1,-1
    80001d8a:	bfcd                	j	80001d7c <sys_sbrk+0x26>

0000000080001d8c <sys_sleep>:

uint64
sys_sleep(void)
{
    80001d8c:	7139                	addi	sp,sp,-64
    80001d8e:	fc06                	sd	ra,56(sp)
    80001d90:	f822                	sd	s0,48(sp)
    80001d92:	f04a                	sd	s2,32(sp)
    80001d94:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001d96:	fcc40593          	addi	a1,s0,-52
    80001d9a:	4501                	li	a0,0
    80001d9c:	e7fff0ef          	jal	80001c1a <argint>
  if(n < 0)
    80001da0:	fcc42783          	lw	a5,-52(s0)
    80001da4:	0607c763          	bltz	a5,80001e12 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001da8:	0000e517          	auipc	a0,0xe
    80001dac:	34850513          	addi	a0,a0,840 # 800100f0 <tickslock>
    80001db0:	1e1030ef          	jal	80005790 <acquire>
  ticks0 = ticks;
    80001db4:	00008917          	auipc	s2,0x8
    80001db8:	4d492903          	lw	s2,1236(s2) # 8000a288 <ticks>
  while(ticks - ticks0 < n){
    80001dbc:	fcc42783          	lw	a5,-52(s0)
    80001dc0:	cf8d                	beqz	a5,80001dfa <sys_sleep+0x6e>
    80001dc2:	f426                	sd	s1,40(sp)
    80001dc4:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001dc6:	0000e997          	auipc	s3,0xe
    80001dca:	32a98993          	addi	s3,s3,810 # 800100f0 <tickslock>
    80001dce:	00008497          	auipc	s1,0x8
    80001dd2:	4ba48493          	addi	s1,s1,1210 # 8000a288 <ticks>
    if(killed(myproc())){
    80001dd6:	f91fe0ef          	jal	80000d66 <myproc>
    80001dda:	f92ff0ef          	jal	8000156c <killed>
    80001dde:	ed0d                	bnez	a0,80001e18 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001de0:	85ce                	mv	a1,s3
    80001de2:	8526                	mv	a0,s1
    80001de4:	d50ff0ef          	jal	80001334 <sleep>
  while(ticks - ticks0 < n){
    80001de8:	409c                	lw	a5,0(s1)
    80001dea:	412787bb          	subw	a5,a5,s2
    80001dee:	fcc42703          	lw	a4,-52(s0)
    80001df2:	fee7e2e3          	bltu	a5,a4,80001dd6 <sys_sleep+0x4a>
    80001df6:	74a2                	ld	s1,40(sp)
    80001df8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001dfa:	0000e517          	auipc	a0,0xe
    80001dfe:	2f650513          	addi	a0,a0,758 # 800100f0 <tickslock>
    80001e02:	227030ef          	jal	80005828 <release>
  return 0;
    80001e06:	4501                	li	a0,0
}
    80001e08:	70e2                	ld	ra,56(sp)
    80001e0a:	7442                	ld	s0,48(sp)
    80001e0c:	7902                	ld	s2,32(sp)
    80001e0e:	6121                	addi	sp,sp,64
    80001e10:	8082                	ret
    n = 0;
    80001e12:	fc042623          	sw	zero,-52(s0)
    80001e16:	bf49                	j	80001da8 <sys_sleep+0x1c>
      release(&tickslock);
    80001e18:	0000e517          	auipc	a0,0xe
    80001e1c:	2d850513          	addi	a0,a0,728 # 800100f0 <tickslock>
    80001e20:	209030ef          	jal	80005828 <release>
      return -1;
    80001e24:	557d                	li	a0,-1
    80001e26:	74a2                	ld	s1,40(sp)
    80001e28:	69e2                	ld	s3,24(sp)
    80001e2a:	bff9                	j	80001e08 <sys_sleep+0x7c>

0000000080001e2c <sys_kill>:

uint64
sys_kill(void)
{
    80001e2c:	1101                	addi	sp,sp,-32
    80001e2e:	ec06                	sd	ra,24(sp)
    80001e30:	e822                	sd	s0,16(sp)
    80001e32:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001e34:	fec40593          	addi	a1,s0,-20
    80001e38:	4501                	li	a0,0
    80001e3a:	de1ff0ef          	jal	80001c1a <argint>
  return kill(pid);
    80001e3e:	fec42503          	lw	a0,-20(s0)
    80001e42:	ea0ff0ef          	jal	800014e2 <kill>
}
    80001e46:	60e2                	ld	ra,24(sp)
    80001e48:	6442                	ld	s0,16(sp)
    80001e4a:	6105                	addi	sp,sp,32
    80001e4c:	8082                	ret

0000000080001e4e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001e4e:	1101                	addi	sp,sp,-32
    80001e50:	ec06                	sd	ra,24(sp)
    80001e52:	e822                	sd	s0,16(sp)
    80001e54:	e426                	sd	s1,8(sp)
    80001e56:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001e58:	0000e517          	auipc	a0,0xe
    80001e5c:	29850513          	addi	a0,a0,664 # 800100f0 <tickslock>
    80001e60:	131030ef          	jal	80005790 <acquire>
  xticks = ticks;
    80001e64:	00008497          	auipc	s1,0x8
    80001e68:	4244a483          	lw	s1,1060(s1) # 8000a288 <ticks>
  release(&tickslock);
    80001e6c:	0000e517          	auipc	a0,0xe
    80001e70:	28450513          	addi	a0,a0,644 # 800100f0 <tickslock>
    80001e74:	1b5030ef          	jal	80005828 <release>
  return xticks;
}
    80001e78:	02049513          	slli	a0,s1,0x20
    80001e7c:	9101                	srli	a0,a0,0x20
    80001e7e:	60e2                	ld	ra,24(sp)
    80001e80:	6442                	ld	s0,16(sp)
    80001e82:	64a2                	ld	s1,8(sp)
    80001e84:	6105                	addi	sp,sp,32
    80001e86:	8082                	ret

0000000080001e88 <sys_hello>:

uint64 sys_hello(void) {
    80001e88:	1141                	addi	sp,sp,-16
    80001e8a:	e406                	sd	ra,8(sp)
    80001e8c:	e022                	sd	s0,0(sp)
    80001e8e:	0800                	addi	s0,sp,16
  printf("Hello, world!\n");
    80001e90:	00005517          	auipc	a0,0x5
    80001e94:	54050513          	addi	a0,a0,1344 # 800073d0 <etext+0x3d0>
    80001e98:	2f8030ef          	jal	80005190 <printf>
  return 0;
}
    80001e9c:	4501                	li	a0,0
    80001e9e:	60a2                	ld	ra,8(sp)
    80001ea0:	6402                	ld	s0,0(sp)
    80001ea2:	0141                	addi	sp,sp,16
    80001ea4:	8082                	ret

0000000080001ea6 <sys_xv6>:

uint64 sys_xv6(void) {
    80001ea6:	7179                	addi	sp,sp,-48
    80001ea8:	f406                	sd	ra,40(sp)
    80001eaa:	f022                	sd	s0,32(sp)
    80001eac:	1800                	addi	s0,sp,48
  int n;

  argint(0, &n);
    80001eae:	fdc40593          	addi	a1,s0,-36
    80001eb2:	4501                	li	a0,0
    80001eb4:	d67ff0ef          	jal	80001c1a <argint>

  for (int i = 0; i < n; i++){
    80001eb8:	fdc42783          	lw	a5,-36(s0)
    80001ebc:	02f05363          	blez	a5,80001ee2 <sys_xv6+0x3c>
    80001ec0:	ec26                	sd	s1,24(sp)
    80001ec2:	e84a                	sd	s2,16(sp)
    80001ec4:	4481                	li	s1,0
    printf("Hello_xv6\n");
    80001ec6:	00005917          	auipc	s2,0x5
    80001eca:	51a90913          	addi	s2,s2,1306 # 800073e0 <etext+0x3e0>
    80001ece:	854a                	mv	a0,s2
    80001ed0:	2c0030ef          	jal	80005190 <printf>
  for (int i = 0; i < n; i++){
    80001ed4:	2485                	addiw	s1,s1,1
    80001ed6:	fdc42783          	lw	a5,-36(s0)
    80001eda:	fef4cae3          	blt	s1,a5,80001ece <sys_xv6+0x28>
    80001ede:	64e2                	ld	s1,24(sp)
    80001ee0:	6942                	ld	s2,16(sp)
  }
  return 0;
    80001ee2:	4501                	li	a0,0
    80001ee4:	70a2                	ld	ra,40(sp)
    80001ee6:	7402                	ld	s0,32(sp)
    80001ee8:	6145                	addi	sp,sp,48
    80001eea:	8082                	ret

0000000080001eec <binit>:
} bcache;

//initialize cache 
void
binit(void)
{
    80001eec:	7179                	addi	sp,sp,-48
    80001eee:	f406                	sd	ra,40(sp)
    80001ef0:	f022                	sd	s0,32(sp)
    80001ef2:	ec26                	sd	s1,24(sp)
    80001ef4:	e84a                	sd	s2,16(sp)
    80001ef6:	e44e                	sd	s3,8(sp)
    80001ef8:	e052                	sd	s4,0(sp)
    80001efa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache"); //initialize lock named "bcache"
    80001efc:	00005597          	auipc	a1,0x5
    80001f00:	4f458593          	addi	a1,a1,1268 # 800073f0 <etext+0x3f0>
    80001f04:	0000e517          	auipc	a0,0xe
    80001f08:	20450513          	addi	a0,a0,516 # 80010108 <bcache>
    80001f0c:	005030ef          	jal	80005710 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001f10:	00016797          	auipc	a5,0x16
    80001f14:	1f878793          	addi	a5,a5,504 # 80018108 <bcache+0x8000>
    80001f18:	00016717          	auipc	a4,0x16
    80001f1c:	45870713          	addi	a4,a4,1112 # 80018370 <bcache+0x8268>
    80001f20:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001f24:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f28:	0000e497          	auipc	s1,0xe
    80001f2c:	1f848493          	addi	s1,s1,504 # 80010120 <bcache+0x18>
    b->next = bcache.head.next;
    80001f30:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001f32:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001f34:	00005a17          	auipc	s4,0x5
    80001f38:	4c4a0a13          	addi	s4,s4,1220 # 800073f8 <etext+0x3f8>
    b->next = bcache.head.next;
    80001f3c:	2b893783          	ld	a5,696(s2)
    80001f40:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001f42:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001f46:	85d2                	mv	a1,s4
    80001f48:	01048513          	addi	a0,s1,16
    80001f4c:	248010ef          	jal	80003194 <initsleeplock>
    bcache.head.next->prev = b;
    80001f50:	2b893783          	ld	a5,696(s2)
    80001f54:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001f56:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f5a:	45848493          	addi	s1,s1,1112
    80001f5e:	fd349fe3          	bne	s1,s3,80001f3c <binit+0x50>
  }
}
    80001f62:	70a2                	ld	ra,40(sp)
    80001f64:	7402                	ld	s0,32(sp)
    80001f66:	64e2                	ld	s1,24(sp)
    80001f68:	6942                	ld	s2,16(sp)
    80001f6a:	69a2                	ld	s3,8(sp)
    80001f6c:	6a02                	ld	s4,0(sp)
    80001f6e:	6145                	addi	sp,sp,48
    80001f70:	8082                	ret

0000000080001f72 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001f72:	7179                	addi	sp,sp,-48
    80001f74:	f406                	sd	ra,40(sp)
    80001f76:	f022                	sd	s0,32(sp)
    80001f78:	ec26                	sd	s1,24(sp)
    80001f7a:	e84a                	sd	s2,16(sp)
    80001f7c:	e44e                	sd	s3,8(sp)
    80001f7e:	1800                	addi	s0,sp,48
    80001f80:	892a                	mv	s2,a0
    80001f82:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80001f84:	0000e517          	auipc	a0,0xe
    80001f88:	18450513          	addi	a0,a0,388 # 80010108 <bcache>
    80001f8c:	005030ef          	jal	80005790 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80001f90:	00016497          	auipc	s1,0x16
    80001f94:	4304b483          	ld	s1,1072(s1) # 800183c0 <bcache+0x82b8>
    80001f98:	00016797          	auipc	a5,0x16
    80001f9c:	3d878793          	addi	a5,a5,984 # 80018370 <bcache+0x8268>
    80001fa0:	02f48b63          	beq	s1,a5,80001fd6 <bread+0x64>
    80001fa4:	873e                	mv	a4,a5
    80001fa6:	a021                	j	80001fae <bread+0x3c>
    80001fa8:	68a4                	ld	s1,80(s1)
    80001faa:	02e48663          	beq	s1,a4,80001fd6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80001fae:	449c                	lw	a5,8(s1)
    80001fb0:	ff279ce3          	bne	a5,s2,80001fa8 <bread+0x36>
    80001fb4:	44dc                	lw	a5,12(s1)
    80001fb6:	ff3799e3          	bne	a5,s3,80001fa8 <bread+0x36>
      b->refcnt++;
    80001fba:	40bc                	lw	a5,64(s1)
    80001fbc:	2785                	addiw	a5,a5,1
    80001fbe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80001fc0:	0000e517          	auipc	a0,0xe
    80001fc4:	14850513          	addi	a0,a0,328 # 80010108 <bcache>
    80001fc8:	061030ef          	jal	80005828 <release>
      acquiresleep(&b->lock);
    80001fcc:	01048513          	addi	a0,s1,16
    80001fd0:	1fa010ef          	jal	800031ca <acquiresleep>
      return b;
    80001fd4:	a889                	j	80002026 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80001fd6:	00016497          	auipc	s1,0x16
    80001fda:	3e24b483          	ld	s1,994(s1) # 800183b8 <bcache+0x82b0>
    80001fde:	00016797          	auipc	a5,0x16
    80001fe2:	39278793          	addi	a5,a5,914 # 80018370 <bcache+0x8268>
    80001fe6:	00f48863          	beq	s1,a5,80001ff6 <bread+0x84>
    80001fea:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80001fec:	40bc                	lw	a5,64(s1)
    80001fee:	cb91                	beqz	a5,80002002 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80001ff0:	64a4                	ld	s1,72(s1)
    80001ff2:	fee49de3          	bne	s1,a4,80001fec <bread+0x7a>
  panic("bget: no buffers"); //if there are no available buffer call panic.
    80001ff6:	00005517          	auipc	a0,0x5
    80001ffa:	40a50513          	addi	a0,a0,1034 # 80007400 <etext+0x400>
    80001ffe:	464030ef          	jal	80005462 <panic>
      b->dev = dev;
    80002002:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002006:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000200a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000200e:	4785                	li	a5,1
    80002010:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002012:	0000e517          	auipc	a0,0xe
    80002016:	0f650513          	addi	a0,a0,246 # 80010108 <bcache>
    8000201a:	00f030ef          	jal	80005828 <release>
      acquiresleep(&b->lock);
    8000201e:	01048513          	addi	a0,s1,16
    80002022:	1a8010ef          	jal	800031ca <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  //check if the data is valid or not
  if(!b->valid) {
    80002026:	409c                	lw	a5,0(s1)
    80002028:	cb89                	beqz	a5,8000203a <bread+0xc8>
    virtio_disk_rw(b, 0); //write data into buffer
    b->valid = 1;
  }
  return b;
}
    8000202a:	8526                	mv	a0,s1
    8000202c:	70a2                	ld	ra,40(sp)
    8000202e:	7402                	ld	s0,32(sp)
    80002030:	64e2                	ld	s1,24(sp)
    80002032:	6942                	ld	s2,16(sp)
    80002034:	69a2                	ld	s3,8(sp)
    80002036:	6145                	addi	sp,sp,48
    80002038:	8082                	ret
    virtio_disk_rw(b, 0); //write data into buffer
    8000203a:	4581                	li	a1,0
    8000203c:	8526                	mv	a0,s1
    8000203e:	1f3020ef          	jal	80004a30 <virtio_disk_rw>
    b->valid = 1;
    80002042:	4785                	li	a5,1
    80002044:	c09c                	sw	a5,0(s1)
  return b;
    80002046:	b7d5                	j	8000202a <bread+0xb8>

0000000080002048 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Synchronize the contents of buffer b with the block on disk.
void
bwrite(struct buf *b)
{
    80002048:	1101                	addi	sp,sp,-32
    8000204a:	ec06                	sd	ra,24(sp)
    8000204c:	e822                	sd	s0,16(sp)
    8000204e:	e426                	sd	s1,8(sp)
    80002050:	1000                	addi	s0,sp,32
    80002052:	84aa                	mv	s1,a0
  //check if buffer is locked by instance process
  if(!holdingsleep(&b->lock))
    80002054:	0541                	addi	a0,a0,16
    80002056:	1f2010ef          	jal	80003248 <holdingsleep>
    8000205a:	c911                	beqz	a0,8000206e <bwrite+0x26>
    panic("bwrite"); //call panic
  virtio_disk_rw(b, 1); // write data into buffer
    8000205c:	4585                	li	a1,1
    8000205e:	8526                	mv	a0,s1
    80002060:	1d1020ef          	jal	80004a30 <virtio_disk_rw>
}
    80002064:	60e2                	ld	ra,24(sp)
    80002066:	6442                	ld	s0,16(sp)
    80002068:	64a2                	ld	s1,8(sp)
    8000206a:	6105                	addi	sp,sp,32
    8000206c:	8082                	ret
    panic("bwrite"); //call panic
    8000206e:	00005517          	auipc	a0,0x5
    80002072:	3aa50513          	addi	a0,a0,938 # 80007418 <etext+0x418>
    80002076:	3ec030ef          	jal	80005462 <panic>

000000008000207a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000207a:	1101                	addi	sp,sp,-32
    8000207c:	ec06                	sd	ra,24(sp)
    8000207e:	e822                	sd	s0,16(sp)
    80002080:	e426                	sd	s1,8(sp)
    80002082:	e04a                	sd	s2,0(sp)
    80002084:	1000                	addi	s0,sp,32
    80002086:	84aa                	mv	s1,a0
  //check if buffer is lock
  if(!holdingsleep(&b->lock))
    80002088:	01050913          	addi	s2,a0,16
    8000208c:	854a                	mv	a0,s2
    8000208e:	1ba010ef          	jal	80003248 <holdingsleep>
    80002092:	c135                	beqz	a0,800020f6 <brelse+0x7c>
    panic("brelse"); // call panic
  //release lock buffer
  releasesleep(&b->lock);
    80002094:	854a                	mv	a0,s2
    80002096:	17a010ef          	jal	80003210 <releasesleep>

  //reduce refcnt
  acquire(&bcache.lock);
    8000209a:	0000e517          	auipc	a0,0xe
    8000209e:	06e50513          	addi	a0,a0,110 # 80010108 <bcache>
    800020a2:	6ee030ef          	jal	80005790 <acquire>
  b->refcnt--;
    800020a6:	40bc                	lw	a5,64(s1)
    800020a8:	37fd                	addiw	a5,a5,-1
    800020aa:	0007871b          	sext.w	a4,a5
    800020ae:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800020b0:	e71d                	bnez	a4,800020de <brelse+0x64>
    // no one is waiting for it and move it to LRU
    b->next->prev = b->prev;
    800020b2:	68b8                	ld	a4,80(s1)
    800020b4:	64bc                	ld	a5,72(s1)
    800020b6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800020b8:	68b8                	ld	a4,80(s1)
    800020ba:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800020bc:	00016797          	auipc	a5,0x16
    800020c0:	04c78793          	addi	a5,a5,76 # 80018108 <bcache+0x8000>
    800020c4:	2b87b703          	ld	a4,696(a5)
    800020c8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800020ca:	00016717          	auipc	a4,0x16
    800020ce:	2a670713          	addi	a4,a4,678 # 80018370 <bcache+0x8268>
    800020d2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800020d4:	2b87b703          	ld	a4,696(a5)
    800020d8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800020da:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800020de:	0000e517          	auipc	a0,0xe
    800020e2:	02a50513          	addi	a0,a0,42 # 80010108 <bcache>
    800020e6:	742030ef          	jal	80005828 <release>
}
    800020ea:	60e2                	ld	ra,24(sp)
    800020ec:	6442                	ld	s0,16(sp)
    800020ee:	64a2                	ld	s1,8(sp)
    800020f0:	6902                	ld	s2,0(sp)
    800020f2:	6105                	addi	sp,sp,32
    800020f4:	8082                	ret
    panic("brelse"); // call panic
    800020f6:	00005517          	auipc	a0,0x5
    800020fa:	32a50513          	addi	a0,a0,810 # 80007420 <etext+0x420>
    800020fe:	364030ef          	jal	80005462 <panic>

0000000080002102 <bpin>:

//pin buffer to prevent buffer from reusing
void
bpin(struct buf *b) {
    80002102:	1101                	addi	sp,sp,-32
    80002104:	ec06                	sd	ra,24(sp)
    80002106:	e822                	sd	s0,16(sp)
    80002108:	e426                	sd	s1,8(sp)
    8000210a:	1000                	addi	s0,sp,32
    8000210c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000210e:	0000e517          	auipc	a0,0xe
    80002112:	ffa50513          	addi	a0,a0,-6 # 80010108 <bcache>
    80002116:	67a030ef          	jal	80005790 <acquire>
  b->refcnt++;
    8000211a:	40bc                	lw	a5,64(s1)
    8000211c:	2785                	addiw	a5,a5,1
    8000211e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002120:	0000e517          	auipc	a0,0xe
    80002124:	fe850513          	addi	a0,a0,-24 # 80010108 <bcache>
    80002128:	700030ef          	jal	80005828 <release>
}
    8000212c:	60e2                	ld	ra,24(sp)
    8000212e:	6442                	ld	s0,16(sp)
    80002130:	64a2                	ld	s1,8(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <bunpin>:

//unpin buffer
void
bunpin(struct buf *b) {
    80002136:	1101                	addi	sp,sp,-32
    80002138:	ec06                	sd	ra,24(sp)
    8000213a:	e822                	sd	s0,16(sp)
    8000213c:	e426                	sd	s1,8(sp)
    8000213e:	1000                	addi	s0,sp,32
    80002140:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002142:	0000e517          	auipc	a0,0xe
    80002146:	fc650513          	addi	a0,a0,-58 # 80010108 <bcache>
    8000214a:	646030ef          	jal	80005790 <acquire>
  b->refcnt--;
    8000214e:	40bc                	lw	a5,64(s1)
    80002150:	37fd                	addiw	a5,a5,-1
    80002152:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002154:	0000e517          	auipc	a0,0xe
    80002158:	fb450513          	addi	a0,a0,-76 # 80010108 <bcache>
    8000215c:	6cc030ef          	jal	80005828 <release>
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6105                	addi	sp,sp,32
    80002168:	8082                	ret

000000008000216a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000216a:	1101                	addi	sp,sp,-32
    8000216c:	ec06                	sd	ra,24(sp)
    8000216e:	e822                	sd	s0,16(sp)
    80002170:	e426                	sd	s1,8(sp)
    80002172:	e04a                	sd	s2,0(sp)
    80002174:	1000                	addi	s0,sp,32
    80002176:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002178:	00d5d59b          	srliw	a1,a1,0xd
    8000217c:	00016797          	auipc	a5,0x16
    80002180:	6687a783          	lw	a5,1640(a5) # 800187e4 <sb+0x1c>
    80002184:	9dbd                	addw	a1,a1,a5
    80002186:	dedff0ef          	jal	80001f72 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000218a:	0074f713          	andi	a4,s1,7
    8000218e:	4785                	li	a5,1
    80002190:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002194:	14ce                	slli	s1,s1,0x33
    80002196:	90d9                	srli	s1,s1,0x36
    80002198:	00950733          	add	a4,a0,s1
    8000219c:	05874703          	lbu	a4,88(a4)
    800021a0:	00e7f6b3          	and	a3,a5,a4
    800021a4:	c29d                	beqz	a3,800021ca <bfree+0x60>
    800021a6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800021a8:	94aa                	add	s1,s1,a0
    800021aa:	fff7c793          	not	a5,a5
    800021ae:	8f7d                	and	a4,a4,a5
    800021b0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800021b4:	711000ef          	jal	800030c4 <log_write>
  brelse(bp);
    800021b8:	854a                	mv	a0,s2
    800021ba:	ec1ff0ef          	jal	8000207a <brelse>
}
    800021be:	60e2                	ld	ra,24(sp)
    800021c0:	6442                	ld	s0,16(sp)
    800021c2:	64a2                	ld	s1,8(sp)
    800021c4:	6902                	ld	s2,0(sp)
    800021c6:	6105                	addi	sp,sp,32
    800021c8:	8082                	ret
    panic("freeing free block");
    800021ca:	00005517          	auipc	a0,0x5
    800021ce:	25e50513          	addi	a0,a0,606 # 80007428 <etext+0x428>
    800021d2:	290030ef          	jal	80005462 <panic>

00000000800021d6 <balloc>:
{
    800021d6:	711d                	addi	sp,sp,-96
    800021d8:	ec86                	sd	ra,88(sp)
    800021da:	e8a2                	sd	s0,80(sp)
    800021dc:	e4a6                	sd	s1,72(sp)
    800021de:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800021e0:	00016797          	auipc	a5,0x16
    800021e4:	5ec7a783          	lw	a5,1516(a5) # 800187cc <sb+0x4>
    800021e8:	0e078f63          	beqz	a5,800022e6 <balloc+0x110>
    800021ec:	e0ca                	sd	s2,64(sp)
    800021ee:	fc4e                	sd	s3,56(sp)
    800021f0:	f852                	sd	s4,48(sp)
    800021f2:	f456                	sd	s5,40(sp)
    800021f4:	f05a                	sd	s6,32(sp)
    800021f6:	ec5e                	sd	s7,24(sp)
    800021f8:	e862                	sd	s8,16(sp)
    800021fa:	e466                	sd	s9,8(sp)
    800021fc:	8baa                	mv	s7,a0
    800021fe:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002200:	00016b17          	auipc	s6,0x16
    80002204:	5c8b0b13          	addi	s6,s6,1480 # 800187c8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002208:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000220a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000220c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000220e:	6c89                	lui	s9,0x2
    80002210:	a0b5                	j	8000227c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002212:	97ca                	add	a5,a5,s2
    80002214:	8e55                	or	a2,a2,a3
    80002216:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000221a:	854a                	mv	a0,s2
    8000221c:	6a9000ef          	jal	800030c4 <log_write>
        brelse(bp);
    80002220:	854a                	mv	a0,s2
    80002222:	e59ff0ef          	jal	8000207a <brelse>
  bp = bread(dev, bno);
    80002226:	85a6                	mv	a1,s1
    80002228:	855e                	mv	a0,s7
    8000222a:	d49ff0ef          	jal	80001f72 <bread>
    8000222e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002230:	40000613          	li	a2,1024
    80002234:	4581                	li	a1,0
    80002236:	05850513          	addi	a0,a0,88
    8000223a:	f15fd0ef          	jal	8000014e <memset>
  log_write(bp);
    8000223e:	854a                	mv	a0,s2
    80002240:	685000ef          	jal	800030c4 <log_write>
  brelse(bp);
    80002244:	854a                	mv	a0,s2
    80002246:	e35ff0ef          	jal	8000207a <brelse>
}
    8000224a:	6906                	ld	s2,64(sp)
    8000224c:	79e2                	ld	s3,56(sp)
    8000224e:	7a42                	ld	s4,48(sp)
    80002250:	7aa2                	ld	s5,40(sp)
    80002252:	7b02                	ld	s6,32(sp)
    80002254:	6be2                	ld	s7,24(sp)
    80002256:	6c42                	ld	s8,16(sp)
    80002258:	6ca2                	ld	s9,8(sp)
}
    8000225a:	8526                	mv	a0,s1
    8000225c:	60e6                	ld	ra,88(sp)
    8000225e:	6446                	ld	s0,80(sp)
    80002260:	64a6                	ld	s1,72(sp)
    80002262:	6125                	addi	sp,sp,96
    80002264:	8082                	ret
    brelse(bp);
    80002266:	854a                	mv	a0,s2
    80002268:	e13ff0ef          	jal	8000207a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000226c:	015c87bb          	addw	a5,s9,s5
    80002270:	00078a9b          	sext.w	s5,a5
    80002274:	004b2703          	lw	a4,4(s6)
    80002278:	04eaff63          	bgeu	s5,a4,800022d6 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000227c:	41fad79b          	sraiw	a5,s5,0x1f
    80002280:	0137d79b          	srliw	a5,a5,0x13
    80002284:	015787bb          	addw	a5,a5,s5
    80002288:	40d7d79b          	sraiw	a5,a5,0xd
    8000228c:	01cb2583          	lw	a1,28(s6)
    80002290:	9dbd                	addw	a1,a1,a5
    80002292:	855e                	mv	a0,s7
    80002294:	cdfff0ef          	jal	80001f72 <bread>
    80002298:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000229a:	004b2503          	lw	a0,4(s6)
    8000229e:	000a849b          	sext.w	s1,s5
    800022a2:	8762                	mv	a4,s8
    800022a4:	fca4f1e3          	bgeu	s1,a0,80002266 <balloc+0x90>
      m = 1 << (bi % 8);
    800022a8:	00777693          	andi	a3,a4,7
    800022ac:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800022b0:	41f7579b          	sraiw	a5,a4,0x1f
    800022b4:	01d7d79b          	srliw	a5,a5,0x1d
    800022b8:	9fb9                	addw	a5,a5,a4
    800022ba:	4037d79b          	sraiw	a5,a5,0x3
    800022be:	00f90633          	add	a2,s2,a5
    800022c2:	05864603          	lbu	a2,88(a2)
    800022c6:	00c6f5b3          	and	a1,a3,a2
    800022ca:	d5a1                	beqz	a1,80002212 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022cc:	2705                	addiw	a4,a4,1
    800022ce:	2485                	addiw	s1,s1,1
    800022d0:	fd471ae3          	bne	a4,s4,800022a4 <balloc+0xce>
    800022d4:	bf49                	j	80002266 <balloc+0x90>
    800022d6:	6906                	ld	s2,64(sp)
    800022d8:	79e2                	ld	s3,56(sp)
    800022da:	7a42                	ld	s4,48(sp)
    800022dc:	7aa2                	ld	s5,40(sp)
    800022de:	7b02                	ld	s6,32(sp)
    800022e0:	6be2                	ld	s7,24(sp)
    800022e2:	6c42                	ld	s8,16(sp)
    800022e4:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800022e6:	00005517          	auipc	a0,0x5
    800022ea:	15a50513          	addi	a0,a0,346 # 80007440 <etext+0x440>
    800022ee:	6a3020ef          	jal	80005190 <printf>
  return 0;
    800022f2:	4481                	li	s1,0
    800022f4:	b79d                	j	8000225a <balloc+0x84>

00000000800022f6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800022f6:	7179                	addi	sp,sp,-48
    800022f8:	f406                	sd	ra,40(sp)
    800022fa:	f022                	sd	s0,32(sp)
    800022fc:	ec26                	sd	s1,24(sp)
    800022fe:	e84a                	sd	s2,16(sp)
    80002300:	e44e                	sd	s3,8(sp)
    80002302:	1800                	addi	s0,sp,48
    80002304:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002306:	47ad                	li	a5,11
    80002308:	02b7e663          	bltu	a5,a1,80002334 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000230c:	02059793          	slli	a5,a1,0x20
    80002310:	01e7d593          	srli	a1,a5,0x1e
    80002314:	00b504b3          	add	s1,a0,a1
    80002318:	0504a903          	lw	s2,80(s1)
    8000231c:	06091a63          	bnez	s2,80002390 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002320:	4108                	lw	a0,0(a0)
    80002322:	eb5ff0ef          	jal	800021d6 <balloc>
    80002326:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000232a:	06090363          	beqz	s2,80002390 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000232e:	0524a823          	sw	s2,80(s1)
    80002332:	a8b9                	j	80002390 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002334:	ff45849b          	addiw	s1,a1,-12
    80002338:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000233c:	0ff00793          	li	a5,255
    80002340:	06e7ee63          	bltu	a5,a4,800023bc <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002344:	08052903          	lw	s2,128(a0)
    80002348:	00091d63          	bnez	s2,80002362 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000234c:	4108                	lw	a0,0(a0)
    8000234e:	e89ff0ef          	jal	800021d6 <balloc>
    80002352:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002356:	02090d63          	beqz	s2,80002390 <bmap+0x9a>
    8000235a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000235c:	0929a023          	sw	s2,128(s3)
    80002360:	a011                	j	80002364 <bmap+0x6e>
    80002362:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002364:	85ca                	mv	a1,s2
    80002366:	0009a503          	lw	a0,0(s3)
    8000236a:	c09ff0ef          	jal	80001f72 <bread>
    8000236e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002370:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002374:	02049713          	slli	a4,s1,0x20
    80002378:	01e75593          	srli	a1,a4,0x1e
    8000237c:	00b784b3          	add	s1,a5,a1
    80002380:	0004a903          	lw	s2,0(s1)
    80002384:	00090e63          	beqz	s2,800023a0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002388:	8552                	mv	a0,s4
    8000238a:	cf1ff0ef          	jal	8000207a <brelse>
    return addr;
    8000238e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002390:	854a                	mv	a0,s2
    80002392:	70a2                	ld	ra,40(sp)
    80002394:	7402                	ld	s0,32(sp)
    80002396:	64e2                	ld	s1,24(sp)
    80002398:	6942                	ld	s2,16(sp)
    8000239a:	69a2                	ld	s3,8(sp)
    8000239c:	6145                	addi	sp,sp,48
    8000239e:	8082                	ret
      addr = balloc(ip->dev);
    800023a0:	0009a503          	lw	a0,0(s3)
    800023a4:	e33ff0ef          	jal	800021d6 <balloc>
    800023a8:	0005091b          	sext.w	s2,a0
      if(addr){
    800023ac:	fc090ee3          	beqz	s2,80002388 <bmap+0x92>
        a[bn] = addr;
    800023b0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800023b4:	8552                	mv	a0,s4
    800023b6:	50f000ef          	jal	800030c4 <log_write>
    800023ba:	b7f9                	j	80002388 <bmap+0x92>
    800023bc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800023be:	00005517          	auipc	a0,0x5
    800023c2:	09a50513          	addi	a0,a0,154 # 80007458 <etext+0x458>
    800023c6:	09c030ef          	jal	80005462 <panic>

00000000800023ca <iget>:
{
    800023ca:	7179                	addi	sp,sp,-48
    800023cc:	f406                	sd	ra,40(sp)
    800023ce:	f022                	sd	s0,32(sp)
    800023d0:	ec26                	sd	s1,24(sp)
    800023d2:	e84a                	sd	s2,16(sp)
    800023d4:	e44e                	sd	s3,8(sp)
    800023d6:	e052                	sd	s4,0(sp)
    800023d8:	1800                	addi	s0,sp,48
    800023da:	89aa                	mv	s3,a0
    800023dc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800023de:	00016517          	auipc	a0,0x16
    800023e2:	40a50513          	addi	a0,a0,1034 # 800187e8 <itable>
    800023e6:	3aa030ef          	jal	80005790 <acquire>
  empty = 0;
    800023ea:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800023ec:	00016497          	auipc	s1,0x16
    800023f0:	41448493          	addi	s1,s1,1044 # 80018800 <itable+0x18>
    800023f4:	00018697          	auipc	a3,0x18
    800023f8:	e9c68693          	addi	a3,a3,-356 # 8001a290 <log>
    800023fc:	a039                	j	8000240a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800023fe:	02090963          	beqz	s2,80002430 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002402:	08848493          	addi	s1,s1,136
    80002406:	02d48863          	beq	s1,a3,80002436 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000240a:	449c                	lw	a5,8(s1)
    8000240c:	fef059e3          	blez	a5,800023fe <iget+0x34>
    80002410:	4098                	lw	a4,0(s1)
    80002412:	ff3716e3          	bne	a4,s3,800023fe <iget+0x34>
    80002416:	40d8                	lw	a4,4(s1)
    80002418:	ff4713e3          	bne	a4,s4,800023fe <iget+0x34>
      ip->ref++;
    8000241c:	2785                	addiw	a5,a5,1
    8000241e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002420:	00016517          	auipc	a0,0x16
    80002424:	3c850513          	addi	a0,a0,968 # 800187e8 <itable>
    80002428:	400030ef          	jal	80005828 <release>
      return ip;
    8000242c:	8926                	mv	s2,s1
    8000242e:	a02d                	j	80002458 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002430:	fbe9                	bnez	a5,80002402 <iget+0x38>
      empty = ip;
    80002432:	8926                	mv	s2,s1
    80002434:	b7f9                	j	80002402 <iget+0x38>
  if(empty == 0)
    80002436:	02090a63          	beqz	s2,8000246a <iget+0xa0>
  ip->dev = dev;
    8000243a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000243e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002442:	4785                	li	a5,1
    80002444:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002448:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000244c:	00016517          	auipc	a0,0x16
    80002450:	39c50513          	addi	a0,a0,924 # 800187e8 <itable>
    80002454:	3d4030ef          	jal	80005828 <release>
}
    80002458:	854a                	mv	a0,s2
    8000245a:	70a2                	ld	ra,40(sp)
    8000245c:	7402                	ld	s0,32(sp)
    8000245e:	64e2                	ld	s1,24(sp)
    80002460:	6942                	ld	s2,16(sp)
    80002462:	69a2                	ld	s3,8(sp)
    80002464:	6a02                	ld	s4,0(sp)
    80002466:	6145                	addi	sp,sp,48
    80002468:	8082                	ret
    panic("iget: no inodes");
    8000246a:	00005517          	auipc	a0,0x5
    8000246e:	00650513          	addi	a0,a0,6 # 80007470 <etext+0x470>
    80002472:	7f1020ef          	jal	80005462 <panic>

0000000080002476 <fsinit>:
fsinit(int dev) {
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	1800                	addi	s0,sp,48
    80002484:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002486:	4585                	li	a1,1
    80002488:	aebff0ef          	jal	80001f72 <bread>
    8000248c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000248e:	00016997          	auipc	s3,0x16
    80002492:	33a98993          	addi	s3,s3,826 # 800187c8 <sb>
    80002496:	02000613          	li	a2,32
    8000249a:	05850593          	addi	a1,a0,88
    8000249e:	854e                	mv	a0,s3
    800024a0:	d0bfd0ef          	jal	800001aa <memmove>
  brelse(bp);
    800024a4:	8526                	mv	a0,s1
    800024a6:	bd5ff0ef          	jal	8000207a <brelse>
  if(sb.magic != FSMAGIC)
    800024aa:	0009a703          	lw	a4,0(s3)
    800024ae:	102037b7          	lui	a5,0x10203
    800024b2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800024b6:	02f71063          	bne	a4,a5,800024d6 <fsinit+0x60>
  initlog(dev, &sb);
    800024ba:	00016597          	auipc	a1,0x16
    800024be:	30e58593          	addi	a1,a1,782 # 800187c8 <sb>
    800024c2:	854a                	mv	a0,s2
    800024c4:	1f9000ef          	jal	80002ebc <initlog>
}
    800024c8:	70a2                	ld	ra,40(sp)
    800024ca:	7402                	ld	s0,32(sp)
    800024cc:	64e2                	ld	s1,24(sp)
    800024ce:	6942                	ld	s2,16(sp)
    800024d0:	69a2                	ld	s3,8(sp)
    800024d2:	6145                	addi	sp,sp,48
    800024d4:	8082                	ret
    panic("invalid file system");
    800024d6:	00005517          	auipc	a0,0x5
    800024da:	faa50513          	addi	a0,a0,-86 # 80007480 <etext+0x480>
    800024de:	785020ef          	jal	80005462 <panic>

00000000800024e2 <iinit>:
{
    800024e2:	7179                	addi	sp,sp,-48
    800024e4:	f406                	sd	ra,40(sp)
    800024e6:	f022                	sd	s0,32(sp)
    800024e8:	ec26                	sd	s1,24(sp)
    800024ea:	e84a                	sd	s2,16(sp)
    800024ec:	e44e                	sd	s3,8(sp)
    800024ee:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800024f0:	00005597          	auipc	a1,0x5
    800024f4:	fa858593          	addi	a1,a1,-88 # 80007498 <etext+0x498>
    800024f8:	00016517          	auipc	a0,0x16
    800024fc:	2f050513          	addi	a0,a0,752 # 800187e8 <itable>
    80002500:	210030ef          	jal	80005710 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002504:	00016497          	auipc	s1,0x16
    80002508:	30c48493          	addi	s1,s1,780 # 80018810 <itable+0x28>
    8000250c:	00018997          	auipc	s3,0x18
    80002510:	d9498993          	addi	s3,s3,-620 # 8001a2a0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002514:	00005917          	auipc	s2,0x5
    80002518:	f8c90913          	addi	s2,s2,-116 # 800074a0 <etext+0x4a0>
    8000251c:	85ca                	mv	a1,s2
    8000251e:	8526                	mv	a0,s1
    80002520:	475000ef          	jal	80003194 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002524:	08848493          	addi	s1,s1,136
    80002528:	ff349ae3          	bne	s1,s3,8000251c <iinit+0x3a>
}
    8000252c:	70a2                	ld	ra,40(sp)
    8000252e:	7402                	ld	s0,32(sp)
    80002530:	64e2                	ld	s1,24(sp)
    80002532:	6942                	ld	s2,16(sp)
    80002534:	69a2                	ld	s3,8(sp)
    80002536:	6145                	addi	sp,sp,48
    80002538:	8082                	ret

000000008000253a <ialloc>:
{
    8000253a:	7139                	addi	sp,sp,-64
    8000253c:	fc06                	sd	ra,56(sp)
    8000253e:	f822                	sd	s0,48(sp)
    80002540:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002542:	00016717          	auipc	a4,0x16
    80002546:	29272703          	lw	a4,658(a4) # 800187d4 <sb+0xc>
    8000254a:	4785                	li	a5,1
    8000254c:	06e7f063          	bgeu	a5,a4,800025ac <ialloc+0x72>
    80002550:	f426                	sd	s1,40(sp)
    80002552:	f04a                	sd	s2,32(sp)
    80002554:	ec4e                	sd	s3,24(sp)
    80002556:	e852                	sd	s4,16(sp)
    80002558:	e456                	sd	s5,8(sp)
    8000255a:	e05a                	sd	s6,0(sp)
    8000255c:	8aaa                	mv	s5,a0
    8000255e:	8b2e                	mv	s6,a1
    80002560:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002562:	00016a17          	auipc	s4,0x16
    80002566:	266a0a13          	addi	s4,s4,614 # 800187c8 <sb>
    8000256a:	00495593          	srli	a1,s2,0x4
    8000256e:	018a2783          	lw	a5,24(s4)
    80002572:	9dbd                	addw	a1,a1,a5
    80002574:	8556                	mv	a0,s5
    80002576:	9fdff0ef          	jal	80001f72 <bread>
    8000257a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000257c:	05850993          	addi	s3,a0,88
    80002580:	00f97793          	andi	a5,s2,15
    80002584:	079a                	slli	a5,a5,0x6
    80002586:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002588:	00099783          	lh	a5,0(s3)
    8000258c:	cb9d                	beqz	a5,800025c2 <ialloc+0x88>
    brelse(bp);
    8000258e:	aedff0ef          	jal	8000207a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002592:	0905                	addi	s2,s2,1
    80002594:	00ca2703          	lw	a4,12(s4)
    80002598:	0009079b          	sext.w	a5,s2
    8000259c:	fce7e7e3          	bltu	a5,a4,8000256a <ialloc+0x30>
    800025a0:	74a2                	ld	s1,40(sp)
    800025a2:	7902                	ld	s2,32(sp)
    800025a4:	69e2                	ld	s3,24(sp)
    800025a6:	6a42                	ld	s4,16(sp)
    800025a8:	6aa2                	ld	s5,8(sp)
    800025aa:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800025ac:	00005517          	auipc	a0,0x5
    800025b0:	efc50513          	addi	a0,a0,-260 # 800074a8 <etext+0x4a8>
    800025b4:	3dd020ef          	jal	80005190 <printf>
  return 0;
    800025b8:	4501                	li	a0,0
}
    800025ba:	70e2                	ld	ra,56(sp)
    800025bc:	7442                	ld	s0,48(sp)
    800025be:	6121                	addi	sp,sp,64
    800025c0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800025c2:	04000613          	li	a2,64
    800025c6:	4581                	li	a1,0
    800025c8:	854e                	mv	a0,s3
    800025ca:	b85fd0ef          	jal	8000014e <memset>
      dip->type = type;
    800025ce:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800025d2:	8526                	mv	a0,s1
    800025d4:	2f1000ef          	jal	800030c4 <log_write>
      brelse(bp);
    800025d8:	8526                	mv	a0,s1
    800025da:	aa1ff0ef          	jal	8000207a <brelse>
      return iget(dev, inum);
    800025de:	0009059b          	sext.w	a1,s2
    800025e2:	8556                	mv	a0,s5
    800025e4:	de7ff0ef          	jal	800023ca <iget>
    800025e8:	74a2                	ld	s1,40(sp)
    800025ea:	7902                	ld	s2,32(sp)
    800025ec:	69e2                	ld	s3,24(sp)
    800025ee:	6a42                	ld	s4,16(sp)
    800025f0:	6aa2                	ld	s5,8(sp)
    800025f2:	6b02                	ld	s6,0(sp)
    800025f4:	b7d9                	j	800025ba <ialloc+0x80>

00000000800025f6 <iupdate>:
{
    800025f6:	1101                	addi	sp,sp,-32
    800025f8:	ec06                	sd	ra,24(sp)
    800025fa:	e822                	sd	s0,16(sp)
    800025fc:	e426                	sd	s1,8(sp)
    800025fe:	e04a                	sd	s2,0(sp)
    80002600:	1000                	addi	s0,sp,32
    80002602:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002604:	415c                	lw	a5,4(a0)
    80002606:	0047d79b          	srliw	a5,a5,0x4
    8000260a:	00016597          	auipc	a1,0x16
    8000260e:	1d65a583          	lw	a1,470(a1) # 800187e0 <sb+0x18>
    80002612:	9dbd                	addw	a1,a1,a5
    80002614:	4108                	lw	a0,0(a0)
    80002616:	95dff0ef          	jal	80001f72 <bread>
    8000261a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000261c:	05850793          	addi	a5,a0,88
    80002620:	40d8                	lw	a4,4(s1)
    80002622:	8b3d                	andi	a4,a4,15
    80002624:	071a                	slli	a4,a4,0x6
    80002626:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002628:	04449703          	lh	a4,68(s1)
    8000262c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002630:	04649703          	lh	a4,70(s1)
    80002634:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002638:	04849703          	lh	a4,72(s1)
    8000263c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002640:	04a49703          	lh	a4,74(s1)
    80002644:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002648:	44f8                	lw	a4,76(s1)
    8000264a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000264c:	03400613          	li	a2,52
    80002650:	05048593          	addi	a1,s1,80
    80002654:	00c78513          	addi	a0,a5,12
    80002658:	b53fd0ef          	jal	800001aa <memmove>
  log_write(bp);
    8000265c:	854a                	mv	a0,s2
    8000265e:	267000ef          	jal	800030c4 <log_write>
  brelse(bp);
    80002662:	854a                	mv	a0,s2
    80002664:	a17ff0ef          	jal	8000207a <brelse>
}
    80002668:	60e2                	ld	ra,24(sp)
    8000266a:	6442                	ld	s0,16(sp)
    8000266c:	64a2                	ld	s1,8(sp)
    8000266e:	6902                	ld	s2,0(sp)
    80002670:	6105                	addi	sp,sp,32
    80002672:	8082                	ret

0000000080002674 <idup>:
{
    80002674:	1101                	addi	sp,sp,-32
    80002676:	ec06                	sd	ra,24(sp)
    80002678:	e822                	sd	s0,16(sp)
    8000267a:	e426                	sd	s1,8(sp)
    8000267c:	1000                	addi	s0,sp,32
    8000267e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002680:	00016517          	auipc	a0,0x16
    80002684:	16850513          	addi	a0,a0,360 # 800187e8 <itable>
    80002688:	108030ef          	jal	80005790 <acquire>
  ip->ref++;
    8000268c:	449c                	lw	a5,8(s1)
    8000268e:	2785                	addiw	a5,a5,1
    80002690:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002692:	00016517          	auipc	a0,0x16
    80002696:	15650513          	addi	a0,a0,342 # 800187e8 <itable>
    8000269a:	18e030ef          	jal	80005828 <release>
}
    8000269e:	8526                	mv	a0,s1
    800026a0:	60e2                	ld	ra,24(sp)
    800026a2:	6442                	ld	s0,16(sp)
    800026a4:	64a2                	ld	s1,8(sp)
    800026a6:	6105                	addi	sp,sp,32
    800026a8:	8082                	ret

00000000800026aa <ilock>:
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800026b4:	cd19                	beqz	a0,800026d2 <ilock+0x28>
    800026b6:	84aa                	mv	s1,a0
    800026b8:	451c                	lw	a5,8(a0)
    800026ba:	00f05c63          	blez	a5,800026d2 <ilock+0x28>
  acquiresleep(&ip->lock);
    800026be:	0541                	addi	a0,a0,16
    800026c0:	30b000ef          	jal	800031ca <acquiresleep>
  if(ip->valid == 0){
    800026c4:	40bc                	lw	a5,64(s1)
    800026c6:	cf89                	beqz	a5,800026e0 <ilock+0x36>
}
    800026c8:	60e2                	ld	ra,24(sp)
    800026ca:	6442                	ld	s0,16(sp)
    800026cc:	64a2                	ld	s1,8(sp)
    800026ce:	6105                	addi	sp,sp,32
    800026d0:	8082                	ret
    800026d2:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800026d4:	00005517          	auipc	a0,0x5
    800026d8:	dec50513          	addi	a0,a0,-532 # 800074c0 <etext+0x4c0>
    800026dc:	587020ef          	jal	80005462 <panic>
    800026e0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026e2:	40dc                	lw	a5,4(s1)
    800026e4:	0047d79b          	srliw	a5,a5,0x4
    800026e8:	00016597          	auipc	a1,0x16
    800026ec:	0f85a583          	lw	a1,248(a1) # 800187e0 <sb+0x18>
    800026f0:	9dbd                	addw	a1,a1,a5
    800026f2:	4088                	lw	a0,0(s1)
    800026f4:	87fff0ef          	jal	80001f72 <bread>
    800026f8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026fa:	05850593          	addi	a1,a0,88
    800026fe:	40dc                	lw	a5,4(s1)
    80002700:	8bbd                	andi	a5,a5,15
    80002702:	079a                	slli	a5,a5,0x6
    80002704:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002706:	00059783          	lh	a5,0(a1)
    8000270a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000270e:	00259783          	lh	a5,2(a1)
    80002712:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002716:	00459783          	lh	a5,4(a1)
    8000271a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000271e:	00659783          	lh	a5,6(a1)
    80002722:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002726:	459c                	lw	a5,8(a1)
    80002728:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000272a:	03400613          	li	a2,52
    8000272e:	05b1                	addi	a1,a1,12
    80002730:	05048513          	addi	a0,s1,80
    80002734:	a77fd0ef          	jal	800001aa <memmove>
    brelse(bp);
    80002738:	854a                	mv	a0,s2
    8000273a:	941ff0ef          	jal	8000207a <brelse>
    ip->valid = 1;
    8000273e:	4785                	li	a5,1
    80002740:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002742:	04449783          	lh	a5,68(s1)
    80002746:	c399                	beqz	a5,8000274c <ilock+0xa2>
    80002748:	6902                	ld	s2,0(sp)
    8000274a:	bfbd                	j	800026c8 <ilock+0x1e>
      panic("ilock: no type");
    8000274c:	00005517          	auipc	a0,0x5
    80002750:	d7c50513          	addi	a0,a0,-644 # 800074c8 <etext+0x4c8>
    80002754:	50f020ef          	jal	80005462 <panic>

0000000080002758 <iunlock>:
{
    80002758:	1101                	addi	sp,sp,-32
    8000275a:	ec06                	sd	ra,24(sp)
    8000275c:	e822                	sd	s0,16(sp)
    8000275e:	e426                	sd	s1,8(sp)
    80002760:	e04a                	sd	s2,0(sp)
    80002762:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002764:	c505                	beqz	a0,8000278c <iunlock+0x34>
    80002766:	84aa                	mv	s1,a0
    80002768:	01050913          	addi	s2,a0,16
    8000276c:	854a                	mv	a0,s2
    8000276e:	2db000ef          	jal	80003248 <holdingsleep>
    80002772:	cd09                	beqz	a0,8000278c <iunlock+0x34>
    80002774:	449c                	lw	a5,8(s1)
    80002776:	00f05b63          	blez	a5,8000278c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000277a:	854a                	mv	a0,s2
    8000277c:	295000ef          	jal	80003210 <releasesleep>
}
    80002780:	60e2                	ld	ra,24(sp)
    80002782:	6442                	ld	s0,16(sp)
    80002784:	64a2                	ld	s1,8(sp)
    80002786:	6902                	ld	s2,0(sp)
    80002788:	6105                	addi	sp,sp,32
    8000278a:	8082                	ret
    panic("iunlock");
    8000278c:	00005517          	auipc	a0,0x5
    80002790:	d4c50513          	addi	a0,a0,-692 # 800074d8 <etext+0x4d8>
    80002794:	4cf020ef          	jal	80005462 <panic>

0000000080002798 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002798:	7179                	addi	sp,sp,-48
    8000279a:	f406                	sd	ra,40(sp)
    8000279c:	f022                	sd	s0,32(sp)
    8000279e:	ec26                	sd	s1,24(sp)
    800027a0:	e84a                	sd	s2,16(sp)
    800027a2:	e44e                	sd	s3,8(sp)
    800027a4:	1800                	addi	s0,sp,48
    800027a6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800027a8:	05050493          	addi	s1,a0,80
    800027ac:	08050913          	addi	s2,a0,128
    800027b0:	a021                	j	800027b8 <itrunc+0x20>
    800027b2:	0491                	addi	s1,s1,4
    800027b4:	01248b63          	beq	s1,s2,800027ca <itrunc+0x32>
    if(ip->addrs[i]){
    800027b8:	408c                	lw	a1,0(s1)
    800027ba:	dde5                	beqz	a1,800027b2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800027bc:	0009a503          	lw	a0,0(s3)
    800027c0:	9abff0ef          	jal	8000216a <bfree>
      ip->addrs[i] = 0;
    800027c4:	0004a023          	sw	zero,0(s1)
    800027c8:	b7ed                	j	800027b2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800027ca:	0809a583          	lw	a1,128(s3)
    800027ce:	ed89                	bnez	a1,800027e8 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800027d0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800027d4:	854e                	mv	a0,s3
    800027d6:	e21ff0ef          	jal	800025f6 <iupdate>
}
    800027da:	70a2                	ld	ra,40(sp)
    800027dc:	7402                	ld	s0,32(sp)
    800027de:	64e2                	ld	s1,24(sp)
    800027e0:	6942                	ld	s2,16(sp)
    800027e2:	69a2                	ld	s3,8(sp)
    800027e4:	6145                	addi	sp,sp,48
    800027e6:	8082                	ret
    800027e8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800027ea:	0009a503          	lw	a0,0(s3)
    800027ee:	f84ff0ef          	jal	80001f72 <bread>
    800027f2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800027f4:	05850493          	addi	s1,a0,88
    800027f8:	45850913          	addi	s2,a0,1112
    800027fc:	a021                	j	80002804 <itrunc+0x6c>
    800027fe:	0491                	addi	s1,s1,4
    80002800:	01248963          	beq	s1,s2,80002812 <itrunc+0x7a>
      if(a[j])
    80002804:	408c                	lw	a1,0(s1)
    80002806:	dde5                	beqz	a1,800027fe <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002808:	0009a503          	lw	a0,0(s3)
    8000280c:	95fff0ef          	jal	8000216a <bfree>
    80002810:	b7fd                	j	800027fe <itrunc+0x66>
    brelse(bp);
    80002812:	8552                	mv	a0,s4
    80002814:	867ff0ef          	jal	8000207a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002818:	0809a583          	lw	a1,128(s3)
    8000281c:	0009a503          	lw	a0,0(s3)
    80002820:	94bff0ef          	jal	8000216a <bfree>
    ip->addrs[NDIRECT] = 0;
    80002824:	0809a023          	sw	zero,128(s3)
    80002828:	6a02                	ld	s4,0(sp)
    8000282a:	b75d                	j	800027d0 <itrunc+0x38>

000000008000282c <iput>:
{
    8000282c:	1101                	addi	sp,sp,-32
    8000282e:	ec06                	sd	ra,24(sp)
    80002830:	e822                	sd	s0,16(sp)
    80002832:	e426                	sd	s1,8(sp)
    80002834:	1000                	addi	s0,sp,32
    80002836:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002838:	00016517          	auipc	a0,0x16
    8000283c:	fb050513          	addi	a0,a0,-80 # 800187e8 <itable>
    80002840:	751020ef          	jal	80005790 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002844:	4498                	lw	a4,8(s1)
    80002846:	4785                	li	a5,1
    80002848:	02f70063          	beq	a4,a5,80002868 <iput+0x3c>
  ip->ref--;
    8000284c:	449c                	lw	a5,8(s1)
    8000284e:	37fd                	addiw	a5,a5,-1
    80002850:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002852:	00016517          	auipc	a0,0x16
    80002856:	f9650513          	addi	a0,a0,-106 # 800187e8 <itable>
    8000285a:	7cf020ef          	jal	80005828 <release>
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002868:	40bc                	lw	a5,64(s1)
    8000286a:	d3ed                	beqz	a5,8000284c <iput+0x20>
    8000286c:	04a49783          	lh	a5,74(s1)
    80002870:	fff1                	bnez	a5,8000284c <iput+0x20>
    80002872:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002874:	01048913          	addi	s2,s1,16
    80002878:	854a                	mv	a0,s2
    8000287a:	151000ef          	jal	800031ca <acquiresleep>
    release(&itable.lock);
    8000287e:	00016517          	auipc	a0,0x16
    80002882:	f6a50513          	addi	a0,a0,-150 # 800187e8 <itable>
    80002886:	7a3020ef          	jal	80005828 <release>
    itrunc(ip);
    8000288a:	8526                	mv	a0,s1
    8000288c:	f0dff0ef          	jal	80002798 <itrunc>
    ip->type = 0;
    80002890:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002894:	8526                	mv	a0,s1
    80002896:	d61ff0ef          	jal	800025f6 <iupdate>
    ip->valid = 0;
    8000289a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000289e:	854a                	mv	a0,s2
    800028a0:	171000ef          	jal	80003210 <releasesleep>
    acquire(&itable.lock);
    800028a4:	00016517          	auipc	a0,0x16
    800028a8:	f4450513          	addi	a0,a0,-188 # 800187e8 <itable>
    800028ac:	6e5020ef          	jal	80005790 <acquire>
    800028b0:	6902                	ld	s2,0(sp)
    800028b2:	bf69                	j	8000284c <iput+0x20>

00000000800028b4 <iunlockput>:
{
    800028b4:	1101                	addi	sp,sp,-32
    800028b6:	ec06                	sd	ra,24(sp)
    800028b8:	e822                	sd	s0,16(sp)
    800028ba:	e426                	sd	s1,8(sp)
    800028bc:	1000                	addi	s0,sp,32
    800028be:	84aa                	mv	s1,a0
  iunlock(ip);
    800028c0:	e99ff0ef          	jal	80002758 <iunlock>
  iput(ip);
    800028c4:	8526                	mv	a0,s1
    800028c6:	f67ff0ef          	jal	8000282c <iput>
}
    800028ca:	60e2                	ld	ra,24(sp)
    800028cc:	6442                	ld	s0,16(sp)
    800028ce:	64a2                	ld	s1,8(sp)
    800028d0:	6105                	addi	sp,sp,32
    800028d2:	8082                	ret

00000000800028d4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800028d4:	1141                	addi	sp,sp,-16
    800028d6:	e422                	sd	s0,8(sp)
    800028d8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800028da:	411c                	lw	a5,0(a0)
    800028dc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800028de:	415c                	lw	a5,4(a0)
    800028e0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800028e2:	04451783          	lh	a5,68(a0)
    800028e6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800028ea:	04a51783          	lh	a5,74(a0)
    800028ee:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800028f2:	04c56783          	lwu	a5,76(a0)
    800028f6:	e99c                	sd	a5,16(a1)
}
    800028f8:	6422                	ld	s0,8(sp)
    800028fa:	0141                	addi	sp,sp,16
    800028fc:	8082                	ret

00000000800028fe <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800028fe:	457c                	lw	a5,76(a0)
    80002900:	0ed7eb63          	bltu	a5,a3,800029f6 <readi+0xf8>
{
    80002904:	7159                	addi	sp,sp,-112
    80002906:	f486                	sd	ra,104(sp)
    80002908:	f0a2                	sd	s0,96(sp)
    8000290a:	eca6                	sd	s1,88(sp)
    8000290c:	e0d2                	sd	s4,64(sp)
    8000290e:	fc56                	sd	s5,56(sp)
    80002910:	f85a                	sd	s6,48(sp)
    80002912:	f45e                	sd	s7,40(sp)
    80002914:	1880                	addi	s0,sp,112
    80002916:	8b2a                	mv	s6,a0
    80002918:	8bae                	mv	s7,a1
    8000291a:	8a32                	mv	s4,a2
    8000291c:	84b6                	mv	s1,a3
    8000291e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002920:	9f35                	addw	a4,a4,a3
    return 0;
    80002922:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002924:	0cd76063          	bltu	a4,a3,800029e4 <readi+0xe6>
    80002928:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000292a:	00e7f463          	bgeu	a5,a4,80002932 <readi+0x34>
    n = ip->size - off;
    8000292e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002932:	080a8f63          	beqz	s5,800029d0 <readi+0xd2>
    80002936:	e8ca                	sd	s2,80(sp)
    80002938:	f062                	sd	s8,32(sp)
    8000293a:	ec66                	sd	s9,24(sp)
    8000293c:	e86a                	sd	s10,16(sp)
    8000293e:	e46e                	sd	s11,8(sp)
    80002940:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002942:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002946:	5c7d                	li	s8,-1
    80002948:	a80d                	j	8000297a <readi+0x7c>
    8000294a:	020d1d93          	slli	s11,s10,0x20
    8000294e:	020ddd93          	srli	s11,s11,0x20
    80002952:	05890613          	addi	a2,s2,88
    80002956:	86ee                	mv	a3,s11
    80002958:	963a                	add	a2,a2,a4
    8000295a:	85d2                	mv	a1,s4
    8000295c:	855e                	mv	a0,s7
    8000295e:	d33fe0ef          	jal	80001690 <either_copyout>
    80002962:	05850763          	beq	a0,s8,800029b0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002966:	854a                	mv	a0,s2
    80002968:	f12ff0ef          	jal	8000207a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000296c:	013d09bb          	addw	s3,s10,s3
    80002970:	009d04bb          	addw	s1,s10,s1
    80002974:	9a6e                	add	s4,s4,s11
    80002976:	0559f763          	bgeu	s3,s5,800029c4 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000297a:	00a4d59b          	srliw	a1,s1,0xa
    8000297e:	855a                	mv	a0,s6
    80002980:	977ff0ef          	jal	800022f6 <bmap>
    80002984:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002988:	c5b1                	beqz	a1,800029d4 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000298a:	000b2503          	lw	a0,0(s6)
    8000298e:	de4ff0ef          	jal	80001f72 <bread>
    80002992:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002994:	3ff4f713          	andi	a4,s1,1023
    80002998:	40ec87bb          	subw	a5,s9,a4
    8000299c:	413a86bb          	subw	a3,s5,s3
    800029a0:	8d3e                	mv	s10,a5
    800029a2:	2781                	sext.w	a5,a5
    800029a4:	0006861b          	sext.w	a2,a3
    800029a8:	faf671e3          	bgeu	a2,a5,8000294a <readi+0x4c>
    800029ac:	8d36                	mv	s10,a3
    800029ae:	bf71                	j	8000294a <readi+0x4c>
      brelse(bp);
    800029b0:	854a                	mv	a0,s2
    800029b2:	ec8ff0ef          	jal	8000207a <brelse>
      tot = -1;
    800029b6:	59fd                	li	s3,-1
      break;
    800029b8:	6946                	ld	s2,80(sp)
    800029ba:	7c02                	ld	s8,32(sp)
    800029bc:	6ce2                	ld	s9,24(sp)
    800029be:	6d42                	ld	s10,16(sp)
    800029c0:	6da2                	ld	s11,8(sp)
    800029c2:	a831                	j	800029de <readi+0xe0>
    800029c4:	6946                	ld	s2,80(sp)
    800029c6:	7c02                	ld	s8,32(sp)
    800029c8:	6ce2                	ld	s9,24(sp)
    800029ca:	6d42                	ld	s10,16(sp)
    800029cc:	6da2                	ld	s11,8(sp)
    800029ce:	a801                	j	800029de <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800029d0:	89d6                	mv	s3,s5
    800029d2:	a031                	j	800029de <readi+0xe0>
    800029d4:	6946                	ld	s2,80(sp)
    800029d6:	7c02                	ld	s8,32(sp)
    800029d8:	6ce2                	ld	s9,24(sp)
    800029da:	6d42                	ld	s10,16(sp)
    800029dc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800029de:	0009851b          	sext.w	a0,s3
    800029e2:	69a6                	ld	s3,72(sp)
}
    800029e4:	70a6                	ld	ra,104(sp)
    800029e6:	7406                	ld	s0,96(sp)
    800029e8:	64e6                	ld	s1,88(sp)
    800029ea:	6a06                	ld	s4,64(sp)
    800029ec:	7ae2                	ld	s5,56(sp)
    800029ee:	7b42                	ld	s6,48(sp)
    800029f0:	7ba2                	ld	s7,40(sp)
    800029f2:	6165                	addi	sp,sp,112
    800029f4:	8082                	ret
    return 0;
    800029f6:	4501                	li	a0,0
}
    800029f8:	8082                	ret

00000000800029fa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800029fa:	457c                	lw	a5,76(a0)
    800029fc:	10d7e063          	bltu	a5,a3,80002afc <writei+0x102>
{
    80002a00:	7159                	addi	sp,sp,-112
    80002a02:	f486                	sd	ra,104(sp)
    80002a04:	f0a2                	sd	s0,96(sp)
    80002a06:	e8ca                	sd	s2,80(sp)
    80002a08:	e0d2                	sd	s4,64(sp)
    80002a0a:	fc56                	sd	s5,56(sp)
    80002a0c:	f85a                	sd	s6,48(sp)
    80002a0e:	f45e                	sd	s7,40(sp)
    80002a10:	1880                	addi	s0,sp,112
    80002a12:	8aaa                	mv	s5,a0
    80002a14:	8bae                	mv	s7,a1
    80002a16:	8a32                	mv	s4,a2
    80002a18:	8936                	mv	s2,a3
    80002a1a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002a1c:	00e687bb          	addw	a5,a3,a4
    80002a20:	0ed7e063          	bltu	a5,a3,80002b00 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002a24:	00043737          	lui	a4,0x43
    80002a28:	0cf76e63          	bltu	a4,a5,80002b04 <writei+0x10a>
    80002a2c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a2e:	0a0b0f63          	beqz	s6,80002aec <writei+0xf2>
    80002a32:	eca6                	sd	s1,88(sp)
    80002a34:	f062                	sd	s8,32(sp)
    80002a36:	ec66                	sd	s9,24(sp)
    80002a38:	e86a                	sd	s10,16(sp)
    80002a3a:	e46e                	sd	s11,8(sp)
    80002a3c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a3e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002a42:	5c7d                	li	s8,-1
    80002a44:	a825                	j	80002a7c <writei+0x82>
    80002a46:	020d1d93          	slli	s11,s10,0x20
    80002a4a:	020ddd93          	srli	s11,s11,0x20
    80002a4e:	05848513          	addi	a0,s1,88
    80002a52:	86ee                	mv	a3,s11
    80002a54:	8652                	mv	a2,s4
    80002a56:	85de                	mv	a1,s7
    80002a58:	953a                	add	a0,a0,a4
    80002a5a:	c81fe0ef          	jal	800016da <either_copyin>
    80002a5e:	05850a63          	beq	a0,s8,80002ab2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002a62:	8526                	mv	a0,s1
    80002a64:	660000ef          	jal	800030c4 <log_write>
    brelse(bp);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	e10ff0ef          	jal	8000207a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a6e:	013d09bb          	addw	s3,s10,s3
    80002a72:	012d093b          	addw	s2,s10,s2
    80002a76:	9a6e                	add	s4,s4,s11
    80002a78:	0569f063          	bgeu	s3,s6,80002ab8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002a7c:	00a9559b          	srliw	a1,s2,0xa
    80002a80:	8556                	mv	a0,s5
    80002a82:	875ff0ef          	jal	800022f6 <bmap>
    80002a86:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002a8a:	c59d                	beqz	a1,80002ab8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002a8c:	000aa503          	lw	a0,0(s5)
    80002a90:	ce2ff0ef          	jal	80001f72 <bread>
    80002a94:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a96:	3ff97713          	andi	a4,s2,1023
    80002a9a:	40ec87bb          	subw	a5,s9,a4
    80002a9e:	413b06bb          	subw	a3,s6,s3
    80002aa2:	8d3e                	mv	s10,a5
    80002aa4:	2781                	sext.w	a5,a5
    80002aa6:	0006861b          	sext.w	a2,a3
    80002aaa:	f8f67ee3          	bgeu	a2,a5,80002a46 <writei+0x4c>
    80002aae:	8d36                	mv	s10,a3
    80002ab0:	bf59                	j	80002a46 <writei+0x4c>
      brelse(bp);
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	dc6ff0ef          	jal	8000207a <brelse>
  }

  if(off > ip->size)
    80002ab8:	04caa783          	lw	a5,76(s5)
    80002abc:	0327fa63          	bgeu	a5,s2,80002af0 <writei+0xf6>
    ip->size = off;
    80002ac0:	052aa623          	sw	s2,76(s5)
    80002ac4:	64e6                	ld	s1,88(sp)
    80002ac6:	7c02                	ld	s8,32(sp)
    80002ac8:	6ce2                	ld	s9,24(sp)
    80002aca:	6d42                	ld	s10,16(sp)
    80002acc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002ace:	8556                	mv	a0,s5
    80002ad0:	b27ff0ef          	jal	800025f6 <iupdate>

  return tot;
    80002ad4:	0009851b          	sext.w	a0,s3
    80002ad8:	69a6                	ld	s3,72(sp)
}
    80002ada:	70a6                	ld	ra,104(sp)
    80002adc:	7406                	ld	s0,96(sp)
    80002ade:	6946                	ld	s2,80(sp)
    80002ae0:	6a06                	ld	s4,64(sp)
    80002ae2:	7ae2                	ld	s5,56(sp)
    80002ae4:	7b42                	ld	s6,48(sp)
    80002ae6:	7ba2                	ld	s7,40(sp)
    80002ae8:	6165                	addi	sp,sp,112
    80002aea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002aec:	89da                	mv	s3,s6
    80002aee:	b7c5                	j	80002ace <writei+0xd4>
    80002af0:	64e6                	ld	s1,88(sp)
    80002af2:	7c02                	ld	s8,32(sp)
    80002af4:	6ce2                	ld	s9,24(sp)
    80002af6:	6d42                	ld	s10,16(sp)
    80002af8:	6da2                	ld	s11,8(sp)
    80002afa:	bfd1                	j	80002ace <writei+0xd4>
    return -1;
    80002afc:	557d                	li	a0,-1
}
    80002afe:	8082                	ret
    return -1;
    80002b00:	557d                	li	a0,-1
    80002b02:	bfe1                	j	80002ada <writei+0xe0>
    return -1;
    80002b04:	557d                	li	a0,-1
    80002b06:	bfd1                	j	80002ada <writei+0xe0>

0000000080002b08 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002b08:	1141                	addi	sp,sp,-16
    80002b0a:	e406                	sd	ra,8(sp)
    80002b0c:	e022                	sd	s0,0(sp)
    80002b0e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002b10:	4639                	li	a2,14
    80002b12:	f08fd0ef          	jal	8000021a <strncmp>
}
    80002b16:	60a2                	ld	ra,8(sp)
    80002b18:	6402                	ld	s0,0(sp)
    80002b1a:	0141                	addi	sp,sp,16
    80002b1c:	8082                	ret

0000000080002b1e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002b1e:	7139                	addi	sp,sp,-64
    80002b20:	fc06                	sd	ra,56(sp)
    80002b22:	f822                	sd	s0,48(sp)
    80002b24:	f426                	sd	s1,40(sp)
    80002b26:	f04a                	sd	s2,32(sp)
    80002b28:	ec4e                	sd	s3,24(sp)
    80002b2a:	e852                	sd	s4,16(sp)
    80002b2c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002b2e:	04451703          	lh	a4,68(a0)
    80002b32:	4785                	li	a5,1
    80002b34:	00f71a63          	bne	a4,a5,80002b48 <dirlookup+0x2a>
    80002b38:	892a                	mv	s2,a0
    80002b3a:	89ae                	mv	s3,a1
    80002b3c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b3e:	457c                	lw	a5,76(a0)
    80002b40:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002b42:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b44:	e39d                	bnez	a5,80002b6a <dirlookup+0x4c>
    80002b46:	a095                	j	80002baa <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002b48:	00005517          	auipc	a0,0x5
    80002b4c:	99850513          	addi	a0,a0,-1640 # 800074e0 <etext+0x4e0>
    80002b50:	113020ef          	jal	80005462 <panic>
      panic("dirlookup read");
    80002b54:	00005517          	auipc	a0,0x5
    80002b58:	9a450513          	addi	a0,a0,-1628 # 800074f8 <etext+0x4f8>
    80002b5c:	107020ef          	jal	80005462 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b60:	24c1                	addiw	s1,s1,16
    80002b62:	04c92783          	lw	a5,76(s2)
    80002b66:	04f4f163          	bgeu	s1,a5,80002ba8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002b6a:	4741                	li	a4,16
    80002b6c:	86a6                	mv	a3,s1
    80002b6e:	fc040613          	addi	a2,s0,-64
    80002b72:	4581                	li	a1,0
    80002b74:	854a                	mv	a0,s2
    80002b76:	d89ff0ef          	jal	800028fe <readi>
    80002b7a:	47c1                	li	a5,16
    80002b7c:	fcf51ce3          	bne	a0,a5,80002b54 <dirlookup+0x36>
    if(de.inum == 0)
    80002b80:	fc045783          	lhu	a5,-64(s0)
    80002b84:	dff1                	beqz	a5,80002b60 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002b86:	fc240593          	addi	a1,s0,-62
    80002b8a:	854e                	mv	a0,s3
    80002b8c:	f7dff0ef          	jal	80002b08 <namecmp>
    80002b90:	f961                	bnez	a0,80002b60 <dirlookup+0x42>
      if(poff)
    80002b92:	000a0463          	beqz	s4,80002b9a <dirlookup+0x7c>
        *poff = off;
    80002b96:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002b9a:	fc045583          	lhu	a1,-64(s0)
    80002b9e:	00092503          	lw	a0,0(s2)
    80002ba2:	829ff0ef          	jal	800023ca <iget>
    80002ba6:	a011                	j	80002baa <dirlookup+0x8c>
  return 0;
    80002ba8:	4501                	li	a0,0
}
    80002baa:	70e2                	ld	ra,56(sp)
    80002bac:	7442                	ld	s0,48(sp)
    80002bae:	74a2                	ld	s1,40(sp)
    80002bb0:	7902                	ld	s2,32(sp)
    80002bb2:	69e2                	ld	s3,24(sp)
    80002bb4:	6a42                	ld	s4,16(sp)
    80002bb6:	6121                	addi	sp,sp,64
    80002bb8:	8082                	ret

0000000080002bba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002bba:	711d                	addi	sp,sp,-96
    80002bbc:	ec86                	sd	ra,88(sp)
    80002bbe:	e8a2                	sd	s0,80(sp)
    80002bc0:	e4a6                	sd	s1,72(sp)
    80002bc2:	e0ca                	sd	s2,64(sp)
    80002bc4:	fc4e                	sd	s3,56(sp)
    80002bc6:	f852                	sd	s4,48(sp)
    80002bc8:	f456                	sd	s5,40(sp)
    80002bca:	f05a                	sd	s6,32(sp)
    80002bcc:	ec5e                	sd	s7,24(sp)
    80002bce:	e862                	sd	s8,16(sp)
    80002bd0:	e466                	sd	s9,8(sp)
    80002bd2:	1080                	addi	s0,sp,96
    80002bd4:	84aa                	mv	s1,a0
    80002bd6:	8b2e                	mv	s6,a1
    80002bd8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002bda:	00054703          	lbu	a4,0(a0)
    80002bde:	02f00793          	li	a5,47
    80002be2:	00f70e63          	beq	a4,a5,80002bfe <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002be6:	980fe0ef          	jal	80000d66 <myproc>
    80002bea:	15053503          	ld	a0,336(a0)
    80002bee:	a87ff0ef          	jal	80002674 <idup>
    80002bf2:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002bf4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002bf8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002bfa:	4b85                	li	s7,1
    80002bfc:	a871                	j	80002c98 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002bfe:	4585                	li	a1,1
    80002c00:	4505                	li	a0,1
    80002c02:	fc8ff0ef          	jal	800023ca <iget>
    80002c06:	8a2a                	mv	s4,a0
    80002c08:	b7f5                	j	80002bf4 <namex+0x3a>
      iunlockput(ip);
    80002c0a:	8552                	mv	a0,s4
    80002c0c:	ca9ff0ef          	jal	800028b4 <iunlockput>
      return 0;
    80002c10:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002c12:	8552                	mv	a0,s4
    80002c14:	60e6                	ld	ra,88(sp)
    80002c16:	6446                	ld	s0,80(sp)
    80002c18:	64a6                	ld	s1,72(sp)
    80002c1a:	6906                	ld	s2,64(sp)
    80002c1c:	79e2                	ld	s3,56(sp)
    80002c1e:	7a42                	ld	s4,48(sp)
    80002c20:	7aa2                	ld	s5,40(sp)
    80002c22:	7b02                	ld	s6,32(sp)
    80002c24:	6be2                	ld	s7,24(sp)
    80002c26:	6c42                	ld	s8,16(sp)
    80002c28:	6ca2                	ld	s9,8(sp)
    80002c2a:	6125                	addi	sp,sp,96
    80002c2c:	8082                	ret
      iunlock(ip);
    80002c2e:	8552                	mv	a0,s4
    80002c30:	b29ff0ef          	jal	80002758 <iunlock>
      return ip;
    80002c34:	bff9                	j	80002c12 <namex+0x58>
      iunlockput(ip);
    80002c36:	8552                	mv	a0,s4
    80002c38:	c7dff0ef          	jal	800028b4 <iunlockput>
      return 0;
    80002c3c:	8a4e                	mv	s4,s3
    80002c3e:	bfd1                	j	80002c12 <namex+0x58>
  len = path - s;
    80002c40:	40998633          	sub	a2,s3,s1
    80002c44:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002c48:	099c5063          	bge	s8,s9,80002cc8 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002c4c:	4639                	li	a2,14
    80002c4e:	85a6                	mv	a1,s1
    80002c50:	8556                	mv	a0,s5
    80002c52:	d58fd0ef          	jal	800001aa <memmove>
    80002c56:	84ce                	mv	s1,s3
  while(*path == '/')
    80002c58:	0004c783          	lbu	a5,0(s1)
    80002c5c:	01279763          	bne	a5,s2,80002c6a <namex+0xb0>
    path++;
    80002c60:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002c62:	0004c783          	lbu	a5,0(s1)
    80002c66:	ff278de3          	beq	a5,s2,80002c60 <namex+0xa6>
    ilock(ip);
    80002c6a:	8552                	mv	a0,s4
    80002c6c:	a3fff0ef          	jal	800026aa <ilock>
    if(ip->type != T_DIR){
    80002c70:	044a1783          	lh	a5,68(s4)
    80002c74:	f9779be3          	bne	a5,s7,80002c0a <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002c78:	000b0563          	beqz	s6,80002c82 <namex+0xc8>
    80002c7c:	0004c783          	lbu	a5,0(s1)
    80002c80:	d7dd                	beqz	a5,80002c2e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002c82:	4601                	li	a2,0
    80002c84:	85d6                	mv	a1,s5
    80002c86:	8552                	mv	a0,s4
    80002c88:	e97ff0ef          	jal	80002b1e <dirlookup>
    80002c8c:	89aa                	mv	s3,a0
    80002c8e:	d545                	beqz	a0,80002c36 <namex+0x7c>
    iunlockput(ip);
    80002c90:	8552                	mv	a0,s4
    80002c92:	c23ff0ef          	jal	800028b4 <iunlockput>
    ip = next;
    80002c96:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002c98:	0004c783          	lbu	a5,0(s1)
    80002c9c:	01279763          	bne	a5,s2,80002caa <namex+0xf0>
    path++;
    80002ca0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002ca2:	0004c783          	lbu	a5,0(s1)
    80002ca6:	ff278de3          	beq	a5,s2,80002ca0 <namex+0xe6>
  if(*path == 0)
    80002caa:	cb8d                	beqz	a5,80002cdc <namex+0x122>
  while(*path != '/' && *path != 0)
    80002cac:	0004c783          	lbu	a5,0(s1)
    80002cb0:	89a6                	mv	s3,s1
  len = path - s;
    80002cb2:	4c81                	li	s9,0
    80002cb4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002cb6:	01278963          	beq	a5,s2,80002cc8 <namex+0x10e>
    80002cba:	d3d9                	beqz	a5,80002c40 <namex+0x86>
    path++;
    80002cbc:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002cbe:	0009c783          	lbu	a5,0(s3)
    80002cc2:	ff279ce3          	bne	a5,s2,80002cba <namex+0x100>
    80002cc6:	bfad                	j	80002c40 <namex+0x86>
    memmove(name, s, len);
    80002cc8:	2601                	sext.w	a2,a2
    80002cca:	85a6                	mv	a1,s1
    80002ccc:	8556                	mv	a0,s5
    80002cce:	cdcfd0ef          	jal	800001aa <memmove>
    name[len] = 0;
    80002cd2:	9cd6                	add	s9,s9,s5
    80002cd4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002cd8:	84ce                	mv	s1,s3
    80002cda:	bfbd                	j	80002c58 <namex+0x9e>
  if(nameiparent){
    80002cdc:	f20b0be3          	beqz	s6,80002c12 <namex+0x58>
    iput(ip);
    80002ce0:	8552                	mv	a0,s4
    80002ce2:	b4bff0ef          	jal	8000282c <iput>
    return 0;
    80002ce6:	4a01                	li	s4,0
    80002ce8:	b72d                	j	80002c12 <namex+0x58>

0000000080002cea <dirlink>:
{
    80002cea:	7139                	addi	sp,sp,-64
    80002cec:	fc06                	sd	ra,56(sp)
    80002cee:	f822                	sd	s0,48(sp)
    80002cf0:	f04a                	sd	s2,32(sp)
    80002cf2:	ec4e                	sd	s3,24(sp)
    80002cf4:	e852                	sd	s4,16(sp)
    80002cf6:	0080                	addi	s0,sp,64
    80002cf8:	892a                	mv	s2,a0
    80002cfa:	8a2e                	mv	s4,a1
    80002cfc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002cfe:	4601                	li	a2,0
    80002d00:	e1fff0ef          	jal	80002b1e <dirlookup>
    80002d04:	e535                	bnez	a0,80002d70 <dirlink+0x86>
    80002d06:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d08:	04c92483          	lw	s1,76(s2)
    80002d0c:	c48d                	beqz	s1,80002d36 <dirlink+0x4c>
    80002d0e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d10:	4741                	li	a4,16
    80002d12:	86a6                	mv	a3,s1
    80002d14:	fc040613          	addi	a2,s0,-64
    80002d18:	4581                	li	a1,0
    80002d1a:	854a                	mv	a0,s2
    80002d1c:	be3ff0ef          	jal	800028fe <readi>
    80002d20:	47c1                	li	a5,16
    80002d22:	04f51b63          	bne	a0,a5,80002d78 <dirlink+0x8e>
    if(de.inum == 0)
    80002d26:	fc045783          	lhu	a5,-64(s0)
    80002d2a:	c791                	beqz	a5,80002d36 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d2c:	24c1                	addiw	s1,s1,16
    80002d2e:	04c92783          	lw	a5,76(s2)
    80002d32:	fcf4efe3          	bltu	s1,a5,80002d10 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002d36:	4639                	li	a2,14
    80002d38:	85d2                	mv	a1,s4
    80002d3a:	fc240513          	addi	a0,s0,-62
    80002d3e:	d12fd0ef          	jal	80000250 <strncpy>
  de.inum = inum;
    80002d42:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d46:	4741                	li	a4,16
    80002d48:	86a6                	mv	a3,s1
    80002d4a:	fc040613          	addi	a2,s0,-64
    80002d4e:	4581                	li	a1,0
    80002d50:	854a                	mv	a0,s2
    80002d52:	ca9ff0ef          	jal	800029fa <writei>
    80002d56:	1541                	addi	a0,a0,-16
    80002d58:	00a03533          	snez	a0,a0
    80002d5c:	40a00533          	neg	a0,a0
    80002d60:	74a2                	ld	s1,40(sp)
}
    80002d62:	70e2                	ld	ra,56(sp)
    80002d64:	7442                	ld	s0,48(sp)
    80002d66:	7902                	ld	s2,32(sp)
    80002d68:	69e2                	ld	s3,24(sp)
    80002d6a:	6a42                	ld	s4,16(sp)
    80002d6c:	6121                	addi	sp,sp,64
    80002d6e:	8082                	ret
    iput(ip);
    80002d70:	abdff0ef          	jal	8000282c <iput>
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	b7f5                	j	80002d62 <dirlink+0x78>
      panic("dirlink read");
    80002d78:	00004517          	auipc	a0,0x4
    80002d7c:	79050513          	addi	a0,a0,1936 # 80007508 <etext+0x508>
    80002d80:	6e2020ef          	jal	80005462 <panic>

0000000080002d84 <namei>:

struct inode*
namei(char *path)
{
    80002d84:	1101                	addi	sp,sp,-32
    80002d86:	ec06                	sd	ra,24(sp)
    80002d88:	e822                	sd	s0,16(sp)
    80002d8a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002d8c:	fe040613          	addi	a2,s0,-32
    80002d90:	4581                	li	a1,0
    80002d92:	e29ff0ef          	jal	80002bba <namex>
}
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret

0000000080002d9e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002d9e:	1141                	addi	sp,sp,-16
    80002da0:	e406                	sd	ra,8(sp)
    80002da2:	e022                	sd	s0,0(sp)
    80002da4:	0800                	addi	s0,sp,16
    80002da6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002da8:	4585                	li	a1,1
    80002daa:	e11ff0ef          	jal	80002bba <namex>
}
    80002dae:	60a2                	ld	ra,8(sp)
    80002db0:	6402                	ld	s0,0(sp)
    80002db2:	0141                	addi	sp,sp,16
    80002db4:	8082                	ret

0000000080002db6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	e04a                	sd	s2,0(sp)
    80002dc0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002dc2:	00017917          	auipc	s2,0x17
    80002dc6:	4ce90913          	addi	s2,s2,1230 # 8001a290 <log>
    80002dca:	01892583          	lw	a1,24(s2)
    80002dce:	02892503          	lw	a0,40(s2)
    80002dd2:	9a0ff0ef          	jal	80001f72 <bread>
    80002dd6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002dd8:	02c92603          	lw	a2,44(s2)
    80002ddc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002dde:	00c05f63          	blez	a2,80002dfc <write_head+0x46>
    80002de2:	00017717          	auipc	a4,0x17
    80002de6:	4de70713          	addi	a4,a4,1246 # 8001a2c0 <log+0x30>
    80002dea:	87aa                	mv	a5,a0
    80002dec:	060a                	slli	a2,a2,0x2
    80002dee:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002df0:	4314                	lw	a3,0(a4)
    80002df2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002df4:	0711                	addi	a4,a4,4
    80002df6:	0791                	addi	a5,a5,4
    80002df8:	fec79ce3          	bne	a5,a2,80002df0 <write_head+0x3a>
  }
  bwrite(buf);
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	a4aff0ef          	jal	80002048 <bwrite>
  brelse(buf);
    80002e02:	8526                	mv	a0,s1
    80002e04:	a76ff0ef          	jal	8000207a <brelse>
}
    80002e08:	60e2                	ld	ra,24(sp)
    80002e0a:	6442                	ld	s0,16(sp)
    80002e0c:	64a2                	ld	s1,8(sp)
    80002e0e:	6902                	ld	s2,0(sp)
    80002e10:	6105                	addi	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e14:	00017797          	auipc	a5,0x17
    80002e18:	4a87a783          	lw	a5,1192(a5) # 8001a2bc <log+0x2c>
    80002e1c:	08f05f63          	blez	a5,80002eba <install_trans+0xa6>
{
    80002e20:	7139                	addi	sp,sp,-64
    80002e22:	fc06                	sd	ra,56(sp)
    80002e24:	f822                	sd	s0,48(sp)
    80002e26:	f426                	sd	s1,40(sp)
    80002e28:	f04a                	sd	s2,32(sp)
    80002e2a:	ec4e                	sd	s3,24(sp)
    80002e2c:	e852                	sd	s4,16(sp)
    80002e2e:	e456                	sd	s5,8(sp)
    80002e30:	e05a                	sd	s6,0(sp)
    80002e32:	0080                	addi	s0,sp,64
    80002e34:	8b2a                	mv	s6,a0
    80002e36:	00017a97          	auipc	s5,0x17
    80002e3a:	48aa8a93          	addi	s5,s5,1162 # 8001a2c0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e3e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002e40:	00017997          	auipc	s3,0x17
    80002e44:	45098993          	addi	s3,s3,1104 # 8001a290 <log>
    80002e48:	a829                	j	80002e62 <install_trans+0x4e>
    brelse(lbuf);
    80002e4a:	854a                	mv	a0,s2
    80002e4c:	a2eff0ef          	jal	8000207a <brelse>
    brelse(dbuf);
    80002e50:	8526                	mv	a0,s1
    80002e52:	a28ff0ef          	jal	8000207a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e56:	2a05                	addiw	s4,s4,1
    80002e58:	0a91                	addi	s5,s5,4
    80002e5a:	02c9a783          	lw	a5,44(s3)
    80002e5e:	04fa5463          	bge	s4,a5,80002ea6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002e62:	0189a583          	lw	a1,24(s3)
    80002e66:	014585bb          	addw	a1,a1,s4
    80002e6a:	2585                	addiw	a1,a1,1
    80002e6c:	0289a503          	lw	a0,40(s3)
    80002e70:	902ff0ef          	jal	80001f72 <bread>
    80002e74:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002e76:	000aa583          	lw	a1,0(s5)
    80002e7a:	0289a503          	lw	a0,40(s3)
    80002e7e:	8f4ff0ef          	jal	80001f72 <bread>
    80002e82:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002e84:	40000613          	li	a2,1024
    80002e88:	05890593          	addi	a1,s2,88
    80002e8c:	05850513          	addi	a0,a0,88
    80002e90:	b1afd0ef          	jal	800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80002e94:	8526                	mv	a0,s1
    80002e96:	9b2ff0ef          	jal	80002048 <bwrite>
    if(recovering == 0)
    80002e9a:	fa0b18e3          	bnez	s6,80002e4a <install_trans+0x36>
      bunpin(dbuf);
    80002e9e:	8526                	mv	a0,s1
    80002ea0:	a96ff0ef          	jal	80002136 <bunpin>
    80002ea4:	b75d                	j	80002e4a <install_trans+0x36>
}
    80002ea6:	70e2                	ld	ra,56(sp)
    80002ea8:	7442                	ld	s0,48(sp)
    80002eaa:	74a2                	ld	s1,40(sp)
    80002eac:	7902                	ld	s2,32(sp)
    80002eae:	69e2                	ld	s3,24(sp)
    80002eb0:	6a42                	ld	s4,16(sp)
    80002eb2:	6aa2                	ld	s5,8(sp)
    80002eb4:	6b02                	ld	s6,0(sp)
    80002eb6:	6121                	addi	sp,sp,64
    80002eb8:	8082                	ret
    80002eba:	8082                	ret

0000000080002ebc <initlog>:
{
    80002ebc:	7179                	addi	sp,sp,-48
    80002ebe:	f406                	sd	ra,40(sp)
    80002ec0:	f022                	sd	s0,32(sp)
    80002ec2:	ec26                	sd	s1,24(sp)
    80002ec4:	e84a                	sd	s2,16(sp)
    80002ec6:	e44e                	sd	s3,8(sp)
    80002ec8:	1800                	addi	s0,sp,48
    80002eca:	892a                	mv	s2,a0
    80002ecc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002ece:	00017497          	auipc	s1,0x17
    80002ed2:	3c248493          	addi	s1,s1,962 # 8001a290 <log>
    80002ed6:	00004597          	auipc	a1,0x4
    80002eda:	64258593          	addi	a1,a1,1602 # 80007518 <etext+0x518>
    80002ede:	8526                	mv	a0,s1
    80002ee0:	031020ef          	jal	80005710 <initlock>
  log.start = sb->logstart;
    80002ee4:	0149a583          	lw	a1,20(s3)
    80002ee8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002eea:	0109a783          	lw	a5,16(s3)
    80002eee:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002ef0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002ef4:	854a                	mv	a0,s2
    80002ef6:	87cff0ef          	jal	80001f72 <bread>
  log.lh.n = lh->n;
    80002efa:	4d30                	lw	a2,88(a0)
    80002efc:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002efe:	00c05f63          	blez	a2,80002f1c <initlog+0x60>
    80002f02:	87aa                	mv	a5,a0
    80002f04:	00017717          	auipc	a4,0x17
    80002f08:	3bc70713          	addi	a4,a4,956 # 8001a2c0 <log+0x30>
    80002f0c:	060a                	slli	a2,a2,0x2
    80002f0e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80002f10:	4ff4                	lw	a3,92(a5)
    80002f12:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002f14:	0791                	addi	a5,a5,4
    80002f16:	0711                	addi	a4,a4,4
    80002f18:	fec79ce3          	bne	a5,a2,80002f10 <initlog+0x54>
  brelse(buf);
    80002f1c:	95eff0ef          	jal	8000207a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002f20:	4505                	li	a0,1
    80002f22:	ef3ff0ef          	jal	80002e14 <install_trans>
  log.lh.n = 0;
    80002f26:	00017797          	auipc	a5,0x17
    80002f2a:	3807ab23          	sw	zero,918(a5) # 8001a2bc <log+0x2c>
  write_head(); // clear the log
    80002f2e:	e89ff0ef          	jal	80002db6 <write_head>
}
    80002f32:	70a2                	ld	ra,40(sp)
    80002f34:	7402                	ld	s0,32(sp)
    80002f36:	64e2                	ld	s1,24(sp)
    80002f38:	6942                	ld	s2,16(sp)
    80002f3a:	69a2                	ld	s3,8(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret

0000000080002f40 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	e04a                	sd	s2,0(sp)
    80002f4a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002f4c:	00017517          	auipc	a0,0x17
    80002f50:	34450513          	addi	a0,a0,836 # 8001a290 <log>
    80002f54:	03d020ef          	jal	80005790 <acquire>
  while(1){
    if(log.committing){
    80002f58:	00017497          	auipc	s1,0x17
    80002f5c:	33848493          	addi	s1,s1,824 # 8001a290 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002f60:	4979                	li	s2,30
    80002f62:	a029                	j	80002f6c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80002f64:	85a6                	mv	a1,s1
    80002f66:	8526                	mv	a0,s1
    80002f68:	bccfe0ef          	jal	80001334 <sleep>
    if(log.committing){
    80002f6c:	50dc                	lw	a5,36(s1)
    80002f6e:	fbfd                	bnez	a5,80002f64 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002f70:	5098                	lw	a4,32(s1)
    80002f72:	2705                	addiw	a4,a4,1
    80002f74:	0027179b          	slliw	a5,a4,0x2
    80002f78:	9fb9                	addw	a5,a5,a4
    80002f7a:	0017979b          	slliw	a5,a5,0x1
    80002f7e:	54d4                	lw	a3,44(s1)
    80002f80:	9fb5                	addw	a5,a5,a3
    80002f82:	00f95763          	bge	s2,a5,80002f90 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80002f86:	85a6                	mv	a1,s1
    80002f88:	8526                	mv	a0,s1
    80002f8a:	baafe0ef          	jal	80001334 <sleep>
    80002f8e:	bff9                	j	80002f6c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80002f90:	00017517          	auipc	a0,0x17
    80002f94:	30050513          	addi	a0,a0,768 # 8001a290 <log>
    80002f98:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80002f9a:	08f020ef          	jal	80005828 <release>
      break;
    }
  }
}
    80002f9e:	60e2                	ld	ra,24(sp)
    80002fa0:	6442                	ld	s0,16(sp)
    80002fa2:	64a2                	ld	s1,8(sp)
    80002fa4:	6902                	ld	s2,0(sp)
    80002fa6:	6105                	addi	sp,sp,32
    80002fa8:	8082                	ret

0000000080002faa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80002faa:	7139                	addi	sp,sp,-64
    80002fac:	fc06                	sd	ra,56(sp)
    80002fae:	f822                	sd	s0,48(sp)
    80002fb0:	f426                	sd	s1,40(sp)
    80002fb2:	f04a                	sd	s2,32(sp)
    80002fb4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80002fb6:	00017497          	auipc	s1,0x17
    80002fba:	2da48493          	addi	s1,s1,730 # 8001a290 <log>
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	7d0020ef          	jal	80005790 <acquire>
  log.outstanding -= 1;
    80002fc4:	509c                	lw	a5,32(s1)
    80002fc6:	37fd                	addiw	a5,a5,-1
    80002fc8:	0007891b          	sext.w	s2,a5
    80002fcc:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80002fce:	50dc                	lw	a5,36(s1)
    80002fd0:	ef9d                	bnez	a5,8000300e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80002fd2:	04091763          	bnez	s2,80003020 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80002fd6:	00017497          	auipc	s1,0x17
    80002fda:	2ba48493          	addi	s1,s1,698 # 8001a290 <log>
    80002fde:	4785                	li	a5,1
    80002fe0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80002fe2:	8526                	mv	a0,s1
    80002fe4:	045020ef          	jal	80005828 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80002fe8:	54dc                	lw	a5,44(s1)
    80002fea:	04f04b63          	bgtz	a5,80003040 <end_op+0x96>
    acquire(&log.lock);
    80002fee:	00017497          	auipc	s1,0x17
    80002ff2:	2a248493          	addi	s1,s1,674 # 8001a290 <log>
    80002ff6:	8526                	mv	a0,s1
    80002ff8:	798020ef          	jal	80005790 <acquire>
    log.committing = 0;
    80002ffc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003000:	8526                	mv	a0,s1
    80003002:	b7efe0ef          	jal	80001380 <wakeup>
    release(&log.lock);
    80003006:	8526                	mv	a0,s1
    80003008:	021020ef          	jal	80005828 <release>
}
    8000300c:	a025                	j	80003034 <end_op+0x8a>
    8000300e:	ec4e                	sd	s3,24(sp)
    80003010:	e852                	sd	s4,16(sp)
    80003012:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003014:	00004517          	auipc	a0,0x4
    80003018:	50c50513          	addi	a0,a0,1292 # 80007520 <etext+0x520>
    8000301c:	446020ef          	jal	80005462 <panic>
    wakeup(&log);
    80003020:	00017497          	auipc	s1,0x17
    80003024:	27048493          	addi	s1,s1,624 # 8001a290 <log>
    80003028:	8526                	mv	a0,s1
    8000302a:	b56fe0ef          	jal	80001380 <wakeup>
  release(&log.lock);
    8000302e:	8526                	mv	a0,s1
    80003030:	7f8020ef          	jal	80005828 <release>
}
    80003034:	70e2                	ld	ra,56(sp)
    80003036:	7442                	ld	s0,48(sp)
    80003038:	74a2                	ld	s1,40(sp)
    8000303a:	7902                	ld	s2,32(sp)
    8000303c:	6121                	addi	sp,sp,64
    8000303e:	8082                	ret
    80003040:	ec4e                	sd	s3,24(sp)
    80003042:	e852                	sd	s4,16(sp)
    80003044:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003046:	00017a97          	auipc	s5,0x17
    8000304a:	27aa8a93          	addi	s5,s5,634 # 8001a2c0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000304e:	00017a17          	auipc	s4,0x17
    80003052:	242a0a13          	addi	s4,s4,578 # 8001a290 <log>
    80003056:	018a2583          	lw	a1,24(s4)
    8000305a:	012585bb          	addw	a1,a1,s2
    8000305e:	2585                	addiw	a1,a1,1
    80003060:	028a2503          	lw	a0,40(s4)
    80003064:	f0ffe0ef          	jal	80001f72 <bread>
    80003068:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000306a:	000aa583          	lw	a1,0(s5)
    8000306e:	028a2503          	lw	a0,40(s4)
    80003072:	f01fe0ef          	jal	80001f72 <bread>
    80003076:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003078:	40000613          	li	a2,1024
    8000307c:	05850593          	addi	a1,a0,88
    80003080:	05848513          	addi	a0,s1,88
    80003084:	926fd0ef          	jal	800001aa <memmove>
    bwrite(to);  // write the log
    80003088:	8526                	mv	a0,s1
    8000308a:	fbffe0ef          	jal	80002048 <bwrite>
    brelse(from);
    8000308e:	854e                	mv	a0,s3
    80003090:	febfe0ef          	jal	8000207a <brelse>
    brelse(to);
    80003094:	8526                	mv	a0,s1
    80003096:	fe5fe0ef          	jal	8000207a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000309a:	2905                	addiw	s2,s2,1
    8000309c:	0a91                	addi	s5,s5,4
    8000309e:	02ca2783          	lw	a5,44(s4)
    800030a2:	faf94ae3          	blt	s2,a5,80003056 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800030a6:	d11ff0ef          	jal	80002db6 <write_head>
    install_trans(0); // Now install writes to home locations
    800030aa:	4501                	li	a0,0
    800030ac:	d69ff0ef          	jal	80002e14 <install_trans>
    log.lh.n = 0;
    800030b0:	00017797          	auipc	a5,0x17
    800030b4:	2007a623          	sw	zero,524(a5) # 8001a2bc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800030b8:	cffff0ef          	jal	80002db6 <write_head>
    800030bc:	69e2                	ld	s3,24(sp)
    800030be:	6a42                	ld	s4,16(sp)
    800030c0:	6aa2                	ld	s5,8(sp)
    800030c2:	b735                	j	80002fee <end_op+0x44>

00000000800030c4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	e426                	sd	s1,8(sp)
    800030cc:	e04a                	sd	s2,0(sp)
    800030ce:	1000                	addi	s0,sp,32
    800030d0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800030d2:	00017917          	auipc	s2,0x17
    800030d6:	1be90913          	addi	s2,s2,446 # 8001a290 <log>
    800030da:	854a                	mv	a0,s2
    800030dc:	6b4020ef          	jal	80005790 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800030e0:	02c92603          	lw	a2,44(s2)
    800030e4:	47f5                	li	a5,29
    800030e6:	06c7c363          	blt	a5,a2,8000314c <log_write+0x88>
    800030ea:	00017797          	auipc	a5,0x17
    800030ee:	1c27a783          	lw	a5,450(a5) # 8001a2ac <log+0x1c>
    800030f2:	37fd                	addiw	a5,a5,-1
    800030f4:	04f65c63          	bge	a2,a5,8000314c <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800030f8:	00017797          	auipc	a5,0x17
    800030fc:	1b87a783          	lw	a5,440(a5) # 8001a2b0 <log+0x20>
    80003100:	04f05c63          	blez	a5,80003158 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003104:	4781                	li	a5,0
    80003106:	04c05f63          	blez	a2,80003164 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000310a:	44cc                	lw	a1,12(s1)
    8000310c:	00017717          	auipc	a4,0x17
    80003110:	1b470713          	addi	a4,a4,436 # 8001a2c0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003114:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003116:	4314                	lw	a3,0(a4)
    80003118:	04b68663          	beq	a3,a1,80003164 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000311c:	2785                	addiw	a5,a5,1
    8000311e:	0711                	addi	a4,a4,4
    80003120:	fef61be3          	bne	a2,a5,80003116 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003124:	0621                	addi	a2,a2,8
    80003126:	060a                	slli	a2,a2,0x2
    80003128:	00017797          	auipc	a5,0x17
    8000312c:	16878793          	addi	a5,a5,360 # 8001a290 <log>
    80003130:	97b2                	add	a5,a5,a2
    80003132:	44d8                	lw	a4,12(s1)
    80003134:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003136:	8526                	mv	a0,s1
    80003138:	fcbfe0ef          	jal	80002102 <bpin>
    log.lh.n++;
    8000313c:	00017717          	auipc	a4,0x17
    80003140:	15470713          	addi	a4,a4,340 # 8001a290 <log>
    80003144:	575c                	lw	a5,44(a4)
    80003146:	2785                	addiw	a5,a5,1
    80003148:	d75c                	sw	a5,44(a4)
    8000314a:	a80d                	j	8000317c <log_write+0xb8>
    panic("too big a transaction");
    8000314c:	00004517          	auipc	a0,0x4
    80003150:	3e450513          	addi	a0,a0,996 # 80007530 <etext+0x530>
    80003154:	30e020ef          	jal	80005462 <panic>
    panic("log_write outside of trans");
    80003158:	00004517          	auipc	a0,0x4
    8000315c:	3f050513          	addi	a0,a0,1008 # 80007548 <etext+0x548>
    80003160:	302020ef          	jal	80005462 <panic>
  log.lh.block[i] = b->blockno;
    80003164:	00878693          	addi	a3,a5,8
    80003168:	068a                	slli	a3,a3,0x2
    8000316a:	00017717          	auipc	a4,0x17
    8000316e:	12670713          	addi	a4,a4,294 # 8001a290 <log>
    80003172:	9736                	add	a4,a4,a3
    80003174:	44d4                	lw	a3,12(s1)
    80003176:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003178:	faf60fe3          	beq	a2,a5,80003136 <log_write+0x72>
  }
  release(&log.lock);
    8000317c:	00017517          	auipc	a0,0x17
    80003180:	11450513          	addi	a0,a0,276 # 8001a290 <log>
    80003184:	6a4020ef          	jal	80005828 <release>
}
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	64a2                	ld	s1,8(sp)
    8000318e:	6902                	ld	s2,0(sp)
    80003190:	6105                	addi	sp,sp,32
    80003192:	8082                	ret

0000000080003194 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003194:	1101                	addi	sp,sp,-32
    80003196:	ec06                	sd	ra,24(sp)
    80003198:	e822                	sd	s0,16(sp)
    8000319a:	e426                	sd	s1,8(sp)
    8000319c:	e04a                	sd	s2,0(sp)
    8000319e:	1000                	addi	s0,sp,32
    800031a0:	84aa                	mv	s1,a0
    800031a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800031a4:	00004597          	auipc	a1,0x4
    800031a8:	3c458593          	addi	a1,a1,964 # 80007568 <etext+0x568>
    800031ac:	0521                	addi	a0,a0,8
    800031ae:	562020ef          	jal	80005710 <initlock>
  lk->name = name;
    800031b2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800031b6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800031ba:	0204a423          	sw	zero,40(s1)
}
    800031be:	60e2                	ld	ra,24(sp)
    800031c0:	6442                	ld	s0,16(sp)
    800031c2:	64a2                	ld	s1,8(sp)
    800031c4:	6902                	ld	s2,0(sp)
    800031c6:	6105                	addi	sp,sp,32
    800031c8:	8082                	ret

00000000800031ca <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800031ca:	1101                	addi	sp,sp,-32
    800031cc:	ec06                	sd	ra,24(sp)
    800031ce:	e822                	sd	s0,16(sp)
    800031d0:	e426                	sd	s1,8(sp)
    800031d2:	e04a                	sd	s2,0(sp)
    800031d4:	1000                	addi	s0,sp,32
    800031d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800031d8:	00850913          	addi	s2,a0,8
    800031dc:	854a                	mv	a0,s2
    800031de:	5b2020ef          	jal	80005790 <acquire>
  while (lk->locked) {
    800031e2:	409c                	lw	a5,0(s1)
    800031e4:	c799                	beqz	a5,800031f2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800031e6:	85ca                	mv	a1,s2
    800031e8:	8526                	mv	a0,s1
    800031ea:	94afe0ef          	jal	80001334 <sleep>
  while (lk->locked) {
    800031ee:	409c                	lw	a5,0(s1)
    800031f0:	fbfd                	bnez	a5,800031e6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800031f2:	4785                	li	a5,1
    800031f4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800031f6:	b71fd0ef          	jal	80000d66 <myproc>
    800031fa:	591c                	lw	a5,48(a0)
    800031fc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800031fe:	854a                	mv	a0,s2
    80003200:	628020ef          	jal	80005828 <release>
}
    80003204:	60e2                	ld	ra,24(sp)
    80003206:	6442                	ld	s0,16(sp)
    80003208:	64a2                	ld	s1,8(sp)
    8000320a:	6902                	ld	s2,0(sp)
    8000320c:	6105                	addi	sp,sp,32
    8000320e:	8082                	ret

0000000080003210 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	e426                	sd	s1,8(sp)
    80003218:	e04a                	sd	s2,0(sp)
    8000321a:	1000                	addi	s0,sp,32
    8000321c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000321e:	00850913          	addi	s2,a0,8
    80003222:	854a                	mv	a0,s2
    80003224:	56c020ef          	jal	80005790 <acquire>
  lk->locked = 0;
    80003228:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000322c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003230:	8526                	mv	a0,s1
    80003232:	94efe0ef          	jal	80001380 <wakeup>
  release(&lk->lk);
    80003236:	854a                	mv	a0,s2
    80003238:	5f0020ef          	jal	80005828 <release>
}
    8000323c:	60e2                	ld	ra,24(sp)
    8000323e:	6442                	ld	s0,16(sp)
    80003240:	64a2                	ld	s1,8(sp)
    80003242:	6902                	ld	s2,0(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret

0000000080003248 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003248:	7179                	addi	sp,sp,-48
    8000324a:	f406                	sd	ra,40(sp)
    8000324c:	f022                	sd	s0,32(sp)
    8000324e:	ec26                	sd	s1,24(sp)
    80003250:	e84a                	sd	s2,16(sp)
    80003252:	1800                	addi	s0,sp,48
    80003254:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003256:	00850913          	addi	s2,a0,8
    8000325a:	854a                	mv	a0,s2
    8000325c:	534020ef          	jal	80005790 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003260:	409c                	lw	a5,0(s1)
    80003262:	ef81                	bnez	a5,8000327a <holdingsleep+0x32>
    80003264:	4481                	li	s1,0
  release(&lk->lk);
    80003266:	854a                	mv	a0,s2
    80003268:	5c0020ef          	jal	80005828 <release>
  return r;
}
    8000326c:	8526                	mv	a0,s1
    8000326e:	70a2                	ld	ra,40(sp)
    80003270:	7402                	ld	s0,32(sp)
    80003272:	64e2                	ld	s1,24(sp)
    80003274:	6942                	ld	s2,16(sp)
    80003276:	6145                	addi	sp,sp,48
    80003278:	8082                	ret
    8000327a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000327c:	0284a983          	lw	s3,40(s1)
    80003280:	ae7fd0ef          	jal	80000d66 <myproc>
    80003284:	5904                	lw	s1,48(a0)
    80003286:	413484b3          	sub	s1,s1,s3
    8000328a:	0014b493          	seqz	s1,s1
    8000328e:	69a2                	ld	s3,8(sp)
    80003290:	bfd9                	j	80003266 <holdingsleep+0x1e>

0000000080003292 <fileinit>:
} ftable;

// initialize file table 
void
fileinit(void)
{
    80003292:	1141                	addi	sp,sp,-16
    80003294:	e406                	sd	ra,8(sp)
    80003296:	e022                	sd	s0,0(sp)
    80003298:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable"); //Initialize spinlock lock for ftable to synchronize access to file table.
    8000329a:	00004597          	auipc	a1,0x4
    8000329e:	2de58593          	addi	a1,a1,734 # 80007578 <etext+0x578>
    800032a2:	00017517          	auipc	a0,0x17
    800032a6:	13650513          	addi	a0,a0,310 # 8001a3d8 <ftable>
    800032aa:	466020ef          	jal	80005710 <initlock>
}
    800032ae:	60a2                	ld	ra,8(sp)
    800032b0:	6402                	ld	s0,0(sp)
    800032b2:	0141                	addi	sp,sp,16
    800032b4:	8082                	ret

00000000800032b6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800032c0:	00017517          	auipc	a0,0x17
    800032c4:	11850513          	addi	a0,a0,280 # 8001a3d8 <ftable>
    800032c8:	4c8020ef          	jal	80005790 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800032cc:	00017497          	auipc	s1,0x17
    800032d0:	12448493          	addi	s1,s1,292 # 8001a3f0 <ftable+0x18>
    800032d4:	00018717          	auipc	a4,0x18
    800032d8:	0bc70713          	addi	a4,a4,188 # 8001b390 <disk>
    //find file structure that are not used
    if(f->ref == 0){
    800032dc:	40dc                	lw	a5,4(s1)
    800032de:	cf89                	beqz	a5,800032f8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800032e0:	02848493          	addi	s1,s1,40
    800032e4:	fee49ce3          	bne	s1,a4,800032dc <filealloc+0x26>
      f->ref = 1; // mark that it has been used 
      release(&ftable.lock); // unlock
      return f;
    }
  }
  release(&ftable.lock); //unlock afer finding
    800032e8:	00017517          	auipc	a0,0x17
    800032ec:	0f050513          	addi	a0,a0,240 # 8001a3d8 <ftable>
    800032f0:	538020ef          	jal	80005828 <release>
  return 0;
    800032f4:	4481                	li	s1,0
    800032f6:	a809                	j	80003308 <filealloc+0x52>
      f->ref = 1; // mark that it has been used 
    800032f8:	4785                	li	a5,1
    800032fa:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock); // unlock
    800032fc:	00017517          	auipc	a0,0x17
    80003300:	0dc50513          	addi	a0,a0,220 # 8001a3d8 <ftable>
    80003304:	524020ef          	jal	80005828 <release>
}
    80003308:	8526                	mv	a0,s1
    8000330a:	60e2                	ld	ra,24(sp)
    8000330c:	6442                	ld	s0,16(sp)
    8000330e:	64a2                	ld	s1,8(sp)
    80003310:	6105                	addi	sp,sp,32
    80003312:	8082                	ret

0000000080003314 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003314:	1101                	addi	sp,sp,-32
    80003316:	ec06                	sd	ra,24(sp)
    80003318:	e822                	sd	s0,16(sp)
    8000331a:	e426                	sd	s1,8(sp)
    8000331c:	1000                	addi	s0,sp,32
    8000331e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003320:	00017517          	auipc	a0,0x17
    80003324:	0b850513          	addi	a0,a0,184 # 8001a3d8 <ftable>
    80003328:	468020ef          	jal	80005790 <acquire>
  if(f->ref < 1)
    8000332c:	40dc                	lw	a5,4(s1)
    8000332e:	02f05063          	blez	a5,8000334e <filedup+0x3a>
    panic("filedup"); // panic cannot duplicate because it isnot used
  f->ref++; //duplicate
    80003332:	2785                	addiw	a5,a5,1
    80003334:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003336:	00017517          	auipc	a0,0x17
    8000333a:	0a250513          	addi	a0,a0,162 # 8001a3d8 <ftable>
    8000333e:	4ea020ef          	jal	80005828 <release>
  return f;
}
    80003342:	8526                	mv	a0,s1
    80003344:	60e2                	ld	ra,24(sp)
    80003346:	6442                	ld	s0,16(sp)
    80003348:	64a2                	ld	s1,8(sp)
    8000334a:	6105                	addi	sp,sp,32
    8000334c:	8082                	ret
    panic("filedup"); // panic cannot duplicate because it isnot used
    8000334e:	00004517          	auipc	a0,0x4
    80003352:	23250513          	addi	a0,a0,562 # 80007580 <etext+0x580>
    80003356:	10c020ef          	jal	80005462 <panic>

000000008000335a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.) and release.
void
fileclose(struct file *f)
{
    8000335a:	7139                	addi	sp,sp,-64
    8000335c:	fc06                	sd	ra,56(sp)
    8000335e:	f822                	sd	s0,48(sp)
    80003360:	f426                	sd	s1,40(sp)
    80003362:	0080                	addi	s0,sp,64
    80003364:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003366:	00017517          	auipc	a0,0x17
    8000336a:	07250513          	addi	a0,a0,114 # 8001a3d8 <ftable>
    8000336e:	422020ef          	jal	80005790 <acquire>
  if(f->ref < 1)
    80003372:	40dc                	lw	a5,4(s1)
    80003374:	04f05a63          	blez	a5,800033c8 <fileclose+0x6e>
    panic("fileclose"); // panic cannot close because it is not used
  // release 1 duplicate
  if(--f->ref > 0){
    80003378:	37fd                	addiw	a5,a5,-1
    8000337a:	0007871b          	sext.w	a4,a5
    8000337e:	c0dc                	sw	a5,4(s1)
    80003380:	04e04e63          	bgtz	a4,800033dc <fileclose+0x82>
    80003384:	f04a                	sd	s2,32(sp)
    80003386:	ec4e                	sd	s3,24(sp)
    80003388:	e852                	sd	s4,16(sp)
    8000338a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  //if ref = 0 close file.
  ff = *f;
    8000338c:	0004a903          	lw	s2,0(s1)
    80003390:	0094ca83          	lbu	s5,9(s1)
    80003394:	0104ba03          	ld	s4,16(s1)
    80003398:	0184b983          	ld	s3,24(s1)
  //reset member
  f->ref = 0;
    8000339c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800033a0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800033a4:	00017517          	auipc	a0,0x17
    800033a8:	03450513          	addi	a0,a0,52 # 8001a3d8 <ftable>
    800033ac:	47c020ef          	jal	80005828 <release>

  //close pipe if open pipe
  if(ff.type == FD_PIPE){
    800033b0:	4785                	li	a5,1
    800033b2:	04f90063          	beq	s2,a5,800033f2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800033b6:	3979                	addiw	s2,s2,-2
    800033b8:	4785                	li	a5,1
    800033ba:	0527f563          	bgeu	a5,s2,80003404 <fileclose+0xaa>
    800033be:	7902                	ld	s2,32(sp)
    800033c0:	69e2                	ld	s3,24(sp)
    800033c2:	6a42                	ld	s4,16(sp)
    800033c4:	6aa2                	ld	s5,8(sp)
    800033c6:	a00d                	j	800033e8 <fileclose+0x8e>
    800033c8:	f04a                	sd	s2,32(sp)
    800033ca:	ec4e                	sd	s3,24(sp)
    800033cc:	e852                	sd	s4,16(sp)
    800033ce:	e456                	sd	s5,8(sp)
    panic("fileclose"); // panic cannot close because it is not used
    800033d0:	00004517          	auipc	a0,0x4
    800033d4:	1b850513          	addi	a0,a0,440 # 80007588 <etext+0x588>
    800033d8:	08a020ef          	jal	80005462 <panic>
    release(&ftable.lock);
    800033dc:	00017517          	auipc	a0,0x17
    800033e0:	ffc50513          	addi	a0,a0,-4 # 8001a3d8 <ftable>
    800033e4:	444020ef          	jal	80005828 <release>
    begin_op();
    iput(ff.ip); //release
    end_op();
  }
}
    800033e8:	70e2                	ld	ra,56(sp)
    800033ea:	7442                	ld	s0,48(sp)
    800033ec:	74a2                	ld	s1,40(sp)
    800033ee:	6121                	addi	sp,sp,64
    800033f0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800033f2:	85d6                	mv	a1,s5
    800033f4:	8552                	mv	a0,s4
    800033f6:	336000ef          	jal	8000372c <pipeclose>
    800033fa:	7902                	ld	s2,32(sp)
    800033fc:	69e2                	ld	s3,24(sp)
    800033fe:	6a42                	ld	s4,16(sp)
    80003400:	6aa2                	ld	s5,8(sp)
    80003402:	b7dd                	j	800033e8 <fileclose+0x8e>
    begin_op();
    80003404:	b3dff0ef          	jal	80002f40 <begin_op>
    iput(ff.ip); //release
    80003408:	854e                	mv	a0,s3
    8000340a:	c22ff0ef          	jal	8000282c <iput>
    end_op();
    8000340e:	b9dff0ef          	jal	80002faa <end_op>
    80003412:	7902                	ld	s2,32(sp)
    80003414:	69e2                	ld	s3,24(sp)
    80003416:	6a42                	ld	s4,16(sp)
    80003418:	6aa2                	ld	s5,8(sp)
    8000341a:	b7f9                	j	800033e8 <fileclose+0x8e>

000000008000341c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000341c:	715d                	addi	sp,sp,-80
    8000341e:	e486                	sd	ra,72(sp)
    80003420:	e0a2                	sd	s0,64(sp)
    80003422:	fc26                	sd	s1,56(sp)
    80003424:	f44e                	sd	s3,40(sp)
    80003426:	0880                	addi	s0,sp,80
    80003428:	84aa                	mv	s1,a0
    8000342a:	89ae                	mv	s3,a1
  struct proc *p = myproc(); //process structure
    8000342c:	93bfd0ef          	jal	80000d66 <myproc>
  struct stat st; // static structure
  
  //get the metadata if the type is inode or device
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003430:	409c                	lw	a5,0(s1)
    80003432:	37f9                	addiw	a5,a5,-2
    80003434:	4705                	li	a4,1
    80003436:	04f76063          	bltu	a4,a5,80003476 <filestat+0x5a>
    8000343a:	f84a                	sd	s2,48(sp)
    8000343c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000343e:	6c88                	ld	a0,24(s1)
    80003440:	a6aff0ef          	jal	800026aa <ilock>
    stati(f->ip, &st); //get the data
    80003444:	fb840593          	addi	a1,s0,-72
    80003448:	6c88                	ld	a0,24(s1)
    8000344a:	c8aff0ef          	jal	800028d4 <stati>
    iunlock(f->ip);
    8000344e:	6c88                	ld	a0,24(s1)
    80003450:	b08ff0ef          	jal	80002758 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0) //Copy the obtained data to the user's memory space
    80003454:	46e1                	li	a3,24
    80003456:	fb840613          	addi	a2,s0,-72
    8000345a:	85ce                	mv	a1,s3
    8000345c:	05093503          	ld	a0,80(s2)
    80003460:	d78fd0ef          	jal	800009d8 <copyout>
    80003464:	41f5551b          	sraiw	a0,a0,0x1f
    80003468:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000346a:	60a6                	ld	ra,72(sp)
    8000346c:	6406                	ld	s0,64(sp)
    8000346e:	74e2                	ld	s1,56(sp)
    80003470:	79a2                	ld	s3,40(sp)
    80003472:	6161                	addi	sp,sp,80
    80003474:	8082                	ret
  return -1;
    80003476:	557d                	li	a0,-1
    80003478:	bfcd                	j	8000346a <filestat+0x4e>

000000008000347a <fileread>:

// Read from file f and copy to address.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000347a:	7179                	addi	sp,sp,-48
    8000347c:	f406                	sd	ra,40(sp)
    8000347e:	f022                	sd	s0,32(sp)
    80003480:	e84a                	sd	s2,16(sp)
    80003482:	1800                	addi	s0,sp,48
  int r = 0;
  // check if file can be read or not
  if(f->readable == 0)
    80003484:	00854783          	lbu	a5,8(a0)
    80003488:	cfd1                	beqz	a5,80003524 <fileread+0xaa>
    8000348a:	ec26                	sd	s1,24(sp)
    8000348c:	e44e                	sd	s3,8(sp)
    8000348e:	84aa                	mv	s1,a0
    80003490:	89ae                	mv	s3,a1
    80003492:	8932                	mv	s2,a2
    return -1;

  //read pipe
  if(f->type == FD_PIPE){
    80003494:	411c                	lw	a5,0(a0)
    80003496:	4705                	li	a4,1
    80003498:	04e78363          	beq	a5,a4,800034de <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  //read device
  } else if(f->type == FD_DEVICE){
    8000349c:	470d                	li	a4,3
    8000349e:	04e78763          	beq	a5,a4,800034ec <fileread+0x72>
    //get the correct device to read from device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  //read inode  
  } else if(f->type == FD_INODE){
    800034a2:	4709                	li	a4,2
    800034a4:	06e79a63          	bne	a5,a4,80003518 <fileread+0x9e>
    ilock(f->ip);
    800034a8:	6d08                	ld	a0,24(a0)
    800034aa:	a00ff0ef          	jal	800026aa <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800034ae:	874a                	mv	a4,s2
    800034b0:	5094                	lw	a3,32(s1)
    800034b2:	864e                	mv	a2,s3
    800034b4:	4585                	li	a1,1
    800034b6:	6c88                	ld	a0,24(s1)
    800034b8:	c46ff0ef          	jal	800028fe <readi>
    800034bc:	892a                	mv	s2,a0
    800034be:	00a05563          	blez	a0,800034c8 <fileread+0x4e>
      f->off += r;
    800034c2:	509c                	lw	a5,32(s1)
    800034c4:	9fa9                	addw	a5,a5,a0
    800034c6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800034c8:	6c88                	ld	a0,24(s1)
    800034ca:	a8eff0ef          	jal	80002758 <iunlock>
    800034ce:	64e2                	ld	s1,24(sp)
    800034d0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800034d2:	854a                	mv	a0,s2
    800034d4:	70a2                	ld	ra,40(sp)
    800034d6:	7402                	ld	s0,32(sp)
    800034d8:	6942                	ld	s2,16(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800034de:	6908                	ld	a0,16(a0)
    800034e0:	388000ef          	jal	80003868 <piperead>
    800034e4:	892a                	mv	s2,a0
    800034e6:	64e2                	ld	s1,24(sp)
    800034e8:	69a2                	ld	s3,8(sp)
    800034ea:	b7e5                	j	800034d2 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800034ec:	02451783          	lh	a5,36(a0)
    800034f0:	03079693          	slli	a3,a5,0x30
    800034f4:	92c1                	srli	a3,a3,0x30
    800034f6:	4725                	li	a4,9
    800034f8:	02d76863          	bltu	a4,a3,80003528 <fileread+0xae>
    800034fc:	0792                	slli	a5,a5,0x4
    800034fe:	00017717          	auipc	a4,0x17
    80003502:	e3a70713          	addi	a4,a4,-454 # 8001a338 <devsw>
    80003506:	97ba                	add	a5,a5,a4
    80003508:	639c                	ld	a5,0(a5)
    8000350a:	c39d                	beqz	a5,80003530 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000350c:	4505                	li	a0,1
    8000350e:	9782                	jalr	a5
    80003510:	892a                	mv	s2,a0
    80003512:	64e2                	ld	s1,24(sp)
    80003514:	69a2                	ld	s3,8(sp)
    80003516:	bf75                	j	800034d2 <fileread+0x58>
    panic("fileread");
    80003518:	00004517          	auipc	a0,0x4
    8000351c:	08050513          	addi	a0,a0,128 # 80007598 <etext+0x598>
    80003520:	743010ef          	jal	80005462 <panic>
    return -1;
    80003524:	597d                	li	s2,-1
    80003526:	b775                	j	800034d2 <fileread+0x58>
      return -1;
    80003528:	597d                	li	s2,-1
    8000352a:	64e2                	ld	s1,24(sp)
    8000352c:	69a2                	ld	s3,8(sp)
    8000352e:	b755                	j	800034d2 <fileread+0x58>
    80003530:	597d                	li	s2,-1
    80003532:	64e2                	ld	s1,24(sp)
    80003534:	69a2                	ld	s3,8(sp)
    80003536:	bf71                	j	800034d2 <fileread+0x58>

0000000080003538 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;
  //check if the file can be writen or not
  if(f->writable == 0)
    80003538:	00954783          	lbu	a5,9(a0)
    8000353c:	10078b63          	beqz	a5,80003652 <filewrite+0x11a>
{
    80003540:	715d                	addi	sp,sp,-80
    80003542:	e486                	sd	ra,72(sp)
    80003544:	e0a2                	sd	s0,64(sp)
    80003546:	f84a                	sd	s2,48(sp)
    80003548:	f052                	sd	s4,32(sp)
    8000354a:	e85a                	sd	s6,16(sp)
    8000354c:	0880                	addi	s0,sp,80
    8000354e:	892a                	mv	s2,a0
    80003550:	8b2e                	mv	s6,a1
    80003552:	8a32                	mv	s4,a2
    return -1;

  //write to pipe
  if(f->type == FD_PIPE){
    80003554:	411c                	lw	a5,0(a0)
    80003556:	4705                	li	a4,1
    80003558:	02e78763          	beq	a5,a4,80003586 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000355c:	470d                	li	a4,3
    8000355e:	02e78863          	beq	a5,a4,8000358e <filewrite+0x56>
    //find the correct device from the device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003562:	4709                	li	a4,2
    80003564:	0ce79c63          	bne	a5,a4,8000363c <filewrite+0x104>
    80003568:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000356a:	0ac05863          	blez	a2,8000361a <filewrite+0xe2>
    8000356e:	fc26                	sd	s1,56(sp)
    80003570:	ec56                	sd	s5,24(sp)
    80003572:	e45e                	sd	s7,8(sp)
    80003574:	e062                	sd	s8,0(sp)
    int i = 0;
    80003576:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80003578:	6b85                	lui	s7,0x1
    8000357a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000357e:	6c05                	lui	s8,0x1
    80003580:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003584:	a8b5                	j	80003600 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80003586:	6908                	ld	a0,16(a0)
    80003588:	1fc000ef          	jal	80003784 <pipewrite>
    8000358c:	a04d                	j	8000362e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000358e:	02451783          	lh	a5,36(a0)
    80003592:	03079693          	slli	a3,a5,0x30
    80003596:	92c1                	srli	a3,a3,0x30
    80003598:	4725                	li	a4,9
    8000359a:	0ad76e63          	bltu	a4,a3,80003656 <filewrite+0x11e>
    8000359e:	0792                	slli	a5,a5,0x4
    800035a0:	00017717          	auipc	a4,0x17
    800035a4:	d9870713          	addi	a4,a4,-616 # 8001a338 <devsw>
    800035a8:	97ba                	add	a5,a5,a4
    800035aa:	679c                	ld	a5,8(a5)
    800035ac:	c7dd                	beqz	a5,8000365a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800035ae:	4505                	li	a0,1
    800035b0:	9782                	jalr	a5
    800035b2:	a8b5                	j	8000362e <filewrite+0xf6>
      if(n1 > max)
    800035b4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800035b8:	989ff0ef          	jal	80002f40 <begin_op>
      ilock(f->ip);
    800035bc:	01893503          	ld	a0,24(s2)
    800035c0:	8eaff0ef          	jal	800026aa <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800035c4:	8756                	mv	a4,s5
    800035c6:	02092683          	lw	a3,32(s2)
    800035ca:	01698633          	add	a2,s3,s6
    800035ce:	4585                	li	a1,1
    800035d0:	01893503          	ld	a0,24(s2)
    800035d4:	c26ff0ef          	jal	800029fa <writei>
    800035d8:	84aa                	mv	s1,a0
    800035da:	00a05763          	blez	a0,800035e8 <filewrite+0xb0>
        f->off += r;
    800035de:	02092783          	lw	a5,32(s2)
    800035e2:	9fa9                	addw	a5,a5,a0
    800035e4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800035e8:	01893503          	ld	a0,24(s2)
    800035ec:	96cff0ef          	jal	80002758 <iunlock>
      end_op();
    800035f0:	9bbff0ef          	jal	80002faa <end_op>

      if(r != n1){
    800035f4:	029a9563          	bne	s5,s1,8000361e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800035f8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800035fc:	0149da63          	bge	s3,s4,80003610 <filewrite+0xd8>
      int n1 = n - i;
    80003600:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003604:	0004879b          	sext.w	a5,s1
    80003608:	fafbd6e3          	bge	s7,a5,800035b4 <filewrite+0x7c>
    8000360c:	84e2                	mv	s1,s8
    8000360e:	b75d                	j	800035b4 <filewrite+0x7c>
    80003610:	74e2                	ld	s1,56(sp)
    80003612:	6ae2                	ld	s5,24(sp)
    80003614:	6ba2                	ld	s7,8(sp)
    80003616:	6c02                	ld	s8,0(sp)
    80003618:	a039                	j	80003626 <filewrite+0xee>
    int i = 0;
    8000361a:	4981                	li	s3,0
    8000361c:	a029                	j	80003626 <filewrite+0xee>
    8000361e:	74e2                	ld	s1,56(sp)
    80003620:	6ae2                	ld	s5,24(sp)
    80003622:	6ba2                	ld	s7,8(sp)
    80003624:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003626:	033a1c63          	bne	s4,s3,8000365e <filewrite+0x126>
    8000362a:	8552                	mv	a0,s4
    8000362c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000362e:	60a6                	ld	ra,72(sp)
    80003630:	6406                	ld	s0,64(sp)
    80003632:	7942                	ld	s2,48(sp)
    80003634:	7a02                	ld	s4,32(sp)
    80003636:	6b42                	ld	s6,16(sp)
    80003638:	6161                	addi	sp,sp,80
    8000363a:	8082                	ret
    8000363c:	fc26                	sd	s1,56(sp)
    8000363e:	f44e                	sd	s3,40(sp)
    80003640:	ec56                	sd	s5,24(sp)
    80003642:	e45e                	sd	s7,8(sp)
    80003644:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003646:	00004517          	auipc	a0,0x4
    8000364a:	f6250513          	addi	a0,a0,-158 # 800075a8 <etext+0x5a8>
    8000364e:	615010ef          	jal	80005462 <panic>
    return -1;
    80003652:	557d                	li	a0,-1
}
    80003654:	8082                	ret
      return -1;
    80003656:	557d                	li	a0,-1
    80003658:	bfd9                	j	8000362e <filewrite+0xf6>
    8000365a:	557d                	li	a0,-1
    8000365c:	bfc9                	j	8000362e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000365e:	557d                	li	a0,-1
    80003660:	79a2                	ld	s3,40(sp)
    80003662:	b7f1                	j	8000362e <filewrite+0xf6>

0000000080003664 <pipealloc>:
};

//nitializes a pipe, and returns two file descriptors: one for read and one for write 
int
pipealloc(struct file **f0, struct file **f1)
{
    80003664:	7179                	addi	sp,sp,-48
    80003666:	f406                	sd	ra,40(sp)
    80003668:	f022                	sd	s0,32(sp)
    8000366a:	ec26                	sd	s1,24(sp)
    8000366c:	e052                	sd	s4,0(sp)
    8000366e:	1800                	addi	s0,sp,48
    80003670:	84aa                	mv	s1,a0
    80003672:	8a2e                	mv	s4,a1
  struct pipe *pi;

  //initialize file descriptors
  pi = 0;
  *f0 = *f1 = 0;
    80003674:	0005b023          	sd	zero,0(a1)
    80003678:	00053023          	sd	zero,0(a0)
  //allocate descriptors
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000367c:	c3bff0ef          	jal	800032b6 <filealloc>
    80003680:	e088                	sd	a0,0(s1)
    80003682:	c549                	beqz	a0,8000370c <pipealloc+0xa8>
    80003684:	c33ff0ef          	jal	800032b6 <filealloc>
    80003688:	00aa3023          	sd	a0,0(s4)
    8000368c:	cd25                	beqz	a0,80003704 <pipealloc+0xa0>
    8000368e:	e84a                	sd	s2,16(sp)
    goto bad;
  //allocate for pipe
  if((pi = (struct pipe*)kalloc()) == 0)
    80003690:	a6ffc0ef          	jal	800000fe <kalloc>
    80003694:	892a                	mv	s2,a0
    80003696:	c12d                	beqz	a0,800036f8 <pipealloc+0x94>
    80003698:	e44e                	sd	s3,8(sp)
    goto bad;
  //set up values
  pi->readopen = 1;
    8000369a:	4985                	li	s3,1
    8000369c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800036a0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800036a4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800036a8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe"); // init lock
    800036ac:	00004597          	auipc	a1,0x4
    800036b0:	f0c58593          	addi	a1,a1,-244 # 800075b8 <etext+0x5b8>
    800036b4:	05c020ef          	jal	80005710 <initlock>
  //set up values and link file with pipe
  (*f0)->type = FD_PIPE;
    800036b8:	609c                	ld	a5,0(s1)
    800036ba:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800036be:	609c                	ld	a5,0(s1)
    800036c0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800036c4:	609c                	ld	a5,0(s1)
    800036c6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800036ca:	609c                	ld	a5,0(s1)
    800036cc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800036d0:	000a3783          	ld	a5,0(s4)
    800036d4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800036d8:	000a3783          	ld	a5,0(s4)
    800036dc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800036e0:	000a3783          	ld	a5,0(s4)
    800036e4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800036e8:	000a3783          	ld	a5,0(s4)
    800036ec:	0127b823          	sd	s2,16(a5)
  return 0;
    800036f0:	4501                	li	a0,0
    800036f2:	6942                	ld	s2,16(sp)
    800036f4:	69a2                	ld	s3,8(sp)
    800036f6:	a01d                	j	8000371c <pipealloc+0xb8>

//exception
 bad:
  if(pi)
    kfree((char*)pi); //deallocate pipe
  if(*f0)
    800036f8:	6088                	ld	a0,0(s1)
    800036fa:	c119                	beqz	a0,80003700 <pipealloc+0x9c>
    800036fc:	6942                	ld	s2,16(sp)
    800036fe:	a029                	j	80003708 <pipealloc+0xa4>
    80003700:	6942                	ld	s2,16(sp)
    80003702:	a029                	j	8000370c <pipealloc+0xa8>
    80003704:	6088                	ld	a0,0(s1)
    80003706:	c10d                	beqz	a0,80003728 <pipealloc+0xc4>
    fileclose(*f0); //close file and release
    80003708:	c53ff0ef          	jal	8000335a <fileclose>
  if(*f1)
    8000370c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003710:	557d                	li	a0,-1
  if(*f1)
    80003712:	c789                	beqz	a5,8000371c <pipealloc+0xb8>
    fileclose(*f1);
    80003714:	853e                	mv	a0,a5
    80003716:	c45ff0ef          	jal	8000335a <fileclose>
  return -1;
    8000371a:	557d                	li	a0,-1
}
    8000371c:	70a2                	ld	ra,40(sp)
    8000371e:	7402                	ld	s0,32(sp)
    80003720:	64e2                	ld	s1,24(sp)
    80003722:	6a02                	ld	s4,0(sp)
    80003724:	6145                	addi	sp,sp,48
    80003726:	8082                	ret
  return -1;
    80003728:	557d                	li	a0,-1
    8000372a:	bfcd                	j	8000371c <pipealloc+0xb8>

000000008000372c <pipeclose>:
//Close one end of the pipe (read or write). If both ends are closed, release the pipe's memory.
// writable = 1 => writable = 0
// writable = 0 => readable = 0
void
pipeclose(struct pipe *pi, int writable)
{
    8000372c:	1101                	addi	sp,sp,-32
    8000372e:	ec06                	sd	ra,24(sp)
    80003730:	e822                	sd	s0,16(sp)
    80003732:	e426                	sd	s1,8(sp)
    80003734:	e04a                	sd	s2,0(sp)
    80003736:	1000                	addi	s0,sp,32
    80003738:	84aa                	mv	s1,a0
    8000373a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000373c:	054020ef          	jal	80005790 <acquire>
  if(writable){
    80003740:	02090763          	beqz	s2,8000376e <pipeclose+0x42>
    pi->writeopen = 0;
    80003744:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread); // wake the reader up when the writer close
    80003748:	21848513          	addi	a0,s1,536
    8000374c:	c35fd0ef          	jal	80001380 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite); // wake the write up when the reader close
  }
  // if all are close, release the memory
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003750:	2204b783          	ld	a5,544(s1)
    80003754:	e785                	bnez	a5,8000377c <pipeclose+0x50>
    release(&pi->lock); // release lock
    80003756:	8526                	mv	a0,s1
    80003758:	0d0020ef          	jal	80005828 <release>
    kfree((char*)pi); // deallocate
    8000375c:	8526                	mv	a0,s1
    8000375e:	8bffc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003762:	60e2                	ld	ra,24(sp)
    80003764:	6442                	ld	s0,16(sp)
    80003766:	64a2                	ld	s1,8(sp)
    80003768:	6902                	ld	s2,0(sp)
    8000376a:	6105                	addi	sp,sp,32
    8000376c:	8082                	ret
    pi->readopen = 0;
    8000376e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite); // wake the write up when the reader close
    80003772:	21c48513          	addi	a0,s1,540
    80003776:	c0bfd0ef          	jal	80001380 <wakeup>
    8000377a:	bfd9                	j	80003750 <pipeclose+0x24>
    release(&pi->lock);
    8000377c:	8526                	mv	a0,s1
    8000377e:	0aa020ef          	jal	80005828 <release>
}
    80003782:	b7c5                	j	80003762 <pipeclose+0x36>

0000000080003784 <pipewrite>:

//Writes data from the process's memory to the pipe.
int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003784:	711d                	addi	sp,sp,-96
    80003786:	ec86                	sd	ra,88(sp)
    80003788:	e8a2                	sd	s0,80(sp)
    8000378a:	e4a6                	sd	s1,72(sp)
    8000378c:	e0ca                	sd	s2,64(sp)
    8000378e:	fc4e                	sd	s3,56(sp)
    80003790:	f852                	sd	s4,48(sp)
    80003792:	f456                	sd	s5,40(sp)
    80003794:	1080                	addi	s0,sp,96
    80003796:	84aa                	mv	s1,a0
    80003798:	8aae                	mv	s5,a1
    8000379a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000379c:	dcafd0ef          	jal	80000d66 <myproc>
    800037a0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800037a2:	8526                	mv	a0,s1
    800037a4:	7ed010ef          	jal	80005790 <acquire>
  while(i < n){
    800037a8:	0b405a63          	blez	s4,8000385c <pipewrite+0xd8>
    800037ac:	f05a                	sd	s6,32(sp)
    800037ae:	ec5e                	sd	s7,24(sp)
    800037b0:	e862                	sd	s8,16(sp)
  int i = 0;
    800037b2:	4901                	li	s2,0
      wakeup(&pi->nread); //wake up reader
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    } else {
      char ch;
      //read each byte from the process's memory (copyin) and write to the pipe's circular buffer
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800037b4:	5b7d                	li	s6,-1
      wakeup(&pi->nread); //wake up reader
    800037b6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    800037ba:	21c48b93          	addi	s7,s1,540
    800037be:	a81d                	j	800037f4 <pipewrite+0x70>
      release(&pi->lock);
    800037c0:	8526                	mv	a0,s1
    800037c2:	066020ef          	jal	80005828 <release>
      return -1;
    800037c6:	597d                	li	s2,-1
    800037c8:	7b02                	ld	s6,32(sp)
    800037ca:	6be2                	ld	s7,24(sp)
    800037cc:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800037ce:	854a                	mv	a0,s2
    800037d0:	60e6                	ld	ra,88(sp)
    800037d2:	6446                	ld	s0,80(sp)
    800037d4:	64a6                	ld	s1,72(sp)
    800037d6:	6906                	ld	s2,64(sp)
    800037d8:	79e2                	ld	s3,56(sp)
    800037da:	7a42                	ld	s4,48(sp)
    800037dc:	7aa2                	ld	s5,40(sp)
    800037de:	6125                	addi	sp,sp,96
    800037e0:	8082                	ret
      wakeup(&pi->nread); //wake up reader
    800037e2:	8562                	mv	a0,s8
    800037e4:	b9dfd0ef          	jal	80001380 <wakeup>
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    800037e8:	85a6                	mv	a1,s1
    800037ea:	855e                	mv	a0,s7
    800037ec:	b49fd0ef          	jal	80001334 <sleep>
  while(i < n){
    800037f0:	05495b63          	bge	s2,s4,80003846 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800037f4:	2204a783          	lw	a5,544(s1)
    800037f8:	d7e1                	beqz	a5,800037c0 <pipewrite+0x3c>
    800037fa:	854e                	mv	a0,s3
    800037fc:	d71fd0ef          	jal	8000156c <killed>
    80003800:	f161                	bnez	a0,800037c0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full cannot write more
    80003802:	2184a783          	lw	a5,536(s1)
    80003806:	21c4a703          	lw	a4,540(s1)
    8000380a:	2007879b          	addiw	a5,a5,512
    8000380e:	fcf70ae3          	beq	a4,a5,800037e2 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003812:	4685                	li	a3,1
    80003814:	01590633          	add	a2,s2,s5
    80003818:	faf40593          	addi	a1,s0,-81
    8000381c:	0509b503          	ld	a0,80(s3)
    80003820:	a8efd0ef          	jal	80000aae <copyin>
    80003824:	03650e63          	beq	a0,s6,80003860 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003828:	21c4a783          	lw	a5,540(s1)
    8000382c:	0017871b          	addiw	a4,a5,1
    80003830:	20e4ae23          	sw	a4,540(s1)
    80003834:	1ff7f793          	andi	a5,a5,511
    80003838:	97a6                	add	a5,a5,s1
    8000383a:	faf44703          	lbu	a4,-81(s0)
    8000383e:	00e78c23          	sb	a4,24(a5)
      i++;
    80003842:	2905                	addiw	s2,s2,1
    80003844:	b775                	j	800037f0 <pipewrite+0x6c>
    80003846:	7b02                	ld	s6,32(sp)
    80003848:	6be2                	ld	s7,24(sp)
    8000384a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000384c:	21848513          	addi	a0,s1,536
    80003850:	b31fd0ef          	jal	80001380 <wakeup>
  release(&pi->lock);
    80003854:	8526                	mv	a0,s1
    80003856:	7d3010ef          	jal	80005828 <release>
  return i;
    8000385a:	bf95                	j	800037ce <pipewrite+0x4a>
  int i = 0;
    8000385c:	4901                	li	s2,0
    8000385e:	b7fd                	j	8000384c <pipewrite+0xc8>
    80003860:	7b02                	ld	s6,32(sp)
    80003862:	6be2                	ld	s7,24(sp)
    80003864:	6c42                	ld	s8,16(sp)
    80003866:	b7dd                	j	8000384c <pipewrite+0xc8>

0000000080003868 <piperead>:

//Read data from the pipe into the process's memory.
int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003868:	715d                	addi	sp,sp,-80
    8000386a:	e486                	sd	ra,72(sp)
    8000386c:	e0a2                	sd	s0,64(sp)
    8000386e:	fc26                	sd	s1,56(sp)
    80003870:	f84a                	sd	s2,48(sp)
    80003872:	f44e                	sd	s3,40(sp)
    80003874:	f052                	sd	s4,32(sp)
    80003876:	ec56                	sd	s5,24(sp)
    80003878:	0880                	addi	s0,sp,80
    8000387a:	84aa                	mv	s1,a0
    8000387c:	892e                	mv	s2,a1
    8000387e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003880:	ce6fd0ef          	jal	80000d66 <myproc>
    80003884:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003886:	8526                	mv	a0,s1
    80003888:	709010ef          	jal	80005790 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    8000388c:	2184a703          	lw	a4,536(s1)
    80003890:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    //waiting
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003894:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003898:	02f71563          	bne	a4,a5,800038c2 <piperead+0x5a>
    8000389c:	2244a783          	lw	a5,548(s1)
    800038a0:	cb85                	beqz	a5,800038d0 <piperead+0x68>
    if(killed(pr)){
    800038a2:	8552                	mv	a0,s4
    800038a4:	cc9fd0ef          	jal	8000156c <killed>
    800038a8:	ed19                	bnez	a0,800038c6 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038aa:	85a6                	mv	a1,s1
    800038ac:	854e                	mv	a0,s3
    800038ae:	a87fd0ef          	jal	80001334 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038b2:	2184a703          	lw	a4,536(s1)
    800038b6:	21c4a783          	lw	a5,540(s1)
    800038ba:	fef701e3          	beq	a4,a5,8000389c <piperead+0x34>
    800038be:	e85a                	sd	s6,16(sp)
    800038c0:	a809                	j	800038d2 <piperead+0x6a>
    800038c2:	e85a                	sd	s6,16(sp)
    800038c4:	a039                	j	800038d2 <piperead+0x6a>
      release(&pi->lock);
    800038c6:	8526                	mv	a0,s1
    800038c8:	761010ef          	jal	80005828 <release>
      return -1;
    800038cc:	59fd                	li	s3,-1
    800038ce:	a8b1                	j	8000392a <piperead+0xc2>
    800038d0:	e85a                	sd	s6,16(sp)
  }
  //Read each byte from the pipe's circular buffer and write it to the process's memory (copyout).
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800038d2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    //increasing nread after reading
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800038d4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800038d6:	05505263          	blez	s5,8000391a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800038da:	2184a783          	lw	a5,536(s1)
    800038de:	21c4a703          	lw	a4,540(s1)
    800038e2:	02f70c63          	beq	a4,a5,8000391a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800038e6:	0017871b          	addiw	a4,a5,1
    800038ea:	20e4ac23          	sw	a4,536(s1)
    800038ee:	1ff7f793          	andi	a5,a5,511
    800038f2:	97a6                	add	a5,a5,s1
    800038f4:	0187c783          	lbu	a5,24(a5)
    800038f8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800038fc:	4685                	li	a3,1
    800038fe:	fbf40613          	addi	a2,s0,-65
    80003902:	85ca                	mv	a1,s2
    80003904:	050a3503          	ld	a0,80(s4)
    80003908:	8d0fd0ef          	jal	800009d8 <copyout>
    8000390c:	01650763          	beq	a0,s6,8000391a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003910:	2985                	addiw	s3,s3,1
    80003912:	0905                	addi	s2,s2,1
    80003914:	fd3a93e3          	bne	s5,s3,800038da <piperead+0x72>
    80003918:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000391a:	21c48513          	addi	a0,s1,540
    8000391e:	a63fd0ef          	jal	80001380 <wakeup>
  release(&pi->lock);
    80003922:	8526                	mv	a0,s1
    80003924:	705010ef          	jal	80005828 <release>
    80003928:	6b42                	ld	s6,16(sp)
  return i;
}
    8000392a:	854e                	mv	a0,s3
    8000392c:	60a6                	ld	ra,72(sp)
    8000392e:	6406                	ld	s0,64(sp)
    80003930:	74e2                	ld	s1,56(sp)
    80003932:	7942                	ld	s2,48(sp)
    80003934:	79a2                	ld	s3,40(sp)
    80003936:	7a02                	ld	s4,32(sp)
    80003938:	6ae2                	ld	s5,24(sp)
    8000393a:	6161                	addi	sp,sp,80
    8000393c:	8082                	ret

000000008000393e <flags2perm>:
//Load file contents into memory
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

//convert ELF flag into type of access  
int flags2perm(int flags)
{
    8000393e:	1141                	addi	sp,sp,-16
    80003940:	e422                	sd	s0,8(sp)
    80003942:	0800                	addi	s0,sp,16
    80003944:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003946:	8905                	andi	a0,a0,1
    80003948:	050e                	slli	a0,a0,0x3
      perm = PTE_X; //execute access
    if(flags & 0x2)
    8000394a:	8b89                	andi	a5,a5,2
    8000394c:	c399                	beqz	a5,80003952 <flags2perm+0x14>
      perm |= PTE_W; //write access
    8000394e:	00456513          	ori	a0,a0,4
    return perm;
}
    80003952:	6422                	ld	s0,8(sp)
    80003954:	0141                	addi	sp,sp,16
    80003956:	8082                	ret

0000000080003958 <exec>:

//execute file
int
exec(char *path, char **argv)
{
    80003958:	df010113          	addi	sp,sp,-528
    8000395c:	20113423          	sd	ra,520(sp)
    80003960:	20813023          	sd	s0,512(sp)
    80003964:	ffa6                	sd	s1,504(sp)
    80003966:	fbca                	sd	s2,496(sp)
    80003968:	0c00                	addi	s0,sp,528
    8000396a:	892a                	mv	s2,a0
    8000396c:	dea43c23          	sd	a0,-520(s0)
    80003970:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003974:	bf2fd0ef          	jal	80000d66 <myproc>
    80003978:	84aa                	mv	s1,a0

// open execute file
  begin_op(); //begin a transaction of file system
    8000397a:	dc6ff0ef          	jal	80002f40 <begin_op>

  if((ip = namei(path)) == 0){ //find inode 
    8000397e:	854a                	mv	a0,s2
    80003980:	c04ff0ef          	jal	80002d84 <namei>
    80003984:	c931                	beqz	a0,800039d8 <exec+0x80>
    80003986:	f3d2                	sd	s4,480(sp)
    80003988:	8a2a                	mv	s4,a0
    end_op(); // end transaction
    return -1;
  }
  ilock(ip); //lock inode to make sure that inode can not be modified during executing
    8000398a:	d21fe0ef          	jal	800026aa <ilock>

  //read and check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) //read
    8000398e:	04000713          	li	a4,64
    80003992:	4681                	li	a3,0
    80003994:	e5040613          	addi	a2,s0,-432
    80003998:	4581                	li	a1,0
    8000399a:	8552                	mv	a0,s4
    8000399c:	f63fe0ef          	jal	800028fe <readi>
    800039a0:	04000793          	li	a5,64
    800039a4:	00f51a63          	bne	a0,a5,800039b8 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC) //check
    800039a8:	e5042703          	lw	a4,-432(s0)
    800039ac:	464c47b7          	lui	a5,0x464c4
    800039b0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800039b4:	02f70663          	beq	a4,a5,800039e0 <exec+0x88>
//handle the unvalid
 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800039b8:	8552                	mv	a0,s4
    800039ba:	efbfe0ef          	jal	800028b4 <iunlockput>
    end_op();
    800039be:	decff0ef          	jal	80002faa <end_op>
  }
  return -1;
    800039c2:	557d                	li	a0,-1
    800039c4:	7a1e                	ld	s4,480(sp)
}
    800039c6:	20813083          	ld	ra,520(sp)
    800039ca:	20013403          	ld	s0,512(sp)
    800039ce:	74fe                	ld	s1,504(sp)
    800039d0:	795e                	ld	s2,496(sp)
    800039d2:	21010113          	addi	sp,sp,528
    800039d6:	8082                	ret
    end_op(); // end transaction
    800039d8:	dd2ff0ef          	jal	80002faa <end_op>
    return -1;
    800039dc:	557d                	li	a0,-1
    800039de:	b7e5                	j	800039c6 <exec+0x6e>
    800039e0:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0) //create new pagetable for executing
    800039e2:	8526                	mv	a0,s1
    800039e4:	c2afd0ef          	jal	80000e0e <proc_pagetable>
    800039e8:	8b2a                	mv	s6,a0
    800039ea:	2c050b63          	beqz	a0,80003cc0 <exec+0x368>
    800039ee:	f7ce                	sd	s3,488(sp)
    800039f0:	efd6                	sd	s5,472(sp)
    800039f2:	e7de                	sd	s7,456(sp)
    800039f4:	e3e2                	sd	s8,448(sp)
    800039f6:	ff66                	sd	s9,440(sp)
    800039f8:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800039fa:	e7042d03          	lw	s10,-400(s0)
    800039fe:	e8845783          	lhu	a5,-376(s0)
    80003a02:	12078963          	beqz	a5,80003b34 <exec+0x1dc>
    80003a06:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003a08:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a0a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003a0c:	6c85                	lui	s9,0x1
    80003a0e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003a12:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003a16:	6a85                	lui	s5,0x1
    80003a18:	a085                	j	80003a78 <exec+0x120>
      panic("loadseg: address should exist");
    80003a1a:	00004517          	auipc	a0,0x4
    80003a1e:	ba650513          	addi	a0,a0,-1114 # 800075c0 <etext+0x5c0>
    80003a22:	241010ef          	jal	80005462 <panic>
    if(sz - i < PGSIZE)
    80003a26:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003a28:	8726                	mv	a4,s1
    80003a2a:	012c06bb          	addw	a3,s8,s2
    80003a2e:	4581                	li	a1,0
    80003a30:	8552                	mv	a0,s4
    80003a32:	ecdfe0ef          	jal	800028fe <readi>
    80003a36:	2501                	sext.w	a0,a0
    80003a38:	24a49a63          	bne	s1,a0,80003c8c <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003a3c:	012a893b          	addw	s2,s5,s2
    80003a40:	03397363          	bgeu	s2,s3,80003a66 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003a44:	02091593          	slli	a1,s2,0x20
    80003a48:	9181                	srli	a1,a1,0x20
    80003a4a:	95de                	add	a1,a1,s7
    80003a4c:	855a                	mv	a0,s6
    80003a4e:	a0ffc0ef          	jal	8000045c <walkaddr>
    80003a52:	862a                	mv	a2,a0
    if(pa == 0)
    80003a54:	d179                	beqz	a0,80003a1a <exec+0xc2>
    if(sz - i < PGSIZE)
    80003a56:	412984bb          	subw	s1,s3,s2
    80003a5a:	0004879b          	sext.w	a5,s1
    80003a5e:	fcfcf4e3          	bgeu	s9,a5,80003a26 <exec+0xce>
    80003a62:	84d6                	mv	s1,s5
    80003a64:	b7c9                	j	80003a26 <exec+0xce>
    sz = sz1;
    80003a66:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a6a:	2d85                	addiw	s11,s11,1
    80003a6c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003a70:	e8845783          	lhu	a5,-376(s0)
    80003a74:	08fdd063          	bge	s11,a5,80003af4 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003a78:	2d01                	sext.w	s10,s10
    80003a7a:	03800713          	li	a4,56
    80003a7e:	86ea                	mv	a3,s10
    80003a80:	e1840613          	addi	a2,s0,-488
    80003a84:	4581                	li	a1,0
    80003a86:	8552                	mv	a0,s4
    80003a88:	e77fe0ef          	jal	800028fe <readi>
    80003a8c:	03800793          	li	a5,56
    80003a90:	1cf51663          	bne	a0,a5,80003c5c <exec+0x304>
    if(ph.type != ELF_PROG_LOAD) //checks if a segment is the type to load into memory 
    80003a94:	e1842783          	lw	a5,-488(s0)
    80003a98:	4705                	li	a4,1
    80003a9a:	fce798e3          	bne	a5,a4,80003a6a <exec+0x112>
    if(ph.memsz < ph.filesz) //memory size >= file size
    80003a9e:	e4043483          	ld	s1,-448(s0)
    80003aa2:	e3843783          	ld	a5,-456(s0)
    80003aa6:	1af4ef63          	bltu	s1,a5,80003c64 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr) //address must align to the page size
    80003aaa:	e2843783          	ld	a5,-472(s0)
    80003aae:	94be                	add	s1,s1,a5
    80003ab0:	1af4ee63          	bltu	s1,a5,80003c6c <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003ab4:	df043703          	ld	a4,-528(s0)
    80003ab8:	8ff9                	and	a5,a5,a4
    80003aba:	1a079d63          	bnez	a5,80003c74 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)//allocate memory for segment
    80003abe:	e1c42503          	lw	a0,-484(s0)
    80003ac2:	e7dff0ef          	jal	8000393e <flags2perm>
    80003ac6:	86aa                	mv	a3,a0
    80003ac8:	8626                	mv	a2,s1
    80003aca:	85ca                	mv	a1,s2
    80003acc:	855a                	mv	a0,s6
    80003ace:	cf7fc0ef          	jal	800007c4 <uvmalloc>
    80003ad2:	e0a43423          	sd	a0,-504(s0)
    80003ad6:	1a050363          	beqz	a0,80003c7c <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0) //Load file contents into memory
    80003ada:	e2843b83          	ld	s7,-472(s0)
    80003ade:	e2042c03          	lw	s8,-480(s0)
    80003ae2:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003ae6:	00098463          	beqz	s3,80003aee <exec+0x196>
    80003aea:	4901                	li	s2,0
    80003aec:	bfa1                	j	80003a44 <exec+0xec>
    sz = sz1;
    80003aee:	e0843903          	ld	s2,-504(s0)
    80003af2:	bfa5                	j	80003a6a <exec+0x112>
    80003af4:	7dba                	ld	s11,424(sp)
  iunlockput(ip); //unlock ip
    80003af6:	8552                	mv	a0,s4
    80003af8:	dbdfe0ef          	jal	800028b4 <iunlockput>
  end_op(); // end transaction
    80003afc:	caeff0ef          	jal	80002faa <end_op>
  p = myproc();
    80003b00:	a66fd0ef          	jal	80000d66 <myproc>
    80003b04:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003b06:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz); //round the value
    80003b0a:	6985                	lui	s3,0x1
    80003b0c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003b0e:	99ca                	add	s3,s3,s2
    80003b10:	77fd                	lui	a5,0xfffff
    80003b12:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0) //allocate stack space in memory.
    80003b16:	4691                	li	a3,4
    80003b18:	660d                	lui	a2,0x3
    80003b1a:	964e                	add	a2,a2,s3
    80003b1c:	85ce                	mv	a1,s3
    80003b1e:	855a                	mv	a0,s6
    80003b20:	ca5fc0ef          	jal	800007c4 <uvmalloc>
    80003b24:	892a                	mv	s2,a0
    80003b26:	e0a43423          	sd	a0,-504(s0)
    80003b2a:	e519                	bnez	a0,80003b38 <exec+0x1e0>
  if(pagetable)
    80003b2c:	e1343423          	sd	s3,-504(s0)
    80003b30:	4a01                	li	s4,0
    80003b32:	aab1                	j	80003c8e <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b34:	4901                	li	s2,0
    80003b36:	b7c1                	j	80003af6 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE); //makes the first page inaccessible, acting as a "stack guard".
    80003b38:	75f5                	lui	a1,0xffffd
    80003b3a:	95aa                	add	a1,a1,a0
    80003b3c:	855a                	mv	a0,s6
    80003b3e:	e71fc0ef          	jal	800009ae <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003b42:	7bf9                	lui	s7,0xffffe
    80003b44:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003b46:	e0043783          	ld	a5,-512(s0)
    80003b4a:	6388                	ld	a0,0(a5)
    80003b4c:	cd39                	beqz	a0,80003baa <exec+0x252>
    80003b4e:	e9040993          	addi	s3,s0,-368
    80003b52:	f9040c13          	addi	s8,s0,-112
    80003b56:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003b58:	f66fc0ef          	jal	800002be <strlen>
    80003b5c:	0015079b          	addiw	a5,a0,1
    80003b60:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003b64:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003b68:	11796e63          	bltu	s2,s7,80003c84 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003b6c:	e0043d03          	ld	s10,-512(s0)
    80003b70:	000d3a03          	ld	s4,0(s10)
    80003b74:	8552                	mv	a0,s4
    80003b76:	f48fc0ef          	jal	800002be <strlen>
    80003b7a:	0015069b          	addiw	a3,a0,1
    80003b7e:	8652                	mv	a2,s4
    80003b80:	85ca                	mv	a1,s2
    80003b82:	855a                	mv	a0,s6
    80003b84:	e55fc0ef          	jal	800009d8 <copyout>
    80003b88:	10054063          	bltz	a0,80003c88 <exec+0x330>
    ustack[argc] = sp;
    80003b8c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003b90:	0485                	addi	s1,s1,1
    80003b92:	008d0793          	addi	a5,s10,8
    80003b96:	e0f43023          	sd	a5,-512(s0)
    80003b9a:	008d3503          	ld	a0,8(s10)
    80003b9e:	c909                	beqz	a0,80003bb0 <exec+0x258>
    if(argc >= MAXARG)
    80003ba0:	09a1                	addi	s3,s3,8
    80003ba2:	fb899be3          	bne	s3,s8,80003b58 <exec+0x200>
  ip = 0;
    80003ba6:	4a01                	li	s4,0
    80003ba8:	a0dd                	j	80003c8e <exec+0x336>
  sp = sz;
    80003baa:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003bae:	4481                	li	s1,0
  ustack[argc] = 0;
    80003bb0:	00349793          	slli	a5,s1,0x3
    80003bb4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb9c0>
    80003bb8:	97a2                	add	a5,a5,s0
    80003bba:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003bbe:	00148693          	addi	a3,s1,1
    80003bc2:	068e                	slli	a3,a3,0x3
    80003bc4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003bc8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003bcc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003bd0:	f5796ee3          	bltu	s2,s7,80003b2c <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003bd4:	e9040613          	addi	a2,s0,-368
    80003bd8:	85ca                	mv	a1,s2
    80003bda:	855a                	mv	a0,s6
    80003bdc:	dfdfc0ef          	jal	800009d8 <copyout>
    80003be0:	0e054263          	bltz	a0,80003cc4 <exec+0x36c>
  p->trapframe->a1 = sp;
    80003be4:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003be8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003bec:	df843783          	ld	a5,-520(s0)
    80003bf0:	0007c703          	lbu	a4,0(a5)
    80003bf4:	cf11                	beqz	a4,80003c10 <exec+0x2b8>
    80003bf6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003bf8:	02f00693          	li	a3,47
    80003bfc:	a039                	j	80003c0a <exec+0x2b2>
      last = s+1;
    80003bfe:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003c02:	0785                	addi	a5,a5,1
    80003c04:	fff7c703          	lbu	a4,-1(a5)
    80003c08:	c701                	beqz	a4,80003c10 <exec+0x2b8>
    if(*s == '/')
    80003c0a:	fed71ce3          	bne	a4,a3,80003c02 <exec+0x2aa>
    80003c0e:	bfc5                	j	80003bfe <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003c10:	4641                	li	a2,16
    80003c12:	df843583          	ld	a1,-520(s0)
    80003c16:	158a8513          	addi	a0,s5,344
    80003c1a:	e72fc0ef          	jal	8000028c <safestrcpy>
  oldpagetable = p->pagetable;
    80003c1e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003c22:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003c26:	e0843783          	ld	a5,-504(s0)
    80003c2a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003c2e:	058ab783          	ld	a5,88(s5)
    80003c32:	e6843703          	ld	a4,-408(s0)
    80003c36:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003c38:	058ab783          	ld	a5,88(s5)
    80003c3c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); //deallocate the old page table
    80003c40:	85e6                	mv	a1,s9
    80003c42:	a50fd0ef          	jal	80000e92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003c46:	0004851b          	sext.w	a0,s1
    80003c4a:	79be                	ld	s3,488(sp)
    80003c4c:	7a1e                	ld	s4,480(sp)
    80003c4e:	6afe                	ld	s5,472(sp)
    80003c50:	6b5e                	ld	s6,464(sp)
    80003c52:	6bbe                	ld	s7,456(sp)
    80003c54:	6c1e                	ld	s8,448(sp)
    80003c56:	7cfa                	ld	s9,440(sp)
    80003c58:	7d5a                	ld	s10,432(sp)
    80003c5a:	b3b5                	j	800039c6 <exec+0x6e>
    80003c5c:	e1243423          	sd	s2,-504(s0)
    80003c60:	7dba                	ld	s11,424(sp)
    80003c62:	a035                	j	80003c8e <exec+0x336>
    80003c64:	e1243423          	sd	s2,-504(s0)
    80003c68:	7dba                	ld	s11,424(sp)
    80003c6a:	a015                	j	80003c8e <exec+0x336>
    80003c6c:	e1243423          	sd	s2,-504(s0)
    80003c70:	7dba                	ld	s11,424(sp)
    80003c72:	a831                	j	80003c8e <exec+0x336>
    80003c74:	e1243423          	sd	s2,-504(s0)
    80003c78:	7dba                	ld	s11,424(sp)
    80003c7a:	a811                	j	80003c8e <exec+0x336>
    80003c7c:	e1243423          	sd	s2,-504(s0)
    80003c80:	7dba                	ld	s11,424(sp)
    80003c82:	a031                	j	80003c8e <exec+0x336>
  ip = 0;
    80003c84:	4a01                	li	s4,0
    80003c86:	a021                	j	80003c8e <exec+0x336>
    80003c88:	4a01                	li	s4,0
  if(pagetable)
    80003c8a:	a011                	j	80003c8e <exec+0x336>
    80003c8c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003c8e:	e0843583          	ld	a1,-504(s0)
    80003c92:	855a                	mv	a0,s6
    80003c94:	9fefd0ef          	jal	80000e92 <proc_freepagetable>
  return -1;
    80003c98:	557d                	li	a0,-1
  if(ip){
    80003c9a:	000a1b63          	bnez	s4,80003cb0 <exec+0x358>
    80003c9e:	79be                	ld	s3,488(sp)
    80003ca0:	7a1e                	ld	s4,480(sp)
    80003ca2:	6afe                	ld	s5,472(sp)
    80003ca4:	6b5e                	ld	s6,464(sp)
    80003ca6:	6bbe                	ld	s7,456(sp)
    80003ca8:	6c1e                	ld	s8,448(sp)
    80003caa:	7cfa                	ld	s9,440(sp)
    80003cac:	7d5a                	ld	s10,432(sp)
    80003cae:	bb21                	j	800039c6 <exec+0x6e>
    80003cb0:	79be                	ld	s3,488(sp)
    80003cb2:	6afe                	ld	s5,472(sp)
    80003cb4:	6b5e                	ld	s6,464(sp)
    80003cb6:	6bbe                	ld	s7,456(sp)
    80003cb8:	6c1e                	ld	s8,448(sp)
    80003cba:	7cfa                	ld	s9,440(sp)
    80003cbc:	7d5a                	ld	s10,432(sp)
    80003cbe:	b9ed                	j	800039b8 <exec+0x60>
    80003cc0:	6b5e                	ld	s6,464(sp)
    80003cc2:	b9dd                	j	800039b8 <exec+0x60>
  sz = sz1;
    80003cc4:	e0843983          	ld	s3,-504(s0)
    80003cc8:	b595                	j	80003b2c <exec+0x1d4>

0000000080003cca <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003cca:	7179                	addi	sp,sp,-48
    80003ccc:	f406                	sd	ra,40(sp)
    80003cce:	f022                	sd	s0,32(sp)
    80003cd0:	ec26                	sd	s1,24(sp)
    80003cd2:	e84a                	sd	s2,16(sp)
    80003cd4:	1800                	addi	s0,sp,48
    80003cd6:	892e                	mv	s2,a1
    80003cd8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003cda:	fdc40593          	addi	a1,s0,-36
    80003cde:	f3dfd0ef          	jal	80001c1a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003ce2:	fdc42703          	lw	a4,-36(s0)
    80003ce6:	47bd                	li	a5,15
    80003ce8:	02e7e963          	bltu	a5,a4,80003d1a <argfd+0x50>
    80003cec:	87afd0ef          	jal	80000d66 <myproc>
    80003cf0:	fdc42703          	lw	a4,-36(s0)
    80003cf4:	01a70793          	addi	a5,a4,26
    80003cf8:	078e                	slli	a5,a5,0x3
    80003cfa:	953e                	add	a0,a0,a5
    80003cfc:	611c                	ld	a5,0(a0)
    80003cfe:	c385                	beqz	a5,80003d1e <argfd+0x54>
    return -1;
  if(pfd)
    80003d00:	00090463          	beqz	s2,80003d08 <argfd+0x3e>
    *pfd = fd;
    80003d04:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003d08:	4501                	li	a0,0
  if(pf)
    80003d0a:	c091                	beqz	s1,80003d0e <argfd+0x44>
    *pf = f;
    80003d0c:	e09c                	sd	a5,0(s1)
}
    80003d0e:	70a2                	ld	ra,40(sp)
    80003d10:	7402                	ld	s0,32(sp)
    80003d12:	64e2                	ld	s1,24(sp)
    80003d14:	6942                	ld	s2,16(sp)
    80003d16:	6145                	addi	sp,sp,48
    80003d18:	8082                	ret
    return -1;
    80003d1a:	557d                	li	a0,-1
    80003d1c:	bfcd                	j	80003d0e <argfd+0x44>
    80003d1e:	557d                	li	a0,-1
    80003d20:	b7fd                	j	80003d0e <argfd+0x44>

0000000080003d22 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	1000                	addi	s0,sp,32
    80003d2c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003d2e:	838fd0ef          	jal	80000d66 <myproc>
    80003d32:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003d34:	0d050793          	addi	a5,a0,208
    80003d38:	4501                	li	a0,0
    80003d3a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003d3c:	6398                	ld	a4,0(a5)
    80003d3e:	cb19                	beqz	a4,80003d54 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003d40:	2505                	addiw	a0,a0,1
    80003d42:	07a1                	addi	a5,a5,8
    80003d44:	fed51ce3          	bne	a0,a3,80003d3c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003d48:	557d                	li	a0,-1
}
    80003d4a:	60e2                	ld	ra,24(sp)
    80003d4c:	6442                	ld	s0,16(sp)
    80003d4e:	64a2                	ld	s1,8(sp)
    80003d50:	6105                	addi	sp,sp,32
    80003d52:	8082                	ret
      p->ofile[fd] = f;
    80003d54:	01a50793          	addi	a5,a0,26
    80003d58:	078e                	slli	a5,a5,0x3
    80003d5a:	963e                	add	a2,a2,a5
    80003d5c:	e204                	sd	s1,0(a2)
      return fd;
    80003d5e:	b7f5                	j	80003d4a <fdalloc+0x28>

0000000080003d60 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003d60:	715d                	addi	sp,sp,-80
    80003d62:	e486                	sd	ra,72(sp)
    80003d64:	e0a2                	sd	s0,64(sp)
    80003d66:	fc26                	sd	s1,56(sp)
    80003d68:	f84a                	sd	s2,48(sp)
    80003d6a:	f44e                	sd	s3,40(sp)
    80003d6c:	ec56                	sd	s5,24(sp)
    80003d6e:	e85a                	sd	s6,16(sp)
    80003d70:	0880                	addi	s0,sp,80
    80003d72:	8b2e                	mv	s6,a1
    80003d74:	89b2                	mv	s3,a2
    80003d76:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003d78:	fb040593          	addi	a1,s0,-80
    80003d7c:	822ff0ef          	jal	80002d9e <nameiparent>
    80003d80:	84aa                	mv	s1,a0
    80003d82:	10050a63          	beqz	a0,80003e96 <create+0x136>
    return 0;

  ilock(dp);
    80003d86:	925fe0ef          	jal	800026aa <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d8a:	4601                	li	a2,0
    80003d8c:	fb040593          	addi	a1,s0,-80
    80003d90:	8526                	mv	a0,s1
    80003d92:	d8dfe0ef          	jal	80002b1e <dirlookup>
    80003d96:	8aaa                	mv	s5,a0
    80003d98:	c129                	beqz	a0,80003dda <create+0x7a>
    iunlockput(dp);
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	b19fe0ef          	jal	800028b4 <iunlockput>
    ilock(ip);
    80003da0:	8556                	mv	a0,s5
    80003da2:	909fe0ef          	jal	800026aa <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003da6:	4789                	li	a5,2
    80003da8:	02fb1463          	bne	s6,a5,80003dd0 <create+0x70>
    80003dac:	044ad783          	lhu	a5,68(s5)
    80003db0:	37f9                	addiw	a5,a5,-2
    80003db2:	17c2                	slli	a5,a5,0x30
    80003db4:	93c1                	srli	a5,a5,0x30
    80003db6:	4705                	li	a4,1
    80003db8:	00f76c63          	bltu	a4,a5,80003dd0 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003dbc:	8556                	mv	a0,s5
    80003dbe:	60a6                	ld	ra,72(sp)
    80003dc0:	6406                	ld	s0,64(sp)
    80003dc2:	74e2                	ld	s1,56(sp)
    80003dc4:	7942                	ld	s2,48(sp)
    80003dc6:	79a2                	ld	s3,40(sp)
    80003dc8:	6ae2                	ld	s5,24(sp)
    80003dca:	6b42                	ld	s6,16(sp)
    80003dcc:	6161                	addi	sp,sp,80
    80003dce:	8082                	ret
    iunlockput(ip);
    80003dd0:	8556                	mv	a0,s5
    80003dd2:	ae3fe0ef          	jal	800028b4 <iunlockput>
    return 0;
    80003dd6:	4a81                	li	s5,0
    80003dd8:	b7d5                	j	80003dbc <create+0x5c>
    80003dda:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003ddc:	85da                	mv	a1,s6
    80003dde:	4088                	lw	a0,0(s1)
    80003de0:	f5afe0ef          	jal	8000253a <ialloc>
    80003de4:	8a2a                	mv	s4,a0
    80003de6:	cd15                	beqz	a0,80003e22 <create+0xc2>
  ilock(ip);
    80003de8:	8c3fe0ef          	jal	800026aa <ilock>
  ip->major = major;
    80003dec:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003df0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003df4:	4905                	li	s2,1
    80003df6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003dfa:	8552                	mv	a0,s4
    80003dfc:	ffafe0ef          	jal	800025f6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003e00:	032b0763          	beq	s6,s2,80003e2e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e04:	004a2603          	lw	a2,4(s4)
    80003e08:	fb040593          	addi	a1,s0,-80
    80003e0c:	8526                	mv	a0,s1
    80003e0e:	eddfe0ef          	jal	80002cea <dirlink>
    80003e12:	06054563          	bltz	a0,80003e7c <create+0x11c>
  iunlockput(dp);
    80003e16:	8526                	mv	a0,s1
    80003e18:	a9dfe0ef          	jal	800028b4 <iunlockput>
  return ip;
    80003e1c:	8ad2                	mv	s5,s4
    80003e1e:	7a02                	ld	s4,32(sp)
    80003e20:	bf71                	j	80003dbc <create+0x5c>
    iunlockput(dp);
    80003e22:	8526                	mv	a0,s1
    80003e24:	a91fe0ef          	jal	800028b4 <iunlockput>
    return 0;
    80003e28:	8ad2                	mv	s5,s4
    80003e2a:	7a02                	ld	s4,32(sp)
    80003e2c:	bf41                	j	80003dbc <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003e2e:	004a2603          	lw	a2,4(s4)
    80003e32:	00003597          	auipc	a1,0x3
    80003e36:	7ae58593          	addi	a1,a1,1966 # 800075e0 <etext+0x5e0>
    80003e3a:	8552                	mv	a0,s4
    80003e3c:	eaffe0ef          	jal	80002cea <dirlink>
    80003e40:	02054e63          	bltz	a0,80003e7c <create+0x11c>
    80003e44:	40d0                	lw	a2,4(s1)
    80003e46:	00003597          	auipc	a1,0x3
    80003e4a:	7a258593          	addi	a1,a1,1954 # 800075e8 <etext+0x5e8>
    80003e4e:	8552                	mv	a0,s4
    80003e50:	e9bfe0ef          	jal	80002cea <dirlink>
    80003e54:	02054463          	bltz	a0,80003e7c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e58:	004a2603          	lw	a2,4(s4)
    80003e5c:	fb040593          	addi	a1,s0,-80
    80003e60:	8526                	mv	a0,s1
    80003e62:	e89fe0ef          	jal	80002cea <dirlink>
    80003e66:	00054b63          	bltz	a0,80003e7c <create+0x11c>
    dp->nlink++;  // for ".."
    80003e6a:	04a4d783          	lhu	a5,74(s1)
    80003e6e:	2785                	addiw	a5,a5,1
    80003e70:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003e74:	8526                	mv	a0,s1
    80003e76:	f80fe0ef          	jal	800025f6 <iupdate>
    80003e7a:	bf71                	j	80003e16 <create+0xb6>
  ip->nlink = 0;
    80003e7c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003e80:	8552                	mv	a0,s4
    80003e82:	f74fe0ef          	jal	800025f6 <iupdate>
  iunlockput(ip);
    80003e86:	8552                	mv	a0,s4
    80003e88:	a2dfe0ef          	jal	800028b4 <iunlockput>
  iunlockput(dp);
    80003e8c:	8526                	mv	a0,s1
    80003e8e:	a27fe0ef          	jal	800028b4 <iunlockput>
  return 0;
    80003e92:	7a02                	ld	s4,32(sp)
    80003e94:	b725                	j	80003dbc <create+0x5c>
    return 0;
    80003e96:	8aaa                	mv	s5,a0
    80003e98:	b715                	j	80003dbc <create+0x5c>

0000000080003e9a <sys_dup>:
{
    80003e9a:	7179                	addi	sp,sp,-48
    80003e9c:	f406                	sd	ra,40(sp)
    80003e9e:	f022                	sd	s0,32(sp)
    80003ea0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003ea2:	fd840613          	addi	a2,s0,-40
    80003ea6:	4581                	li	a1,0
    80003ea8:	4501                	li	a0,0
    80003eaa:	e21ff0ef          	jal	80003cca <argfd>
    return -1;
    80003eae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003eb0:	02054363          	bltz	a0,80003ed6 <sys_dup+0x3c>
    80003eb4:	ec26                	sd	s1,24(sp)
    80003eb6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80003eb8:	fd843903          	ld	s2,-40(s0)
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	e65ff0ef          	jal	80003d22 <fdalloc>
    80003ec2:	84aa                	mv	s1,a0
    return -1;
    80003ec4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003ec6:	00054d63          	bltz	a0,80003ee0 <sys_dup+0x46>
  filedup(f);
    80003eca:	854a                	mv	a0,s2
    80003ecc:	c48ff0ef          	jal	80003314 <filedup>
  return fd;
    80003ed0:	87a6                	mv	a5,s1
    80003ed2:	64e2                	ld	s1,24(sp)
    80003ed4:	6942                	ld	s2,16(sp)
}
    80003ed6:	853e                	mv	a0,a5
    80003ed8:	70a2                	ld	ra,40(sp)
    80003eda:	7402                	ld	s0,32(sp)
    80003edc:	6145                	addi	sp,sp,48
    80003ede:	8082                	ret
    80003ee0:	64e2                	ld	s1,24(sp)
    80003ee2:	6942                	ld	s2,16(sp)
    80003ee4:	bfcd                	j	80003ed6 <sys_dup+0x3c>

0000000080003ee6 <sys_read>:
{
    80003ee6:	7179                	addi	sp,sp,-48
    80003ee8:	f406                	sd	ra,40(sp)
    80003eea:	f022                	sd	s0,32(sp)
    80003eec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003eee:	fd840593          	addi	a1,s0,-40
    80003ef2:	4505                	li	a0,1
    80003ef4:	d43fd0ef          	jal	80001c36 <argaddr>
  argint(2, &n);
    80003ef8:	fe440593          	addi	a1,s0,-28
    80003efc:	4509                	li	a0,2
    80003efe:	d1dfd0ef          	jal	80001c1a <argint>
  if(argfd(0, 0, &f) < 0)
    80003f02:	fe840613          	addi	a2,s0,-24
    80003f06:	4581                	li	a1,0
    80003f08:	4501                	li	a0,0
    80003f0a:	dc1ff0ef          	jal	80003cca <argfd>
    80003f0e:	87aa                	mv	a5,a0
    return -1;
    80003f10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f12:	0007ca63          	bltz	a5,80003f26 <sys_read+0x40>
  return fileread(f, p, n);
    80003f16:	fe442603          	lw	a2,-28(s0)
    80003f1a:	fd843583          	ld	a1,-40(s0)
    80003f1e:	fe843503          	ld	a0,-24(s0)
    80003f22:	d58ff0ef          	jal	8000347a <fileread>
}
    80003f26:	70a2                	ld	ra,40(sp)
    80003f28:	7402                	ld	s0,32(sp)
    80003f2a:	6145                	addi	sp,sp,48
    80003f2c:	8082                	ret

0000000080003f2e <sys_write>:
{
    80003f2e:	7179                	addi	sp,sp,-48
    80003f30:	f406                	sd	ra,40(sp)
    80003f32:	f022                	sd	s0,32(sp)
    80003f34:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f36:	fd840593          	addi	a1,s0,-40
    80003f3a:	4505                	li	a0,1
    80003f3c:	cfbfd0ef          	jal	80001c36 <argaddr>
  argint(2, &n);
    80003f40:	fe440593          	addi	a1,s0,-28
    80003f44:	4509                	li	a0,2
    80003f46:	cd5fd0ef          	jal	80001c1a <argint>
  if(argfd(0, 0, &f) < 0)
    80003f4a:	fe840613          	addi	a2,s0,-24
    80003f4e:	4581                	li	a1,0
    80003f50:	4501                	li	a0,0
    80003f52:	d79ff0ef          	jal	80003cca <argfd>
    80003f56:	87aa                	mv	a5,a0
    return -1;
    80003f58:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f5a:	0007ca63          	bltz	a5,80003f6e <sys_write+0x40>
  return filewrite(f, p, n);
    80003f5e:	fe442603          	lw	a2,-28(s0)
    80003f62:	fd843583          	ld	a1,-40(s0)
    80003f66:	fe843503          	ld	a0,-24(s0)
    80003f6a:	dceff0ef          	jal	80003538 <filewrite>
}
    80003f6e:	70a2                	ld	ra,40(sp)
    80003f70:	7402                	ld	s0,32(sp)
    80003f72:	6145                	addi	sp,sp,48
    80003f74:	8082                	ret

0000000080003f76 <sys_close>:
{
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003f7e:	fe040613          	addi	a2,s0,-32
    80003f82:	fec40593          	addi	a1,s0,-20
    80003f86:	4501                	li	a0,0
    80003f88:	d43ff0ef          	jal	80003cca <argfd>
    return -1;
    80003f8c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003f8e:	02054063          	bltz	a0,80003fae <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003f92:	dd5fc0ef          	jal	80000d66 <myproc>
    80003f96:	fec42783          	lw	a5,-20(s0)
    80003f9a:	07e9                	addi	a5,a5,26
    80003f9c:	078e                	slli	a5,a5,0x3
    80003f9e:	953e                	add	a0,a0,a5
    80003fa0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80003fa4:	fe043503          	ld	a0,-32(s0)
    80003fa8:	bb2ff0ef          	jal	8000335a <fileclose>
  return 0;
    80003fac:	4781                	li	a5,0
}
    80003fae:	853e                	mv	a0,a5
    80003fb0:	60e2                	ld	ra,24(sp)
    80003fb2:	6442                	ld	s0,16(sp)
    80003fb4:	6105                	addi	sp,sp,32
    80003fb6:	8082                	ret

0000000080003fb8 <sys_fstat>:
{
    80003fb8:	1101                	addi	sp,sp,-32
    80003fba:	ec06                	sd	ra,24(sp)
    80003fbc:	e822                	sd	s0,16(sp)
    80003fbe:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80003fc0:	fe040593          	addi	a1,s0,-32
    80003fc4:	4505                	li	a0,1
    80003fc6:	c71fd0ef          	jal	80001c36 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80003fca:	fe840613          	addi	a2,s0,-24
    80003fce:	4581                	li	a1,0
    80003fd0:	4501                	li	a0,0
    80003fd2:	cf9ff0ef          	jal	80003cca <argfd>
    80003fd6:	87aa                	mv	a5,a0
    return -1;
    80003fd8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003fda:	0007c863          	bltz	a5,80003fea <sys_fstat+0x32>
  return filestat(f, st);
    80003fde:	fe043583          	ld	a1,-32(s0)
    80003fe2:	fe843503          	ld	a0,-24(s0)
    80003fe6:	c36ff0ef          	jal	8000341c <filestat>
}
    80003fea:	60e2                	ld	ra,24(sp)
    80003fec:	6442                	ld	s0,16(sp)
    80003fee:	6105                	addi	sp,sp,32
    80003ff0:	8082                	ret

0000000080003ff2 <sys_link>:
{
    80003ff2:	7169                	addi	sp,sp,-304
    80003ff4:	f606                	sd	ra,296(sp)
    80003ff6:	f222                	sd	s0,288(sp)
    80003ff8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80003ffa:	08000613          	li	a2,128
    80003ffe:	ed040593          	addi	a1,s0,-304
    80004002:	4501                	li	a0,0
    80004004:	c4ffd0ef          	jal	80001c52 <argstr>
    return -1;
    80004008:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000400a:	0c054e63          	bltz	a0,800040e6 <sys_link+0xf4>
    8000400e:	08000613          	li	a2,128
    80004012:	f5040593          	addi	a1,s0,-176
    80004016:	4505                	li	a0,1
    80004018:	c3bfd0ef          	jal	80001c52 <argstr>
    return -1;
    8000401c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000401e:	0c054463          	bltz	a0,800040e6 <sys_link+0xf4>
    80004022:	ee26                	sd	s1,280(sp)
  begin_op();
    80004024:	f1dfe0ef          	jal	80002f40 <begin_op>
  if((ip = namei(old)) == 0){
    80004028:	ed040513          	addi	a0,s0,-304
    8000402c:	d59fe0ef          	jal	80002d84 <namei>
    80004030:	84aa                	mv	s1,a0
    80004032:	c53d                	beqz	a0,800040a0 <sys_link+0xae>
  ilock(ip);
    80004034:	e76fe0ef          	jal	800026aa <ilock>
  if(ip->type == T_DIR){
    80004038:	04449703          	lh	a4,68(s1)
    8000403c:	4785                	li	a5,1
    8000403e:	06f70663          	beq	a4,a5,800040aa <sys_link+0xb8>
    80004042:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004044:	04a4d783          	lhu	a5,74(s1)
    80004048:	2785                	addiw	a5,a5,1
    8000404a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000404e:	8526                	mv	a0,s1
    80004050:	da6fe0ef          	jal	800025f6 <iupdate>
  iunlock(ip);
    80004054:	8526                	mv	a0,s1
    80004056:	f02fe0ef          	jal	80002758 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000405a:	fd040593          	addi	a1,s0,-48
    8000405e:	f5040513          	addi	a0,s0,-176
    80004062:	d3dfe0ef          	jal	80002d9e <nameiparent>
    80004066:	892a                	mv	s2,a0
    80004068:	cd21                	beqz	a0,800040c0 <sys_link+0xce>
  ilock(dp);
    8000406a:	e40fe0ef          	jal	800026aa <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000406e:	00092703          	lw	a4,0(s2)
    80004072:	409c                	lw	a5,0(s1)
    80004074:	04f71363          	bne	a4,a5,800040ba <sys_link+0xc8>
    80004078:	40d0                	lw	a2,4(s1)
    8000407a:	fd040593          	addi	a1,s0,-48
    8000407e:	854a                	mv	a0,s2
    80004080:	c6bfe0ef          	jal	80002cea <dirlink>
    80004084:	02054b63          	bltz	a0,800040ba <sys_link+0xc8>
  iunlockput(dp);
    80004088:	854a                	mv	a0,s2
    8000408a:	82bfe0ef          	jal	800028b4 <iunlockput>
  iput(ip);
    8000408e:	8526                	mv	a0,s1
    80004090:	f9cfe0ef          	jal	8000282c <iput>
  end_op();
    80004094:	f17fe0ef          	jal	80002faa <end_op>
  return 0;
    80004098:	4781                	li	a5,0
    8000409a:	64f2                	ld	s1,280(sp)
    8000409c:	6952                	ld	s2,272(sp)
    8000409e:	a0a1                	j	800040e6 <sys_link+0xf4>
    end_op();
    800040a0:	f0bfe0ef          	jal	80002faa <end_op>
    return -1;
    800040a4:	57fd                	li	a5,-1
    800040a6:	64f2                	ld	s1,280(sp)
    800040a8:	a83d                	j	800040e6 <sys_link+0xf4>
    iunlockput(ip);
    800040aa:	8526                	mv	a0,s1
    800040ac:	809fe0ef          	jal	800028b4 <iunlockput>
    end_op();
    800040b0:	efbfe0ef          	jal	80002faa <end_op>
    return -1;
    800040b4:	57fd                	li	a5,-1
    800040b6:	64f2                	ld	s1,280(sp)
    800040b8:	a03d                	j	800040e6 <sys_link+0xf4>
    iunlockput(dp);
    800040ba:	854a                	mv	a0,s2
    800040bc:	ff8fe0ef          	jal	800028b4 <iunlockput>
  ilock(ip);
    800040c0:	8526                	mv	a0,s1
    800040c2:	de8fe0ef          	jal	800026aa <ilock>
  ip->nlink--;
    800040c6:	04a4d783          	lhu	a5,74(s1)
    800040ca:	37fd                	addiw	a5,a5,-1
    800040cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800040d0:	8526                	mv	a0,s1
    800040d2:	d24fe0ef          	jal	800025f6 <iupdate>
  iunlockput(ip);
    800040d6:	8526                	mv	a0,s1
    800040d8:	fdcfe0ef          	jal	800028b4 <iunlockput>
  end_op();
    800040dc:	ecffe0ef          	jal	80002faa <end_op>
  return -1;
    800040e0:	57fd                	li	a5,-1
    800040e2:	64f2                	ld	s1,280(sp)
    800040e4:	6952                	ld	s2,272(sp)
}
    800040e6:	853e                	mv	a0,a5
    800040e8:	70b2                	ld	ra,296(sp)
    800040ea:	7412                	ld	s0,288(sp)
    800040ec:	6155                	addi	sp,sp,304
    800040ee:	8082                	ret

00000000800040f0 <sys_unlink>:
{
    800040f0:	7151                	addi	sp,sp,-240
    800040f2:	f586                	sd	ra,232(sp)
    800040f4:	f1a2                	sd	s0,224(sp)
    800040f6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800040f8:	08000613          	li	a2,128
    800040fc:	f3040593          	addi	a1,s0,-208
    80004100:	4501                	li	a0,0
    80004102:	b51fd0ef          	jal	80001c52 <argstr>
    80004106:	16054063          	bltz	a0,80004266 <sys_unlink+0x176>
    8000410a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000410c:	e35fe0ef          	jal	80002f40 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004110:	fb040593          	addi	a1,s0,-80
    80004114:	f3040513          	addi	a0,s0,-208
    80004118:	c87fe0ef          	jal	80002d9e <nameiparent>
    8000411c:	84aa                	mv	s1,a0
    8000411e:	c945                	beqz	a0,800041ce <sys_unlink+0xde>
  ilock(dp);
    80004120:	d8afe0ef          	jal	800026aa <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004124:	00003597          	auipc	a1,0x3
    80004128:	4bc58593          	addi	a1,a1,1212 # 800075e0 <etext+0x5e0>
    8000412c:	fb040513          	addi	a0,s0,-80
    80004130:	9d9fe0ef          	jal	80002b08 <namecmp>
    80004134:	10050e63          	beqz	a0,80004250 <sys_unlink+0x160>
    80004138:	00003597          	auipc	a1,0x3
    8000413c:	4b058593          	addi	a1,a1,1200 # 800075e8 <etext+0x5e8>
    80004140:	fb040513          	addi	a0,s0,-80
    80004144:	9c5fe0ef          	jal	80002b08 <namecmp>
    80004148:	10050463          	beqz	a0,80004250 <sys_unlink+0x160>
    8000414c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000414e:	f2c40613          	addi	a2,s0,-212
    80004152:	fb040593          	addi	a1,s0,-80
    80004156:	8526                	mv	a0,s1
    80004158:	9c7fe0ef          	jal	80002b1e <dirlookup>
    8000415c:	892a                	mv	s2,a0
    8000415e:	0e050863          	beqz	a0,8000424e <sys_unlink+0x15e>
  ilock(ip);
    80004162:	d48fe0ef          	jal	800026aa <ilock>
  if(ip->nlink < 1)
    80004166:	04a91783          	lh	a5,74(s2)
    8000416a:	06f05763          	blez	a5,800041d8 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000416e:	04491703          	lh	a4,68(s2)
    80004172:	4785                	li	a5,1
    80004174:	06f70963          	beq	a4,a5,800041e6 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004178:	4641                	li	a2,16
    8000417a:	4581                	li	a1,0
    8000417c:	fc040513          	addi	a0,s0,-64
    80004180:	fcffb0ef          	jal	8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004184:	4741                	li	a4,16
    80004186:	f2c42683          	lw	a3,-212(s0)
    8000418a:	fc040613          	addi	a2,s0,-64
    8000418e:	4581                	li	a1,0
    80004190:	8526                	mv	a0,s1
    80004192:	869fe0ef          	jal	800029fa <writei>
    80004196:	47c1                	li	a5,16
    80004198:	08f51b63          	bne	a0,a5,8000422e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000419c:	04491703          	lh	a4,68(s2)
    800041a0:	4785                	li	a5,1
    800041a2:	08f70d63          	beq	a4,a5,8000423c <sys_unlink+0x14c>
  iunlockput(dp);
    800041a6:	8526                	mv	a0,s1
    800041a8:	f0cfe0ef          	jal	800028b4 <iunlockput>
  ip->nlink--;
    800041ac:	04a95783          	lhu	a5,74(s2)
    800041b0:	37fd                	addiw	a5,a5,-1
    800041b2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800041b6:	854a                	mv	a0,s2
    800041b8:	c3efe0ef          	jal	800025f6 <iupdate>
  iunlockput(ip);
    800041bc:	854a                	mv	a0,s2
    800041be:	ef6fe0ef          	jal	800028b4 <iunlockput>
  end_op();
    800041c2:	de9fe0ef          	jal	80002faa <end_op>
  return 0;
    800041c6:	4501                	li	a0,0
    800041c8:	64ee                	ld	s1,216(sp)
    800041ca:	694e                	ld	s2,208(sp)
    800041cc:	a849                	j	8000425e <sys_unlink+0x16e>
    end_op();
    800041ce:	dddfe0ef          	jal	80002faa <end_op>
    return -1;
    800041d2:	557d                	li	a0,-1
    800041d4:	64ee                	ld	s1,216(sp)
    800041d6:	a061                	j	8000425e <sys_unlink+0x16e>
    800041d8:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800041da:	00003517          	auipc	a0,0x3
    800041de:	41650513          	addi	a0,a0,1046 # 800075f0 <etext+0x5f0>
    800041e2:	280010ef          	jal	80005462 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800041e6:	04c92703          	lw	a4,76(s2)
    800041ea:	02000793          	li	a5,32
    800041ee:	f8e7f5e3          	bgeu	a5,a4,80004178 <sys_unlink+0x88>
    800041f2:	e5ce                	sd	s3,200(sp)
    800041f4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041f8:	4741                	li	a4,16
    800041fa:	86ce                	mv	a3,s3
    800041fc:	f1840613          	addi	a2,s0,-232
    80004200:	4581                	li	a1,0
    80004202:	854a                	mv	a0,s2
    80004204:	efafe0ef          	jal	800028fe <readi>
    80004208:	47c1                	li	a5,16
    8000420a:	00f51c63          	bne	a0,a5,80004222 <sys_unlink+0x132>
    if(de.inum != 0)
    8000420e:	f1845783          	lhu	a5,-232(s0)
    80004212:	efa1                	bnez	a5,8000426a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004214:	29c1                	addiw	s3,s3,16
    80004216:	04c92783          	lw	a5,76(s2)
    8000421a:	fcf9efe3          	bltu	s3,a5,800041f8 <sys_unlink+0x108>
    8000421e:	69ae                	ld	s3,200(sp)
    80004220:	bfa1                	j	80004178 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004222:	00003517          	auipc	a0,0x3
    80004226:	3e650513          	addi	a0,a0,998 # 80007608 <etext+0x608>
    8000422a:	238010ef          	jal	80005462 <panic>
    8000422e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004230:	00003517          	auipc	a0,0x3
    80004234:	3f050513          	addi	a0,a0,1008 # 80007620 <etext+0x620>
    80004238:	22a010ef          	jal	80005462 <panic>
    dp->nlink--;
    8000423c:	04a4d783          	lhu	a5,74(s1)
    80004240:	37fd                	addiw	a5,a5,-1
    80004242:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004246:	8526                	mv	a0,s1
    80004248:	baefe0ef          	jal	800025f6 <iupdate>
    8000424c:	bfa9                	j	800041a6 <sys_unlink+0xb6>
    8000424e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004250:	8526                	mv	a0,s1
    80004252:	e62fe0ef          	jal	800028b4 <iunlockput>
  end_op();
    80004256:	d55fe0ef          	jal	80002faa <end_op>
  return -1;
    8000425a:	557d                	li	a0,-1
    8000425c:	64ee                	ld	s1,216(sp)
}
    8000425e:	70ae                	ld	ra,232(sp)
    80004260:	740e                	ld	s0,224(sp)
    80004262:	616d                	addi	sp,sp,240
    80004264:	8082                	ret
    return -1;
    80004266:	557d                	li	a0,-1
    80004268:	bfdd                	j	8000425e <sys_unlink+0x16e>
    iunlockput(ip);
    8000426a:	854a                	mv	a0,s2
    8000426c:	e48fe0ef          	jal	800028b4 <iunlockput>
    goto bad;
    80004270:	694e                	ld	s2,208(sp)
    80004272:	69ae                	ld	s3,200(sp)
    80004274:	bff1                	j	80004250 <sys_unlink+0x160>

0000000080004276 <sys_open>:

uint64
sys_open(void)
{
    80004276:	7131                	addi	sp,sp,-192
    80004278:	fd06                	sd	ra,184(sp)
    8000427a:	f922                	sd	s0,176(sp)
    8000427c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000427e:	f4c40593          	addi	a1,s0,-180
    80004282:	4505                	li	a0,1
    80004284:	997fd0ef          	jal	80001c1a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004288:	08000613          	li	a2,128
    8000428c:	f5040593          	addi	a1,s0,-176
    80004290:	4501                	li	a0,0
    80004292:	9c1fd0ef          	jal	80001c52 <argstr>
    80004296:	87aa                	mv	a5,a0
    return -1;
    80004298:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000429a:	0a07c263          	bltz	a5,8000433e <sys_open+0xc8>
    8000429e:	f526                	sd	s1,168(sp)

  begin_op();
    800042a0:	ca1fe0ef          	jal	80002f40 <begin_op>

  if(omode & O_CREATE){
    800042a4:	f4c42783          	lw	a5,-180(s0)
    800042a8:	2007f793          	andi	a5,a5,512
    800042ac:	c3d5                	beqz	a5,80004350 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800042ae:	4681                	li	a3,0
    800042b0:	4601                	li	a2,0
    800042b2:	4589                	li	a1,2
    800042b4:	f5040513          	addi	a0,s0,-176
    800042b8:	aa9ff0ef          	jal	80003d60 <create>
    800042bc:	84aa                	mv	s1,a0
    if(ip == 0){
    800042be:	c541                	beqz	a0,80004346 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800042c0:	04449703          	lh	a4,68(s1)
    800042c4:	478d                	li	a5,3
    800042c6:	00f71763          	bne	a4,a5,800042d4 <sys_open+0x5e>
    800042ca:	0464d703          	lhu	a4,70(s1)
    800042ce:	47a5                	li	a5,9
    800042d0:	0ae7ed63          	bltu	a5,a4,8000438a <sys_open+0x114>
    800042d4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800042d6:	fe1fe0ef          	jal	800032b6 <filealloc>
    800042da:	892a                	mv	s2,a0
    800042dc:	c179                	beqz	a0,800043a2 <sys_open+0x12c>
    800042de:	ed4e                	sd	s3,152(sp)
    800042e0:	a43ff0ef          	jal	80003d22 <fdalloc>
    800042e4:	89aa                	mv	s3,a0
    800042e6:	0a054a63          	bltz	a0,8000439a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800042ea:	04449703          	lh	a4,68(s1)
    800042ee:	478d                	li	a5,3
    800042f0:	0cf70263          	beq	a4,a5,800043b4 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800042f4:	4789                	li	a5,2
    800042f6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800042fa:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800042fe:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004302:	f4c42783          	lw	a5,-180(s0)
    80004306:	0017c713          	xori	a4,a5,1
    8000430a:	8b05                	andi	a4,a4,1
    8000430c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004310:	0037f713          	andi	a4,a5,3
    80004314:	00e03733          	snez	a4,a4
    80004318:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000431c:	4007f793          	andi	a5,a5,1024
    80004320:	c791                	beqz	a5,8000432c <sys_open+0xb6>
    80004322:	04449703          	lh	a4,68(s1)
    80004326:	4789                	li	a5,2
    80004328:	08f70d63          	beq	a4,a5,800043c2 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000432c:	8526                	mv	a0,s1
    8000432e:	c2afe0ef          	jal	80002758 <iunlock>
  end_op();
    80004332:	c79fe0ef          	jal	80002faa <end_op>

  return fd;
    80004336:	854e                	mv	a0,s3
    80004338:	74aa                	ld	s1,168(sp)
    8000433a:	790a                	ld	s2,160(sp)
    8000433c:	69ea                	ld	s3,152(sp)
}
    8000433e:	70ea                	ld	ra,184(sp)
    80004340:	744a                	ld	s0,176(sp)
    80004342:	6129                	addi	sp,sp,192
    80004344:	8082                	ret
      end_op();
    80004346:	c65fe0ef          	jal	80002faa <end_op>
      return -1;
    8000434a:	557d                	li	a0,-1
    8000434c:	74aa                	ld	s1,168(sp)
    8000434e:	bfc5                	j	8000433e <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004350:	f5040513          	addi	a0,s0,-176
    80004354:	a31fe0ef          	jal	80002d84 <namei>
    80004358:	84aa                	mv	s1,a0
    8000435a:	c11d                	beqz	a0,80004380 <sys_open+0x10a>
    ilock(ip);
    8000435c:	b4efe0ef          	jal	800026aa <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004360:	04449703          	lh	a4,68(s1)
    80004364:	4785                	li	a5,1
    80004366:	f4f71de3          	bne	a4,a5,800042c0 <sys_open+0x4a>
    8000436a:	f4c42783          	lw	a5,-180(s0)
    8000436e:	d3bd                	beqz	a5,800042d4 <sys_open+0x5e>
      iunlockput(ip);
    80004370:	8526                	mv	a0,s1
    80004372:	d42fe0ef          	jal	800028b4 <iunlockput>
      end_op();
    80004376:	c35fe0ef          	jal	80002faa <end_op>
      return -1;
    8000437a:	557d                	li	a0,-1
    8000437c:	74aa                	ld	s1,168(sp)
    8000437e:	b7c1                	j	8000433e <sys_open+0xc8>
      end_op();
    80004380:	c2bfe0ef          	jal	80002faa <end_op>
      return -1;
    80004384:	557d                	li	a0,-1
    80004386:	74aa                	ld	s1,168(sp)
    80004388:	bf5d                	j	8000433e <sys_open+0xc8>
    iunlockput(ip);
    8000438a:	8526                	mv	a0,s1
    8000438c:	d28fe0ef          	jal	800028b4 <iunlockput>
    end_op();
    80004390:	c1bfe0ef          	jal	80002faa <end_op>
    return -1;
    80004394:	557d                	li	a0,-1
    80004396:	74aa                	ld	s1,168(sp)
    80004398:	b75d                	j	8000433e <sys_open+0xc8>
      fileclose(f);
    8000439a:	854a                	mv	a0,s2
    8000439c:	fbffe0ef          	jal	8000335a <fileclose>
    800043a0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800043a2:	8526                	mv	a0,s1
    800043a4:	d10fe0ef          	jal	800028b4 <iunlockput>
    end_op();
    800043a8:	c03fe0ef          	jal	80002faa <end_op>
    return -1;
    800043ac:	557d                	li	a0,-1
    800043ae:	74aa                	ld	s1,168(sp)
    800043b0:	790a                	ld	s2,160(sp)
    800043b2:	b771                	j	8000433e <sys_open+0xc8>
    f->type = FD_DEVICE;
    800043b4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800043b8:	04649783          	lh	a5,70(s1)
    800043bc:	02f91223          	sh	a5,36(s2)
    800043c0:	bf3d                	j	800042fe <sys_open+0x88>
    itrunc(ip);
    800043c2:	8526                	mv	a0,s1
    800043c4:	bd4fe0ef          	jal	80002798 <itrunc>
    800043c8:	b795                	j	8000432c <sys_open+0xb6>

00000000800043ca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800043ca:	7175                	addi	sp,sp,-144
    800043cc:	e506                	sd	ra,136(sp)
    800043ce:	e122                	sd	s0,128(sp)
    800043d0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800043d2:	b6ffe0ef          	jal	80002f40 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800043d6:	08000613          	li	a2,128
    800043da:	f7040593          	addi	a1,s0,-144
    800043de:	4501                	li	a0,0
    800043e0:	873fd0ef          	jal	80001c52 <argstr>
    800043e4:	02054363          	bltz	a0,8000440a <sys_mkdir+0x40>
    800043e8:	4681                	li	a3,0
    800043ea:	4601                	li	a2,0
    800043ec:	4585                	li	a1,1
    800043ee:	f7040513          	addi	a0,s0,-144
    800043f2:	96fff0ef          	jal	80003d60 <create>
    800043f6:	c911                	beqz	a0,8000440a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800043f8:	cbcfe0ef          	jal	800028b4 <iunlockput>
  end_op();
    800043fc:	baffe0ef          	jal	80002faa <end_op>
  return 0;
    80004400:	4501                	li	a0,0
}
    80004402:	60aa                	ld	ra,136(sp)
    80004404:	640a                	ld	s0,128(sp)
    80004406:	6149                	addi	sp,sp,144
    80004408:	8082                	ret
    end_op();
    8000440a:	ba1fe0ef          	jal	80002faa <end_op>
    return -1;
    8000440e:	557d                	li	a0,-1
    80004410:	bfcd                	j	80004402 <sys_mkdir+0x38>

0000000080004412 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004412:	7135                	addi	sp,sp,-160
    80004414:	ed06                	sd	ra,152(sp)
    80004416:	e922                	sd	s0,144(sp)
    80004418:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000441a:	b27fe0ef          	jal	80002f40 <begin_op>
  argint(1, &major);
    8000441e:	f6c40593          	addi	a1,s0,-148
    80004422:	4505                	li	a0,1
    80004424:	ff6fd0ef          	jal	80001c1a <argint>
  argint(2, &minor);
    80004428:	f6840593          	addi	a1,s0,-152
    8000442c:	4509                	li	a0,2
    8000442e:	fecfd0ef          	jal	80001c1a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004432:	08000613          	li	a2,128
    80004436:	f7040593          	addi	a1,s0,-144
    8000443a:	4501                	li	a0,0
    8000443c:	817fd0ef          	jal	80001c52 <argstr>
    80004440:	02054563          	bltz	a0,8000446a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004444:	f6841683          	lh	a3,-152(s0)
    80004448:	f6c41603          	lh	a2,-148(s0)
    8000444c:	458d                	li	a1,3
    8000444e:	f7040513          	addi	a0,s0,-144
    80004452:	90fff0ef          	jal	80003d60 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004456:	c911                	beqz	a0,8000446a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004458:	c5cfe0ef          	jal	800028b4 <iunlockput>
  end_op();
    8000445c:	b4ffe0ef          	jal	80002faa <end_op>
  return 0;
    80004460:	4501                	li	a0,0
}
    80004462:	60ea                	ld	ra,152(sp)
    80004464:	644a                	ld	s0,144(sp)
    80004466:	610d                	addi	sp,sp,160
    80004468:	8082                	ret
    end_op();
    8000446a:	b41fe0ef          	jal	80002faa <end_op>
    return -1;
    8000446e:	557d                	li	a0,-1
    80004470:	bfcd                	j	80004462 <sys_mknod+0x50>

0000000080004472 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004472:	7135                	addi	sp,sp,-160
    80004474:	ed06                	sd	ra,152(sp)
    80004476:	e922                	sd	s0,144(sp)
    80004478:	e14a                	sd	s2,128(sp)
    8000447a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000447c:	8ebfc0ef          	jal	80000d66 <myproc>
    80004480:	892a                	mv	s2,a0
  
  begin_op();
    80004482:	abffe0ef          	jal	80002f40 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004486:	08000613          	li	a2,128
    8000448a:	f6040593          	addi	a1,s0,-160
    8000448e:	4501                	li	a0,0
    80004490:	fc2fd0ef          	jal	80001c52 <argstr>
    80004494:	04054363          	bltz	a0,800044da <sys_chdir+0x68>
    80004498:	e526                	sd	s1,136(sp)
    8000449a:	f6040513          	addi	a0,s0,-160
    8000449e:	8e7fe0ef          	jal	80002d84 <namei>
    800044a2:	84aa                	mv	s1,a0
    800044a4:	c915                	beqz	a0,800044d8 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800044a6:	a04fe0ef          	jal	800026aa <ilock>
  if(ip->type != T_DIR){
    800044aa:	04449703          	lh	a4,68(s1)
    800044ae:	4785                	li	a5,1
    800044b0:	02f71963          	bne	a4,a5,800044e2 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800044b4:	8526                	mv	a0,s1
    800044b6:	aa2fe0ef          	jal	80002758 <iunlock>
  iput(p->cwd);
    800044ba:	15093503          	ld	a0,336(s2)
    800044be:	b6efe0ef          	jal	8000282c <iput>
  end_op();
    800044c2:	ae9fe0ef          	jal	80002faa <end_op>
  p->cwd = ip;
    800044c6:	14993823          	sd	s1,336(s2)
  return 0;
    800044ca:	4501                	li	a0,0
    800044cc:	64aa                	ld	s1,136(sp)
}
    800044ce:	60ea                	ld	ra,152(sp)
    800044d0:	644a                	ld	s0,144(sp)
    800044d2:	690a                	ld	s2,128(sp)
    800044d4:	610d                	addi	sp,sp,160
    800044d6:	8082                	ret
    800044d8:	64aa                	ld	s1,136(sp)
    end_op();
    800044da:	ad1fe0ef          	jal	80002faa <end_op>
    return -1;
    800044de:	557d                	li	a0,-1
    800044e0:	b7fd                	j	800044ce <sys_chdir+0x5c>
    iunlockput(ip);
    800044e2:	8526                	mv	a0,s1
    800044e4:	bd0fe0ef          	jal	800028b4 <iunlockput>
    end_op();
    800044e8:	ac3fe0ef          	jal	80002faa <end_op>
    return -1;
    800044ec:	557d                	li	a0,-1
    800044ee:	64aa                	ld	s1,136(sp)
    800044f0:	bff9                	j	800044ce <sys_chdir+0x5c>

00000000800044f2 <sys_exec>:

uint64
sys_exec(void)
{
    800044f2:	7121                	addi	sp,sp,-448
    800044f4:	ff06                	sd	ra,440(sp)
    800044f6:	fb22                	sd	s0,432(sp)
    800044f8:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800044fa:	e4840593          	addi	a1,s0,-440
    800044fe:	4505                	li	a0,1
    80004500:	f36fd0ef          	jal	80001c36 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004504:	08000613          	li	a2,128
    80004508:	f5040593          	addi	a1,s0,-176
    8000450c:	4501                	li	a0,0
    8000450e:	f44fd0ef          	jal	80001c52 <argstr>
    80004512:	87aa                	mv	a5,a0
    return -1;
    80004514:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004516:	0c07c463          	bltz	a5,800045de <sys_exec+0xec>
    8000451a:	f726                	sd	s1,424(sp)
    8000451c:	f34a                	sd	s2,416(sp)
    8000451e:	ef4e                	sd	s3,408(sp)
    80004520:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004522:	10000613          	li	a2,256
    80004526:	4581                	li	a1,0
    80004528:	e5040513          	addi	a0,s0,-432
    8000452c:	c23fb0ef          	jal	8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004530:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004534:	89a6                	mv	s3,s1
    80004536:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004538:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000453c:	00391513          	slli	a0,s2,0x3
    80004540:	e4040593          	addi	a1,s0,-448
    80004544:	e4843783          	ld	a5,-440(s0)
    80004548:	953e                	add	a0,a0,a5
    8000454a:	e46fd0ef          	jal	80001b90 <fetchaddr>
    8000454e:	02054663          	bltz	a0,8000457a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004552:	e4043783          	ld	a5,-448(s0)
    80004556:	c3a9                	beqz	a5,80004598 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004558:	ba7fb0ef          	jal	800000fe <kalloc>
    8000455c:	85aa                	mv	a1,a0
    8000455e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004562:	cd01                	beqz	a0,8000457a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004564:	6605                	lui	a2,0x1
    80004566:	e4043503          	ld	a0,-448(s0)
    8000456a:	e70fd0ef          	jal	80001bda <fetchstr>
    8000456e:	00054663          	bltz	a0,8000457a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004572:	0905                	addi	s2,s2,1
    80004574:	09a1                	addi	s3,s3,8
    80004576:	fd4913e3          	bne	s2,s4,8000453c <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000457a:	f5040913          	addi	s2,s0,-176
    8000457e:	6088                	ld	a0,0(s1)
    80004580:	c931                	beqz	a0,800045d4 <sys_exec+0xe2>
    kfree(argv[i]);
    80004582:	a9bfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004586:	04a1                	addi	s1,s1,8
    80004588:	ff249be3          	bne	s1,s2,8000457e <sys_exec+0x8c>
  return -1;
    8000458c:	557d                	li	a0,-1
    8000458e:	74ba                	ld	s1,424(sp)
    80004590:	791a                	ld	s2,416(sp)
    80004592:	69fa                	ld	s3,408(sp)
    80004594:	6a5a                	ld	s4,400(sp)
    80004596:	a0a1                	j	800045de <sys_exec+0xec>
      argv[i] = 0;
    80004598:	0009079b          	sext.w	a5,s2
    8000459c:	078e                	slli	a5,a5,0x3
    8000459e:	fd078793          	addi	a5,a5,-48
    800045a2:	97a2                	add	a5,a5,s0
    800045a4:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800045a8:	e5040593          	addi	a1,s0,-432
    800045ac:	f5040513          	addi	a0,s0,-176
    800045b0:	ba8ff0ef          	jal	80003958 <exec>
    800045b4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045b6:	f5040993          	addi	s3,s0,-176
    800045ba:	6088                	ld	a0,0(s1)
    800045bc:	c511                	beqz	a0,800045c8 <sys_exec+0xd6>
    kfree(argv[i]);
    800045be:	a5ffb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045c2:	04a1                	addi	s1,s1,8
    800045c4:	ff349be3          	bne	s1,s3,800045ba <sys_exec+0xc8>
  return ret;
    800045c8:	854a                	mv	a0,s2
    800045ca:	74ba                	ld	s1,424(sp)
    800045cc:	791a                	ld	s2,416(sp)
    800045ce:	69fa                	ld	s3,408(sp)
    800045d0:	6a5a                	ld	s4,400(sp)
    800045d2:	a031                	j	800045de <sys_exec+0xec>
  return -1;
    800045d4:	557d                	li	a0,-1
    800045d6:	74ba                	ld	s1,424(sp)
    800045d8:	791a                	ld	s2,416(sp)
    800045da:	69fa                	ld	s3,408(sp)
    800045dc:	6a5a                	ld	s4,400(sp)
}
    800045de:	70fa                	ld	ra,440(sp)
    800045e0:	745a                	ld	s0,432(sp)
    800045e2:	6139                	addi	sp,sp,448
    800045e4:	8082                	ret

00000000800045e6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800045e6:	7139                	addi	sp,sp,-64
    800045e8:	fc06                	sd	ra,56(sp)
    800045ea:	f822                	sd	s0,48(sp)
    800045ec:	f426                	sd	s1,40(sp)
    800045ee:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800045f0:	f76fc0ef          	jal	80000d66 <myproc>
    800045f4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800045f6:	fd840593          	addi	a1,s0,-40
    800045fa:	4501                	li	a0,0
    800045fc:	e3afd0ef          	jal	80001c36 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004600:	fc840593          	addi	a1,s0,-56
    80004604:	fd040513          	addi	a0,s0,-48
    80004608:	85cff0ef          	jal	80003664 <pipealloc>
    return -1;
    8000460c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000460e:	0a054463          	bltz	a0,800046b6 <sys_pipe+0xd0>
  fd0 = -1;
    80004612:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004616:	fd043503          	ld	a0,-48(s0)
    8000461a:	f08ff0ef          	jal	80003d22 <fdalloc>
    8000461e:	fca42223          	sw	a0,-60(s0)
    80004622:	08054163          	bltz	a0,800046a4 <sys_pipe+0xbe>
    80004626:	fc843503          	ld	a0,-56(s0)
    8000462a:	ef8ff0ef          	jal	80003d22 <fdalloc>
    8000462e:	fca42023          	sw	a0,-64(s0)
    80004632:	06054063          	bltz	a0,80004692 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004636:	4691                	li	a3,4
    80004638:	fc440613          	addi	a2,s0,-60
    8000463c:	fd843583          	ld	a1,-40(s0)
    80004640:	68a8                	ld	a0,80(s1)
    80004642:	b96fc0ef          	jal	800009d8 <copyout>
    80004646:	00054e63          	bltz	a0,80004662 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000464a:	4691                	li	a3,4
    8000464c:	fc040613          	addi	a2,s0,-64
    80004650:	fd843583          	ld	a1,-40(s0)
    80004654:	0591                	addi	a1,a1,4
    80004656:	68a8                	ld	a0,80(s1)
    80004658:	b80fc0ef          	jal	800009d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000465c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000465e:	04055c63          	bgez	a0,800046b6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004662:	fc442783          	lw	a5,-60(s0)
    80004666:	07e9                	addi	a5,a5,26
    80004668:	078e                	slli	a5,a5,0x3
    8000466a:	97a6                	add	a5,a5,s1
    8000466c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004670:	fc042783          	lw	a5,-64(s0)
    80004674:	07e9                	addi	a5,a5,26
    80004676:	078e                	slli	a5,a5,0x3
    80004678:	94be                	add	s1,s1,a5
    8000467a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000467e:	fd043503          	ld	a0,-48(s0)
    80004682:	cd9fe0ef          	jal	8000335a <fileclose>
    fileclose(wf);
    80004686:	fc843503          	ld	a0,-56(s0)
    8000468a:	cd1fe0ef          	jal	8000335a <fileclose>
    return -1;
    8000468e:	57fd                	li	a5,-1
    80004690:	a01d                	j	800046b6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004692:	fc442783          	lw	a5,-60(s0)
    80004696:	0007c763          	bltz	a5,800046a4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000469a:	07e9                	addi	a5,a5,26
    8000469c:	078e                	slli	a5,a5,0x3
    8000469e:	97a6                	add	a5,a5,s1
    800046a0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800046a4:	fd043503          	ld	a0,-48(s0)
    800046a8:	cb3fe0ef          	jal	8000335a <fileclose>
    fileclose(wf);
    800046ac:	fc843503          	ld	a0,-56(s0)
    800046b0:	cabfe0ef          	jal	8000335a <fileclose>
    return -1;
    800046b4:	57fd                	li	a5,-1
}
    800046b6:	853e                	mv	a0,a5
    800046b8:	70e2                	ld	ra,56(sp)
    800046ba:	7442                	ld	s0,48(sp)
    800046bc:	74a2                	ld	s1,40(sp)
    800046be:	6121                	addi	sp,sp,64
    800046c0:	8082                	ret
	...

00000000800046d0 <kernelvec>:
    800046d0:	7111                	addi	sp,sp,-256
    800046d2:	e006                	sd	ra,0(sp)
    800046d4:	e40a                	sd	sp,8(sp)
    800046d6:	e80e                	sd	gp,16(sp)
    800046d8:	ec12                	sd	tp,24(sp)
    800046da:	f016                	sd	t0,32(sp)
    800046dc:	f41a                	sd	t1,40(sp)
    800046de:	f81e                	sd	t2,48(sp)
    800046e0:	e4aa                	sd	a0,72(sp)
    800046e2:	e8ae                	sd	a1,80(sp)
    800046e4:	ecb2                	sd	a2,88(sp)
    800046e6:	f0b6                	sd	a3,96(sp)
    800046e8:	f4ba                	sd	a4,104(sp)
    800046ea:	f8be                	sd	a5,112(sp)
    800046ec:	fcc2                	sd	a6,120(sp)
    800046ee:	e146                	sd	a7,128(sp)
    800046f0:	edf2                	sd	t3,216(sp)
    800046f2:	f1f6                	sd	t4,224(sp)
    800046f4:	f5fa                	sd	t5,232(sp)
    800046f6:	f9fe                	sd	t6,240(sp)
    800046f8:	ba8fd0ef          	jal	80001aa0 <kerneltrap>
    800046fc:	6082                	ld	ra,0(sp)
    800046fe:	6122                	ld	sp,8(sp)
    80004700:	61c2                	ld	gp,16(sp)
    80004702:	7282                	ld	t0,32(sp)
    80004704:	7322                	ld	t1,40(sp)
    80004706:	73c2                	ld	t2,48(sp)
    80004708:	6526                	ld	a0,72(sp)
    8000470a:	65c6                	ld	a1,80(sp)
    8000470c:	6666                	ld	a2,88(sp)
    8000470e:	7686                	ld	a3,96(sp)
    80004710:	7726                	ld	a4,104(sp)
    80004712:	77c6                	ld	a5,112(sp)
    80004714:	7866                	ld	a6,120(sp)
    80004716:	688a                	ld	a7,128(sp)
    80004718:	6e6e                	ld	t3,216(sp)
    8000471a:	7e8e                	ld	t4,224(sp)
    8000471c:	7f2e                	ld	t5,232(sp)
    8000471e:	7fce                	ld	t6,240(sp)
    80004720:	6111                	addi	sp,sp,256
    80004722:	10200073          	sret
	...

000000008000472e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000472e:	1141                	addi	sp,sp,-16
    80004730:	e422                	sd	s0,8(sp)
    80004732:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004734:	0c0007b7          	lui	a5,0xc000
    80004738:	4705                	li	a4,1
    8000473a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000473c:	0c0007b7          	lui	a5,0xc000
    80004740:	c3d8                	sw	a4,4(a5)
}
    80004742:	6422                	ld	s0,8(sp)
    80004744:	0141                	addi	sp,sp,16
    80004746:	8082                	ret

0000000080004748 <plicinithart>:

void
plicinithart(void)
{
    80004748:	1141                	addi	sp,sp,-16
    8000474a:	e406                	sd	ra,8(sp)
    8000474c:	e022                	sd	s0,0(sp)
    8000474e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004750:	deafc0ef          	jal	80000d3a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004754:	0085171b          	slliw	a4,a0,0x8
    80004758:	0c0027b7          	lui	a5,0xc002
    8000475c:	97ba                	add	a5,a5,a4
    8000475e:	40200713          	li	a4,1026
    80004762:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004766:	00d5151b          	slliw	a0,a0,0xd
    8000476a:	0c2017b7          	lui	a5,0xc201
    8000476e:	97aa                	add	a5,a5,a0
    80004770:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004774:	60a2                	ld	ra,8(sp)
    80004776:	6402                	ld	s0,0(sp)
    80004778:	0141                	addi	sp,sp,16
    8000477a:	8082                	ret

000000008000477c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000477c:	1141                	addi	sp,sp,-16
    8000477e:	e406                	sd	ra,8(sp)
    80004780:	e022                	sd	s0,0(sp)
    80004782:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004784:	db6fc0ef          	jal	80000d3a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004788:	00d5151b          	slliw	a0,a0,0xd
    8000478c:	0c2017b7          	lui	a5,0xc201
    80004790:	97aa                	add	a5,a5,a0
  return irq;
}
    80004792:	43c8                	lw	a0,4(a5)
    80004794:	60a2                	ld	ra,8(sp)
    80004796:	6402                	ld	s0,0(sp)
    80004798:	0141                	addi	sp,sp,16
    8000479a:	8082                	ret

000000008000479c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	e426                	sd	s1,8(sp)
    800047a4:	1000                	addi	s0,sp,32
    800047a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800047a8:	d92fc0ef          	jal	80000d3a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800047ac:	00d5151b          	slliw	a0,a0,0xd
    800047b0:	0c2017b7          	lui	a5,0xc201
    800047b4:	97aa                	add	a5,a5,a0
    800047b6:	c3c4                	sw	s1,4(a5)
}
    800047b8:	60e2                	ld	ra,24(sp)
    800047ba:	6442                	ld	s0,16(sp)
    800047bc:	64a2                	ld	s1,8(sp)
    800047be:	6105                	addi	sp,sp,32
    800047c0:	8082                	ret

00000000800047c2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800047c2:	1141                	addi	sp,sp,-16
    800047c4:	e406                	sd	ra,8(sp)
    800047c6:	e022                	sd	s0,0(sp)
    800047c8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800047ca:	479d                	li	a5,7
    800047cc:	04a7ca63          	blt	a5,a0,80004820 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800047d0:	00017797          	auipc	a5,0x17
    800047d4:	bc078793          	addi	a5,a5,-1088 # 8001b390 <disk>
    800047d8:	97aa                	add	a5,a5,a0
    800047da:	0187c783          	lbu	a5,24(a5)
    800047de:	e7b9                	bnez	a5,8000482c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800047e0:	00451693          	slli	a3,a0,0x4
    800047e4:	00017797          	auipc	a5,0x17
    800047e8:	bac78793          	addi	a5,a5,-1108 # 8001b390 <disk>
    800047ec:	6398                	ld	a4,0(a5)
    800047ee:	9736                	add	a4,a4,a3
    800047f0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800047f4:	6398                	ld	a4,0(a5)
    800047f6:	9736                	add	a4,a4,a3
    800047f8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800047fc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004800:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004804:	97aa                	add	a5,a5,a0
    80004806:	4705                	li	a4,1
    80004808:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000480c:	00017517          	auipc	a0,0x17
    80004810:	b9c50513          	addi	a0,a0,-1124 # 8001b3a8 <disk+0x18>
    80004814:	b6dfc0ef          	jal	80001380 <wakeup>
}
    80004818:	60a2                	ld	ra,8(sp)
    8000481a:	6402                	ld	s0,0(sp)
    8000481c:	0141                	addi	sp,sp,16
    8000481e:	8082                	ret
    panic("free_desc 1");
    80004820:	00003517          	auipc	a0,0x3
    80004824:	e1050513          	addi	a0,a0,-496 # 80007630 <etext+0x630>
    80004828:	43b000ef          	jal	80005462 <panic>
    panic("free_desc 2");
    8000482c:	00003517          	auipc	a0,0x3
    80004830:	e1450513          	addi	a0,a0,-492 # 80007640 <etext+0x640>
    80004834:	42f000ef          	jal	80005462 <panic>

0000000080004838 <virtio_disk_init>:
{
    80004838:	1101                	addi	sp,sp,-32
    8000483a:	ec06                	sd	ra,24(sp)
    8000483c:	e822                	sd	s0,16(sp)
    8000483e:	e426                	sd	s1,8(sp)
    80004840:	e04a                	sd	s2,0(sp)
    80004842:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004844:	00003597          	auipc	a1,0x3
    80004848:	e0c58593          	addi	a1,a1,-500 # 80007650 <etext+0x650>
    8000484c:	00017517          	auipc	a0,0x17
    80004850:	c6c50513          	addi	a0,a0,-916 # 8001b4b8 <disk+0x128>
    80004854:	6bd000ef          	jal	80005710 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004858:	100017b7          	lui	a5,0x10001
    8000485c:	4398                	lw	a4,0(a5)
    8000485e:	2701                	sext.w	a4,a4
    80004860:	747277b7          	lui	a5,0x74727
    80004864:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004868:	18f71063          	bne	a4,a5,800049e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000486c:	100017b7          	lui	a5,0x10001
    80004870:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004872:	439c                	lw	a5,0(a5)
    80004874:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004876:	4709                	li	a4,2
    80004878:	16e79863          	bne	a5,a4,800049e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000487c:	100017b7          	lui	a5,0x10001
    80004880:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004882:	439c                	lw	a5,0(a5)
    80004884:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004886:	16e79163          	bne	a5,a4,800049e8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000488a:	100017b7          	lui	a5,0x10001
    8000488e:	47d8                	lw	a4,12(a5)
    80004890:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004892:	554d47b7          	lui	a5,0x554d4
    80004896:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000489a:	14f71763          	bne	a4,a5,800049e8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000489e:	100017b7          	lui	a5,0x10001
    800048a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800048a6:	4705                	li	a4,1
    800048a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048aa:	470d                	li	a4,3
    800048ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800048ae:	10001737          	lui	a4,0x10001
    800048b2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800048b4:	c7ffe737          	lui	a4,0xc7ffe
    800048b8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb18f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800048bc:	8ef9                	and	a3,a3,a4
    800048be:	10001737          	lui	a4,0x10001
    800048c2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048c4:	472d                	li	a4,11
    800048c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800048c8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800048cc:	439c                	lw	a5,0(a5)
    800048ce:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800048d2:	8ba1                	andi	a5,a5,8
    800048d4:	12078063          	beqz	a5,800049f4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800048d8:	100017b7          	lui	a5,0x10001
    800048dc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800048e0:	100017b7          	lui	a5,0x10001
    800048e4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800048e8:	439c                	lw	a5,0(a5)
    800048ea:	2781                	sext.w	a5,a5
    800048ec:	10079a63          	bnez	a5,80004a00 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800048f0:	100017b7          	lui	a5,0x10001
    800048f4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800048f8:	439c                	lw	a5,0(a5)
    800048fa:	2781                	sext.w	a5,a5
  if(max == 0)
    800048fc:	10078863          	beqz	a5,80004a0c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004900:	471d                	li	a4,7
    80004902:	10f77b63          	bgeu	a4,a5,80004a18 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004906:	ff8fb0ef          	jal	800000fe <kalloc>
    8000490a:	00017497          	auipc	s1,0x17
    8000490e:	a8648493          	addi	s1,s1,-1402 # 8001b390 <disk>
    80004912:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004914:	feafb0ef          	jal	800000fe <kalloc>
    80004918:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000491a:	fe4fb0ef          	jal	800000fe <kalloc>
    8000491e:	87aa                	mv	a5,a0
    80004920:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004922:	6088                	ld	a0,0(s1)
    80004924:	10050063          	beqz	a0,80004a24 <virtio_disk_init+0x1ec>
    80004928:	00017717          	auipc	a4,0x17
    8000492c:	a7073703          	ld	a4,-1424(a4) # 8001b398 <disk+0x8>
    80004930:	0e070a63          	beqz	a4,80004a24 <virtio_disk_init+0x1ec>
    80004934:	0e078863          	beqz	a5,80004a24 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004938:	6605                	lui	a2,0x1
    8000493a:	4581                	li	a1,0
    8000493c:	813fb0ef          	jal	8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    80004940:	00017497          	auipc	s1,0x17
    80004944:	a5048493          	addi	s1,s1,-1456 # 8001b390 <disk>
    80004948:	6605                	lui	a2,0x1
    8000494a:	4581                	li	a1,0
    8000494c:	6488                	ld	a0,8(s1)
    8000494e:	801fb0ef          	jal	8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    80004952:	6605                	lui	a2,0x1
    80004954:	4581                	li	a1,0
    80004956:	6888                	ld	a0,16(s1)
    80004958:	ff6fb0ef          	jal	8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000495c:	100017b7          	lui	a5,0x10001
    80004960:	4721                	li	a4,8
    80004962:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004964:	4098                	lw	a4,0(s1)
    80004966:	100017b7          	lui	a5,0x10001
    8000496a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000496e:	40d8                	lw	a4,4(s1)
    80004970:	100017b7          	lui	a5,0x10001
    80004974:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004978:	649c                	ld	a5,8(s1)
    8000497a:	0007869b          	sext.w	a3,a5
    8000497e:	10001737          	lui	a4,0x10001
    80004982:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004986:	9781                	srai	a5,a5,0x20
    80004988:	10001737          	lui	a4,0x10001
    8000498c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004990:	689c                	ld	a5,16(s1)
    80004992:	0007869b          	sext.w	a3,a5
    80004996:	10001737          	lui	a4,0x10001
    8000499a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000499e:	9781                	srai	a5,a5,0x20
    800049a0:	10001737          	lui	a4,0x10001
    800049a4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800049a8:	10001737          	lui	a4,0x10001
    800049ac:	4785                	li	a5,1
    800049ae:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800049b0:	00f48c23          	sb	a5,24(s1)
    800049b4:	00f48ca3          	sb	a5,25(s1)
    800049b8:	00f48d23          	sb	a5,26(s1)
    800049bc:	00f48da3          	sb	a5,27(s1)
    800049c0:	00f48e23          	sb	a5,28(s1)
    800049c4:	00f48ea3          	sb	a5,29(s1)
    800049c8:	00f48f23          	sb	a5,30(s1)
    800049cc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800049d0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800049d4:	100017b7          	lui	a5,0x10001
    800049d8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800049dc:	60e2                	ld	ra,24(sp)
    800049de:	6442                	ld	s0,16(sp)
    800049e0:	64a2                	ld	s1,8(sp)
    800049e2:	6902                	ld	s2,0(sp)
    800049e4:	6105                	addi	sp,sp,32
    800049e6:	8082                	ret
    panic("could not find virtio disk");
    800049e8:	00003517          	auipc	a0,0x3
    800049ec:	c7850513          	addi	a0,a0,-904 # 80007660 <etext+0x660>
    800049f0:	273000ef          	jal	80005462 <panic>
    panic("virtio disk FEATURES_OK unset");
    800049f4:	00003517          	auipc	a0,0x3
    800049f8:	c8c50513          	addi	a0,a0,-884 # 80007680 <etext+0x680>
    800049fc:	267000ef          	jal	80005462 <panic>
    panic("virtio disk should not be ready");
    80004a00:	00003517          	auipc	a0,0x3
    80004a04:	ca050513          	addi	a0,a0,-864 # 800076a0 <etext+0x6a0>
    80004a08:	25b000ef          	jal	80005462 <panic>
    panic("virtio disk has no queue 0");
    80004a0c:	00003517          	auipc	a0,0x3
    80004a10:	cb450513          	addi	a0,a0,-844 # 800076c0 <etext+0x6c0>
    80004a14:	24f000ef          	jal	80005462 <panic>
    panic("virtio disk max queue too short");
    80004a18:	00003517          	auipc	a0,0x3
    80004a1c:	cc850513          	addi	a0,a0,-824 # 800076e0 <etext+0x6e0>
    80004a20:	243000ef          	jal	80005462 <panic>
    panic("virtio disk kalloc");
    80004a24:	00003517          	auipc	a0,0x3
    80004a28:	cdc50513          	addi	a0,a0,-804 # 80007700 <etext+0x700>
    80004a2c:	237000ef          	jal	80005462 <panic>

0000000080004a30 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004a30:	7159                	addi	sp,sp,-112
    80004a32:	f486                	sd	ra,104(sp)
    80004a34:	f0a2                	sd	s0,96(sp)
    80004a36:	eca6                	sd	s1,88(sp)
    80004a38:	e8ca                	sd	s2,80(sp)
    80004a3a:	e4ce                	sd	s3,72(sp)
    80004a3c:	e0d2                	sd	s4,64(sp)
    80004a3e:	fc56                	sd	s5,56(sp)
    80004a40:	f85a                	sd	s6,48(sp)
    80004a42:	f45e                	sd	s7,40(sp)
    80004a44:	f062                	sd	s8,32(sp)
    80004a46:	ec66                	sd	s9,24(sp)
    80004a48:	1880                	addi	s0,sp,112
    80004a4a:	8a2a                	mv	s4,a0
    80004a4c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004a4e:	00c52c83          	lw	s9,12(a0)
    80004a52:	001c9c9b          	slliw	s9,s9,0x1
    80004a56:	1c82                	slli	s9,s9,0x20
    80004a58:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004a5c:	00017517          	auipc	a0,0x17
    80004a60:	a5c50513          	addi	a0,a0,-1444 # 8001b4b8 <disk+0x128>
    80004a64:	52d000ef          	jal	80005790 <acquire>
  for(int i = 0; i < 3; i++){
    80004a68:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004a6a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004a6c:	00017b17          	auipc	s6,0x17
    80004a70:	924b0b13          	addi	s6,s6,-1756 # 8001b390 <disk>
  for(int i = 0; i < 3; i++){
    80004a74:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004a76:	00017c17          	auipc	s8,0x17
    80004a7a:	a42c0c13          	addi	s8,s8,-1470 # 8001b4b8 <disk+0x128>
    80004a7e:	a8b9                	j	80004adc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004a80:	00fb0733          	add	a4,s6,a5
    80004a84:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004a88:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004a8a:	0207c563          	bltz	a5,80004ab4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004a8e:	2905                	addiw	s2,s2,1
    80004a90:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004a92:	05590963          	beq	s2,s5,80004ae4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004a96:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004a98:	00017717          	auipc	a4,0x17
    80004a9c:	8f870713          	addi	a4,a4,-1800 # 8001b390 <disk>
    80004aa0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004aa2:	01874683          	lbu	a3,24(a4)
    80004aa6:	fee9                	bnez	a3,80004a80 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004aa8:	2785                	addiw	a5,a5,1
    80004aaa:	0705                	addi	a4,a4,1
    80004aac:	fe979be3          	bne	a5,s1,80004aa2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004ab0:	57fd                	li	a5,-1
    80004ab2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004ab4:	01205d63          	blez	s2,80004ace <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004ab8:	f9042503          	lw	a0,-112(s0)
    80004abc:	d07ff0ef          	jal	800047c2 <free_desc>
      for(int j = 0; j < i; j++)
    80004ac0:	4785                	li	a5,1
    80004ac2:	0127d663          	bge	a5,s2,80004ace <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004ac6:	f9442503          	lw	a0,-108(s0)
    80004aca:	cf9ff0ef          	jal	800047c2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004ace:	85e2                	mv	a1,s8
    80004ad0:	00017517          	auipc	a0,0x17
    80004ad4:	8d850513          	addi	a0,a0,-1832 # 8001b3a8 <disk+0x18>
    80004ad8:	85dfc0ef          	jal	80001334 <sleep>
  for(int i = 0; i < 3; i++){
    80004adc:	f9040613          	addi	a2,s0,-112
    80004ae0:	894e                	mv	s2,s3
    80004ae2:	bf55                	j	80004a96 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004ae4:	f9042503          	lw	a0,-112(s0)
    80004ae8:	00451693          	slli	a3,a0,0x4

  if(write)
    80004aec:	00017797          	auipc	a5,0x17
    80004af0:	8a478793          	addi	a5,a5,-1884 # 8001b390 <disk>
    80004af4:	00a50713          	addi	a4,a0,10
    80004af8:	0712                	slli	a4,a4,0x4
    80004afa:	973e                	add	a4,a4,a5
    80004afc:	01703633          	snez	a2,s7
    80004b00:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004b02:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004b06:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b0a:	6398                	ld	a4,0(a5)
    80004b0c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b0e:	0a868613          	addi	a2,a3,168
    80004b12:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b14:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004b16:	6390                	ld	a2,0(a5)
    80004b18:	00d605b3          	add	a1,a2,a3
    80004b1c:	4741                	li	a4,16
    80004b1e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004b20:	4805                	li	a6,1
    80004b22:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004b26:	f9442703          	lw	a4,-108(s0)
    80004b2a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004b2e:	0712                	slli	a4,a4,0x4
    80004b30:	963a                	add	a2,a2,a4
    80004b32:	058a0593          	addi	a1,s4,88
    80004b36:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004b38:	0007b883          	ld	a7,0(a5)
    80004b3c:	9746                	add	a4,a4,a7
    80004b3e:	40000613          	li	a2,1024
    80004b42:	c710                	sw	a2,8(a4)
  if(write)
    80004b44:	001bb613          	seqz	a2,s7
    80004b48:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004b4c:	00166613          	ori	a2,a2,1
    80004b50:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004b54:	f9842583          	lw	a1,-104(s0)
    80004b58:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004b5c:	00250613          	addi	a2,a0,2
    80004b60:	0612                	slli	a2,a2,0x4
    80004b62:	963e                	add	a2,a2,a5
    80004b64:	577d                	li	a4,-1
    80004b66:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004b6a:	0592                	slli	a1,a1,0x4
    80004b6c:	98ae                	add	a7,a7,a1
    80004b6e:	03068713          	addi	a4,a3,48
    80004b72:	973e                	add	a4,a4,a5
    80004b74:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004b78:	6398                	ld	a4,0(a5)
    80004b7a:	972e                	add	a4,a4,a1
    80004b7c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004b80:	4689                	li	a3,2
    80004b82:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004b86:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004b8a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004b8e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004b92:	6794                	ld	a3,8(a5)
    80004b94:	0026d703          	lhu	a4,2(a3)
    80004b98:	8b1d                	andi	a4,a4,7
    80004b9a:	0706                	slli	a4,a4,0x1
    80004b9c:	96ba                	add	a3,a3,a4
    80004b9e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004ba2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004ba6:	6798                	ld	a4,8(a5)
    80004ba8:	00275783          	lhu	a5,2(a4)
    80004bac:	2785                	addiw	a5,a5,1
    80004bae:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004bb2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004bb6:	100017b7          	lui	a5,0x10001
    80004bba:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004bbe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004bc2:	00017917          	auipc	s2,0x17
    80004bc6:	8f690913          	addi	s2,s2,-1802 # 8001b4b8 <disk+0x128>
  while(b->disk == 1) {
    80004bca:	4485                	li	s1,1
    80004bcc:	01079a63          	bne	a5,a6,80004be0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004bd0:	85ca                	mv	a1,s2
    80004bd2:	8552                	mv	a0,s4
    80004bd4:	f60fc0ef          	jal	80001334 <sleep>
  while(b->disk == 1) {
    80004bd8:	004a2783          	lw	a5,4(s4)
    80004bdc:	fe978ae3          	beq	a5,s1,80004bd0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004be0:	f9042903          	lw	s2,-112(s0)
    80004be4:	00290713          	addi	a4,s2,2
    80004be8:	0712                	slli	a4,a4,0x4
    80004bea:	00016797          	auipc	a5,0x16
    80004bee:	7a678793          	addi	a5,a5,1958 # 8001b390 <disk>
    80004bf2:	97ba                	add	a5,a5,a4
    80004bf4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004bf8:	00016997          	auipc	s3,0x16
    80004bfc:	79898993          	addi	s3,s3,1944 # 8001b390 <disk>
    80004c00:	00491713          	slli	a4,s2,0x4
    80004c04:	0009b783          	ld	a5,0(s3)
    80004c08:	97ba                	add	a5,a5,a4
    80004c0a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004c0e:	854a                	mv	a0,s2
    80004c10:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004c14:	bafff0ef          	jal	800047c2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004c18:	8885                	andi	s1,s1,1
    80004c1a:	f0fd                	bnez	s1,80004c00 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004c1c:	00017517          	auipc	a0,0x17
    80004c20:	89c50513          	addi	a0,a0,-1892 # 8001b4b8 <disk+0x128>
    80004c24:	405000ef          	jal	80005828 <release>
}
    80004c28:	70a6                	ld	ra,104(sp)
    80004c2a:	7406                	ld	s0,96(sp)
    80004c2c:	64e6                	ld	s1,88(sp)
    80004c2e:	6946                	ld	s2,80(sp)
    80004c30:	69a6                	ld	s3,72(sp)
    80004c32:	6a06                	ld	s4,64(sp)
    80004c34:	7ae2                	ld	s5,56(sp)
    80004c36:	7b42                	ld	s6,48(sp)
    80004c38:	7ba2                	ld	s7,40(sp)
    80004c3a:	7c02                	ld	s8,32(sp)
    80004c3c:	6ce2                	ld	s9,24(sp)
    80004c3e:	6165                	addi	sp,sp,112
    80004c40:	8082                	ret

0000000080004c42 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004c42:	1101                	addi	sp,sp,-32
    80004c44:	ec06                	sd	ra,24(sp)
    80004c46:	e822                	sd	s0,16(sp)
    80004c48:	e426                	sd	s1,8(sp)
    80004c4a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004c4c:	00016497          	auipc	s1,0x16
    80004c50:	74448493          	addi	s1,s1,1860 # 8001b390 <disk>
    80004c54:	00017517          	auipc	a0,0x17
    80004c58:	86450513          	addi	a0,a0,-1948 # 8001b4b8 <disk+0x128>
    80004c5c:	335000ef          	jal	80005790 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004c60:	100017b7          	lui	a5,0x10001
    80004c64:	53b8                	lw	a4,96(a5)
    80004c66:	8b0d                	andi	a4,a4,3
    80004c68:	100017b7          	lui	a5,0x10001
    80004c6c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004c6e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004c72:	689c                	ld	a5,16(s1)
    80004c74:	0204d703          	lhu	a4,32(s1)
    80004c78:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004c7c:	04f70663          	beq	a4,a5,80004cc8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004c80:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004c84:	6898                	ld	a4,16(s1)
    80004c86:	0204d783          	lhu	a5,32(s1)
    80004c8a:	8b9d                	andi	a5,a5,7
    80004c8c:	078e                	slli	a5,a5,0x3
    80004c8e:	97ba                	add	a5,a5,a4
    80004c90:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004c92:	00278713          	addi	a4,a5,2
    80004c96:	0712                	slli	a4,a4,0x4
    80004c98:	9726                	add	a4,a4,s1
    80004c9a:	01074703          	lbu	a4,16(a4)
    80004c9e:	e321                	bnez	a4,80004cde <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004ca0:	0789                	addi	a5,a5,2
    80004ca2:	0792                	slli	a5,a5,0x4
    80004ca4:	97a6                	add	a5,a5,s1
    80004ca6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004ca8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004cac:	ed4fc0ef          	jal	80001380 <wakeup>

    disk.used_idx += 1;
    80004cb0:	0204d783          	lhu	a5,32(s1)
    80004cb4:	2785                	addiw	a5,a5,1
    80004cb6:	17c2                	slli	a5,a5,0x30
    80004cb8:	93c1                	srli	a5,a5,0x30
    80004cba:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004cbe:	6898                	ld	a4,16(s1)
    80004cc0:	00275703          	lhu	a4,2(a4)
    80004cc4:	faf71ee3          	bne	a4,a5,80004c80 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004cc8:	00016517          	auipc	a0,0x16
    80004ccc:	7f050513          	addi	a0,a0,2032 # 8001b4b8 <disk+0x128>
    80004cd0:	359000ef          	jal	80005828 <release>
}
    80004cd4:	60e2                	ld	ra,24(sp)
    80004cd6:	6442                	ld	s0,16(sp)
    80004cd8:	64a2                	ld	s1,8(sp)
    80004cda:	6105                	addi	sp,sp,32
    80004cdc:	8082                	ret
      panic("virtio_disk_intr status");
    80004cde:	00003517          	auipc	a0,0x3
    80004ce2:	a3a50513          	addi	a0,a0,-1478 # 80007718 <etext+0x718>
    80004ce6:	77c000ef          	jal	80005462 <panic>

0000000080004cea <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004cea:	1141                	addi	sp,sp,-16
    80004cec:	e422                	sd	s0,8(sp)
    80004cee:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004cf0:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004cf4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004cf8:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004cfc:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004d00:	577d                	li	a4,-1
    80004d02:	177e                	slli	a4,a4,0x3f
    80004d04:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004d06:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004d0a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004d0e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004d12:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004d16:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004d1a:	000f4737          	lui	a4,0xf4
    80004d1e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004d22:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004d24:	14d79073          	csrw	stimecmp,a5
}
    80004d28:	6422                	ld	s0,8(sp)
    80004d2a:	0141                	addi	sp,sp,16
    80004d2c:	8082                	ret

0000000080004d2e <start>:
{
    80004d2e:	1141                	addi	sp,sp,-16
    80004d30:	e406                	sd	ra,8(sp)
    80004d32:	e022                	sd	s0,0(sp)
    80004d34:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004d36:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004d3a:	7779                	lui	a4,0xffffe
    80004d3c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb22f>
    80004d40:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004d42:	6705                	lui	a4,0x1
    80004d44:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004d48:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004d4a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004d4e:	ffffb797          	auipc	a5,0xffffb
    80004d52:	59a78793          	addi	a5,a5,1434 # 800002e8 <main>
    80004d56:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004d5a:	4781                	li	a5,0
    80004d5c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004d60:	67c1                	lui	a5,0x10
    80004d62:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004d64:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004d68:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004d6c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004d70:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004d74:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004d78:	57fd                	li	a5,-1
    80004d7a:	83a9                	srli	a5,a5,0xa
    80004d7c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004d80:	47bd                	li	a5,15
    80004d82:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004d86:	f65ff0ef          	jal	80004cea <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004d8a:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004d8e:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004d90:	823e                	mv	tp,a5
  asm volatile("mret");
    80004d92:	30200073          	mret
}
    80004d96:	60a2                	ld	ra,8(sp)
    80004d98:	6402                	ld	s0,0(sp)
    80004d9a:	0141                	addi	sp,sp,16
    80004d9c:	8082                	ret

0000000080004d9e <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004d9e:	715d                	addi	sp,sp,-80
    80004da0:	e486                	sd	ra,72(sp)
    80004da2:	e0a2                	sd	s0,64(sp)
    80004da4:	f84a                	sd	s2,48(sp)
    80004da6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004da8:	04c05263          	blez	a2,80004dec <consolewrite+0x4e>
    80004dac:	fc26                	sd	s1,56(sp)
    80004dae:	f44e                	sd	s3,40(sp)
    80004db0:	f052                	sd	s4,32(sp)
    80004db2:	ec56                	sd	s5,24(sp)
    80004db4:	8a2a                	mv	s4,a0
    80004db6:	84ae                	mv	s1,a1
    80004db8:	89b2                	mv	s3,a2
    80004dba:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004dbc:	5afd                	li	s5,-1
    80004dbe:	4685                	li	a3,1
    80004dc0:	8626                	mv	a2,s1
    80004dc2:	85d2                	mv	a1,s4
    80004dc4:	fbf40513          	addi	a0,s0,-65
    80004dc8:	913fc0ef          	jal	800016da <either_copyin>
    80004dcc:	03550263          	beq	a0,s5,80004df0 <consolewrite+0x52>
      break;
    uartputc(c);
    80004dd0:	fbf44503          	lbu	a0,-65(s0)
    80004dd4:	035000ef          	jal	80005608 <uartputc>
  for(i = 0; i < n; i++){
    80004dd8:	2905                	addiw	s2,s2,1
    80004dda:	0485                	addi	s1,s1,1
    80004ddc:	ff2991e3          	bne	s3,s2,80004dbe <consolewrite+0x20>
    80004de0:	894e                	mv	s2,s3
    80004de2:	74e2                	ld	s1,56(sp)
    80004de4:	79a2                	ld	s3,40(sp)
    80004de6:	7a02                	ld	s4,32(sp)
    80004de8:	6ae2                	ld	s5,24(sp)
    80004dea:	a039                	j	80004df8 <consolewrite+0x5a>
    80004dec:	4901                	li	s2,0
    80004dee:	a029                	j	80004df8 <consolewrite+0x5a>
    80004df0:	74e2                	ld	s1,56(sp)
    80004df2:	79a2                	ld	s3,40(sp)
    80004df4:	7a02                	ld	s4,32(sp)
    80004df6:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80004df8:	854a                	mv	a0,s2
    80004dfa:	60a6                	ld	ra,72(sp)
    80004dfc:	6406                	ld	s0,64(sp)
    80004dfe:	7942                	ld	s2,48(sp)
    80004e00:	6161                	addi	sp,sp,80
    80004e02:	8082                	ret

0000000080004e04 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004e04:	711d                	addi	sp,sp,-96
    80004e06:	ec86                	sd	ra,88(sp)
    80004e08:	e8a2                	sd	s0,80(sp)
    80004e0a:	e4a6                	sd	s1,72(sp)
    80004e0c:	e0ca                	sd	s2,64(sp)
    80004e0e:	fc4e                	sd	s3,56(sp)
    80004e10:	f852                	sd	s4,48(sp)
    80004e12:	f456                	sd	s5,40(sp)
    80004e14:	f05a                	sd	s6,32(sp)
    80004e16:	1080                	addi	s0,sp,96
    80004e18:	8aaa                	mv	s5,a0
    80004e1a:	8a2e                	mv	s4,a1
    80004e1c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004e1e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004e22:	0001e517          	auipc	a0,0x1e
    80004e26:	6ae50513          	addi	a0,a0,1710 # 800234d0 <cons>
    80004e2a:	167000ef          	jal	80005790 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004e2e:	0001e497          	auipc	s1,0x1e
    80004e32:	6a248493          	addi	s1,s1,1698 # 800234d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004e36:	0001e917          	auipc	s2,0x1e
    80004e3a:	73290913          	addi	s2,s2,1842 # 80023568 <cons+0x98>
  while(n > 0){
    80004e3e:	0b305d63          	blez	s3,80004ef8 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004e42:	0984a783          	lw	a5,152(s1)
    80004e46:	09c4a703          	lw	a4,156(s1)
    80004e4a:	0af71263          	bne	a4,a5,80004eee <consoleread+0xea>
      if(killed(myproc())){
    80004e4e:	f19fb0ef          	jal	80000d66 <myproc>
    80004e52:	f1afc0ef          	jal	8000156c <killed>
    80004e56:	e12d                	bnez	a0,80004eb8 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004e58:	85a6                	mv	a1,s1
    80004e5a:	854a                	mv	a0,s2
    80004e5c:	cd8fc0ef          	jal	80001334 <sleep>
    while(cons.r == cons.w){
    80004e60:	0984a783          	lw	a5,152(s1)
    80004e64:	09c4a703          	lw	a4,156(s1)
    80004e68:	fef703e3          	beq	a4,a5,80004e4e <consoleread+0x4a>
    80004e6c:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004e6e:	0001e717          	auipc	a4,0x1e
    80004e72:	66270713          	addi	a4,a4,1634 # 800234d0 <cons>
    80004e76:	0017869b          	addiw	a3,a5,1
    80004e7a:	08d72c23          	sw	a3,152(a4)
    80004e7e:	07f7f693          	andi	a3,a5,127
    80004e82:	9736                	add	a4,a4,a3
    80004e84:	01874703          	lbu	a4,24(a4)
    80004e88:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004e8c:	4691                	li	a3,4
    80004e8e:	04db8663          	beq	s7,a3,80004eda <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80004e92:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004e96:	4685                	li	a3,1
    80004e98:	faf40613          	addi	a2,s0,-81
    80004e9c:	85d2                	mv	a1,s4
    80004e9e:	8556                	mv	a0,s5
    80004ea0:	ff0fc0ef          	jal	80001690 <either_copyout>
    80004ea4:	57fd                	li	a5,-1
    80004ea6:	04f50863          	beq	a0,a5,80004ef6 <consoleread+0xf2>
      break;

    dst++;
    80004eaa:	0a05                	addi	s4,s4,1
    --n;
    80004eac:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80004eae:	47a9                	li	a5,10
    80004eb0:	04fb8d63          	beq	s7,a5,80004f0a <consoleread+0x106>
    80004eb4:	6be2                	ld	s7,24(sp)
    80004eb6:	b761                	j	80004e3e <consoleread+0x3a>
        release(&cons.lock);
    80004eb8:	0001e517          	auipc	a0,0x1e
    80004ebc:	61850513          	addi	a0,a0,1560 # 800234d0 <cons>
    80004ec0:	169000ef          	jal	80005828 <release>
        return -1;
    80004ec4:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80004ec6:	60e6                	ld	ra,88(sp)
    80004ec8:	6446                	ld	s0,80(sp)
    80004eca:	64a6                	ld	s1,72(sp)
    80004ecc:	6906                	ld	s2,64(sp)
    80004ece:	79e2                	ld	s3,56(sp)
    80004ed0:	7a42                	ld	s4,48(sp)
    80004ed2:	7aa2                	ld	s5,40(sp)
    80004ed4:	7b02                	ld	s6,32(sp)
    80004ed6:	6125                	addi	sp,sp,96
    80004ed8:	8082                	ret
      if(n < target){
    80004eda:	0009871b          	sext.w	a4,s3
    80004ede:	01677a63          	bgeu	a4,s6,80004ef2 <consoleread+0xee>
        cons.r--;
    80004ee2:	0001e717          	auipc	a4,0x1e
    80004ee6:	68f72323          	sw	a5,1670(a4) # 80023568 <cons+0x98>
    80004eea:	6be2                	ld	s7,24(sp)
    80004eec:	a031                	j	80004ef8 <consoleread+0xf4>
    80004eee:	ec5e                	sd	s7,24(sp)
    80004ef0:	bfbd                	j	80004e6e <consoleread+0x6a>
    80004ef2:	6be2                	ld	s7,24(sp)
    80004ef4:	a011                	j	80004ef8 <consoleread+0xf4>
    80004ef6:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80004ef8:	0001e517          	auipc	a0,0x1e
    80004efc:	5d850513          	addi	a0,a0,1496 # 800234d0 <cons>
    80004f00:	129000ef          	jal	80005828 <release>
  return target - n;
    80004f04:	413b053b          	subw	a0,s6,s3
    80004f08:	bf7d                	j	80004ec6 <consoleread+0xc2>
    80004f0a:	6be2                	ld	s7,24(sp)
    80004f0c:	b7f5                	j	80004ef8 <consoleread+0xf4>

0000000080004f0e <consputc>:
{
    80004f0e:	1141                	addi	sp,sp,-16
    80004f10:	e406                	sd	ra,8(sp)
    80004f12:	e022                	sd	s0,0(sp)
    80004f14:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004f16:	10000793          	li	a5,256
    80004f1a:	00f50863          	beq	a0,a5,80004f2a <consputc+0x1c>
    uartputc_sync(c);
    80004f1e:	604000ef          	jal	80005522 <uartputc_sync>
}
    80004f22:	60a2                	ld	ra,8(sp)
    80004f24:	6402                	ld	s0,0(sp)
    80004f26:	0141                	addi	sp,sp,16
    80004f28:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004f2a:	4521                	li	a0,8
    80004f2c:	5f6000ef          	jal	80005522 <uartputc_sync>
    80004f30:	02000513          	li	a0,32
    80004f34:	5ee000ef          	jal	80005522 <uartputc_sync>
    80004f38:	4521                	li	a0,8
    80004f3a:	5e8000ef          	jal	80005522 <uartputc_sync>
    80004f3e:	b7d5                	j	80004f22 <consputc+0x14>

0000000080004f40 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004f40:	1101                	addi	sp,sp,-32
    80004f42:	ec06                	sd	ra,24(sp)
    80004f44:	e822                	sd	s0,16(sp)
    80004f46:	e426                	sd	s1,8(sp)
    80004f48:	1000                	addi	s0,sp,32
    80004f4a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004f4c:	0001e517          	auipc	a0,0x1e
    80004f50:	58450513          	addi	a0,a0,1412 # 800234d0 <cons>
    80004f54:	03d000ef          	jal	80005790 <acquire>

  switch(c){
    80004f58:	47d5                	li	a5,21
    80004f5a:	08f48f63          	beq	s1,a5,80004ff8 <consoleintr+0xb8>
    80004f5e:	0297c563          	blt	a5,s1,80004f88 <consoleintr+0x48>
    80004f62:	47a1                	li	a5,8
    80004f64:	0ef48463          	beq	s1,a5,8000504c <consoleintr+0x10c>
    80004f68:	47c1                	li	a5,16
    80004f6a:	10f49563          	bne	s1,a5,80005074 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    80004f6e:	fb6fc0ef          	jal	80001724 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80004f72:	0001e517          	auipc	a0,0x1e
    80004f76:	55e50513          	addi	a0,a0,1374 # 800234d0 <cons>
    80004f7a:	0af000ef          	jal	80005828 <release>
}
    80004f7e:	60e2                	ld	ra,24(sp)
    80004f80:	6442                	ld	s0,16(sp)
    80004f82:	64a2                	ld	s1,8(sp)
    80004f84:	6105                	addi	sp,sp,32
    80004f86:	8082                	ret
  switch(c){
    80004f88:	07f00793          	li	a5,127
    80004f8c:	0cf48063          	beq	s1,a5,8000504c <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004f90:	0001e717          	auipc	a4,0x1e
    80004f94:	54070713          	addi	a4,a4,1344 # 800234d0 <cons>
    80004f98:	0a072783          	lw	a5,160(a4)
    80004f9c:	09872703          	lw	a4,152(a4)
    80004fa0:	9f99                	subw	a5,a5,a4
    80004fa2:	07f00713          	li	a4,127
    80004fa6:	fcf766e3          	bltu	a4,a5,80004f72 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80004faa:	47b5                	li	a5,13
    80004fac:	0cf48763          	beq	s1,a5,8000507a <consoleintr+0x13a>
      consputc(c);
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	f5dff0ef          	jal	80004f0e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004fb6:	0001e797          	auipc	a5,0x1e
    80004fba:	51a78793          	addi	a5,a5,1306 # 800234d0 <cons>
    80004fbe:	0a07a683          	lw	a3,160(a5)
    80004fc2:	0016871b          	addiw	a4,a3,1
    80004fc6:	0007061b          	sext.w	a2,a4
    80004fca:	0ae7a023          	sw	a4,160(a5)
    80004fce:	07f6f693          	andi	a3,a3,127
    80004fd2:	97b6                	add	a5,a5,a3
    80004fd4:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80004fd8:	47a9                	li	a5,10
    80004fda:	0cf48563          	beq	s1,a5,800050a4 <consoleintr+0x164>
    80004fde:	4791                	li	a5,4
    80004fe0:	0cf48263          	beq	s1,a5,800050a4 <consoleintr+0x164>
    80004fe4:	0001e797          	auipc	a5,0x1e
    80004fe8:	5847a783          	lw	a5,1412(a5) # 80023568 <cons+0x98>
    80004fec:	9f1d                	subw	a4,a4,a5
    80004fee:	08000793          	li	a5,128
    80004ff2:	f8f710e3          	bne	a4,a5,80004f72 <consoleintr+0x32>
    80004ff6:	a07d                	j	800050a4 <consoleintr+0x164>
    80004ff8:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80004ffa:	0001e717          	auipc	a4,0x1e
    80004ffe:	4d670713          	addi	a4,a4,1238 # 800234d0 <cons>
    80005002:	0a072783          	lw	a5,160(a4)
    80005006:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000500a:	0001e497          	auipc	s1,0x1e
    8000500e:	4c648493          	addi	s1,s1,1222 # 800234d0 <cons>
    while(cons.e != cons.w &&
    80005012:	4929                	li	s2,10
    80005014:	02f70863          	beq	a4,a5,80005044 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005018:	37fd                	addiw	a5,a5,-1
    8000501a:	07f7f713          	andi	a4,a5,127
    8000501e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005020:	01874703          	lbu	a4,24(a4)
    80005024:	03270263          	beq	a4,s2,80005048 <consoleintr+0x108>
      cons.e--;
    80005028:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000502c:	10000513          	li	a0,256
    80005030:	edfff0ef          	jal	80004f0e <consputc>
    while(cons.e != cons.w &&
    80005034:	0a04a783          	lw	a5,160(s1)
    80005038:	09c4a703          	lw	a4,156(s1)
    8000503c:	fcf71ee3          	bne	a4,a5,80005018 <consoleintr+0xd8>
    80005040:	6902                	ld	s2,0(sp)
    80005042:	bf05                	j	80004f72 <consoleintr+0x32>
    80005044:	6902                	ld	s2,0(sp)
    80005046:	b735                	j	80004f72 <consoleintr+0x32>
    80005048:	6902                	ld	s2,0(sp)
    8000504a:	b725                	j	80004f72 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000504c:	0001e717          	auipc	a4,0x1e
    80005050:	48470713          	addi	a4,a4,1156 # 800234d0 <cons>
    80005054:	0a072783          	lw	a5,160(a4)
    80005058:	09c72703          	lw	a4,156(a4)
    8000505c:	f0f70be3          	beq	a4,a5,80004f72 <consoleintr+0x32>
      cons.e--;
    80005060:	37fd                	addiw	a5,a5,-1
    80005062:	0001e717          	auipc	a4,0x1e
    80005066:	50f72723          	sw	a5,1294(a4) # 80023570 <cons+0xa0>
      consputc(BACKSPACE);
    8000506a:	10000513          	li	a0,256
    8000506e:	ea1ff0ef          	jal	80004f0e <consputc>
    80005072:	b701                	j	80004f72 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005074:	ee048fe3          	beqz	s1,80004f72 <consoleintr+0x32>
    80005078:	bf21                	j	80004f90 <consoleintr+0x50>
      consputc(c);
    8000507a:	4529                	li	a0,10
    8000507c:	e93ff0ef          	jal	80004f0e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005080:	0001e797          	auipc	a5,0x1e
    80005084:	45078793          	addi	a5,a5,1104 # 800234d0 <cons>
    80005088:	0a07a703          	lw	a4,160(a5)
    8000508c:	0017069b          	addiw	a3,a4,1
    80005090:	0006861b          	sext.w	a2,a3
    80005094:	0ad7a023          	sw	a3,160(a5)
    80005098:	07f77713          	andi	a4,a4,127
    8000509c:	97ba                	add	a5,a5,a4
    8000509e:	4729                	li	a4,10
    800050a0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800050a4:	0001e797          	auipc	a5,0x1e
    800050a8:	4cc7a423          	sw	a2,1224(a5) # 8002356c <cons+0x9c>
        wakeup(&cons.r);
    800050ac:	0001e517          	auipc	a0,0x1e
    800050b0:	4bc50513          	addi	a0,a0,1212 # 80023568 <cons+0x98>
    800050b4:	accfc0ef          	jal	80001380 <wakeup>
    800050b8:	bd6d                	j	80004f72 <consoleintr+0x32>

00000000800050ba <consoleinit>:

void
consoleinit(void)
{
    800050ba:	1141                	addi	sp,sp,-16
    800050bc:	e406                	sd	ra,8(sp)
    800050be:	e022                	sd	s0,0(sp)
    800050c0:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800050c2:	00002597          	auipc	a1,0x2
    800050c6:	66e58593          	addi	a1,a1,1646 # 80007730 <etext+0x730>
    800050ca:	0001e517          	auipc	a0,0x1e
    800050ce:	40650513          	addi	a0,a0,1030 # 800234d0 <cons>
    800050d2:	63e000ef          	jal	80005710 <initlock>

  uartinit();
    800050d6:	3f4000ef          	jal	800054ca <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800050da:	00015797          	auipc	a5,0x15
    800050de:	25e78793          	addi	a5,a5,606 # 8001a338 <devsw>
    800050e2:	00000717          	auipc	a4,0x0
    800050e6:	d2270713          	addi	a4,a4,-734 # 80004e04 <consoleread>
    800050ea:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800050ec:	00000717          	auipc	a4,0x0
    800050f0:	cb270713          	addi	a4,a4,-846 # 80004d9e <consolewrite>
    800050f4:	ef98                	sd	a4,24(a5)
}
    800050f6:	60a2                	ld	ra,8(sp)
    800050f8:	6402                	ld	s0,0(sp)
    800050fa:	0141                	addi	sp,sp,16
    800050fc:	8082                	ret

00000000800050fe <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800050fe:	7179                	addi	sp,sp,-48
    80005100:	f406                	sd	ra,40(sp)
    80005102:	f022                	sd	s0,32(sp)
    80005104:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005106:	c219                	beqz	a2,8000510c <printint+0xe>
    80005108:	08054063          	bltz	a0,80005188 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000510c:	4881                	li	a7,0
    8000510e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005112:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005114:	00002617          	auipc	a2,0x2
    80005118:	78460613          	addi	a2,a2,1924 # 80007898 <digits>
    8000511c:	883e                	mv	a6,a5
    8000511e:	2785                	addiw	a5,a5,1
    80005120:	02b57733          	remu	a4,a0,a1
    80005124:	9732                	add	a4,a4,a2
    80005126:	00074703          	lbu	a4,0(a4)
    8000512a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000512e:	872a                	mv	a4,a0
    80005130:	02b55533          	divu	a0,a0,a1
    80005134:	0685                	addi	a3,a3,1
    80005136:	feb773e3          	bgeu	a4,a1,8000511c <printint+0x1e>

  if(sign)
    8000513a:	00088a63          	beqz	a7,8000514e <printint+0x50>
    buf[i++] = '-';
    8000513e:	1781                	addi	a5,a5,-32
    80005140:	97a2                	add	a5,a5,s0
    80005142:	02d00713          	li	a4,45
    80005146:	fee78823          	sb	a4,-16(a5)
    8000514a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000514e:	02f05963          	blez	a5,80005180 <printint+0x82>
    80005152:	ec26                	sd	s1,24(sp)
    80005154:	e84a                	sd	s2,16(sp)
    80005156:	fd040713          	addi	a4,s0,-48
    8000515a:	00f704b3          	add	s1,a4,a5
    8000515e:	fff70913          	addi	s2,a4,-1
    80005162:	993e                	add	s2,s2,a5
    80005164:	37fd                	addiw	a5,a5,-1
    80005166:	1782                	slli	a5,a5,0x20
    80005168:	9381                	srli	a5,a5,0x20
    8000516a:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000516e:	fff4c503          	lbu	a0,-1(s1)
    80005172:	d9dff0ef          	jal	80004f0e <consputc>
  while(--i >= 0)
    80005176:	14fd                	addi	s1,s1,-1
    80005178:	ff249be3          	bne	s1,s2,8000516e <printint+0x70>
    8000517c:	64e2                	ld	s1,24(sp)
    8000517e:	6942                	ld	s2,16(sp)
}
    80005180:	70a2                	ld	ra,40(sp)
    80005182:	7402                	ld	s0,32(sp)
    80005184:	6145                	addi	sp,sp,48
    80005186:	8082                	ret
    x = -xx;
    80005188:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000518c:	4885                	li	a7,1
    x = -xx;
    8000518e:	b741                	j	8000510e <printint+0x10>

0000000080005190 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005190:	7155                	addi	sp,sp,-208
    80005192:	e506                	sd	ra,136(sp)
    80005194:	e122                	sd	s0,128(sp)
    80005196:	f0d2                	sd	s4,96(sp)
    80005198:	0900                	addi	s0,sp,144
    8000519a:	8a2a                	mv	s4,a0
    8000519c:	e40c                	sd	a1,8(s0)
    8000519e:	e810                	sd	a2,16(s0)
    800051a0:	ec14                	sd	a3,24(s0)
    800051a2:	f018                	sd	a4,32(s0)
    800051a4:	f41c                	sd	a5,40(s0)
    800051a6:	03043823          	sd	a6,48(s0)
    800051aa:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800051ae:	0001e797          	auipc	a5,0x1e
    800051b2:	3e27a783          	lw	a5,994(a5) # 80023590 <pr+0x18>
    800051b6:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800051ba:	e3a1                	bnez	a5,800051fa <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800051bc:	00840793          	addi	a5,s0,8
    800051c0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800051c4:	00054503          	lbu	a0,0(a0)
    800051c8:	26050763          	beqz	a0,80005436 <printf+0x2a6>
    800051cc:	fca6                	sd	s1,120(sp)
    800051ce:	f8ca                	sd	s2,112(sp)
    800051d0:	f4ce                	sd	s3,104(sp)
    800051d2:	ecd6                	sd	s5,88(sp)
    800051d4:	e8da                	sd	s6,80(sp)
    800051d6:	e0e2                	sd	s8,64(sp)
    800051d8:	fc66                	sd	s9,56(sp)
    800051da:	f86a                	sd	s10,48(sp)
    800051dc:	f46e                	sd	s11,40(sp)
    800051de:	4981                	li	s3,0
    if(cx != '%'){
    800051e0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800051e4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800051e8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800051ec:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800051f0:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800051f4:	07000d93          	li	s11,112
    800051f8:	a815                	j	8000522c <printf+0x9c>
    acquire(&pr.lock);
    800051fa:	0001e517          	auipc	a0,0x1e
    800051fe:	37e50513          	addi	a0,a0,894 # 80023578 <pr>
    80005202:	58e000ef          	jal	80005790 <acquire>
  va_start(ap, fmt);
    80005206:	00840793          	addi	a5,s0,8
    8000520a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000520e:	000a4503          	lbu	a0,0(s4)
    80005212:	fd4d                	bnez	a0,800051cc <printf+0x3c>
    80005214:	a481                	j	80005454 <printf+0x2c4>
      consputc(cx);
    80005216:	cf9ff0ef          	jal	80004f0e <consputc>
      continue;
    8000521a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000521c:	0014899b          	addiw	s3,s1,1
    80005220:	013a07b3          	add	a5,s4,s3
    80005224:	0007c503          	lbu	a0,0(a5)
    80005228:	1e050b63          	beqz	a0,8000541e <printf+0x28e>
    if(cx != '%'){
    8000522c:	ff5515e3          	bne	a0,s5,80005216 <printf+0x86>
    i++;
    80005230:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005234:	009a07b3          	add	a5,s4,s1
    80005238:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000523c:	1e090163          	beqz	s2,8000541e <printf+0x28e>
    80005240:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005244:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80005246:	c789                	beqz	a5,80005250 <printf+0xc0>
    80005248:	009a0733          	add	a4,s4,s1
    8000524c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005250:	03690763          	beq	s2,s6,8000527e <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80005254:	05890163          	beq	s2,s8,80005296 <printf+0x106>
    } else if(c0 == 'u'){
    80005258:	0d990b63          	beq	s2,s9,8000532e <printf+0x19e>
    } else if(c0 == 'x'){
    8000525c:	13a90163          	beq	s2,s10,8000537e <printf+0x1ee>
    } else if(c0 == 'p'){
    80005260:	13b90b63          	beq	s2,s11,80005396 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80005264:	07300793          	li	a5,115
    80005268:	16f90a63          	beq	s2,a5,800053dc <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000526c:	1b590463          	beq	s2,s5,80005414 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80005270:	8556                	mv	a0,s5
    80005272:	c9dff0ef          	jal	80004f0e <consputc>
      consputc(c0);
    80005276:	854a                	mv	a0,s2
    80005278:	c97ff0ef          	jal	80004f0e <consputc>
    8000527c:	b745                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    8000527e:	f8843783          	ld	a5,-120(s0)
    80005282:	00878713          	addi	a4,a5,8
    80005286:	f8e43423          	sd	a4,-120(s0)
    8000528a:	4605                	li	a2,1
    8000528c:	45a9                	li	a1,10
    8000528e:	4388                	lw	a0,0(a5)
    80005290:	e6fff0ef          	jal	800050fe <printint>
    80005294:	b761                	j	8000521c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    80005296:	03678663          	beq	a5,s6,800052c2 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000529a:	05878263          	beq	a5,s8,800052de <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    8000529e:	0b978463          	beq	a5,s9,80005346 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800052a2:	fda797e3          	bne	a5,s10,80005270 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800052a6:	f8843783          	ld	a5,-120(s0)
    800052aa:	00878713          	addi	a4,a5,8
    800052ae:	f8e43423          	sd	a4,-120(s0)
    800052b2:	4601                	li	a2,0
    800052b4:	45c1                	li	a1,16
    800052b6:	6388                	ld	a0,0(a5)
    800052b8:	e47ff0ef          	jal	800050fe <printint>
      i += 1;
    800052bc:	0029849b          	addiw	s1,s3,2
    800052c0:	bfb1                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800052c2:	f8843783          	ld	a5,-120(s0)
    800052c6:	00878713          	addi	a4,a5,8
    800052ca:	f8e43423          	sd	a4,-120(s0)
    800052ce:	4605                	li	a2,1
    800052d0:	45a9                	li	a1,10
    800052d2:	6388                	ld	a0,0(a5)
    800052d4:	e2bff0ef          	jal	800050fe <printint>
      i += 1;
    800052d8:	0029849b          	addiw	s1,s3,2
    800052dc:	b781                	j	8000521c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800052de:	06400793          	li	a5,100
    800052e2:	02f68863          	beq	a3,a5,80005312 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800052e6:	07500793          	li	a5,117
    800052ea:	06f68c63          	beq	a3,a5,80005362 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800052ee:	07800793          	li	a5,120
    800052f2:	f6f69fe3          	bne	a3,a5,80005270 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800052f6:	f8843783          	ld	a5,-120(s0)
    800052fa:	00878713          	addi	a4,a5,8
    800052fe:	f8e43423          	sd	a4,-120(s0)
    80005302:	4601                	li	a2,0
    80005304:	45c1                	li	a1,16
    80005306:	6388                	ld	a0,0(a5)
    80005308:	df7ff0ef          	jal	800050fe <printint>
      i += 2;
    8000530c:	0039849b          	addiw	s1,s3,3
    80005310:	b731                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005312:	f8843783          	ld	a5,-120(s0)
    80005316:	00878713          	addi	a4,a5,8
    8000531a:	f8e43423          	sd	a4,-120(s0)
    8000531e:	4605                	li	a2,1
    80005320:	45a9                	li	a1,10
    80005322:	6388                	ld	a0,0(a5)
    80005324:	ddbff0ef          	jal	800050fe <printint>
      i += 2;
    80005328:	0039849b          	addiw	s1,s3,3
    8000532c:	bdc5                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000532e:	f8843783          	ld	a5,-120(s0)
    80005332:	00878713          	addi	a4,a5,8
    80005336:	f8e43423          	sd	a4,-120(s0)
    8000533a:	4601                	li	a2,0
    8000533c:	45a9                	li	a1,10
    8000533e:	4388                	lw	a0,0(a5)
    80005340:	dbfff0ef          	jal	800050fe <printint>
    80005344:	bde1                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005346:	f8843783          	ld	a5,-120(s0)
    8000534a:	00878713          	addi	a4,a5,8
    8000534e:	f8e43423          	sd	a4,-120(s0)
    80005352:	4601                	li	a2,0
    80005354:	45a9                	li	a1,10
    80005356:	6388                	ld	a0,0(a5)
    80005358:	da7ff0ef          	jal	800050fe <printint>
      i += 1;
    8000535c:	0029849b          	addiw	s1,s3,2
    80005360:	bd75                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005362:	f8843783          	ld	a5,-120(s0)
    80005366:	00878713          	addi	a4,a5,8
    8000536a:	f8e43423          	sd	a4,-120(s0)
    8000536e:	4601                	li	a2,0
    80005370:	45a9                	li	a1,10
    80005372:	6388                	ld	a0,0(a5)
    80005374:	d8bff0ef          	jal	800050fe <printint>
      i += 2;
    80005378:	0039849b          	addiw	s1,s3,3
    8000537c:	b545                	j	8000521c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    8000537e:	f8843783          	ld	a5,-120(s0)
    80005382:	00878713          	addi	a4,a5,8
    80005386:	f8e43423          	sd	a4,-120(s0)
    8000538a:	4601                	li	a2,0
    8000538c:	45c1                	li	a1,16
    8000538e:	4388                	lw	a0,0(a5)
    80005390:	d6fff0ef          	jal	800050fe <printint>
    80005394:	b561                	j	8000521c <printf+0x8c>
    80005396:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    80005398:	f8843783          	ld	a5,-120(s0)
    8000539c:	00878713          	addi	a4,a5,8
    800053a0:	f8e43423          	sd	a4,-120(s0)
    800053a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800053a8:	03000513          	li	a0,48
    800053ac:	b63ff0ef          	jal	80004f0e <consputc>
  consputc('x');
    800053b0:	07800513          	li	a0,120
    800053b4:	b5bff0ef          	jal	80004f0e <consputc>
    800053b8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800053ba:	00002b97          	auipc	s7,0x2
    800053be:	4deb8b93          	addi	s7,s7,1246 # 80007898 <digits>
    800053c2:	03c9d793          	srli	a5,s3,0x3c
    800053c6:	97de                	add	a5,a5,s7
    800053c8:	0007c503          	lbu	a0,0(a5)
    800053cc:	b43ff0ef          	jal	80004f0e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800053d0:	0992                	slli	s3,s3,0x4
    800053d2:	397d                	addiw	s2,s2,-1
    800053d4:	fe0917e3          	bnez	s2,800053c2 <printf+0x232>
    800053d8:	6ba6                	ld	s7,72(sp)
    800053da:	b589                	j	8000521c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    800053dc:	f8843783          	ld	a5,-120(s0)
    800053e0:	00878713          	addi	a4,a5,8
    800053e4:	f8e43423          	sd	a4,-120(s0)
    800053e8:	0007b903          	ld	s2,0(a5)
    800053ec:	00090d63          	beqz	s2,80005406 <printf+0x276>
      for(; *s; s++)
    800053f0:	00094503          	lbu	a0,0(s2)
    800053f4:	e20504e3          	beqz	a0,8000521c <printf+0x8c>
        consputc(*s);
    800053f8:	b17ff0ef          	jal	80004f0e <consputc>
      for(; *s; s++)
    800053fc:	0905                	addi	s2,s2,1
    800053fe:	00094503          	lbu	a0,0(s2)
    80005402:	f97d                	bnez	a0,800053f8 <printf+0x268>
    80005404:	bd21                	j	8000521c <printf+0x8c>
        s = "(null)";
    80005406:	00002917          	auipc	s2,0x2
    8000540a:	33290913          	addi	s2,s2,818 # 80007738 <etext+0x738>
      for(; *s; s++)
    8000540e:	02800513          	li	a0,40
    80005412:	b7dd                	j	800053f8 <printf+0x268>
      consputc('%');
    80005414:	02500513          	li	a0,37
    80005418:	af7ff0ef          	jal	80004f0e <consputc>
    8000541c:	b501                	j	8000521c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000541e:	f7843783          	ld	a5,-136(s0)
    80005422:	e385                	bnez	a5,80005442 <printf+0x2b2>
    80005424:	74e6                	ld	s1,120(sp)
    80005426:	7946                	ld	s2,112(sp)
    80005428:	79a6                	ld	s3,104(sp)
    8000542a:	6ae6                	ld	s5,88(sp)
    8000542c:	6b46                	ld	s6,80(sp)
    8000542e:	6c06                	ld	s8,64(sp)
    80005430:	7ce2                	ld	s9,56(sp)
    80005432:	7d42                	ld	s10,48(sp)
    80005434:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80005436:	4501                	li	a0,0
    80005438:	60aa                	ld	ra,136(sp)
    8000543a:	640a                	ld	s0,128(sp)
    8000543c:	7a06                	ld	s4,96(sp)
    8000543e:	6169                	addi	sp,sp,208
    80005440:	8082                	ret
    80005442:	74e6                	ld	s1,120(sp)
    80005444:	7946                	ld	s2,112(sp)
    80005446:	79a6                	ld	s3,104(sp)
    80005448:	6ae6                	ld	s5,88(sp)
    8000544a:	6b46                	ld	s6,80(sp)
    8000544c:	6c06                	ld	s8,64(sp)
    8000544e:	7ce2                	ld	s9,56(sp)
    80005450:	7d42                	ld	s10,48(sp)
    80005452:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80005454:	0001e517          	auipc	a0,0x1e
    80005458:	12450513          	addi	a0,a0,292 # 80023578 <pr>
    8000545c:	3cc000ef          	jal	80005828 <release>
    80005460:	bfd9                	j	80005436 <printf+0x2a6>

0000000080005462 <panic>:

void
panic(char *s)
{
    80005462:	1101                	addi	sp,sp,-32
    80005464:	ec06                	sd	ra,24(sp)
    80005466:	e822                	sd	s0,16(sp)
    80005468:	e426                	sd	s1,8(sp)
    8000546a:	1000                	addi	s0,sp,32
    8000546c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000546e:	0001e797          	auipc	a5,0x1e
    80005472:	1207a123          	sw	zero,290(a5) # 80023590 <pr+0x18>
  printf("panic: ");
    80005476:	00002517          	auipc	a0,0x2
    8000547a:	2ca50513          	addi	a0,a0,714 # 80007740 <etext+0x740>
    8000547e:	d13ff0ef          	jal	80005190 <printf>
  printf("%s\n", s);
    80005482:	85a6                	mv	a1,s1
    80005484:	00002517          	auipc	a0,0x2
    80005488:	2c450513          	addi	a0,a0,708 # 80007748 <etext+0x748>
    8000548c:	d05ff0ef          	jal	80005190 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005490:	4785                	li	a5,1
    80005492:	00005717          	auipc	a4,0x5
    80005496:	def72d23          	sw	a5,-518(a4) # 8000a28c <panicked>
  for(;;)
    8000549a:	a001                	j	8000549a <panic+0x38>

000000008000549c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000549c:	1101                	addi	sp,sp,-32
    8000549e:	ec06                	sd	ra,24(sp)
    800054a0:	e822                	sd	s0,16(sp)
    800054a2:	e426                	sd	s1,8(sp)
    800054a4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800054a6:	0001e497          	auipc	s1,0x1e
    800054aa:	0d248493          	addi	s1,s1,210 # 80023578 <pr>
    800054ae:	00002597          	auipc	a1,0x2
    800054b2:	2a258593          	addi	a1,a1,674 # 80007750 <etext+0x750>
    800054b6:	8526                	mv	a0,s1
    800054b8:	258000ef          	jal	80005710 <initlock>
  pr.locking = 1;
    800054bc:	4785                	li	a5,1
    800054be:	cc9c                	sw	a5,24(s1)
}
    800054c0:	60e2                	ld	ra,24(sp)
    800054c2:	6442                	ld	s0,16(sp)
    800054c4:	64a2                	ld	s1,8(sp)
    800054c6:	6105                	addi	sp,sp,32
    800054c8:	8082                	ret

00000000800054ca <uartinit>:

void uartstart();

void
uartinit(void)
{
    800054ca:	1141                	addi	sp,sp,-16
    800054cc:	e406                	sd	ra,8(sp)
    800054ce:	e022                	sd	s0,0(sp)
    800054d0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800054d2:	100007b7          	lui	a5,0x10000
    800054d6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800054da:	10000737          	lui	a4,0x10000
    800054de:	f8000693          	li	a3,-128
    800054e2:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800054e6:	468d                	li	a3,3
    800054e8:	10000637          	lui	a2,0x10000
    800054ec:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800054f0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800054f4:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800054f8:	10000737          	lui	a4,0x10000
    800054fc:	461d                	li	a2,7
    800054fe:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005502:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005506:	00002597          	auipc	a1,0x2
    8000550a:	25258593          	addi	a1,a1,594 # 80007758 <etext+0x758>
    8000550e:	0001e517          	auipc	a0,0x1e
    80005512:	08a50513          	addi	a0,a0,138 # 80023598 <uart_tx_lock>
    80005516:	1fa000ef          	jal	80005710 <initlock>
}
    8000551a:	60a2                	ld	ra,8(sp)
    8000551c:	6402                	ld	s0,0(sp)
    8000551e:	0141                	addi	sp,sp,16
    80005520:	8082                	ret

0000000080005522 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005522:	1101                	addi	sp,sp,-32
    80005524:	ec06                	sd	ra,24(sp)
    80005526:	e822                	sd	s0,16(sp)
    80005528:	e426                	sd	s1,8(sp)
    8000552a:	1000                	addi	s0,sp,32
    8000552c:	84aa                	mv	s1,a0
  push_off();
    8000552e:	222000ef          	jal	80005750 <push_off>

  if(panicked){
    80005532:	00005797          	auipc	a5,0x5
    80005536:	d5a7a783          	lw	a5,-678(a5) # 8000a28c <panicked>
    8000553a:	e795                	bnez	a5,80005566 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000553c:	10000737          	lui	a4,0x10000
    80005540:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005542:	00074783          	lbu	a5,0(a4)
    80005546:	0207f793          	andi	a5,a5,32
    8000554a:	dfe5                	beqz	a5,80005542 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000554c:	0ff4f513          	zext.b	a0,s1
    80005550:	100007b7          	lui	a5,0x10000
    80005554:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005558:	27c000ef          	jal	800057d4 <pop_off>
}
    8000555c:	60e2                	ld	ra,24(sp)
    8000555e:	6442                	ld	s0,16(sp)
    80005560:	64a2                	ld	s1,8(sp)
    80005562:	6105                	addi	sp,sp,32
    80005564:	8082                	ret
    for(;;)
    80005566:	a001                	j	80005566 <uartputc_sync+0x44>

0000000080005568 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005568:	00005797          	auipc	a5,0x5
    8000556c:	d287b783          	ld	a5,-728(a5) # 8000a290 <uart_tx_r>
    80005570:	00005717          	auipc	a4,0x5
    80005574:	d2873703          	ld	a4,-728(a4) # 8000a298 <uart_tx_w>
    80005578:	08f70263          	beq	a4,a5,800055fc <uartstart+0x94>
{
    8000557c:	7139                	addi	sp,sp,-64
    8000557e:	fc06                	sd	ra,56(sp)
    80005580:	f822                	sd	s0,48(sp)
    80005582:	f426                	sd	s1,40(sp)
    80005584:	f04a                	sd	s2,32(sp)
    80005586:	ec4e                	sd	s3,24(sp)
    80005588:	e852                	sd	s4,16(sp)
    8000558a:	e456                	sd	s5,8(sp)
    8000558c:	e05a                	sd	s6,0(sp)
    8000558e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005590:	10000937          	lui	s2,0x10000
    80005594:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005596:	0001ea97          	auipc	s5,0x1e
    8000559a:	002a8a93          	addi	s5,s5,2 # 80023598 <uart_tx_lock>
    uart_tx_r += 1;
    8000559e:	00005497          	auipc	s1,0x5
    800055a2:	cf248493          	addi	s1,s1,-782 # 8000a290 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800055a6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800055aa:	00005997          	auipc	s3,0x5
    800055ae:	cee98993          	addi	s3,s3,-786 # 8000a298 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800055b2:	00094703          	lbu	a4,0(s2)
    800055b6:	02077713          	andi	a4,a4,32
    800055ba:	c71d                	beqz	a4,800055e8 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800055bc:	01f7f713          	andi	a4,a5,31
    800055c0:	9756                	add	a4,a4,s5
    800055c2:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800055c6:	0785                	addi	a5,a5,1
    800055c8:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800055ca:	8526                	mv	a0,s1
    800055cc:	db5fb0ef          	jal	80001380 <wakeup>
    WriteReg(THR, c);
    800055d0:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800055d4:	609c                	ld	a5,0(s1)
    800055d6:	0009b703          	ld	a4,0(s3)
    800055da:	fcf71ce3          	bne	a4,a5,800055b2 <uartstart+0x4a>
      ReadReg(ISR);
    800055de:	100007b7          	lui	a5,0x10000
    800055e2:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800055e4:	0007c783          	lbu	a5,0(a5)
  }
}
    800055e8:	70e2                	ld	ra,56(sp)
    800055ea:	7442                	ld	s0,48(sp)
    800055ec:	74a2                	ld	s1,40(sp)
    800055ee:	7902                	ld	s2,32(sp)
    800055f0:	69e2                	ld	s3,24(sp)
    800055f2:	6a42                	ld	s4,16(sp)
    800055f4:	6aa2                	ld	s5,8(sp)
    800055f6:	6b02                	ld	s6,0(sp)
    800055f8:	6121                	addi	sp,sp,64
    800055fa:	8082                	ret
      ReadReg(ISR);
    800055fc:	100007b7          	lui	a5,0x10000
    80005600:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005602:	0007c783          	lbu	a5,0(a5)
      return;
    80005606:	8082                	ret

0000000080005608 <uartputc>:
{
    80005608:	7179                	addi	sp,sp,-48
    8000560a:	f406                	sd	ra,40(sp)
    8000560c:	f022                	sd	s0,32(sp)
    8000560e:	ec26                	sd	s1,24(sp)
    80005610:	e84a                	sd	s2,16(sp)
    80005612:	e44e                	sd	s3,8(sp)
    80005614:	e052                	sd	s4,0(sp)
    80005616:	1800                	addi	s0,sp,48
    80005618:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000561a:	0001e517          	auipc	a0,0x1e
    8000561e:	f7e50513          	addi	a0,a0,-130 # 80023598 <uart_tx_lock>
    80005622:	16e000ef          	jal	80005790 <acquire>
  if(panicked){
    80005626:	00005797          	auipc	a5,0x5
    8000562a:	c667a783          	lw	a5,-922(a5) # 8000a28c <panicked>
    8000562e:	efbd                	bnez	a5,800056ac <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005630:	00005717          	auipc	a4,0x5
    80005634:	c6873703          	ld	a4,-920(a4) # 8000a298 <uart_tx_w>
    80005638:	00005797          	auipc	a5,0x5
    8000563c:	c587b783          	ld	a5,-936(a5) # 8000a290 <uart_tx_r>
    80005640:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005644:	0001e997          	auipc	s3,0x1e
    80005648:	f5498993          	addi	s3,s3,-172 # 80023598 <uart_tx_lock>
    8000564c:	00005497          	auipc	s1,0x5
    80005650:	c4448493          	addi	s1,s1,-956 # 8000a290 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005654:	00005917          	auipc	s2,0x5
    80005658:	c4490913          	addi	s2,s2,-956 # 8000a298 <uart_tx_w>
    8000565c:	00e79d63          	bne	a5,a4,80005676 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005660:	85ce                	mv	a1,s3
    80005662:	8526                	mv	a0,s1
    80005664:	cd1fb0ef          	jal	80001334 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005668:	00093703          	ld	a4,0(s2)
    8000566c:	609c                	ld	a5,0(s1)
    8000566e:	02078793          	addi	a5,a5,32
    80005672:	fee787e3          	beq	a5,a4,80005660 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80005676:	0001e497          	auipc	s1,0x1e
    8000567a:	f2248493          	addi	s1,s1,-222 # 80023598 <uart_tx_lock>
    8000567e:	01f77793          	andi	a5,a4,31
    80005682:	97a6                	add	a5,a5,s1
    80005684:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80005688:	0705                	addi	a4,a4,1
    8000568a:	00005797          	auipc	a5,0x5
    8000568e:	c0e7b723          	sd	a4,-1010(a5) # 8000a298 <uart_tx_w>
  uartstart();
    80005692:	ed7ff0ef          	jal	80005568 <uartstart>
  release(&uart_tx_lock);
    80005696:	8526                	mv	a0,s1
    80005698:	190000ef          	jal	80005828 <release>
}
    8000569c:	70a2                	ld	ra,40(sp)
    8000569e:	7402                	ld	s0,32(sp)
    800056a0:	64e2                	ld	s1,24(sp)
    800056a2:	6942                	ld	s2,16(sp)
    800056a4:	69a2                	ld	s3,8(sp)
    800056a6:	6a02                	ld	s4,0(sp)
    800056a8:	6145                	addi	sp,sp,48
    800056aa:	8082                	ret
    for(;;)
    800056ac:	a001                	j	800056ac <uartputc+0xa4>

00000000800056ae <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800056ae:	1141                	addi	sp,sp,-16
    800056b0:	e422                	sd	s0,8(sp)
    800056b2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800056b4:	100007b7          	lui	a5,0x10000
    800056b8:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800056ba:	0007c783          	lbu	a5,0(a5)
    800056be:	8b85                	andi	a5,a5,1
    800056c0:	cb81                	beqz	a5,800056d0 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800056c2:	100007b7          	lui	a5,0x10000
    800056c6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800056ca:	6422                	ld	s0,8(sp)
    800056cc:	0141                	addi	sp,sp,16
    800056ce:	8082                	ret
    return -1;
    800056d0:	557d                	li	a0,-1
    800056d2:	bfe5                	j	800056ca <uartgetc+0x1c>

00000000800056d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800056d4:	1101                	addi	sp,sp,-32
    800056d6:	ec06                	sd	ra,24(sp)
    800056d8:	e822                	sd	s0,16(sp)
    800056da:	e426                	sd	s1,8(sp)
    800056dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800056de:	54fd                	li	s1,-1
    800056e0:	a019                	j	800056e6 <uartintr+0x12>
      break;
    consoleintr(c);
    800056e2:	85fff0ef          	jal	80004f40 <consoleintr>
    int c = uartgetc();
    800056e6:	fc9ff0ef          	jal	800056ae <uartgetc>
    if(c == -1)
    800056ea:	fe951ce3          	bne	a0,s1,800056e2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800056ee:	0001e497          	auipc	s1,0x1e
    800056f2:	eaa48493          	addi	s1,s1,-342 # 80023598 <uart_tx_lock>
    800056f6:	8526                	mv	a0,s1
    800056f8:	098000ef          	jal	80005790 <acquire>
  uartstart();
    800056fc:	e6dff0ef          	jal	80005568 <uartstart>
  release(&uart_tx_lock);
    80005700:	8526                	mv	a0,s1
    80005702:	126000ef          	jal	80005828 <release>
}
    80005706:	60e2                	ld	ra,24(sp)
    80005708:	6442                	ld	s0,16(sp)
    8000570a:	64a2                	ld	s1,8(sp)
    8000570c:	6105                	addi	sp,sp,32
    8000570e:	8082                	ret

0000000080005710 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005710:	1141                	addi	sp,sp,-16
    80005712:	e422                	sd	s0,8(sp)
    80005714:	0800                	addi	s0,sp,16
  lk->name = name;
    80005716:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005718:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000571c:	00053823          	sd	zero,16(a0)
}
    80005720:	6422                	ld	s0,8(sp)
    80005722:	0141                	addi	sp,sp,16
    80005724:	8082                	ret

0000000080005726 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005726:	411c                	lw	a5,0(a0)
    80005728:	e399                	bnez	a5,8000572e <holding+0x8>
    8000572a:	4501                	li	a0,0
  return r;
}
    8000572c:	8082                	ret
{
    8000572e:	1101                	addi	sp,sp,-32
    80005730:	ec06                	sd	ra,24(sp)
    80005732:	e822                	sd	s0,16(sp)
    80005734:	e426                	sd	s1,8(sp)
    80005736:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005738:	6904                	ld	s1,16(a0)
    8000573a:	e10fb0ef          	jal	80000d4a <mycpu>
    8000573e:	40a48533          	sub	a0,s1,a0
    80005742:	00153513          	seqz	a0,a0
}
    80005746:	60e2                	ld	ra,24(sp)
    80005748:	6442                	ld	s0,16(sp)
    8000574a:	64a2                	ld	s1,8(sp)
    8000574c:	6105                	addi	sp,sp,32
    8000574e:	8082                	ret

0000000080005750 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005750:	1101                	addi	sp,sp,-32
    80005752:	ec06                	sd	ra,24(sp)
    80005754:	e822                	sd	s0,16(sp)
    80005756:	e426                	sd	s1,8(sp)
    80005758:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000575a:	100024f3          	csrr	s1,sstatus
    8000575e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005762:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005764:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005768:	de2fb0ef          	jal	80000d4a <mycpu>
    8000576c:	5d3c                	lw	a5,120(a0)
    8000576e:	cb99                	beqz	a5,80005784 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005770:	ddafb0ef          	jal	80000d4a <mycpu>
    80005774:	5d3c                	lw	a5,120(a0)
    80005776:	2785                	addiw	a5,a5,1
    80005778:	dd3c                	sw	a5,120(a0)
}
    8000577a:	60e2                	ld	ra,24(sp)
    8000577c:	6442                	ld	s0,16(sp)
    8000577e:	64a2                	ld	s1,8(sp)
    80005780:	6105                	addi	sp,sp,32
    80005782:	8082                	ret
    mycpu()->intena = old;
    80005784:	dc6fb0ef          	jal	80000d4a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005788:	8085                	srli	s1,s1,0x1
    8000578a:	8885                	andi	s1,s1,1
    8000578c:	dd64                	sw	s1,124(a0)
    8000578e:	b7cd                	j	80005770 <push_off+0x20>

0000000080005790 <acquire>:
{
    80005790:	1101                	addi	sp,sp,-32
    80005792:	ec06                	sd	ra,24(sp)
    80005794:	e822                	sd	s0,16(sp)
    80005796:	e426                	sd	s1,8(sp)
    80005798:	1000                	addi	s0,sp,32
    8000579a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000579c:	fb5ff0ef          	jal	80005750 <push_off>
  if(holding(lk))
    800057a0:	8526                	mv	a0,s1
    800057a2:	f85ff0ef          	jal	80005726 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800057a6:	4705                	li	a4,1
  if(holding(lk))
    800057a8:	e105                	bnez	a0,800057c8 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800057aa:	87ba                	mv	a5,a4
    800057ac:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800057b0:	2781                	sext.w	a5,a5
    800057b2:	ffe5                	bnez	a5,800057aa <acquire+0x1a>
  __sync_synchronize();
    800057b4:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800057b8:	d92fb0ef          	jal	80000d4a <mycpu>
    800057bc:	e888                	sd	a0,16(s1)
}
    800057be:	60e2                	ld	ra,24(sp)
    800057c0:	6442                	ld	s0,16(sp)
    800057c2:	64a2                	ld	s1,8(sp)
    800057c4:	6105                	addi	sp,sp,32
    800057c6:	8082                	ret
    panic("acquire");
    800057c8:	00002517          	auipc	a0,0x2
    800057cc:	f9850513          	addi	a0,a0,-104 # 80007760 <etext+0x760>
    800057d0:	c93ff0ef          	jal	80005462 <panic>

00000000800057d4 <pop_off>:

void
pop_off(void)
{
    800057d4:	1141                	addi	sp,sp,-16
    800057d6:	e406                	sd	ra,8(sp)
    800057d8:	e022                	sd	s0,0(sp)
    800057da:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800057dc:	d6efb0ef          	jal	80000d4a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800057e4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800057e6:	e78d                	bnez	a5,80005810 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800057e8:	5d3c                	lw	a5,120(a0)
    800057ea:	02f05963          	blez	a5,8000581c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800057ee:	37fd                	addiw	a5,a5,-1
    800057f0:	0007871b          	sext.w	a4,a5
    800057f4:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800057f6:	eb09                	bnez	a4,80005808 <pop_off+0x34>
    800057f8:	5d7c                	lw	a5,124(a0)
    800057fa:	c799                	beqz	a5,80005808 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057fc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005800:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005804:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005808:	60a2                	ld	ra,8(sp)
    8000580a:	6402                	ld	s0,0(sp)
    8000580c:	0141                	addi	sp,sp,16
    8000580e:	8082                	ret
    panic("pop_off - interruptible");
    80005810:	00002517          	auipc	a0,0x2
    80005814:	f5850513          	addi	a0,a0,-168 # 80007768 <etext+0x768>
    80005818:	c4bff0ef          	jal	80005462 <panic>
    panic("pop_off");
    8000581c:	00002517          	auipc	a0,0x2
    80005820:	f6450513          	addi	a0,a0,-156 # 80007780 <etext+0x780>
    80005824:	c3fff0ef          	jal	80005462 <panic>

0000000080005828 <release>:
{
    80005828:	1101                	addi	sp,sp,-32
    8000582a:	ec06                	sd	ra,24(sp)
    8000582c:	e822                	sd	s0,16(sp)
    8000582e:	e426                	sd	s1,8(sp)
    80005830:	1000                	addi	s0,sp,32
    80005832:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005834:	ef3ff0ef          	jal	80005726 <holding>
    80005838:	c105                	beqz	a0,80005858 <release+0x30>
  lk->cpu = 0;
    8000583a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000583e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005842:	0310000f          	fence	rw,w
    80005846:	0004a023          	sw	zero,0(s1)
  pop_off();
    8000584a:	f8bff0ef          	jal	800057d4 <pop_off>
}
    8000584e:	60e2                	ld	ra,24(sp)
    80005850:	6442                	ld	s0,16(sp)
    80005852:	64a2                	ld	s1,8(sp)
    80005854:	6105                	addi	sp,sp,32
    80005856:	8082                	ret
    panic("release");
    80005858:	00002517          	auipc	a0,0x2
    8000585c:	f3050513          	addi	a0,a0,-208 # 80007788 <etext+0x788>
    80005860:	c03ff0ef          	jal	80005462 <panic>
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
