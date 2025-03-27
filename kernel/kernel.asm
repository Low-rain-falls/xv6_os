
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	58013103          	ld	sp,1408(sp) # 8000a580 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	759040ef          	jal	80004f6e <start>

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
    80000030:	00024797          	auipc	a5,0x24
    80000034:	ad078793          	addi	a5,a5,-1328 # 80023b00 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree"); //stop the system

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	148000ef          	jal	80000190 <memset>

  r = (struct run*)pa;

  //put page pa to free list
  acquire(&kmem.lock);
    8000004c:	0000a917          	auipc	s2,0xa
    80000050:	58490913          	addi	s2,s2,1412 # 8000a5d0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	17b050ef          	jal	800059d0 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	203050ef          	jal	80005a68 <release>
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
    8000007e:	624050ef          	jal	800056a2 <panic>

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
    800000de:	4f650513          	addi	a0,a0,1270 # 8000a5d0 <kmem>
    800000e2:	06f050ef          	jal	80005950 <initlock>
  freerange(end, (void*)PHYSTOP); //release a range of page from "end" to phystop = put a range to free list pf page
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00024517          	auipc	a0,0x24
    800000ee:	a1650513          	addi	a0,a0,-1514 # 80023b00 <end>
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
    8000010c:	4c848493          	addi	s1,s1,1224 # 8000a5d0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	0bf050ef          	jal	800059d0 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	4b450513          	addi	a0,a0,1204 # 8000a5d0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	143050ef          	jal	80005a68 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk to easily detect errors if there is misuse.
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	060000ef          	jal	80000190 <memset>
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
    80000144:	49050513          	addi	a0,a0,1168 # 8000a5d0 <kmem>
    80000148:	121050ef          	jal	80005a68 <release>
  if(r)
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>

000000008000014e <kfree_memsize>:

// coun the number of free memory
uint64 kfree_memsize(void) {
    8000014e:	1101                	addi	sp,sp,-32
    80000150:	ec06                	sd	ra,24(sp)
    80000152:	e822                	sd	s0,16(sp)
    80000154:	e426                	sd	s1,8(sp)
    80000156:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000158:	0000a497          	auipc	s1,0xa
    8000015c:	47848493          	addi	s1,s1,1144 # 8000a5d0 <kmem>
    80000160:	8526                	mv	a0,s1
    80000162:	06f050ef          	jal	800059d0 <acquire>

  uint64 free_mem = 0;
  struct run *r = kmem.freelist;
    80000166:	6c9c                	ld	a5,24(s1)


  while(r) {
    80000168:	c395                	beqz	a5,8000018c <kfree_memsize+0x3e>
  uint64 free_mem = 0;
    8000016a:	4481                	li	s1,0
    free_mem += PGSIZE;
    8000016c:	6705                	lui	a4,0x1
    8000016e:	94ba                	add	s1,s1,a4
    r = r->next;
    80000170:	639c                	ld	a5,0(a5)
  while(r) {
    80000172:	fff5                	bnez	a5,8000016e <kfree_memsize+0x20>
  }

  release(&kmem.lock);
    80000174:	0000a517          	auipc	a0,0xa
    80000178:	45c50513          	addi	a0,a0,1116 # 8000a5d0 <kmem>
    8000017c:	0ed050ef          	jal	80005a68 <release>
  return free_mem;
    80000180:	8526                	mv	a0,s1
    80000182:	60e2                	ld	ra,24(sp)
    80000184:	6442                	ld	s0,16(sp)
    80000186:	64a2                	ld	s1,8(sp)
    80000188:	6105                	addi	sp,sp,32
    8000018a:	8082                	ret
  uint64 free_mem = 0;
    8000018c:	4481                	li	s1,0
    8000018e:	b7dd                	j	80000174 <kfree_memsize+0x26>

0000000080000190 <memset>:

//Assign the value c to each byte in memory starting from dst, lasting n bytes
//Fill with junk (c)
void*
memset(void *dst, int c, uint n)
{
    80000190:	1141                	addi	sp,sp,-16
    80000192:	e422                	sd	s0,8(sp)
    80000194:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000196:	ca19                	beqz	a2,800001ac <memset+0x1c>
    80000198:	87aa                	mv	a5,a0
    8000019a:	1602                	slli	a2,a2,0x20
    8000019c:	9201                	srli	a2,a2,0x20
    8000019e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800001a2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800001a6:	0785                	addi	a5,a5,1
    800001a8:	fee79de3          	bne	a5,a4,800001a2 <memset+0x12>
  }
  return dst;
}
    800001ac:	6422                	ld	s0,8(sp)
    800001ae:	0141                	addi	sp,sp,16
    800001b0:	8082                	ret

00000000800001b2 <memcmp>:

//Compare n bytes between two memory areas v1 and v2.
int
memcmp(const void *v1, const void *v2, uint n)
{
    800001b2:	1141                	addi	sp,sp,-16
    800001b4:	e422                	sd	s0,8(sp)
    800001b6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001b8:	ca05                	beqz	a2,800001e8 <memcmp+0x36>
    800001ba:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    800001be:	1682                	slli	a3,a3,0x20
    800001c0:	9281                	srli	a3,a3,0x20
    800001c2:	0685                	addi	a3,a3,1
    800001c4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001c6:	00054783          	lbu	a5,0(a0)
    800001ca:	0005c703          	lbu	a4,0(a1)
    800001ce:	00e79863          	bne	a5,a4,800001de <memcmp+0x2c>
      return *s1 - *s2; // < 0 or > 0 : difference between bytes
    s1++, s2++;
    800001d2:	0505                	addi	a0,a0,1
    800001d4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001d6:	fed518e3          	bne	a0,a3,800001c6 <memcmp+0x14>
  }

  return 0; // the same memory
    800001da:	4501                	li	a0,0
    800001dc:	a019                	j	800001e2 <memcmp+0x30>
      return *s1 - *s2; // < 0 or > 0 : difference between bytes
    800001de:	40e7853b          	subw	a0,a5,a4
}
    800001e2:	6422                	ld	s0,8(sp)
    800001e4:	0141                	addi	sp,sp,16
    800001e6:	8082                	ret
  return 0; // the same memory
    800001e8:	4501                	li	a0,0
    800001ea:	bfe5                	j	800001e2 <memcmp+0x30>

00000000800001ec <memmove>:

//Copy n bytes from src to dst. Handles cases of overlapping memory areas.
void*
memmove(void *dst, const void *src, uint n)
{
    800001ec:	1141                	addi	sp,sp,-16
    800001ee:	e422                	sd	s0,8(sp)
    800001f0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001f2:	c205                	beqz	a2,80000212 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  //check overlap
  if(s < d && s + n > d){
    800001f4:	02a5e263          	bltu	a1,a0,80000218 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001f8:	1602                	slli	a2,a2,0x20
    800001fa:	9201                	srli	a2,a2,0x20
    800001fc:	00c587b3          	add	a5,a1,a2
{
    80000200:	872a                	mv	a4,a0
      *d++ = *s++;
    80000202:	0585                	addi	a1,a1,1
    80000204:	0705                	addi	a4,a4,1 # 1001 <_entry-0x7fffefff>
    80000206:	fff5c683          	lbu	a3,-1(a1)
    8000020a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    8000020e:	feb79ae3          	bne	a5,a1,80000202 <memmove+0x16>

  return dst;
}
    80000212:	6422                	ld	s0,8(sp)
    80000214:	0141                	addi	sp,sp,16
    80000216:	8082                	ret
  if(s < d && s + n > d){
    80000218:	02061693          	slli	a3,a2,0x20
    8000021c:	9281                	srli	a3,a3,0x20
    8000021e:	00d58733          	add	a4,a1,a3
    80000222:	fce57be3          	bgeu	a0,a4,800001f8 <memmove+0xc>
    d += n;
    80000226:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000228:	fff6079b          	addiw	a5,a2,-1
    8000022c:	1782                	slli	a5,a5,0x20
    8000022e:	9381                	srli	a5,a5,0x20
    80000230:	fff7c793          	not	a5,a5
    80000234:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000236:	177d                	addi	a4,a4,-1
    80000238:	16fd                	addi	a3,a3,-1
    8000023a:	00074603          	lbu	a2,0(a4)
    8000023e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000242:	fef71ae3          	bne	a4,a5,80000236 <memmove+0x4a>
    80000246:	b7f1                	j	80000212 <memmove+0x26>

0000000080000248 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000248:	1141                	addi	sp,sp,-16
    8000024a:	e406                	sd	ra,8(sp)
    8000024c:	e022                	sd	s0,0(sp)
    8000024e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000250:	f9dff0ef          	jal	800001ec <memmove>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret

000000008000025c <strncmp>:

//Compares the first n characters between two strings p and q.
int
strncmp(const char *p, const char *q, uint n)
{
    8000025c:	1141                	addi	sp,sp,-16
    8000025e:	e422                	sd	s0,8(sp)
    80000260:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000262:	ce11                	beqz	a2,8000027e <strncmp+0x22>
    80000264:	00054783          	lbu	a5,0(a0)
    80000268:	cf89                	beqz	a5,80000282 <strncmp+0x26>
    8000026a:	0005c703          	lbu	a4,0(a1)
    8000026e:	00f71a63          	bne	a4,a5,80000282 <strncmp+0x26>
    n--, p++, q++;
    80000272:	367d                	addiw	a2,a2,-1
    80000274:	0505                	addi	a0,a0,1
    80000276:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000278:	f675                	bnez	a2,80000264 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000027a:	4501                	li	a0,0
    8000027c:	a801                	j	8000028c <strncmp+0x30>
    8000027e:	4501                	li	a0,0
    80000280:	a031                	j	8000028c <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000282:	00054503          	lbu	a0,0(a0)
    80000286:	0005c783          	lbu	a5,0(a1)
    8000028a:	9d1d                	subw	a0,a0,a5
}
    8000028c:	6422                	ld	s0,8(sp)
    8000028e:	0141                	addi	sp,sp,16
    80000290:	8082                	ret

0000000080000292 <strncpy>:

//Copy n characters from string t to s
char*
strncpy(char *s, const char *t, int n)
{
    80000292:	1141                	addi	sp,sp,-16
    80000294:	e422                	sd	s0,8(sp)
    80000296:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000298:	87aa                	mv	a5,a0
    8000029a:	86b2                	mv	a3,a2
    8000029c:	367d                	addiw	a2,a2,-1
    8000029e:	02d05563          	blez	a3,800002c8 <strncpy+0x36>
    800002a2:	0785                	addi	a5,a5,1
    800002a4:	0005c703          	lbu	a4,0(a1)
    800002a8:	fee78fa3          	sb	a4,-1(a5)
    800002ac:	0585                	addi	a1,a1,1
    800002ae:	f775                	bnez	a4,8000029a <strncpy+0x8>
    ;
  while(n-- > 0)
    800002b0:	873e                	mv	a4,a5
    800002b2:	9fb5                	addw	a5,a5,a3
    800002b4:	37fd                	addiw	a5,a5,-1
    800002b6:	00c05963          	blez	a2,800002c8 <strncpy+0x36>
    *s++ = 0; //add /0 to make sure that string end.
    800002ba:	0705                	addi	a4,a4,1
    800002bc:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    800002c0:	40e786bb          	subw	a3,a5,a4
    800002c4:	fed04be3          	bgtz	a3,800002ba <strncpy+0x28>
  return os;
}
    800002c8:	6422                	ld	s0,8(sp)
    800002ca:	0141                	addi	sp,sp,16
    800002cc:	8082                	ret

00000000800002ce <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002ce:	1141                	addi	sp,sp,-16
    800002d0:	e422                	sd	s0,8(sp)
    800002d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002d4:	02c05363          	blez	a2,800002fa <safestrcpy+0x2c>
    800002d8:	fff6069b          	addiw	a3,a2,-1
    800002dc:	1682                	slli	a3,a3,0x20
    800002de:	9281                	srli	a3,a3,0x20
    800002e0:	96ae                	add	a3,a3,a1
    800002e2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002e4:	00d58963          	beq	a1,a3,800002f6 <safestrcpy+0x28>
    800002e8:	0585                	addi	a1,a1,1
    800002ea:	0785                	addi	a5,a5,1
    800002ec:	fff5c703          	lbu	a4,-1(a1)
    800002f0:	fee78fa3          	sb	a4,-1(a5)
    800002f4:	fb65                	bnez	a4,800002e4 <safestrcpy+0x16>
    ;
  *s = 0;
    800002f6:	00078023          	sb	zero,0(a5)
  return os;
}
    800002fa:	6422                	ld	s0,8(sp)
    800002fc:	0141                	addi	sp,sp,16
    800002fe:	8082                	ret

0000000080000300 <strlen>:

//get the length of the string
int
strlen(const char *s)
{
    80000300:	1141                	addi	sp,sp,-16
    80000302:	e422                	sd	s0,8(sp)
    80000304:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000306:	00054783          	lbu	a5,0(a0)
    8000030a:	cf91                	beqz	a5,80000326 <strlen+0x26>
    8000030c:	0505                	addi	a0,a0,1
    8000030e:	87aa                	mv	a5,a0
    80000310:	86be                	mv	a3,a5
    80000312:	0785                	addi	a5,a5,1
    80000314:	fff7c703          	lbu	a4,-1(a5)
    80000318:	ff65                	bnez	a4,80000310 <strlen+0x10>
    8000031a:	40a6853b          	subw	a0,a3,a0
    8000031e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000320:	6422                	ld	s0,8(sp)
    80000322:	0141                	addi	sp,sp,16
    80000324:	8082                	ret
  for(n = 0; s[n]; n++)
    80000326:	4501                	li	a0,0
    80000328:	bfe5                	j	80000320 <strlen+0x20>

000000008000032a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000032a:	1141                	addi	sp,sp,-16
    8000032c:	e406                	sd	ra,8(sp)
    8000032e:	e022                	sd	s0,0(sp)
    80000330:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000332:	323000ef          	jal	80000e54 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000336:	0000a717          	auipc	a4,0xa
    8000033a:	26a70713          	addi	a4,a4,618 # 8000a5a0 <started>
  if(cpuid() == 0){
    8000033e:	c51d                	beqz	a0,8000036c <main+0x42>
    while(started == 0)
    80000340:	431c                	lw	a5,0(a4)
    80000342:	2781                	sext.w	a5,a5
    80000344:	dff5                	beqz	a5,80000340 <main+0x16>
      ;
    __sync_synchronize();
    80000346:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    8000034a:	30b000ef          	jal	80000e54 <cpuid>
    8000034e:	85aa                	mv	a1,a0
    80000350:	00007517          	auipc	a0,0x7
    80000354:	ce850513          	addi	a0,a0,-792 # 80007038 <etext+0x38>
    80000358:	078050ef          	jal	800053d0 <printf>
    kvminithart();    // turn on paging
    8000035c:	080000ef          	jal	800003dc <kvminithart>
    trapinithart();   // install kernel trap vector
    80000360:	646010ef          	jal	800019a6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000364:	624040ef          	jal	80004988 <plicinithart>
  }

  scheduler();        
    80000368:	755000ef          	jal	800012bc <scheduler>
    consoleinit();
    8000036c:	78f040ef          	jal	800052fa <consoleinit>
    printfinit();
    80000370:	36c050ef          	jal	800056dc <printfinit>
    printf("\n");
    80000374:	00007517          	auipc	a0,0x7
    80000378:	ca450513          	addi	a0,a0,-860 # 80007018 <etext+0x18>
    8000037c:	054050ef          	jal	800053d0 <printf>
    printf("xv6 kernel is booting\n");
    80000380:	00007517          	auipc	a0,0x7
    80000384:	ca050513          	addi	a0,a0,-864 # 80007020 <etext+0x20>
    80000388:	048050ef          	jal	800053d0 <printf>
    printf("\n");
    8000038c:	00007517          	auipc	a0,0x7
    80000390:	c8c50513          	addi	a0,a0,-884 # 80007018 <etext+0x18>
    80000394:	03c050ef          	jal	800053d0 <printf>
    kinit();         // physical page allocator
    80000398:	d33ff0ef          	jal	800000ca <kinit>
    kvminit();       // create kernel page table
    8000039c:	2ca000ef          	jal	80000666 <kvminit>
    kvminithart();   // turn on paging
    800003a0:	03c000ef          	jal	800003dc <kvminithart>
    procinit();      // process table
    800003a4:	1fb000ef          	jal	80000d9e <procinit>
    trapinit();      // trap vectors
    800003a8:	5da010ef          	jal	80001982 <trapinit>
    trapinithart();  // install kernel trap vector
    800003ac:	5fa010ef          	jal	800019a6 <trapinithart>
    plicinit();      // set up interrupt controller
    800003b0:	5be040ef          	jal	8000496e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003b4:	5d4040ef          	jal	80004988 <plicinithart>
    binit();         // buffer cache
    800003b8:	52d010ef          	jal	800020e4 <binit>
    iinit();         // inode table
    800003bc:	31e020ef          	jal	800026da <iinit>
    fileinit();      // file table
    800003c0:	0ca030ef          	jal	8000348a <fileinit>
    virtio_disk_init(); // emulated hard disk
    800003c4:	6b4040ef          	jal	80004a78 <virtio_disk_init>
    userinit();      // first user process
    800003c8:	521000ef          	jal	800010e8 <userinit>
    __sync_synchronize();
    800003cc:	0330000f          	fence	rw,rw
    started = 1;
    800003d0:	4785                	li	a5,1
    800003d2:	0000a717          	auipc	a4,0xa
    800003d6:	1cf72723          	sw	a5,462(a4) # 8000a5a0 <started>
    800003da:	b779                	j	80000368 <main+0x3e>

00000000800003dc <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800003dc:	1141                	addi	sp,sp,-16
    800003de:	e422                	sd	s0,8(sp)
    800003e0:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003e2:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003e6:	0000a797          	auipc	a5,0xa
    800003ea:	1c27b783          	ld	a5,450(a5) # 8000a5a8 <kernel_pagetable>
    800003ee:	83b1                	srli	a5,a5,0xc
    800003f0:	577d                	li	a4,-1
    800003f2:	177e                	slli	a4,a4,0x3f
    800003f4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003f6:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003fa:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003fe:	6422                	ld	s0,8(sp)
    80000400:	0141                	addi	sp,sp,16
    80000402:	8082                	ret

0000000080000404 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000404:	7139                	addi	sp,sp,-64
    80000406:	fc06                	sd	ra,56(sp)
    80000408:	f822                	sd	s0,48(sp)
    8000040a:	f426                	sd	s1,40(sp)
    8000040c:	f04a                	sd	s2,32(sp)
    8000040e:	ec4e                	sd	s3,24(sp)
    80000410:	e852                	sd	s4,16(sp)
    80000412:	e456                	sd	s5,8(sp)
    80000414:	e05a                	sd	s6,0(sp)
    80000416:	0080                	addi	s0,sp,64
    80000418:	84aa                	mv	s1,a0
    8000041a:	89ae                	mv	s3,a1
    8000041c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000041e:	57fd                	li	a5,-1
    80000420:	83e9                	srli	a5,a5,0x1a
    80000422:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000424:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000426:	02b7fc63          	bgeu	a5,a1,8000045e <walk+0x5a>
    panic("walk");
    8000042a:	00007517          	auipc	a0,0x7
    8000042e:	c2650513          	addi	a0,a0,-986 # 80007050 <etext+0x50>
    80000432:	270050ef          	jal	800056a2 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000436:	060a8263          	beqz	s5,8000049a <walk+0x96>
    8000043a:	cc5ff0ef          	jal	800000fe <kalloc>
    8000043e:	84aa                	mv	s1,a0
    80000440:	c139                	beqz	a0,80000486 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000442:	6605                	lui	a2,0x1
    80000444:	4581                	li	a1,0
    80000446:	d4bff0ef          	jal	80000190 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000044a:	00c4d793          	srli	a5,s1,0xc
    8000044e:	07aa                	slli	a5,a5,0xa
    80000450:	0017e793          	ori	a5,a5,1
    80000454:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000458:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb4f7>
    8000045a:	036a0063          	beq	s4,s6,8000047a <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000045e:	0149d933          	srl	s2,s3,s4
    80000462:	1ff97913          	andi	s2,s2,511
    80000466:	090e                	slli	s2,s2,0x3
    80000468:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000046a:	00093483          	ld	s1,0(s2)
    8000046e:	0014f793          	andi	a5,s1,1
    80000472:	d3f1                	beqz	a5,80000436 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000474:	80a9                	srli	s1,s1,0xa
    80000476:	04b2                	slli	s1,s1,0xc
    80000478:	b7c5                	j	80000458 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    8000047a:	00c9d513          	srli	a0,s3,0xc
    8000047e:	1ff57513          	andi	a0,a0,511
    80000482:	050e                	slli	a0,a0,0x3
    80000484:	9526                	add	a0,a0,s1
}
    80000486:	70e2                	ld	ra,56(sp)
    80000488:	7442                	ld	s0,48(sp)
    8000048a:	74a2                	ld	s1,40(sp)
    8000048c:	7902                	ld	s2,32(sp)
    8000048e:	69e2                	ld	s3,24(sp)
    80000490:	6a42                	ld	s4,16(sp)
    80000492:	6aa2                	ld	s5,8(sp)
    80000494:	6b02                	ld	s6,0(sp)
    80000496:	6121                	addi	sp,sp,64
    80000498:	8082                	ret
        return 0;
    8000049a:	4501                	li	a0,0
    8000049c:	b7ed                	j	80000486 <walk+0x82>

000000008000049e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000049e:	57fd                	li	a5,-1
    800004a0:	83e9                	srli	a5,a5,0x1a
    800004a2:	00b7f463          	bgeu	a5,a1,800004aa <walkaddr+0xc>
    return 0;
    800004a6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800004a8:	8082                	ret
{
    800004aa:	1141                	addi	sp,sp,-16
    800004ac:	e406                	sd	ra,8(sp)
    800004ae:	e022                	sd	s0,0(sp)
    800004b0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800004b2:	4601                	li	a2,0
    800004b4:	f51ff0ef          	jal	80000404 <walk>
  if(pte == 0)
    800004b8:	c105                	beqz	a0,800004d8 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800004ba:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800004bc:	0117f693          	andi	a3,a5,17
    800004c0:	4745                	li	a4,17
    return 0;
    800004c2:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800004c4:	00e68663          	beq	a3,a4,800004d0 <walkaddr+0x32>
}
    800004c8:	60a2                	ld	ra,8(sp)
    800004ca:	6402                	ld	s0,0(sp)
    800004cc:	0141                	addi	sp,sp,16
    800004ce:	8082                	ret
  pa = PTE2PA(*pte);
    800004d0:	83a9                	srli	a5,a5,0xa
    800004d2:	00c79513          	slli	a0,a5,0xc
  return pa;
    800004d6:	bfcd                	j	800004c8 <walkaddr+0x2a>
    return 0;
    800004d8:	4501                	li	a0,0
    800004da:	b7fd                	j	800004c8 <walkaddr+0x2a>

00000000800004dc <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800004dc:	715d                	addi	sp,sp,-80
    800004de:	e486                	sd	ra,72(sp)
    800004e0:	e0a2                	sd	s0,64(sp)
    800004e2:	fc26                	sd	s1,56(sp)
    800004e4:	f84a                	sd	s2,48(sp)
    800004e6:	f44e                	sd	s3,40(sp)
    800004e8:	f052                	sd	s4,32(sp)
    800004ea:	ec56                	sd	s5,24(sp)
    800004ec:	e85a                	sd	s6,16(sp)
    800004ee:	e45e                	sd	s7,8(sp)
    800004f0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004f2:	03459793          	slli	a5,a1,0x34
    800004f6:	e7a9                	bnez	a5,80000540 <mappages+0x64>
    800004f8:	8aaa                	mv	s5,a0
    800004fa:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004fc:	03461793          	slli	a5,a2,0x34
    80000500:	e7b1                	bnez	a5,8000054c <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000502:	ca39                	beqz	a2,80000558 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000504:	77fd                	lui	a5,0xfffff
    80000506:	963e                	add	a2,a2,a5
    80000508:	00b609b3          	add	s3,a2,a1
  a = va;
    8000050c:	892e                	mv	s2,a1
    8000050e:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000512:	6b85                	lui	s7,0x1
    80000514:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80000518:	4605                	li	a2,1
    8000051a:	85ca                	mv	a1,s2
    8000051c:	8556                	mv	a0,s5
    8000051e:	ee7ff0ef          	jal	80000404 <walk>
    80000522:	c539                	beqz	a0,80000570 <mappages+0x94>
    if(*pte & PTE_V)
    80000524:	611c                	ld	a5,0(a0)
    80000526:	8b85                	andi	a5,a5,1
    80000528:	ef95                	bnez	a5,80000564 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000052a:	80b1                	srli	s1,s1,0xc
    8000052c:	04aa                	slli	s1,s1,0xa
    8000052e:	0164e4b3          	or	s1,s1,s6
    80000532:	0014e493          	ori	s1,s1,1
    80000536:	e104                	sd	s1,0(a0)
    if(a == last)
    80000538:	05390863          	beq	s2,s3,80000588 <mappages+0xac>
    a += PGSIZE;
    8000053c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000053e:	bfd9                	j	80000514 <mappages+0x38>
    panic("mappages: va not aligned");
    80000540:	00007517          	auipc	a0,0x7
    80000544:	b1850513          	addi	a0,a0,-1256 # 80007058 <etext+0x58>
    80000548:	15a050ef          	jal	800056a2 <panic>
    panic("mappages: size not aligned");
    8000054c:	00007517          	auipc	a0,0x7
    80000550:	b2c50513          	addi	a0,a0,-1236 # 80007078 <etext+0x78>
    80000554:	14e050ef          	jal	800056a2 <panic>
    panic("mappages: size");
    80000558:	00007517          	auipc	a0,0x7
    8000055c:	b4050513          	addi	a0,a0,-1216 # 80007098 <etext+0x98>
    80000560:	142050ef          	jal	800056a2 <panic>
      panic("mappages: remap");
    80000564:	00007517          	auipc	a0,0x7
    80000568:	b4450513          	addi	a0,a0,-1212 # 800070a8 <etext+0xa8>
    8000056c:	136050ef          	jal	800056a2 <panic>
      return -1;
    80000570:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000572:	60a6                	ld	ra,72(sp)
    80000574:	6406                	ld	s0,64(sp)
    80000576:	74e2                	ld	s1,56(sp)
    80000578:	7942                	ld	s2,48(sp)
    8000057a:	79a2                	ld	s3,40(sp)
    8000057c:	7a02                	ld	s4,32(sp)
    8000057e:	6ae2                	ld	s5,24(sp)
    80000580:	6b42                	ld	s6,16(sp)
    80000582:	6ba2                	ld	s7,8(sp)
    80000584:	6161                	addi	sp,sp,80
    80000586:	8082                	ret
  return 0;
    80000588:	4501                	li	a0,0
    8000058a:	b7e5                	j	80000572 <mappages+0x96>

000000008000058c <kvmmap>:
{
    8000058c:	1141                	addi	sp,sp,-16
    8000058e:	e406                	sd	ra,8(sp)
    80000590:	e022                	sd	s0,0(sp)
    80000592:	0800                	addi	s0,sp,16
    80000594:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000596:	86b2                	mv	a3,a2
    80000598:	863e                	mv	a2,a5
    8000059a:	f43ff0ef          	jal	800004dc <mappages>
    8000059e:	e509                	bnez	a0,800005a8 <kvmmap+0x1c>
}
    800005a0:	60a2                	ld	ra,8(sp)
    800005a2:	6402                	ld	s0,0(sp)
    800005a4:	0141                	addi	sp,sp,16
    800005a6:	8082                	ret
    panic("kvmmap");
    800005a8:	00007517          	auipc	a0,0x7
    800005ac:	b1050513          	addi	a0,a0,-1264 # 800070b8 <etext+0xb8>
    800005b0:	0f2050ef          	jal	800056a2 <panic>

00000000800005b4 <kvmmake>:
{
    800005b4:	1101                	addi	sp,sp,-32
    800005b6:	ec06                	sd	ra,24(sp)
    800005b8:	e822                	sd	s0,16(sp)
    800005ba:	e426                	sd	s1,8(sp)
    800005bc:	e04a                	sd	s2,0(sp)
    800005be:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800005c0:	b3fff0ef          	jal	800000fe <kalloc>
    800005c4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800005c6:	6605                	lui	a2,0x1
    800005c8:	4581                	li	a1,0
    800005ca:	bc7ff0ef          	jal	80000190 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800005ce:	4719                	li	a4,6
    800005d0:	6685                	lui	a3,0x1
    800005d2:	10000637          	lui	a2,0x10000
    800005d6:	100005b7          	lui	a1,0x10000
    800005da:	8526                	mv	a0,s1
    800005dc:	fb1ff0ef          	jal	8000058c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800005e0:	4719                	li	a4,6
    800005e2:	6685                	lui	a3,0x1
    800005e4:	10001637          	lui	a2,0x10001
    800005e8:	100015b7          	lui	a1,0x10001
    800005ec:	8526                	mv	a0,s1
    800005ee:	f9fff0ef          	jal	8000058c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005f2:	4719                	li	a4,6
    800005f4:	040006b7          	lui	a3,0x4000
    800005f8:	0c000637          	lui	a2,0xc000
    800005fc:	0c0005b7          	lui	a1,0xc000
    80000600:	8526                	mv	a0,s1
    80000602:	f8bff0ef          	jal	8000058c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80000606:	00007917          	auipc	s2,0x7
    8000060a:	9fa90913          	addi	s2,s2,-1542 # 80007000 <etext>
    8000060e:	4729                	li	a4,10
    80000610:	80007697          	auipc	a3,0x80007
    80000614:	9f068693          	addi	a3,a3,-1552 # 7000 <_entry-0x7fff9000>
    80000618:	4605                	li	a2,1
    8000061a:	067e                	slli	a2,a2,0x1f
    8000061c:	85b2                	mv	a1,a2
    8000061e:	8526                	mv	a0,s1
    80000620:	f6dff0ef          	jal	8000058c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80000624:	46c5                	li	a3,17
    80000626:	06ee                	slli	a3,a3,0x1b
    80000628:	4719                	li	a4,6
    8000062a:	412686b3          	sub	a3,a3,s2
    8000062e:	864a                	mv	a2,s2
    80000630:	85ca                	mv	a1,s2
    80000632:	8526                	mv	a0,s1
    80000634:	f59ff0ef          	jal	8000058c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000638:	4729                	li	a4,10
    8000063a:	6685                	lui	a3,0x1
    8000063c:	00006617          	auipc	a2,0x6
    80000640:	9c460613          	addi	a2,a2,-1596 # 80006000 <_trampoline>
    80000644:	040005b7          	lui	a1,0x4000
    80000648:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000064a:	05b2                	slli	a1,a1,0xc
    8000064c:	8526                	mv	a0,s1
    8000064e:	f3fff0ef          	jal	8000058c <kvmmap>
  proc_mapstacks(kpgtbl);
    80000652:	8526                	mv	a0,s1
    80000654:	6b2000ef          	jal	80000d06 <proc_mapstacks>
}
    80000658:	8526                	mv	a0,s1
    8000065a:	60e2                	ld	ra,24(sp)
    8000065c:	6442                	ld	s0,16(sp)
    8000065e:	64a2                	ld	s1,8(sp)
    80000660:	6902                	ld	s2,0(sp)
    80000662:	6105                	addi	sp,sp,32
    80000664:	8082                	ret

0000000080000666 <kvminit>:
{
    80000666:	1141                	addi	sp,sp,-16
    80000668:	e406                	sd	ra,8(sp)
    8000066a:	e022                	sd	s0,0(sp)
    8000066c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000066e:	f47ff0ef          	jal	800005b4 <kvmmake>
    80000672:	0000a797          	auipc	a5,0xa
    80000676:	f2a7bb23          	sd	a0,-202(a5) # 8000a5a8 <kernel_pagetable>
}
    8000067a:	60a2                	ld	ra,8(sp)
    8000067c:	6402                	ld	s0,0(sp)
    8000067e:	0141                	addi	sp,sp,16
    80000680:	8082                	ret

0000000080000682 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000682:	715d                	addi	sp,sp,-80
    80000684:	e486                	sd	ra,72(sp)
    80000686:	e0a2                	sd	s0,64(sp)
    80000688:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000068a:	03459793          	slli	a5,a1,0x34
    8000068e:	e39d                	bnez	a5,800006b4 <uvmunmap+0x32>
    80000690:	f84a                	sd	s2,48(sp)
    80000692:	f44e                	sd	s3,40(sp)
    80000694:	f052                	sd	s4,32(sp)
    80000696:	ec56                	sd	s5,24(sp)
    80000698:	e85a                	sd	s6,16(sp)
    8000069a:	e45e                	sd	s7,8(sp)
    8000069c:	8a2a                	mv	s4,a0
    8000069e:	892e                	mv	s2,a1
    800006a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006a2:	0632                	slli	a2,a2,0xc
    800006a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800006a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006aa:	6b05                	lui	s6,0x1
    800006ac:	0735ff63          	bgeu	a1,s3,8000072a <uvmunmap+0xa8>
    800006b0:	fc26                	sd	s1,56(sp)
    800006b2:	a0a9                	j	800006fc <uvmunmap+0x7a>
    800006b4:	fc26                	sd	s1,56(sp)
    800006b6:	f84a                	sd	s2,48(sp)
    800006b8:	f44e                	sd	s3,40(sp)
    800006ba:	f052                	sd	s4,32(sp)
    800006bc:	ec56                	sd	s5,24(sp)
    800006be:	e85a                	sd	s6,16(sp)
    800006c0:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800006c2:	00007517          	auipc	a0,0x7
    800006c6:	9fe50513          	addi	a0,a0,-1538 # 800070c0 <etext+0xc0>
    800006ca:	7d9040ef          	jal	800056a2 <panic>
      panic("uvmunmap: walk");
    800006ce:	00007517          	auipc	a0,0x7
    800006d2:	a0a50513          	addi	a0,a0,-1526 # 800070d8 <etext+0xd8>
    800006d6:	7cd040ef          	jal	800056a2 <panic>
      panic("uvmunmap: not mapped");
    800006da:	00007517          	auipc	a0,0x7
    800006de:	a0e50513          	addi	a0,a0,-1522 # 800070e8 <etext+0xe8>
    800006e2:	7c1040ef          	jal	800056a2 <panic>
      panic("uvmunmap: not a leaf");
    800006e6:	00007517          	auipc	a0,0x7
    800006ea:	a1a50513          	addi	a0,a0,-1510 # 80007100 <etext+0x100>
    800006ee:	7b5040ef          	jal	800056a2 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800006f2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006f6:	995a                	add	s2,s2,s6
    800006f8:	03397863          	bgeu	s2,s3,80000728 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800006fc:	4601                	li	a2,0
    800006fe:	85ca                	mv	a1,s2
    80000700:	8552                	mv	a0,s4
    80000702:	d03ff0ef          	jal	80000404 <walk>
    80000706:	84aa                	mv	s1,a0
    80000708:	d179                	beqz	a0,800006ce <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    8000070a:	6108                	ld	a0,0(a0)
    8000070c:	00157793          	andi	a5,a0,1
    80000710:	d7e9                	beqz	a5,800006da <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000712:	3ff57793          	andi	a5,a0,1023
    80000716:	fd7788e3          	beq	a5,s7,800006e6 <uvmunmap+0x64>
    if(do_free){
    8000071a:	fc0a8ce3          	beqz	s5,800006f2 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000071e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80000720:	0532                	slli	a0,a0,0xc
    80000722:	8fbff0ef          	jal	8000001c <kfree>
    80000726:	b7f1                	j	800006f2 <uvmunmap+0x70>
    80000728:	74e2                	ld	s1,56(sp)
    8000072a:	7942                	ld	s2,48(sp)
    8000072c:	79a2                	ld	s3,40(sp)
    8000072e:	7a02                	ld	s4,32(sp)
    80000730:	6ae2                	ld	s5,24(sp)
    80000732:	6b42                	ld	s6,16(sp)
    80000734:	6ba2                	ld	s7,8(sp)
  }
}
    80000736:	60a6                	ld	ra,72(sp)
    80000738:	6406                	ld	s0,64(sp)
    8000073a:	6161                	addi	sp,sp,80
    8000073c:	8082                	ret

000000008000073e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000073e:	1101                	addi	sp,sp,-32
    80000740:	ec06                	sd	ra,24(sp)
    80000742:	e822                	sd	s0,16(sp)
    80000744:	e426                	sd	s1,8(sp)
    80000746:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000748:	9b7ff0ef          	jal	800000fe <kalloc>
    8000074c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000074e:	c509                	beqz	a0,80000758 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000750:	6605                	lui	a2,0x1
    80000752:	4581                	li	a1,0
    80000754:	a3dff0ef          	jal	80000190 <memset>
  return pagetable;
}
    80000758:	8526                	mv	a0,s1
    8000075a:	60e2                	ld	ra,24(sp)
    8000075c:	6442                	ld	s0,16(sp)
    8000075e:	64a2                	ld	s1,8(sp)
    80000760:	6105                	addi	sp,sp,32
    80000762:	8082                	ret

0000000080000764 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000764:	7179                	addi	sp,sp,-48
    80000766:	f406                	sd	ra,40(sp)
    80000768:	f022                	sd	s0,32(sp)
    8000076a:	ec26                	sd	s1,24(sp)
    8000076c:	e84a                	sd	s2,16(sp)
    8000076e:	e44e                	sd	s3,8(sp)
    80000770:	e052                	sd	s4,0(sp)
    80000772:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000774:	6785                	lui	a5,0x1
    80000776:	04f67063          	bgeu	a2,a5,800007b6 <uvmfirst+0x52>
    8000077a:	8a2a                	mv	s4,a0
    8000077c:	89ae                	mv	s3,a1
    8000077e:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000780:	97fff0ef          	jal	800000fe <kalloc>
    80000784:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000786:	6605                	lui	a2,0x1
    80000788:	4581                	li	a1,0
    8000078a:	a07ff0ef          	jal	80000190 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000078e:	4779                	li	a4,30
    80000790:	86ca                	mv	a3,s2
    80000792:	6605                	lui	a2,0x1
    80000794:	4581                	li	a1,0
    80000796:	8552                	mv	a0,s4
    80000798:	d45ff0ef          	jal	800004dc <mappages>
  memmove(mem, src, sz);
    8000079c:	8626                	mv	a2,s1
    8000079e:	85ce                	mv	a1,s3
    800007a0:	854a                	mv	a0,s2
    800007a2:	a4bff0ef          	jal	800001ec <memmove>
}
    800007a6:	70a2                	ld	ra,40(sp)
    800007a8:	7402                	ld	s0,32(sp)
    800007aa:	64e2                	ld	s1,24(sp)
    800007ac:	6942                	ld	s2,16(sp)
    800007ae:	69a2                	ld	s3,8(sp)
    800007b0:	6a02                	ld	s4,0(sp)
    800007b2:	6145                	addi	sp,sp,48
    800007b4:	8082                	ret
    panic("uvmfirst: more than a page");
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	96250513          	addi	a0,a0,-1694 # 80007118 <etext+0x118>
    800007be:	6e5040ef          	jal	800056a2 <panic>

00000000800007c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800007c2:	1101                	addi	sp,sp,-32
    800007c4:	ec06                	sd	ra,24(sp)
    800007c6:	e822                	sd	s0,16(sp)
    800007c8:	e426                	sd	s1,8(sp)
    800007ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800007cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800007ce:	00b67d63          	bgeu	a2,a1,800007e8 <uvmdealloc+0x26>
    800007d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800007d4:	6785                	lui	a5,0x1
    800007d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007d8:	00f60733          	add	a4,a2,a5
    800007dc:	76fd                	lui	a3,0xfffff
    800007de:	8f75                	and	a4,a4,a3
    800007e0:	97ae                	add	a5,a5,a1
    800007e2:	8ff5                	and	a5,a5,a3
    800007e4:	00f76863          	bltu	a4,a5,800007f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007e8:	8526                	mv	a0,s1
    800007ea:	60e2                	ld	ra,24(sp)
    800007ec:	6442                	ld	s0,16(sp)
    800007ee:	64a2                	ld	s1,8(sp)
    800007f0:	6105                	addi	sp,sp,32
    800007f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007f4:	8f99                	sub	a5,a5,a4
    800007f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007f8:	4685                	li	a3,1
    800007fa:	0007861b          	sext.w	a2,a5
    800007fe:	85ba                	mv	a1,a4
    80000800:	e83ff0ef          	jal	80000682 <uvmunmap>
    80000804:	b7d5                	j	800007e8 <uvmdealloc+0x26>

0000000080000806 <uvmalloc>:
  if(newsz < oldsz)
    80000806:	08b66f63          	bltu	a2,a1,800008a4 <uvmalloc+0x9e>
{
    8000080a:	7139                	addi	sp,sp,-64
    8000080c:	fc06                	sd	ra,56(sp)
    8000080e:	f822                	sd	s0,48(sp)
    80000810:	ec4e                	sd	s3,24(sp)
    80000812:	e852                	sd	s4,16(sp)
    80000814:	e456                	sd	s5,8(sp)
    80000816:	0080                	addi	s0,sp,64
    80000818:	8aaa                	mv	s5,a0
    8000081a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000081c:	6785                	lui	a5,0x1
    8000081e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000820:	95be                	add	a1,a1,a5
    80000822:	77fd                	lui	a5,0xfffff
    80000824:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000828:	08c9f063          	bgeu	s3,a2,800008a8 <uvmalloc+0xa2>
    8000082c:	f426                	sd	s1,40(sp)
    8000082e:	f04a                	sd	s2,32(sp)
    80000830:	e05a                	sd	s6,0(sp)
    80000832:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000834:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000838:	8c7ff0ef          	jal	800000fe <kalloc>
    8000083c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000083e:	c515                	beqz	a0,8000086a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80000840:	6605                	lui	a2,0x1
    80000842:	4581                	li	a1,0
    80000844:	94dff0ef          	jal	80000190 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000848:	875a                	mv	a4,s6
    8000084a:	86a6                	mv	a3,s1
    8000084c:	6605                	lui	a2,0x1
    8000084e:	85ca                	mv	a1,s2
    80000850:	8556                	mv	a0,s5
    80000852:	c8bff0ef          	jal	800004dc <mappages>
    80000856:	e915                	bnez	a0,8000088a <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000858:	6785                	lui	a5,0x1
    8000085a:	993e                	add	s2,s2,a5
    8000085c:	fd496ee3          	bltu	s2,s4,80000838 <uvmalloc+0x32>
  return newsz;
    80000860:	8552                	mv	a0,s4
    80000862:	74a2                	ld	s1,40(sp)
    80000864:	7902                	ld	s2,32(sp)
    80000866:	6b02                	ld	s6,0(sp)
    80000868:	a811                	j	8000087c <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    8000086a:	864e                	mv	a2,s3
    8000086c:	85ca                	mv	a1,s2
    8000086e:	8556                	mv	a0,s5
    80000870:	f53ff0ef          	jal	800007c2 <uvmdealloc>
      return 0;
    80000874:	4501                	li	a0,0
    80000876:	74a2                	ld	s1,40(sp)
    80000878:	7902                	ld	s2,32(sp)
    8000087a:	6b02                	ld	s6,0(sp)
}
    8000087c:	70e2                	ld	ra,56(sp)
    8000087e:	7442                	ld	s0,48(sp)
    80000880:	69e2                	ld	s3,24(sp)
    80000882:	6a42                	ld	s4,16(sp)
    80000884:	6aa2                	ld	s5,8(sp)
    80000886:	6121                	addi	sp,sp,64
    80000888:	8082                	ret
      kfree(mem);
    8000088a:	8526                	mv	a0,s1
    8000088c:	f90ff0ef          	jal	8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000890:	864e                	mv	a2,s3
    80000892:	85ca                	mv	a1,s2
    80000894:	8556                	mv	a0,s5
    80000896:	f2dff0ef          	jal	800007c2 <uvmdealloc>
      return 0;
    8000089a:	4501                	li	a0,0
    8000089c:	74a2                	ld	s1,40(sp)
    8000089e:	7902                	ld	s2,32(sp)
    800008a0:	6b02                	ld	s6,0(sp)
    800008a2:	bfe9                	j	8000087c <uvmalloc+0x76>
    return oldsz;
    800008a4:	852e                	mv	a0,a1
}
    800008a6:	8082                	ret
  return newsz;
    800008a8:	8532                	mv	a0,a2
    800008aa:	bfc9                	j	8000087c <uvmalloc+0x76>

00000000800008ac <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800008ac:	7179                	addi	sp,sp,-48
    800008ae:	f406                	sd	ra,40(sp)
    800008b0:	f022                	sd	s0,32(sp)
    800008b2:	ec26                	sd	s1,24(sp)
    800008b4:	e84a                	sd	s2,16(sp)
    800008b6:	e44e                	sd	s3,8(sp)
    800008b8:	e052                	sd	s4,0(sp)
    800008ba:	1800                	addi	s0,sp,48
    800008bc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800008be:	84aa                	mv	s1,a0
    800008c0:	6905                	lui	s2,0x1
    800008c2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800008c4:	4985                	li	s3,1
    800008c6:	a819                	j	800008dc <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800008c8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800008ca:	00c79513          	slli	a0,a5,0xc
    800008ce:	fdfff0ef          	jal	800008ac <freewalk>
      pagetable[i] = 0;
    800008d2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800008d6:	04a1                	addi	s1,s1,8
    800008d8:	01248f63          	beq	s1,s2,800008f6 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800008dc:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800008de:	00f7f713          	andi	a4,a5,15
    800008e2:	ff3703e3          	beq	a4,s3,800008c8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800008e6:	8b85                	andi	a5,a5,1
    800008e8:	d7fd                	beqz	a5,800008d6 <freewalk+0x2a>
      panic("freewalk: leaf");
    800008ea:	00007517          	auipc	a0,0x7
    800008ee:	84e50513          	addi	a0,a0,-1970 # 80007138 <etext+0x138>
    800008f2:	5b1040ef          	jal	800056a2 <panic>
    }
  }
  kfree((void*)pagetable);
    800008f6:	8552                	mv	a0,s4
    800008f8:	f24ff0ef          	jal	8000001c <kfree>
}
    800008fc:	70a2                	ld	ra,40(sp)
    800008fe:	7402                	ld	s0,32(sp)
    80000900:	64e2                	ld	s1,24(sp)
    80000902:	6942                	ld	s2,16(sp)
    80000904:	69a2                	ld	s3,8(sp)
    80000906:	6a02                	ld	s4,0(sp)
    80000908:	6145                	addi	sp,sp,48
    8000090a:	8082                	ret

000000008000090c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000090c:	1101                	addi	sp,sp,-32
    8000090e:	ec06                	sd	ra,24(sp)
    80000910:	e822                	sd	s0,16(sp)
    80000912:	e426                	sd	s1,8(sp)
    80000914:	1000                	addi	s0,sp,32
    80000916:	84aa                	mv	s1,a0
  if(sz > 0)
    80000918:	e989                	bnez	a1,8000092a <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000091a:	8526                	mv	a0,s1
    8000091c:	f91ff0ef          	jal	800008ac <freewalk>
}
    80000920:	60e2                	ld	ra,24(sp)
    80000922:	6442                	ld	s0,16(sp)
    80000924:	64a2                	ld	s1,8(sp)
    80000926:	6105                	addi	sp,sp,32
    80000928:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000092a:	6785                	lui	a5,0x1
    8000092c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000092e:	95be                	add	a1,a1,a5
    80000930:	4685                	li	a3,1
    80000932:	00c5d613          	srli	a2,a1,0xc
    80000936:	4581                	li	a1,0
    80000938:	d4bff0ef          	jal	80000682 <uvmunmap>
    8000093c:	bff9                	j	8000091a <uvmfree+0xe>

000000008000093e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000093e:	c65d                	beqz	a2,800009ec <uvmcopy+0xae>
{
    80000940:	715d                	addi	sp,sp,-80
    80000942:	e486                	sd	ra,72(sp)
    80000944:	e0a2                	sd	s0,64(sp)
    80000946:	fc26                	sd	s1,56(sp)
    80000948:	f84a                	sd	s2,48(sp)
    8000094a:	f44e                	sd	s3,40(sp)
    8000094c:	f052                	sd	s4,32(sp)
    8000094e:	ec56                	sd	s5,24(sp)
    80000950:	e85a                	sd	s6,16(sp)
    80000952:	e45e                	sd	s7,8(sp)
    80000954:	0880                	addi	s0,sp,80
    80000956:	8b2a                	mv	s6,a0
    80000958:	8aae                	mv	s5,a1
    8000095a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000095c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000095e:	4601                	li	a2,0
    80000960:	85ce                	mv	a1,s3
    80000962:	855a                	mv	a0,s6
    80000964:	aa1ff0ef          	jal	80000404 <walk>
    80000968:	c121                	beqz	a0,800009a8 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000096a:	6118                	ld	a4,0(a0)
    8000096c:	00177793          	andi	a5,a4,1
    80000970:	c3b1                	beqz	a5,800009b4 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000972:	00a75593          	srli	a1,a4,0xa
    80000976:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000097a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000097e:	f80ff0ef          	jal	800000fe <kalloc>
    80000982:	892a                	mv	s2,a0
    80000984:	c129                	beqz	a0,800009c6 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000986:	6605                	lui	a2,0x1
    80000988:	85de                	mv	a1,s7
    8000098a:	863ff0ef          	jal	800001ec <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000098e:	8726                	mv	a4,s1
    80000990:	86ca                	mv	a3,s2
    80000992:	6605                	lui	a2,0x1
    80000994:	85ce                	mv	a1,s3
    80000996:	8556                	mv	a0,s5
    80000998:	b45ff0ef          	jal	800004dc <mappages>
    8000099c:	e115                	bnez	a0,800009c0 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000099e:	6785                	lui	a5,0x1
    800009a0:	99be                	add	s3,s3,a5
    800009a2:	fb49eee3          	bltu	s3,s4,8000095e <uvmcopy+0x20>
    800009a6:	a805                	j	800009d6 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800009a8:	00006517          	auipc	a0,0x6
    800009ac:	7a050513          	addi	a0,a0,1952 # 80007148 <etext+0x148>
    800009b0:	4f3040ef          	jal	800056a2 <panic>
      panic("uvmcopy: page not present");
    800009b4:	00006517          	auipc	a0,0x6
    800009b8:	7b450513          	addi	a0,a0,1972 # 80007168 <etext+0x168>
    800009bc:	4e7040ef          	jal	800056a2 <panic>
      kfree(mem);
    800009c0:	854a                	mv	a0,s2
    800009c2:	e5aff0ef          	jal	8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800009c6:	4685                	li	a3,1
    800009c8:	00c9d613          	srli	a2,s3,0xc
    800009cc:	4581                	li	a1,0
    800009ce:	8556                	mv	a0,s5
    800009d0:	cb3ff0ef          	jal	80000682 <uvmunmap>
  return -1;
    800009d4:	557d                	li	a0,-1
}
    800009d6:	60a6                	ld	ra,72(sp)
    800009d8:	6406                	ld	s0,64(sp)
    800009da:	74e2                	ld	s1,56(sp)
    800009dc:	7942                	ld	s2,48(sp)
    800009de:	79a2                	ld	s3,40(sp)
    800009e0:	7a02                	ld	s4,32(sp)
    800009e2:	6ae2                	ld	s5,24(sp)
    800009e4:	6b42                	ld	s6,16(sp)
    800009e6:	6ba2                	ld	s7,8(sp)
    800009e8:	6161                	addi	sp,sp,80
    800009ea:	8082                	ret
  return 0;
    800009ec:	4501                	li	a0,0
}
    800009ee:	8082                	ret

00000000800009f0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800009f0:	1141                	addi	sp,sp,-16
    800009f2:	e406                	sd	ra,8(sp)
    800009f4:	e022                	sd	s0,0(sp)
    800009f6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800009f8:	4601                	li	a2,0
    800009fa:	a0bff0ef          	jal	80000404 <walk>
  if(pte == 0)
    800009fe:	c901                	beqz	a0,80000a0e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000a00:	611c                	ld	a5,0(a0)
    80000a02:	9bbd                	andi	a5,a5,-17
    80000a04:	e11c                	sd	a5,0(a0)
}
    80000a06:	60a2                	ld	ra,8(sp)
    80000a08:	6402                	ld	s0,0(sp)
    80000a0a:	0141                	addi	sp,sp,16
    80000a0c:	8082                	ret
    panic("uvmclear");
    80000a0e:	00006517          	auipc	a0,0x6
    80000a12:	77a50513          	addi	a0,a0,1914 # 80007188 <etext+0x188>
    80000a16:	48d040ef          	jal	800056a2 <panic>

0000000080000a1a <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80000a1a:	cad1                	beqz	a3,80000aae <copyout+0x94>
{
    80000a1c:	711d                	addi	sp,sp,-96
    80000a1e:	ec86                	sd	ra,88(sp)
    80000a20:	e8a2                	sd	s0,80(sp)
    80000a22:	e4a6                	sd	s1,72(sp)
    80000a24:	fc4e                	sd	s3,56(sp)
    80000a26:	f456                	sd	s5,40(sp)
    80000a28:	f05a                	sd	s6,32(sp)
    80000a2a:	ec5e                	sd	s7,24(sp)
    80000a2c:	1080                	addi	s0,sp,96
    80000a2e:	8baa                	mv	s7,a0
    80000a30:	8aae                	mv	s5,a1
    80000a32:	8b32                	mv	s6,a2
    80000a34:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000a36:	74fd                	lui	s1,0xfffff
    80000a38:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80000a3a:	57fd                	li	a5,-1
    80000a3c:	83e9                	srli	a5,a5,0x1a
    80000a3e:	0697ea63          	bltu	a5,s1,80000ab2 <copyout+0x98>
    80000a42:	e0ca                	sd	s2,64(sp)
    80000a44:	f852                	sd	s4,48(sp)
    80000a46:	e862                	sd	s8,16(sp)
    80000a48:	e466                	sd	s9,8(sp)
    80000a4a:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000a4c:	4cd5                	li	s9,21
    80000a4e:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80000a50:	8c3e                	mv	s8,a5
    80000a52:	a025                	j	80000a7a <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    80000a54:	83a9                	srli	a5,a5,0xa
    80000a56:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a58:	409a8533          	sub	a0,s5,s1
    80000a5c:	0009061b          	sext.w	a2,s2
    80000a60:	85da                	mv	a1,s6
    80000a62:	953e                	add	a0,a0,a5
    80000a64:	f88ff0ef          	jal	800001ec <memmove>

    len -= n;
    80000a68:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a6c:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80000a6e:	02098963          	beqz	s3,80000aa0 <copyout+0x86>
    if(va0 >= MAXVA)
    80000a72:	054c6263          	bltu	s8,s4,80000ab6 <copyout+0x9c>
    80000a76:	84d2                	mv	s1,s4
    80000a78:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80000a7a:	4601                	li	a2,0
    80000a7c:	85a6                	mv	a1,s1
    80000a7e:	855e                	mv	a0,s7
    80000a80:	985ff0ef          	jal	80000404 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000a84:	c121                	beqz	a0,80000ac4 <copyout+0xaa>
    80000a86:	611c                	ld	a5,0(a0)
    80000a88:	0157f713          	andi	a4,a5,21
    80000a8c:	05971b63          	bne	a4,s9,80000ae2 <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    80000a90:	01a48a33          	add	s4,s1,s10
    80000a94:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80000a98:	fb29fee3          	bgeu	s3,s2,80000a54 <copyout+0x3a>
    80000a9c:	894e                	mv	s2,s3
    80000a9e:	bf5d                	j	80000a54 <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80000aa0:	4501                	li	a0,0
    80000aa2:	6906                	ld	s2,64(sp)
    80000aa4:	7a42                	ld	s4,48(sp)
    80000aa6:	6c42                	ld	s8,16(sp)
    80000aa8:	6ca2                	ld	s9,8(sp)
    80000aaa:	6d02                	ld	s10,0(sp)
    80000aac:	a015                	j	80000ad0 <copyout+0xb6>
    80000aae:	4501                	li	a0,0
}
    80000ab0:	8082                	ret
      return -1;
    80000ab2:	557d                	li	a0,-1
    80000ab4:	a831                	j	80000ad0 <copyout+0xb6>
    80000ab6:	557d                	li	a0,-1
    80000ab8:	6906                	ld	s2,64(sp)
    80000aba:	7a42                	ld	s4,48(sp)
    80000abc:	6c42                	ld	s8,16(sp)
    80000abe:	6ca2                	ld	s9,8(sp)
    80000ac0:	6d02                	ld	s10,0(sp)
    80000ac2:	a039                	j	80000ad0 <copyout+0xb6>
      return -1;
    80000ac4:	557d                	li	a0,-1
    80000ac6:	6906                	ld	s2,64(sp)
    80000ac8:	7a42                	ld	s4,48(sp)
    80000aca:	6c42                	ld	s8,16(sp)
    80000acc:	6ca2                	ld	s9,8(sp)
    80000ace:	6d02                	ld	s10,0(sp)
}
    80000ad0:	60e6                	ld	ra,88(sp)
    80000ad2:	6446                	ld	s0,80(sp)
    80000ad4:	64a6                	ld	s1,72(sp)
    80000ad6:	79e2                	ld	s3,56(sp)
    80000ad8:	7aa2                	ld	s5,40(sp)
    80000ada:	7b02                	ld	s6,32(sp)
    80000adc:	6be2                	ld	s7,24(sp)
    80000ade:	6125                	addi	sp,sp,96
    80000ae0:	8082                	ret
      return -1;
    80000ae2:	557d                	li	a0,-1
    80000ae4:	6906                	ld	s2,64(sp)
    80000ae6:	7a42                	ld	s4,48(sp)
    80000ae8:	6c42                	ld	s8,16(sp)
    80000aea:	6ca2                	ld	s9,8(sp)
    80000aec:	6d02                	ld	s10,0(sp)
    80000aee:	b7cd                	j	80000ad0 <copyout+0xb6>

0000000080000af0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000af0:	c6a5                	beqz	a3,80000b58 <copyin+0x68>
{
    80000af2:	715d                	addi	sp,sp,-80
    80000af4:	e486                	sd	ra,72(sp)
    80000af6:	e0a2                	sd	s0,64(sp)
    80000af8:	fc26                	sd	s1,56(sp)
    80000afa:	f84a                	sd	s2,48(sp)
    80000afc:	f44e                	sd	s3,40(sp)
    80000afe:	f052                	sd	s4,32(sp)
    80000b00:	ec56                	sd	s5,24(sp)
    80000b02:	e85a                	sd	s6,16(sp)
    80000b04:	e45e                	sd	s7,8(sp)
    80000b06:	e062                	sd	s8,0(sp)
    80000b08:	0880                	addi	s0,sp,80
    80000b0a:	8b2a                	mv	s6,a0
    80000b0c:	8a2e                	mv	s4,a1
    80000b0e:	8c32                	mv	s8,a2
    80000b10:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000b12:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b14:	6a85                	lui	s5,0x1
    80000b16:	a00d                	j	80000b38 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000b18:	018505b3          	add	a1,a0,s8
    80000b1c:	0004861b          	sext.w	a2,s1
    80000b20:	412585b3          	sub	a1,a1,s2
    80000b24:	8552                	mv	a0,s4
    80000b26:	ec6ff0ef          	jal	800001ec <memmove>

    len -= n;
    80000b2a:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000b2e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000b30:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b34:	02098063          	beqz	s3,80000b54 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000b38:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b3c:	85ca                	mv	a1,s2
    80000b3e:	855a                	mv	a0,s6
    80000b40:	95fff0ef          	jal	8000049e <walkaddr>
    if(pa0 == 0)
    80000b44:	cd01                	beqz	a0,80000b5c <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000b46:	418904b3          	sub	s1,s2,s8
    80000b4a:	94d6                	add	s1,s1,s5
    if(n > len)
    80000b4c:	fc99f6e3          	bgeu	s3,s1,80000b18 <copyin+0x28>
    80000b50:	84ce                	mv	s1,s3
    80000b52:	b7d9                	j	80000b18 <copyin+0x28>
  }
  return 0;
    80000b54:	4501                	li	a0,0
    80000b56:	a021                	j	80000b5e <copyin+0x6e>
    80000b58:	4501                	li	a0,0
}
    80000b5a:	8082                	ret
      return -1;
    80000b5c:	557d                	li	a0,-1
}
    80000b5e:	60a6                	ld	ra,72(sp)
    80000b60:	6406                	ld	s0,64(sp)
    80000b62:	74e2                	ld	s1,56(sp)
    80000b64:	7942                	ld	s2,48(sp)
    80000b66:	79a2                	ld	s3,40(sp)
    80000b68:	7a02                	ld	s4,32(sp)
    80000b6a:	6ae2                	ld	s5,24(sp)
    80000b6c:	6b42                	ld	s6,16(sp)
    80000b6e:	6ba2                	ld	s7,8(sp)
    80000b70:	6c02                	ld	s8,0(sp)
    80000b72:	6161                	addi	sp,sp,80
    80000b74:	8082                	ret

0000000080000b76 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000b76:	c6dd                	beqz	a3,80000c24 <copyinstr+0xae>
{
    80000b78:	715d                	addi	sp,sp,-80
    80000b7a:	e486                	sd	ra,72(sp)
    80000b7c:	e0a2                	sd	s0,64(sp)
    80000b7e:	fc26                	sd	s1,56(sp)
    80000b80:	f84a                	sd	s2,48(sp)
    80000b82:	f44e                	sd	s3,40(sp)
    80000b84:	f052                	sd	s4,32(sp)
    80000b86:	ec56                	sd	s5,24(sp)
    80000b88:	e85a                	sd	s6,16(sp)
    80000b8a:	e45e                	sd	s7,8(sp)
    80000b8c:	0880                	addi	s0,sp,80
    80000b8e:	8a2a                	mv	s4,a0
    80000b90:	8b2e                	mv	s6,a1
    80000b92:	8bb2                	mv	s7,a2
    80000b94:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000b96:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b98:	6985                	lui	s3,0x1
    80000b9a:	a825                	j	80000bd2 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000b9c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000ba0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000ba2:	37fd                	addiw	a5,a5,-1
    80000ba4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000ba8:	60a6                	ld	ra,72(sp)
    80000baa:	6406                	ld	s0,64(sp)
    80000bac:	74e2                	ld	s1,56(sp)
    80000bae:	7942                	ld	s2,48(sp)
    80000bb0:	79a2                	ld	s3,40(sp)
    80000bb2:	7a02                	ld	s4,32(sp)
    80000bb4:	6ae2                	ld	s5,24(sp)
    80000bb6:	6b42                	ld	s6,16(sp)
    80000bb8:	6ba2                	ld	s7,8(sp)
    80000bba:	6161                	addi	sp,sp,80
    80000bbc:	8082                	ret
    80000bbe:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80000bc2:	9742                	add	a4,a4,a6
      --max;
    80000bc4:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000bc8:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000bcc:	04e58463          	beq	a1,a4,80000c14 <copyinstr+0x9e>
{
    80000bd0:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000bd2:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000bd6:	85a6                	mv	a1,s1
    80000bd8:	8552                	mv	a0,s4
    80000bda:	8c5ff0ef          	jal	8000049e <walkaddr>
    if(pa0 == 0)
    80000bde:	cd0d                	beqz	a0,80000c18 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000be0:	417486b3          	sub	a3,s1,s7
    80000be4:	96ce                	add	a3,a3,s3
    if(n > max)
    80000be6:	00d97363          	bgeu	s2,a3,80000bec <copyinstr+0x76>
    80000bea:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80000bec:	955e                	add	a0,a0,s7
    80000bee:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80000bf0:	c695                	beqz	a3,80000c1c <copyinstr+0xa6>
    80000bf2:	87da                	mv	a5,s6
    80000bf4:	885a                	mv	a6,s6
      if(*p == '\0'){
    80000bf6:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80000bfa:	96da                	add	a3,a3,s6
    80000bfc:	85be                	mv	a1,a5
      if(*p == '\0'){
    80000bfe:	00f60733          	add	a4,a2,a5
    80000c02:	00074703          	lbu	a4,0(a4)
    80000c06:	db59                	beqz	a4,80000b9c <copyinstr+0x26>
        *dst = *p;
    80000c08:	00e78023          	sb	a4,0(a5)
      dst++;
    80000c0c:	0785                	addi	a5,a5,1
    while(n > 0){
    80000c0e:	fed797e3          	bne	a5,a3,80000bfc <copyinstr+0x86>
    80000c12:	b775                	j	80000bbe <copyinstr+0x48>
    80000c14:	4781                	li	a5,0
    80000c16:	b771                	j	80000ba2 <copyinstr+0x2c>
      return -1;
    80000c18:	557d                	li	a0,-1
    80000c1a:	b779                	j	80000ba8 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80000c1c:	6b85                	lui	s7,0x1
    80000c1e:	9ba6                	add	s7,s7,s1
    80000c20:	87da                	mv	a5,s6
    80000c22:	b77d                	j	80000bd0 <copyinstr+0x5a>
  int got_null = 0;
    80000c24:	4781                	li	a5,0
  if(got_null){
    80000c26:	37fd                	addiw	a5,a5,-1
    80000c28:	0007851b          	sext.w	a0,a5
}
    80000c2c:	8082                	ret

0000000080000c2e <vm_print_recursive>:

void vm_print_recursive (pagetable_t pagetable, int depth){
  // base case
  if (pagetable == 0)
    80000c2e:	c54d                	beqz	a0,80000cd8 <vm_print_recursive+0xaa>
void vm_print_recursive (pagetable_t pagetable, int depth){
    80000c30:	7159                	addi	sp,sp,-112
    80000c32:	f486                	sd	ra,104(sp)
    80000c34:	f0a2                	sd	s0,96(sp)
    80000c36:	eca6                	sd	s1,88(sp)
    80000c38:	e8ca                	sd	s2,80(sp)
    80000c3a:	e4ce                	sd	s3,72(sp)
    80000c3c:	e0d2                	sd	s4,64(sp)
    80000c3e:	fc56                	sd	s5,56(sp)
    80000c40:	f85a                	sd	s6,48(sp)
    80000c42:	f45e                	sd	s7,40(sp)
    80000c44:	f062                	sd	s8,32(sp)
    80000c46:	ec66                	sd	s9,24(sp)
    80000c48:	e86a                	sd	s10,16(sp)
    80000c4a:	e46e                	sd	s11,8(sp)
    80000c4c:	1880                	addi	s0,sp,112
    80000c4e:	892a                	mv	s2,a0
    80000c50:	8a2e                	mv	s4,a1
    return;

  for (int i = 0; i < 512; i++){
    80000c52:	4981                	li	s3,0
      // print the inndetation base on depth
      for (int j = 0; j < depth; j++){
        printf(" ..");
      }

      printf("%d: pte %p pa %p\n", i, pte, (pte_t*)pa);
    80000c54:	00006c17          	auipc	s8,0x6
    80000c58:	54cc0c13          	addi	s8,s8,1356 # 800071a0 <etext+0x1a0>

      if ((*pte & (PTE_R|PTE_W|PTE_X)) == 0){
        vm_print_recursive((pagetable_t)pa, depth + 1);
    80000c5c:	00158d1b          	addiw	s10,a1,1
      for (int j = 0; j < depth; j++){
    80000c60:	4c81                	li	s9,0
        printf(" ..");
    80000c62:	00006a97          	auipc	s5,0x6
    80000c66:	536a8a93          	addi	s5,s5,1334 # 80007198 <etext+0x198>
  for (int i = 0; i < 512; i++){
    80000c6a:	20000b93          	li	s7,512
    80000c6e:	a029                	j	80000c78 <vm_print_recursive+0x4a>
    80000c70:	2985                	addiw	s3,s3,1 # 1001 <_entry-0x7fffefff>
    80000c72:	0921                	addi	s2,s2,8
    80000c74:	05798363          	beq	s3,s7,80000cba <vm_print_recursive+0x8c>
    pte_t* pte = &pagetable[i];
    80000c78:	8b4a                	mv	s6,s2
    if(*pte & PTE_V){
    80000c7a:	00093783          	ld	a5,0(s2)
    80000c7e:	0017f713          	andi	a4,a5,1
    80000c82:	d77d                	beqz	a4,80000c70 <vm_print_recursive+0x42>
      uint64 pa = PTE2PA(*pte);
    80000c84:	83a9                	srli	a5,a5,0xa
    80000c86:	00c79d93          	slli	s11,a5,0xc
      for (int j = 0; j < depth; j++){
    80000c8a:	01405963          	blez	s4,80000c9c <vm_print_recursive+0x6e>
    80000c8e:	84e6                	mv	s1,s9
        printf(" ..");
    80000c90:	8556                	mv	a0,s5
    80000c92:	73e040ef          	jal	800053d0 <printf>
      for (int j = 0; j < depth; j++){
    80000c96:	2485                	addiw	s1,s1,1 # fffffffffffff001 <end+0xffffffff7ffdb501>
    80000c98:	fe9a1ce3          	bne	s4,s1,80000c90 <vm_print_recursive+0x62>
      printf("%d: pte %p pa %p\n", i, pte, (pte_t*)pa);
    80000c9c:	86ee                	mv	a3,s11
    80000c9e:	865a                	mv	a2,s6
    80000ca0:	85ce                	mv	a1,s3
    80000ca2:	8562                	mv	a0,s8
    80000ca4:	72c040ef          	jal	800053d0 <printf>
      if ((*pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000ca8:	000b3783          	ld	a5,0(s6) # 1000 <_entry-0x7ffff000>
    80000cac:	8bb9                	andi	a5,a5,14
    80000cae:	f3e9                	bnez	a5,80000c70 <vm_print_recursive+0x42>
        vm_print_recursive((pagetable_t)pa, depth + 1);
    80000cb0:	85ea                	mv	a1,s10
    80000cb2:	856e                	mv	a0,s11
    80000cb4:	f7bff0ef          	jal	80000c2e <vm_print_recursive>
    80000cb8:	bf65                	j	80000c70 <vm_print_recursive+0x42>
      }
    } 
  }
}
    80000cba:	70a6                	ld	ra,104(sp)
    80000cbc:	7406                	ld	s0,96(sp)
    80000cbe:	64e6                	ld	s1,88(sp)
    80000cc0:	6946                	ld	s2,80(sp)
    80000cc2:	69a6                	ld	s3,72(sp)
    80000cc4:	6a06                	ld	s4,64(sp)
    80000cc6:	7ae2                	ld	s5,56(sp)
    80000cc8:	7b42                	ld	s6,48(sp)
    80000cca:	7ba2                	ld	s7,40(sp)
    80000ccc:	7c02                	ld	s8,32(sp)
    80000cce:	6ce2                	ld	s9,24(sp)
    80000cd0:	6d42                	ld	s10,16(sp)
    80000cd2:	6da2                	ld	s11,8(sp)
    80000cd4:	6165                	addi	sp,sp,112
    80000cd6:	8082                	ret
    80000cd8:	8082                	ret

0000000080000cda <vm_print>:

void vm_print(pagetable_t pagetable){
    80000cda:	1101                	addi	sp,sp,-32
    80000cdc:	ec06                	sd	ra,24(sp)
    80000cde:	e822                	sd	s0,16(sp)
    80000ce0:	e426                	sd	s1,8(sp)
    80000ce2:	1000                	addi	s0,sp,32
    80000ce4:	84aa                	mv	s1,a0
  printf("Page table %p\n ", pagetable);
    80000ce6:	85aa                	mv	a1,a0
    80000ce8:	00006517          	auipc	a0,0x6
    80000cec:	4d050513          	addi	a0,a0,1232 # 800071b8 <etext+0x1b8>
    80000cf0:	6e0040ef          	jal	800053d0 <printf>
  vm_print_recursive(pagetable, 0);
    80000cf4:	4581                	li	a1,0
    80000cf6:	8526                	mv	a0,s1
    80000cf8:	f37ff0ef          	jal	80000c2e <vm_print_recursive>
    80000cfc:	60e2                	ld	ra,24(sp)
    80000cfe:	6442                	ld	s0,16(sp)
    80000d00:	64a2                	ld	s1,8(sp)
    80000d02:	6105                	addi	sp,sp,32
    80000d04:	8082                	ret

0000000080000d06 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000d06:	7139                	addi	sp,sp,-64
    80000d08:	fc06                	sd	ra,56(sp)
    80000d0a:	f822                	sd	s0,48(sp)
    80000d0c:	f426                	sd	s1,40(sp)
    80000d0e:	f04a                	sd	s2,32(sp)
    80000d10:	ec4e                	sd	s3,24(sp)
    80000d12:	e852                	sd	s4,16(sp)
    80000d14:	e456                	sd	s5,8(sp)
    80000d16:	e05a                	sd	s6,0(sp)
    80000d18:	0080                	addi	s0,sp,64
    80000d1a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d1c:	0000a497          	auipc	s1,0xa
    80000d20:	d0448493          	addi	s1,s1,-764 # 8000aa20 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000d24:	8b26                	mv	s6,s1
    80000d26:	ff4df937          	lui	s2,0xff4df
    80000d2a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baebd>
    80000d2e:	0936                	slli	s2,s2,0xd
    80000d30:	6f590913          	addi	s2,s2,1781
    80000d34:	0936                	slli	s2,s2,0xd
    80000d36:	bd390913          	addi	s2,s2,-1069
    80000d3a:	0932                	slli	s2,s2,0xc
    80000d3c:	7a790913          	addi	s2,s2,1959
    80000d40:	040009b7          	lui	s3,0x4000
    80000d44:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d46:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d48:	00010a97          	auipc	s5,0x10
    80000d4c:	8d8a8a93          	addi	s5,s5,-1832 # 80010620 <tickslock>
    char *pa = kalloc();
    80000d50:	baeff0ef          	jal	800000fe <kalloc>
    80000d54:	862a                	mv	a2,a0
    if(pa == 0)
    80000d56:	cd15                	beqz	a0,80000d92 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000d58:	416485b3          	sub	a1,s1,s6
    80000d5c:	8591                	srai	a1,a1,0x4
    80000d5e:	032585b3          	mul	a1,a1,s2
    80000d62:	2585                	addiw	a1,a1,1
    80000d64:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d68:	4719                	li	a4,6
    80000d6a:	6685                	lui	a3,0x1
    80000d6c:	40b985b3          	sub	a1,s3,a1
    80000d70:	8552                	mv	a0,s4
    80000d72:	81bff0ef          	jal	8000058c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d76:	17048493          	addi	s1,s1,368
    80000d7a:	fd549be3          	bne	s1,s5,80000d50 <proc_mapstacks+0x4a>
  }
}
    80000d7e:	70e2                	ld	ra,56(sp)
    80000d80:	7442                	ld	s0,48(sp)
    80000d82:	74a2                	ld	s1,40(sp)
    80000d84:	7902                	ld	s2,32(sp)
    80000d86:	69e2                	ld	s3,24(sp)
    80000d88:	6a42                	ld	s4,16(sp)
    80000d8a:	6aa2                	ld	s5,8(sp)
    80000d8c:	6b02                	ld	s6,0(sp)
    80000d8e:	6121                	addi	sp,sp,64
    80000d90:	8082                	ret
      panic("kalloc");
    80000d92:	00006517          	auipc	a0,0x6
    80000d96:	43650513          	addi	a0,a0,1078 # 800071c8 <etext+0x1c8>
    80000d9a:	109040ef          	jal	800056a2 <panic>

0000000080000d9e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000d9e:	7139                	addi	sp,sp,-64
    80000da0:	fc06                	sd	ra,56(sp)
    80000da2:	f822                	sd	s0,48(sp)
    80000da4:	f426                	sd	s1,40(sp)
    80000da6:	f04a                	sd	s2,32(sp)
    80000da8:	ec4e                	sd	s3,24(sp)
    80000daa:	e852                	sd	s4,16(sp)
    80000dac:	e456                	sd	s5,8(sp)
    80000dae:	e05a                	sd	s6,0(sp)
    80000db0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000db2:	00006597          	auipc	a1,0x6
    80000db6:	41e58593          	addi	a1,a1,1054 # 800071d0 <etext+0x1d0>
    80000dba:	0000a517          	auipc	a0,0xa
    80000dbe:	83650513          	addi	a0,a0,-1994 # 8000a5f0 <pid_lock>
    80000dc2:	38f040ef          	jal	80005950 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000dc6:	00006597          	auipc	a1,0x6
    80000dca:	41258593          	addi	a1,a1,1042 # 800071d8 <etext+0x1d8>
    80000dce:	0000a517          	auipc	a0,0xa
    80000dd2:	83a50513          	addi	a0,a0,-1990 # 8000a608 <wait_lock>
    80000dd6:	37b040ef          	jal	80005950 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dda:	0000a497          	auipc	s1,0xa
    80000dde:	c4648493          	addi	s1,s1,-954 # 8000aa20 <proc>
      initlock(&p->lock, "proc");
    80000de2:	00006b17          	auipc	s6,0x6
    80000de6:	406b0b13          	addi	s6,s6,1030 # 800071e8 <etext+0x1e8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000dea:	8aa6                	mv	s5,s1
    80000dec:	ff4df937          	lui	s2,0xff4df
    80000df0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baebd>
    80000df4:	0936                	slli	s2,s2,0xd
    80000df6:	6f590913          	addi	s2,s2,1781
    80000dfa:	0936                	slli	s2,s2,0xd
    80000dfc:	bd390913          	addi	s2,s2,-1069
    80000e00:	0932                	slli	s2,s2,0xc
    80000e02:	7a790913          	addi	s2,s2,1959
    80000e06:	040009b7          	lui	s3,0x4000
    80000e0a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000e0c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e0e:	00010a17          	auipc	s4,0x10
    80000e12:	812a0a13          	addi	s4,s4,-2030 # 80010620 <tickslock>
      initlock(&p->lock, "proc");
    80000e16:	85da                	mv	a1,s6
    80000e18:	8526                	mv	a0,s1
    80000e1a:	337040ef          	jal	80005950 <initlock>
      p->state = UNUSED;
    80000e1e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000e22:	415487b3          	sub	a5,s1,s5
    80000e26:	8791                	srai	a5,a5,0x4
    80000e28:	032787b3          	mul	a5,a5,s2
    80000e2c:	2785                	addiw	a5,a5,1
    80000e2e:	00d7979b          	slliw	a5,a5,0xd
    80000e32:	40f987b3          	sub	a5,s3,a5
    80000e36:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e38:	17048493          	addi	s1,s1,368
    80000e3c:	fd449de3          	bne	s1,s4,80000e16 <procinit+0x78>
  }
}
    80000e40:	70e2                	ld	ra,56(sp)
    80000e42:	7442                	ld	s0,48(sp)
    80000e44:	74a2                	ld	s1,40(sp)
    80000e46:	7902                	ld	s2,32(sp)
    80000e48:	69e2                	ld	s3,24(sp)
    80000e4a:	6a42                	ld	s4,16(sp)
    80000e4c:	6aa2                	ld	s5,8(sp)
    80000e4e:	6b02                	ld	s6,0(sp)
    80000e50:	6121                	addi	sp,sp,64
    80000e52:	8082                	ret

0000000080000e54 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e54:	1141                	addi	sp,sp,-16
    80000e56:	e422                	sd	s0,8(sp)
    80000e58:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e5a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e5c:	2501                	sext.w	a0,a0
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
    80000e6a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e6c:	2781                	sext.w	a5,a5
    80000e6e:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e70:	00009517          	auipc	a0,0x9
    80000e74:	7b050513          	addi	a0,a0,1968 # 8000a620 <cpus>
    80000e78:	953e                	add	a0,a0,a5
    80000e7a:	6422                	ld	s0,8(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000e80:	1101                	addi	sp,sp,-32
    80000e82:	ec06                	sd	ra,24(sp)
    80000e84:	e822                	sd	s0,16(sp)
    80000e86:	e426                	sd	s1,8(sp)
    80000e88:	1000                	addi	s0,sp,32
  push_off();
    80000e8a:	307040ef          	jal	80005990 <push_off>
    80000e8e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e90:	2781                	sext.w	a5,a5
    80000e92:	079e                	slli	a5,a5,0x7
    80000e94:	00009717          	auipc	a4,0x9
    80000e98:	75c70713          	addi	a4,a4,1884 # 8000a5f0 <pid_lock>
    80000e9c:	97ba                	add	a5,a5,a4
    80000e9e:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ea0:	375040ef          	jal	80005a14 <pop_off>
  return p;
}
    80000ea4:	8526                	mv	a0,s1
    80000ea6:	60e2                	ld	ra,24(sp)
    80000ea8:	6442                	ld	s0,16(sp)
    80000eaa:	64a2                	ld	s1,8(sp)
    80000eac:	6105                	addi	sp,sp,32
    80000eae:	8082                	ret

0000000080000eb0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000eb0:	1141                	addi	sp,sp,-16
    80000eb2:	e406                	sd	ra,8(sp)
    80000eb4:	e022                	sd	s0,0(sp)
    80000eb6:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000eb8:	fc9ff0ef          	jal	80000e80 <myproc>
    80000ebc:	3ad040ef          	jal	80005a68 <release>

  if (first) {
    80000ec0:	00009797          	auipc	a5,0x9
    80000ec4:	6707a783          	lw	a5,1648(a5) # 8000a530 <first.1>
    80000ec8:	e799                	bnez	a5,80000ed6 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000eca:	2f5000ef          	jal	800019be <usertrapret>
}
    80000ece:	60a2                	ld	ra,8(sp)
    80000ed0:	6402                	ld	s0,0(sp)
    80000ed2:	0141                	addi	sp,sp,16
    80000ed4:	8082                	ret
    fsinit(ROOTDEV);
    80000ed6:	4505                	li	a0,1
    80000ed8:	796010ef          	jal	8000266e <fsinit>
    first = 0;
    80000edc:	00009797          	auipc	a5,0x9
    80000ee0:	6407aa23          	sw	zero,1620(a5) # 8000a530 <first.1>
    __sync_synchronize();
    80000ee4:	0330000f          	fence	rw,rw
    80000ee8:	b7cd                	j	80000eca <forkret+0x1a>

0000000080000eea <allocpid>:
{
    80000eea:	1101                	addi	sp,sp,-32
    80000eec:	ec06                	sd	ra,24(sp)
    80000eee:	e822                	sd	s0,16(sp)
    80000ef0:	e426                	sd	s1,8(sp)
    80000ef2:	e04a                	sd	s2,0(sp)
    80000ef4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000ef6:	00009917          	auipc	s2,0x9
    80000efa:	6fa90913          	addi	s2,s2,1786 # 8000a5f0 <pid_lock>
    80000efe:	854a                	mv	a0,s2
    80000f00:	2d1040ef          	jal	800059d0 <acquire>
  pid = nextpid;
    80000f04:	00009797          	auipc	a5,0x9
    80000f08:	63078793          	addi	a5,a5,1584 # 8000a534 <nextpid>
    80000f0c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000f0e:	0014871b          	addiw	a4,s1,1
    80000f12:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f14:	854a                	mv	a0,s2
    80000f16:	353040ef          	jal	80005a68 <release>
}
    80000f1a:	8526                	mv	a0,s1
    80000f1c:	60e2                	ld	ra,24(sp)
    80000f1e:	6442                	ld	s0,16(sp)
    80000f20:	64a2                	ld	s1,8(sp)
    80000f22:	6902                	ld	s2,0(sp)
    80000f24:	6105                	addi	sp,sp,32
    80000f26:	8082                	ret

0000000080000f28 <proc_pagetable>:
{
    80000f28:	1101                	addi	sp,sp,-32
    80000f2a:	ec06                	sd	ra,24(sp)
    80000f2c:	e822                	sd	s0,16(sp)
    80000f2e:	e426                	sd	s1,8(sp)
    80000f30:	e04a                	sd	s2,0(sp)
    80000f32:	1000                	addi	s0,sp,32
    80000f34:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f36:	809ff0ef          	jal	8000073e <uvmcreate>
    80000f3a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f3c:	cd05                	beqz	a0,80000f74 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f3e:	4729                	li	a4,10
    80000f40:	00005697          	auipc	a3,0x5
    80000f44:	0c068693          	addi	a3,a3,192 # 80006000 <_trampoline>
    80000f48:	6605                	lui	a2,0x1
    80000f4a:	040005b7          	lui	a1,0x4000
    80000f4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f50:	05b2                	slli	a1,a1,0xc
    80000f52:	d8aff0ef          	jal	800004dc <mappages>
    80000f56:	02054663          	bltz	a0,80000f82 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f5a:	4719                	li	a4,6
    80000f5c:	05893683          	ld	a3,88(s2)
    80000f60:	6605                	lui	a2,0x1
    80000f62:	020005b7          	lui	a1,0x2000
    80000f66:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f68:	05b6                	slli	a1,a1,0xd
    80000f6a:	8526                	mv	a0,s1
    80000f6c:	d70ff0ef          	jal	800004dc <mappages>
    80000f70:	00054f63          	bltz	a0,80000f8e <proc_pagetable+0x66>
}
    80000f74:	8526                	mv	a0,s1
    80000f76:	60e2                	ld	ra,24(sp)
    80000f78:	6442                	ld	s0,16(sp)
    80000f7a:	64a2                	ld	s1,8(sp)
    80000f7c:	6902                	ld	s2,0(sp)
    80000f7e:	6105                	addi	sp,sp,32
    80000f80:	8082                	ret
    uvmfree(pagetable, 0);
    80000f82:	4581                	li	a1,0
    80000f84:	8526                	mv	a0,s1
    80000f86:	987ff0ef          	jal	8000090c <uvmfree>
    return 0;
    80000f8a:	4481                	li	s1,0
    80000f8c:	b7e5                	j	80000f74 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f8e:	4681                	li	a3,0
    80000f90:	4605                	li	a2,1
    80000f92:	040005b7          	lui	a1,0x4000
    80000f96:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f98:	05b2                	slli	a1,a1,0xc
    80000f9a:	8526                	mv	a0,s1
    80000f9c:	ee6ff0ef          	jal	80000682 <uvmunmap>
    uvmfree(pagetable, 0);
    80000fa0:	4581                	li	a1,0
    80000fa2:	8526                	mv	a0,s1
    80000fa4:	969ff0ef          	jal	8000090c <uvmfree>
    return 0;
    80000fa8:	4481                	li	s1,0
    80000faa:	b7e9                	j	80000f74 <proc_pagetable+0x4c>

0000000080000fac <proc_freepagetable>:
{
    80000fac:	1101                	addi	sp,sp,-32
    80000fae:	ec06                	sd	ra,24(sp)
    80000fb0:	e822                	sd	s0,16(sp)
    80000fb2:	e426                	sd	s1,8(sp)
    80000fb4:	e04a                	sd	s2,0(sp)
    80000fb6:	1000                	addi	s0,sp,32
    80000fb8:	84aa                	mv	s1,a0
    80000fba:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fbc:	4681                	li	a3,0
    80000fbe:	4605                	li	a2,1
    80000fc0:	040005b7          	lui	a1,0x4000
    80000fc4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000fc6:	05b2                	slli	a1,a1,0xc
    80000fc8:	ebaff0ef          	jal	80000682 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000fcc:	4681                	li	a3,0
    80000fce:	4605                	li	a2,1
    80000fd0:	020005b7          	lui	a1,0x2000
    80000fd4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000fd6:	05b6                	slli	a1,a1,0xd
    80000fd8:	8526                	mv	a0,s1
    80000fda:	ea8ff0ef          	jal	80000682 <uvmunmap>
  uvmfree(pagetable, sz);
    80000fde:	85ca                	mv	a1,s2
    80000fe0:	8526                	mv	a0,s1
    80000fe2:	92bff0ef          	jal	8000090c <uvmfree>
}
    80000fe6:	60e2                	ld	ra,24(sp)
    80000fe8:	6442                	ld	s0,16(sp)
    80000fea:	64a2                	ld	s1,8(sp)
    80000fec:	6902                	ld	s2,0(sp)
    80000fee:	6105                	addi	sp,sp,32
    80000ff0:	8082                	ret

0000000080000ff2 <freeproc>:
{
    80000ff2:	1101                	addi	sp,sp,-32
    80000ff4:	ec06                	sd	ra,24(sp)
    80000ff6:	e822                	sd	s0,16(sp)
    80000ff8:	e426                	sd	s1,8(sp)
    80000ffa:	1000                	addi	s0,sp,32
    80000ffc:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000ffe:	6d28                	ld	a0,88(a0)
    80001000:	c119                	beqz	a0,80001006 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001002:	81aff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80001006:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000100a:	68a8                	ld	a0,80(s1)
    8000100c:	c501                	beqz	a0,80001014 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    8000100e:	64ac                	ld	a1,72(s1)
    80001010:	f9dff0ef          	jal	80000fac <proc_freepagetable>
  p->pagetable = 0;
    80001014:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001018:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000101c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001020:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001024:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001028:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000102c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001030:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001034:	0004ac23          	sw	zero,24(s1)
}
    80001038:	60e2                	ld	ra,24(sp)
    8000103a:	6442                	ld	s0,16(sp)
    8000103c:	64a2                	ld	s1,8(sp)
    8000103e:	6105                	addi	sp,sp,32
    80001040:	8082                	ret

0000000080001042 <allocproc>:
{
    80001042:	1101                	addi	sp,sp,-32
    80001044:	ec06                	sd	ra,24(sp)
    80001046:	e822                	sd	s0,16(sp)
    80001048:	e426                	sd	s1,8(sp)
    8000104a:	e04a                	sd	s2,0(sp)
    8000104c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000104e:	0000a497          	auipc	s1,0xa
    80001052:	9d248493          	addi	s1,s1,-1582 # 8000aa20 <proc>
    80001056:	0000f917          	auipc	s2,0xf
    8000105a:	5ca90913          	addi	s2,s2,1482 # 80010620 <tickslock>
    acquire(&p->lock);
    8000105e:	8526                	mv	a0,s1
    80001060:	171040ef          	jal	800059d0 <acquire>
    if(p->state == UNUSED) {
    80001064:	4c9c                	lw	a5,24(s1)
    80001066:	cb91                	beqz	a5,8000107a <allocproc+0x38>
      release(&p->lock);
    80001068:	8526                	mv	a0,s1
    8000106a:	1ff040ef          	jal	80005a68 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106e:	17048493          	addi	s1,s1,368
    80001072:	ff2496e3          	bne	s1,s2,8000105e <allocproc+0x1c>
  return 0;
    80001076:	4481                	li	s1,0
    80001078:	a089                	j	800010ba <allocproc+0x78>
  p->pid = allocpid();
    8000107a:	e71ff0ef          	jal	80000eea <allocpid>
    8000107e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001080:	4785                	li	a5,1
    80001082:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001084:	87aff0ef          	jal	800000fe <kalloc>
    80001088:	892a                	mv	s2,a0
    8000108a:	eca8                	sd	a0,88(s1)
    8000108c:	cd15                	beqz	a0,800010c8 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    8000108e:	8526                	mv	a0,s1
    80001090:	e99ff0ef          	jal	80000f28 <proc_pagetable>
    80001094:	892a                	mv	s2,a0
    80001096:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001098:	c121                	beqz	a0,800010d8 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    8000109a:	07000613          	li	a2,112
    8000109e:	4581                	li	a1,0
    800010a0:	06048513          	addi	a0,s1,96
    800010a4:	8ecff0ef          	jal	80000190 <memset>
  p->context.ra = (uint64)forkret;
    800010a8:	00000797          	auipc	a5,0x0
    800010ac:	e0878793          	addi	a5,a5,-504 # 80000eb0 <forkret>
    800010b0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800010b2:	60bc                	ld	a5,64(s1)
    800010b4:	6705                	lui	a4,0x1
    800010b6:	97ba                	add	a5,a5,a4
    800010b8:	f4bc                	sd	a5,104(s1)
}
    800010ba:	8526                	mv	a0,s1
    800010bc:	60e2                	ld	ra,24(sp)
    800010be:	6442                	ld	s0,16(sp)
    800010c0:	64a2                	ld	s1,8(sp)
    800010c2:	6902                	ld	s2,0(sp)
    800010c4:	6105                	addi	sp,sp,32
    800010c6:	8082                	ret
    freeproc(p);
    800010c8:	8526                	mv	a0,s1
    800010ca:	f29ff0ef          	jal	80000ff2 <freeproc>
    release(&p->lock);
    800010ce:	8526                	mv	a0,s1
    800010d0:	199040ef          	jal	80005a68 <release>
    return 0;
    800010d4:	84ca                	mv	s1,s2
    800010d6:	b7d5                	j	800010ba <allocproc+0x78>
    freeproc(p);
    800010d8:	8526                	mv	a0,s1
    800010da:	f19ff0ef          	jal	80000ff2 <freeproc>
    release(&p->lock);
    800010de:	8526                	mv	a0,s1
    800010e0:	189040ef          	jal	80005a68 <release>
    return 0;
    800010e4:	84ca                	mv	s1,s2
    800010e6:	bfd1                	j	800010ba <allocproc+0x78>

00000000800010e8 <userinit>:
{
    800010e8:	1101                	addi	sp,sp,-32
    800010ea:	ec06                	sd	ra,24(sp)
    800010ec:	e822                	sd	s0,16(sp)
    800010ee:	e426                	sd	s1,8(sp)
    800010f0:	1000                	addi	s0,sp,32
  p = allocproc();
    800010f2:	f51ff0ef          	jal	80001042 <allocproc>
    800010f6:	84aa                	mv	s1,a0
  initproc = p;
    800010f8:	00009797          	auipc	a5,0x9
    800010fc:	4aa7bc23          	sd	a0,1208(a5) # 8000a5b0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001100:	03400613          	li	a2,52
    80001104:	00009597          	auipc	a1,0x9
    80001108:	43c58593          	addi	a1,a1,1084 # 8000a540 <initcode>
    8000110c:	6928                	ld	a0,80(a0)
    8000110e:	e56ff0ef          	jal	80000764 <uvmfirst>
  p->sz = PGSIZE;
    80001112:	6785                	lui	a5,0x1
    80001114:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001116:	6cb8                	ld	a4,88(s1)
    80001118:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000111c:	6cb8                	ld	a4,88(s1)
    8000111e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001120:	4641                	li	a2,16
    80001122:	00006597          	auipc	a1,0x6
    80001126:	0ce58593          	addi	a1,a1,206 # 800071f0 <etext+0x1f0>
    8000112a:	15848513          	addi	a0,s1,344
    8000112e:	9a0ff0ef          	jal	800002ce <safestrcpy>
  p->cwd = namei("/");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	0ce50513          	addi	a0,a0,206 # 80007200 <etext+0x200>
    8000113a:	643010ef          	jal	80002f7c <namei>
    8000113e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001142:	478d                	li	a5,3
    80001144:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001146:	8526                	mv	a0,s1
    80001148:	121040ef          	jal	80005a68 <release>
}
    8000114c:	60e2                	ld	ra,24(sp)
    8000114e:	6442                	ld	s0,16(sp)
    80001150:	64a2                	ld	s1,8(sp)
    80001152:	6105                	addi	sp,sp,32
    80001154:	8082                	ret

0000000080001156 <growproc>:
{
    80001156:	1101                	addi	sp,sp,-32
    80001158:	ec06                	sd	ra,24(sp)
    8000115a:	e822                	sd	s0,16(sp)
    8000115c:	e426                	sd	s1,8(sp)
    8000115e:	e04a                	sd	s2,0(sp)
    80001160:	1000                	addi	s0,sp,32
    80001162:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001164:	d1dff0ef          	jal	80000e80 <myproc>
    80001168:	84aa                	mv	s1,a0
  sz = p->sz;
    8000116a:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000116c:	01204c63          	bgtz	s2,80001184 <growproc+0x2e>
  } else if(n < 0){
    80001170:	02094463          	bltz	s2,80001198 <growproc+0x42>
  p->sz = sz;
    80001174:	e4ac                	sd	a1,72(s1)
  return 0;
    80001176:	4501                	li	a0,0
}
    80001178:	60e2                	ld	ra,24(sp)
    8000117a:	6442                	ld	s0,16(sp)
    8000117c:	64a2                	ld	s1,8(sp)
    8000117e:	6902                	ld	s2,0(sp)
    80001180:	6105                	addi	sp,sp,32
    80001182:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001184:	4691                	li	a3,4
    80001186:	00b90633          	add	a2,s2,a1
    8000118a:	6928                	ld	a0,80(a0)
    8000118c:	e7aff0ef          	jal	80000806 <uvmalloc>
    80001190:	85aa                	mv	a1,a0
    80001192:	f16d                	bnez	a0,80001174 <growproc+0x1e>
      return -1;
    80001194:	557d                	li	a0,-1
    80001196:	b7cd                	j	80001178 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001198:	00b90633          	add	a2,s2,a1
    8000119c:	6928                	ld	a0,80(a0)
    8000119e:	e24ff0ef          	jal	800007c2 <uvmdealloc>
    800011a2:	85aa                	mv	a1,a0
    800011a4:	bfc1                	j	80001174 <growproc+0x1e>

00000000800011a6 <fork>:
{
    800011a6:	7139                	addi	sp,sp,-64
    800011a8:	fc06                	sd	ra,56(sp)
    800011aa:	f822                	sd	s0,48(sp)
    800011ac:	f04a                	sd	s2,32(sp)
    800011ae:	e456                	sd	s5,8(sp)
    800011b0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800011b2:	ccfff0ef          	jal	80000e80 <myproc>
    800011b6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800011b8:	e8bff0ef          	jal	80001042 <allocproc>
    800011bc:	0e050e63          	beqz	a0,800012b8 <fork+0x112>
    800011c0:	ec4e                	sd	s3,24(sp)
    800011c2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800011c4:	048ab603          	ld	a2,72(s5)
    800011c8:	692c                	ld	a1,80(a0)
    800011ca:	050ab503          	ld	a0,80(s5)
    800011ce:	f70ff0ef          	jal	8000093e <uvmcopy>
    800011d2:	04054e63          	bltz	a0,8000122e <fork+0x88>
    800011d6:	f426                	sd	s1,40(sp)
    800011d8:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800011da:	048ab783          	ld	a5,72(s5)
    800011de:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800011e2:	058ab683          	ld	a3,88(s5)
    800011e6:	87b6                	mv	a5,a3
    800011e8:	0589b703          	ld	a4,88(s3)
    800011ec:	12068693          	addi	a3,a3,288
    800011f0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800011f4:	6788                	ld	a0,8(a5)
    800011f6:	6b8c                	ld	a1,16(a5)
    800011f8:	6f90                	ld	a2,24(a5)
    800011fa:	01073023          	sd	a6,0(a4)
    800011fe:	e708                	sd	a0,8(a4)
    80001200:	eb0c                	sd	a1,16(a4)
    80001202:	ef10                	sd	a2,24(a4)
    80001204:	02078793          	addi	a5,a5,32
    80001208:	02070713          	addi	a4,a4,32
    8000120c:	fed792e3          	bne	a5,a3,800011f0 <fork+0x4a>
  np->trace_mask = p->trace_mask;
    80001210:	168aa783          	lw	a5,360(s5)
    80001214:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001218:	0589b783          	ld	a5,88(s3)
    8000121c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001220:	0d0a8493          	addi	s1,s5,208
    80001224:	0d098913          	addi	s2,s3,208
    80001228:	150a8a13          	addi	s4,s5,336
    8000122c:	a831                	j	80001248 <fork+0xa2>
    freeproc(np);
    8000122e:	854e                	mv	a0,s3
    80001230:	dc3ff0ef          	jal	80000ff2 <freeproc>
    release(&np->lock);
    80001234:	854e                	mv	a0,s3
    80001236:	033040ef          	jal	80005a68 <release>
    return -1;
    8000123a:	597d                	li	s2,-1
    8000123c:	69e2                	ld	s3,24(sp)
    8000123e:	a0b5                	j	800012aa <fork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001240:	04a1                	addi	s1,s1,8
    80001242:	0921                	addi	s2,s2,8
    80001244:	01448963          	beq	s1,s4,80001256 <fork+0xb0>
    if(p->ofile[i])
    80001248:	6088                	ld	a0,0(s1)
    8000124a:	d97d                	beqz	a0,80001240 <fork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    8000124c:	2c0020ef          	jal	8000350c <filedup>
    80001250:	00a93023          	sd	a0,0(s2)
    80001254:	b7f5                	j	80001240 <fork+0x9a>
  np->cwd = idup(p->cwd);
    80001256:	150ab503          	ld	a0,336(s5)
    8000125a:	612010ef          	jal	8000286c <idup>
    8000125e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001262:	4641                	li	a2,16
    80001264:	158a8593          	addi	a1,s5,344
    80001268:	15898513          	addi	a0,s3,344
    8000126c:	862ff0ef          	jal	800002ce <safestrcpy>
  pid = np->pid;
    80001270:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001274:	854e                	mv	a0,s3
    80001276:	7f2040ef          	jal	80005a68 <release>
  acquire(&wait_lock);
    8000127a:	00009497          	auipc	s1,0x9
    8000127e:	38e48493          	addi	s1,s1,910 # 8000a608 <wait_lock>
    80001282:	8526                	mv	a0,s1
    80001284:	74c040ef          	jal	800059d0 <acquire>
  np->parent = p;
    80001288:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000128c:	8526                	mv	a0,s1
    8000128e:	7da040ef          	jal	80005a68 <release>
  acquire(&np->lock);
    80001292:	854e                	mv	a0,s3
    80001294:	73c040ef          	jal	800059d0 <acquire>
  np->state = RUNNABLE;
    80001298:	478d                	li	a5,3
    8000129a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000129e:	854e                	mv	a0,s3
    800012a0:	7c8040ef          	jal	80005a68 <release>
  return pid;
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	69e2                	ld	s3,24(sp)
    800012a8:	6a42                	ld	s4,16(sp)
}
    800012aa:	854a                	mv	a0,s2
    800012ac:	70e2                	ld	ra,56(sp)
    800012ae:	7442                	ld	s0,48(sp)
    800012b0:	7902                	ld	s2,32(sp)
    800012b2:	6aa2                	ld	s5,8(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret
    return -1;
    800012b8:	597d                	li	s2,-1
    800012ba:	bfc5                	j	800012aa <fork+0x104>

00000000800012bc <scheduler>:
{
    800012bc:	715d                	addi	sp,sp,-80
    800012be:	e486                	sd	ra,72(sp)
    800012c0:	e0a2                	sd	s0,64(sp)
    800012c2:	fc26                	sd	s1,56(sp)
    800012c4:	f84a                	sd	s2,48(sp)
    800012c6:	f44e                	sd	s3,40(sp)
    800012c8:	f052                	sd	s4,32(sp)
    800012ca:	ec56                	sd	s5,24(sp)
    800012cc:	e85a                	sd	s6,16(sp)
    800012ce:	e45e                	sd	s7,8(sp)
    800012d0:	e062                	sd	s8,0(sp)
    800012d2:	0880                	addi	s0,sp,80
    800012d4:	8792                	mv	a5,tp
  int id = r_tp();
    800012d6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800012d8:	00779b13          	slli	s6,a5,0x7
    800012dc:	00009717          	auipc	a4,0x9
    800012e0:	31470713          	addi	a4,a4,788 # 8000a5f0 <pid_lock>
    800012e4:	975a                	add	a4,a4,s6
    800012e6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800012ea:	00009717          	auipc	a4,0x9
    800012ee:	33e70713          	addi	a4,a4,830 # 8000a628 <cpus+0x8>
    800012f2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800012f4:	4c11                	li	s8,4
        c->proc = p;
    800012f6:	079e                	slli	a5,a5,0x7
    800012f8:	00009a17          	auipc	s4,0x9
    800012fc:	2f8a0a13          	addi	s4,s4,760 # 8000a5f0 <pid_lock>
    80001300:	9a3e                	add	s4,s4,a5
        found = 1;
    80001302:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001304:	0000f997          	auipc	s3,0xf
    80001308:	31c98993          	addi	s3,s3,796 # 80010620 <tickslock>
    8000130c:	a0a9                	j	80001356 <scheduler+0x9a>
      release(&p->lock);
    8000130e:	8526                	mv	a0,s1
    80001310:	758040ef          	jal	80005a68 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001314:	17048493          	addi	s1,s1,368
    80001318:	03348563          	beq	s1,s3,80001342 <scheduler+0x86>
      acquire(&p->lock);
    8000131c:	8526                	mv	a0,s1
    8000131e:	6b2040ef          	jal	800059d0 <acquire>
      if(p->state == RUNNABLE) {
    80001322:	4c9c                	lw	a5,24(s1)
    80001324:	ff2795e3          	bne	a5,s2,8000130e <scheduler+0x52>
        p->state = RUNNING;
    80001328:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000132c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001330:	06048593          	addi	a1,s1,96
    80001334:	855a                	mv	a0,s6
    80001336:	5e2000ef          	jal	80001918 <swtch>
        c->proc = 0;
    8000133a:	020a3823          	sd	zero,48(s4)
        found = 1;
    8000133e:	8ade                	mv	s5,s7
    80001340:	b7f9                	j	8000130e <scheduler+0x52>
    if(found == 0) {
    80001342:	000a9a63          	bnez	s5,80001356 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001346:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000134a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000134e:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001352:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001356:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000135a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000135e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001362:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001364:	00009497          	auipc	s1,0x9
    80001368:	6bc48493          	addi	s1,s1,1724 # 8000aa20 <proc>
      if(p->state == RUNNABLE) {
    8000136c:	490d                	li	s2,3
    8000136e:	b77d                	j	8000131c <scheduler+0x60>

0000000080001370 <sched>:
{
    80001370:	7179                	addi	sp,sp,-48
    80001372:	f406                	sd	ra,40(sp)
    80001374:	f022                	sd	s0,32(sp)
    80001376:	ec26                	sd	s1,24(sp)
    80001378:	e84a                	sd	s2,16(sp)
    8000137a:	e44e                	sd	s3,8(sp)
    8000137c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000137e:	b03ff0ef          	jal	80000e80 <myproc>
    80001382:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001384:	5e2040ef          	jal	80005966 <holding>
    80001388:	c92d                	beqz	a0,800013fa <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000138a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000138c:	2781                	sext.w	a5,a5
    8000138e:	079e                	slli	a5,a5,0x7
    80001390:	00009717          	auipc	a4,0x9
    80001394:	26070713          	addi	a4,a4,608 # 8000a5f0 <pid_lock>
    80001398:	97ba                	add	a5,a5,a4
    8000139a:	0a87a703          	lw	a4,168(a5)
    8000139e:	4785                	li	a5,1
    800013a0:	06f71363          	bne	a4,a5,80001406 <sched+0x96>
  if(p->state == RUNNING)
    800013a4:	4c98                	lw	a4,24(s1)
    800013a6:	4791                	li	a5,4
    800013a8:	06f70563          	beq	a4,a5,80001412 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013ac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800013b0:	8b89                	andi	a5,a5,2
  if(intr_get())
    800013b2:	e7b5                	bnez	a5,8000141e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800013b4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800013b6:	00009917          	auipc	s2,0x9
    800013ba:	23a90913          	addi	s2,s2,570 # 8000a5f0 <pid_lock>
    800013be:	2781                	sext.w	a5,a5
    800013c0:	079e                	slli	a5,a5,0x7
    800013c2:	97ca                	add	a5,a5,s2
    800013c4:	0ac7a983          	lw	s3,172(a5)
    800013c8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800013ca:	2781                	sext.w	a5,a5
    800013cc:	079e                	slli	a5,a5,0x7
    800013ce:	00009597          	auipc	a1,0x9
    800013d2:	25a58593          	addi	a1,a1,602 # 8000a628 <cpus+0x8>
    800013d6:	95be                	add	a1,a1,a5
    800013d8:	06048513          	addi	a0,s1,96
    800013dc:	53c000ef          	jal	80001918 <swtch>
    800013e0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800013e2:	2781                	sext.w	a5,a5
    800013e4:	079e                	slli	a5,a5,0x7
    800013e6:	993e                	add	s2,s2,a5
    800013e8:	0b392623          	sw	s3,172(s2)
}
    800013ec:	70a2                	ld	ra,40(sp)
    800013ee:	7402                	ld	s0,32(sp)
    800013f0:	64e2                	ld	s1,24(sp)
    800013f2:	6942                	ld	s2,16(sp)
    800013f4:	69a2                	ld	s3,8(sp)
    800013f6:	6145                	addi	sp,sp,48
    800013f8:	8082                	ret
    panic("sched p->lock");
    800013fa:	00006517          	auipc	a0,0x6
    800013fe:	e0e50513          	addi	a0,a0,-498 # 80007208 <etext+0x208>
    80001402:	2a0040ef          	jal	800056a2 <panic>
    panic("sched locks");
    80001406:	00006517          	auipc	a0,0x6
    8000140a:	e1250513          	addi	a0,a0,-494 # 80007218 <etext+0x218>
    8000140e:	294040ef          	jal	800056a2 <panic>
    panic("sched running");
    80001412:	00006517          	auipc	a0,0x6
    80001416:	e1650513          	addi	a0,a0,-490 # 80007228 <etext+0x228>
    8000141a:	288040ef          	jal	800056a2 <panic>
    panic("sched interruptible");
    8000141e:	00006517          	auipc	a0,0x6
    80001422:	e1a50513          	addi	a0,a0,-486 # 80007238 <etext+0x238>
    80001426:	27c040ef          	jal	800056a2 <panic>

000000008000142a <yield>:
{
    8000142a:	1101                	addi	sp,sp,-32
    8000142c:	ec06                	sd	ra,24(sp)
    8000142e:	e822                	sd	s0,16(sp)
    80001430:	e426                	sd	s1,8(sp)
    80001432:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001434:	a4dff0ef          	jal	80000e80 <myproc>
    80001438:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000143a:	596040ef          	jal	800059d0 <acquire>
  p->state = RUNNABLE;
    8000143e:	478d                	li	a5,3
    80001440:	cc9c                	sw	a5,24(s1)
  sched();
    80001442:	f2fff0ef          	jal	80001370 <sched>
  release(&p->lock);
    80001446:	8526                	mv	a0,s1
    80001448:	620040ef          	jal	80005a68 <release>
}
    8000144c:	60e2                	ld	ra,24(sp)
    8000144e:	6442                	ld	s0,16(sp)
    80001450:	64a2                	ld	s1,8(sp)
    80001452:	6105                	addi	sp,sp,32
    80001454:	8082                	ret

0000000080001456 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001456:	7179                	addi	sp,sp,-48
    80001458:	f406                	sd	ra,40(sp)
    8000145a:	f022                	sd	s0,32(sp)
    8000145c:	ec26                	sd	s1,24(sp)
    8000145e:	e84a                	sd	s2,16(sp)
    80001460:	e44e                	sd	s3,8(sp)
    80001462:	1800                	addi	s0,sp,48
    80001464:	89aa                	mv	s3,a0
    80001466:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001468:	a19ff0ef          	jal	80000e80 <myproc>
    8000146c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000146e:	562040ef          	jal	800059d0 <acquire>
  release(lk);
    80001472:	854a                	mv	a0,s2
    80001474:	5f4040ef          	jal	80005a68 <release>

  // Go to sleep.
  p->chan = chan;
    80001478:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000147c:	4789                	li	a5,2
    8000147e:	cc9c                	sw	a5,24(s1)

  sched();
    80001480:	ef1ff0ef          	jal	80001370 <sched>

  // Tidy up.
  p->chan = 0;
    80001484:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001488:	8526                	mv	a0,s1
    8000148a:	5de040ef          	jal	80005a68 <release>
  acquire(lk);
    8000148e:	854a                	mv	a0,s2
    80001490:	540040ef          	jal	800059d0 <acquire>
}
    80001494:	70a2                	ld	ra,40(sp)
    80001496:	7402                	ld	s0,32(sp)
    80001498:	64e2                	ld	s1,24(sp)
    8000149a:	6942                	ld	s2,16(sp)
    8000149c:	69a2                	ld	s3,8(sp)
    8000149e:	6145                	addi	sp,sp,48
    800014a0:	8082                	ret

00000000800014a2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800014a2:	7139                	addi	sp,sp,-64
    800014a4:	fc06                	sd	ra,56(sp)
    800014a6:	f822                	sd	s0,48(sp)
    800014a8:	f426                	sd	s1,40(sp)
    800014aa:	f04a                	sd	s2,32(sp)
    800014ac:	ec4e                	sd	s3,24(sp)
    800014ae:	e852                	sd	s4,16(sp)
    800014b0:	e456                	sd	s5,8(sp)
    800014b2:	0080                	addi	s0,sp,64
    800014b4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800014b6:	00009497          	auipc	s1,0x9
    800014ba:	56a48493          	addi	s1,s1,1386 # 8000aa20 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800014be:	4989                	li	s3,2
        p->state = RUNNABLE;
    800014c0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800014c2:	0000f917          	auipc	s2,0xf
    800014c6:	15e90913          	addi	s2,s2,350 # 80010620 <tickslock>
    800014ca:	a801                	j	800014da <wakeup+0x38>
      }
      release(&p->lock);
    800014cc:	8526                	mv	a0,s1
    800014ce:	59a040ef          	jal	80005a68 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800014d2:	17048493          	addi	s1,s1,368
    800014d6:	03248263          	beq	s1,s2,800014fa <wakeup+0x58>
    if(p != myproc()){
    800014da:	9a7ff0ef          	jal	80000e80 <myproc>
    800014de:	fea48ae3          	beq	s1,a0,800014d2 <wakeup+0x30>
      acquire(&p->lock);
    800014e2:	8526                	mv	a0,s1
    800014e4:	4ec040ef          	jal	800059d0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800014e8:	4c9c                	lw	a5,24(s1)
    800014ea:	ff3791e3          	bne	a5,s3,800014cc <wakeup+0x2a>
    800014ee:	709c                	ld	a5,32(s1)
    800014f0:	fd479ee3          	bne	a5,s4,800014cc <wakeup+0x2a>
        p->state = RUNNABLE;
    800014f4:	0154ac23          	sw	s5,24(s1)
    800014f8:	bfd1                	j	800014cc <wakeup+0x2a>
    }
  }
}
    800014fa:	70e2                	ld	ra,56(sp)
    800014fc:	7442                	ld	s0,48(sp)
    800014fe:	74a2                	ld	s1,40(sp)
    80001500:	7902                	ld	s2,32(sp)
    80001502:	69e2                	ld	s3,24(sp)
    80001504:	6a42                	ld	s4,16(sp)
    80001506:	6aa2                	ld	s5,8(sp)
    80001508:	6121                	addi	sp,sp,64
    8000150a:	8082                	ret

000000008000150c <reparent>:
{
    8000150c:	7179                	addi	sp,sp,-48
    8000150e:	f406                	sd	ra,40(sp)
    80001510:	f022                	sd	s0,32(sp)
    80001512:	ec26                	sd	s1,24(sp)
    80001514:	e84a                	sd	s2,16(sp)
    80001516:	e44e                	sd	s3,8(sp)
    80001518:	e052                	sd	s4,0(sp)
    8000151a:	1800                	addi	s0,sp,48
    8000151c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000151e:	00009497          	auipc	s1,0x9
    80001522:	50248493          	addi	s1,s1,1282 # 8000aa20 <proc>
      pp->parent = initproc;
    80001526:	00009a17          	auipc	s4,0x9
    8000152a:	08aa0a13          	addi	s4,s4,138 # 8000a5b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000152e:	0000f997          	auipc	s3,0xf
    80001532:	0f298993          	addi	s3,s3,242 # 80010620 <tickslock>
    80001536:	a029                	j	80001540 <reparent+0x34>
    80001538:	17048493          	addi	s1,s1,368
    8000153c:	01348b63          	beq	s1,s3,80001552 <reparent+0x46>
    if(pp->parent == p){
    80001540:	7c9c                	ld	a5,56(s1)
    80001542:	ff279be3          	bne	a5,s2,80001538 <reparent+0x2c>
      pp->parent = initproc;
    80001546:	000a3503          	ld	a0,0(s4)
    8000154a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000154c:	f57ff0ef          	jal	800014a2 <wakeup>
    80001550:	b7e5                	j	80001538 <reparent+0x2c>
}
    80001552:	70a2                	ld	ra,40(sp)
    80001554:	7402                	ld	s0,32(sp)
    80001556:	64e2                	ld	s1,24(sp)
    80001558:	6942                	ld	s2,16(sp)
    8000155a:	69a2                	ld	s3,8(sp)
    8000155c:	6a02                	ld	s4,0(sp)
    8000155e:	6145                	addi	sp,sp,48
    80001560:	8082                	ret

0000000080001562 <exit>:
{
    80001562:	7179                	addi	sp,sp,-48
    80001564:	f406                	sd	ra,40(sp)
    80001566:	f022                	sd	s0,32(sp)
    80001568:	ec26                	sd	s1,24(sp)
    8000156a:	e84a                	sd	s2,16(sp)
    8000156c:	e44e                	sd	s3,8(sp)
    8000156e:	e052                	sd	s4,0(sp)
    80001570:	1800                	addi	s0,sp,48
    80001572:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001574:	90dff0ef          	jal	80000e80 <myproc>
    80001578:	89aa                	mv	s3,a0
  if(p == initproc)
    8000157a:	00009797          	auipc	a5,0x9
    8000157e:	0367b783          	ld	a5,54(a5) # 8000a5b0 <initproc>
    80001582:	0d050493          	addi	s1,a0,208
    80001586:	15050913          	addi	s2,a0,336
    8000158a:	00a79f63          	bne	a5,a0,800015a8 <exit+0x46>
    panic("init exiting");
    8000158e:	00006517          	auipc	a0,0x6
    80001592:	cc250513          	addi	a0,a0,-830 # 80007250 <etext+0x250>
    80001596:	10c040ef          	jal	800056a2 <panic>
      fileclose(f);
    8000159a:	7b9010ef          	jal	80003552 <fileclose>
      p->ofile[fd] = 0;
    8000159e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800015a2:	04a1                	addi	s1,s1,8
    800015a4:	01248563          	beq	s1,s2,800015ae <exit+0x4c>
    if(p->ofile[fd]){
    800015a8:	6088                	ld	a0,0(s1)
    800015aa:	f965                	bnez	a0,8000159a <exit+0x38>
    800015ac:	bfdd                	j	800015a2 <exit+0x40>
  begin_op();
    800015ae:	38b010ef          	jal	80003138 <begin_op>
  iput(p->cwd);
    800015b2:	1509b503          	ld	a0,336(s3)
    800015b6:	46e010ef          	jal	80002a24 <iput>
  end_op();
    800015ba:	3e9010ef          	jal	800031a2 <end_op>
  p->cwd = 0;
    800015be:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800015c2:	00009497          	auipc	s1,0x9
    800015c6:	04648493          	addi	s1,s1,70 # 8000a608 <wait_lock>
    800015ca:	8526                	mv	a0,s1
    800015cc:	404040ef          	jal	800059d0 <acquire>
  reparent(p);
    800015d0:	854e                	mv	a0,s3
    800015d2:	f3bff0ef          	jal	8000150c <reparent>
  wakeup(p->parent);
    800015d6:	0389b503          	ld	a0,56(s3)
    800015da:	ec9ff0ef          	jal	800014a2 <wakeup>
  acquire(&p->lock);
    800015de:	854e                	mv	a0,s3
    800015e0:	3f0040ef          	jal	800059d0 <acquire>
  p->xstate = status;
    800015e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800015e8:	4795                	li	a5,5
    800015ea:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800015ee:	8526                	mv	a0,s1
    800015f0:	478040ef          	jal	80005a68 <release>
  sched();
    800015f4:	d7dff0ef          	jal	80001370 <sched>
  panic("zombie exit");
    800015f8:	00006517          	auipc	a0,0x6
    800015fc:	c6850513          	addi	a0,a0,-920 # 80007260 <etext+0x260>
    80001600:	0a2040ef          	jal	800056a2 <panic>

0000000080001604 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001604:	7179                	addi	sp,sp,-48
    80001606:	f406                	sd	ra,40(sp)
    80001608:	f022                	sd	s0,32(sp)
    8000160a:	ec26                	sd	s1,24(sp)
    8000160c:	e84a                	sd	s2,16(sp)
    8000160e:	e44e                	sd	s3,8(sp)
    80001610:	1800                	addi	s0,sp,48
    80001612:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001614:	00009497          	auipc	s1,0x9
    80001618:	40c48493          	addi	s1,s1,1036 # 8000aa20 <proc>
    8000161c:	0000f997          	auipc	s3,0xf
    80001620:	00498993          	addi	s3,s3,4 # 80010620 <tickslock>
    acquire(&p->lock);
    80001624:	8526                	mv	a0,s1
    80001626:	3aa040ef          	jal	800059d0 <acquire>
    if(p->pid == pid){
    8000162a:	589c                	lw	a5,48(s1)
    8000162c:	01278b63          	beq	a5,s2,80001642 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001630:	8526                	mv	a0,s1
    80001632:	436040ef          	jal	80005a68 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001636:	17048493          	addi	s1,s1,368
    8000163a:	ff3495e3          	bne	s1,s3,80001624 <kill+0x20>
  }
  return -1;
    8000163e:	557d                	li	a0,-1
    80001640:	a819                	j	80001656 <kill+0x52>
      p->killed = 1;
    80001642:	4785                	li	a5,1
    80001644:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001646:	4c98                	lw	a4,24(s1)
    80001648:	4789                	li	a5,2
    8000164a:	00f70d63          	beq	a4,a5,80001664 <kill+0x60>
      release(&p->lock);
    8000164e:	8526                	mv	a0,s1
    80001650:	418040ef          	jal	80005a68 <release>
      return 0;
    80001654:	4501                	li	a0,0
}
    80001656:	70a2                	ld	ra,40(sp)
    80001658:	7402                	ld	s0,32(sp)
    8000165a:	64e2                	ld	s1,24(sp)
    8000165c:	6942                	ld	s2,16(sp)
    8000165e:	69a2                	ld	s3,8(sp)
    80001660:	6145                	addi	sp,sp,48
    80001662:	8082                	ret
        p->state = RUNNABLE;
    80001664:	478d                	li	a5,3
    80001666:	cc9c                	sw	a5,24(s1)
    80001668:	b7dd                	j	8000164e <kill+0x4a>

000000008000166a <setkilled>:

void
setkilled(struct proc *p)
{
    8000166a:	1101                	addi	sp,sp,-32
    8000166c:	ec06                	sd	ra,24(sp)
    8000166e:	e822                	sd	s0,16(sp)
    80001670:	e426                	sd	s1,8(sp)
    80001672:	1000                	addi	s0,sp,32
    80001674:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001676:	35a040ef          	jal	800059d0 <acquire>
  p->killed = 1;
    8000167a:	4785                	li	a5,1
    8000167c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000167e:	8526                	mv	a0,s1
    80001680:	3e8040ef          	jal	80005a68 <release>
}
    80001684:	60e2                	ld	ra,24(sp)
    80001686:	6442                	ld	s0,16(sp)
    80001688:	64a2                	ld	s1,8(sp)
    8000168a:	6105                	addi	sp,sp,32
    8000168c:	8082                	ret

000000008000168e <killed>:

int
killed(struct proc *p)
{
    8000168e:	1101                	addi	sp,sp,-32
    80001690:	ec06                	sd	ra,24(sp)
    80001692:	e822                	sd	s0,16(sp)
    80001694:	e426                	sd	s1,8(sp)
    80001696:	e04a                	sd	s2,0(sp)
    80001698:	1000                	addi	s0,sp,32
    8000169a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000169c:	334040ef          	jal	800059d0 <acquire>
  k = p->killed;
    800016a0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800016a4:	8526                	mv	a0,s1
    800016a6:	3c2040ef          	jal	80005a68 <release>
  return k;
}
    800016aa:	854a                	mv	a0,s2
    800016ac:	60e2                	ld	ra,24(sp)
    800016ae:	6442                	ld	s0,16(sp)
    800016b0:	64a2                	ld	s1,8(sp)
    800016b2:	6902                	ld	s2,0(sp)
    800016b4:	6105                	addi	sp,sp,32
    800016b6:	8082                	ret

00000000800016b8 <wait>:
{
    800016b8:	715d                	addi	sp,sp,-80
    800016ba:	e486                	sd	ra,72(sp)
    800016bc:	e0a2                	sd	s0,64(sp)
    800016be:	fc26                	sd	s1,56(sp)
    800016c0:	f84a                	sd	s2,48(sp)
    800016c2:	f44e                	sd	s3,40(sp)
    800016c4:	f052                	sd	s4,32(sp)
    800016c6:	ec56                	sd	s5,24(sp)
    800016c8:	e85a                	sd	s6,16(sp)
    800016ca:	e45e                	sd	s7,8(sp)
    800016cc:	e062                	sd	s8,0(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800016d2:	faeff0ef          	jal	80000e80 <myproc>
    800016d6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800016d8:	00009517          	auipc	a0,0x9
    800016dc:	f3050513          	addi	a0,a0,-208 # 8000a608 <wait_lock>
    800016e0:	2f0040ef          	jal	800059d0 <acquire>
    havekids = 0;
    800016e4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800016e6:	4a15                	li	s4,5
        havekids = 1;
    800016e8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016ea:	0000f997          	auipc	s3,0xf
    800016ee:	f3698993          	addi	s3,s3,-202 # 80010620 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016f2:	00009c17          	auipc	s8,0x9
    800016f6:	f16c0c13          	addi	s8,s8,-234 # 8000a608 <wait_lock>
    800016fa:	a871                	j	80001796 <wait+0xde>
          pid = pp->pid;
    800016fc:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001700:	000b0c63          	beqz	s6,80001718 <wait+0x60>
    80001704:	4691                	li	a3,4
    80001706:	02c48613          	addi	a2,s1,44
    8000170a:	85da                	mv	a1,s6
    8000170c:	05093503          	ld	a0,80(s2)
    80001710:	b0aff0ef          	jal	80000a1a <copyout>
    80001714:	02054b63          	bltz	a0,8000174a <wait+0x92>
          freeproc(pp);
    80001718:	8526                	mv	a0,s1
    8000171a:	8d9ff0ef          	jal	80000ff2 <freeproc>
          release(&pp->lock);
    8000171e:	8526                	mv	a0,s1
    80001720:	348040ef          	jal	80005a68 <release>
          release(&wait_lock);
    80001724:	00009517          	auipc	a0,0x9
    80001728:	ee450513          	addi	a0,a0,-284 # 8000a608 <wait_lock>
    8000172c:	33c040ef          	jal	80005a68 <release>
}
    80001730:	854e                	mv	a0,s3
    80001732:	60a6                	ld	ra,72(sp)
    80001734:	6406                	ld	s0,64(sp)
    80001736:	74e2                	ld	s1,56(sp)
    80001738:	7942                	ld	s2,48(sp)
    8000173a:	79a2                	ld	s3,40(sp)
    8000173c:	7a02                	ld	s4,32(sp)
    8000173e:	6ae2                	ld	s5,24(sp)
    80001740:	6b42                	ld	s6,16(sp)
    80001742:	6ba2                	ld	s7,8(sp)
    80001744:	6c02                	ld	s8,0(sp)
    80001746:	6161                	addi	sp,sp,80
    80001748:	8082                	ret
            release(&pp->lock);
    8000174a:	8526                	mv	a0,s1
    8000174c:	31c040ef          	jal	80005a68 <release>
            release(&wait_lock);
    80001750:	00009517          	auipc	a0,0x9
    80001754:	eb850513          	addi	a0,a0,-328 # 8000a608 <wait_lock>
    80001758:	310040ef          	jal	80005a68 <release>
            return -1;
    8000175c:	59fd                	li	s3,-1
    8000175e:	bfc9                	j	80001730 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001760:	17048493          	addi	s1,s1,368
    80001764:	03348063          	beq	s1,s3,80001784 <wait+0xcc>
      if(pp->parent == p){
    80001768:	7c9c                	ld	a5,56(s1)
    8000176a:	ff279be3          	bne	a5,s2,80001760 <wait+0xa8>
        acquire(&pp->lock);
    8000176e:	8526                	mv	a0,s1
    80001770:	260040ef          	jal	800059d0 <acquire>
        if(pp->state == ZOMBIE){
    80001774:	4c9c                	lw	a5,24(s1)
    80001776:	f94783e3          	beq	a5,s4,800016fc <wait+0x44>
        release(&pp->lock);
    8000177a:	8526                	mv	a0,s1
    8000177c:	2ec040ef          	jal	80005a68 <release>
        havekids = 1;
    80001780:	8756                	mv	a4,s5
    80001782:	bff9                	j	80001760 <wait+0xa8>
    if(!havekids || killed(p)){
    80001784:	cf19                	beqz	a4,800017a2 <wait+0xea>
    80001786:	854a                	mv	a0,s2
    80001788:	f07ff0ef          	jal	8000168e <killed>
    8000178c:	e919                	bnez	a0,800017a2 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000178e:	85e2                	mv	a1,s8
    80001790:	854a                	mv	a0,s2
    80001792:	cc5ff0ef          	jal	80001456 <sleep>
    havekids = 0;
    80001796:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001798:	00009497          	auipc	s1,0x9
    8000179c:	28848493          	addi	s1,s1,648 # 8000aa20 <proc>
    800017a0:	b7e1                	j	80001768 <wait+0xb0>
      release(&wait_lock);
    800017a2:	00009517          	auipc	a0,0x9
    800017a6:	e6650513          	addi	a0,a0,-410 # 8000a608 <wait_lock>
    800017aa:	2be040ef          	jal	80005a68 <release>
      return -1;
    800017ae:	59fd                	li	s3,-1
    800017b0:	b741                	j	80001730 <wait+0x78>

00000000800017b2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800017b2:	7179                	addi	sp,sp,-48
    800017b4:	f406                	sd	ra,40(sp)
    800017b6:	f022                	sd	s0,32(sp)
    800017b8:	ec26                	sd	s1,24(sp)
    800017ba:	e84a                	sd	s2,16(sp)
    800017bc:	e44e                	sd	s3,8(sp)
    800017be:	e052                	sd	s4,0(sp)
    800017c0:	1800                	addi	s0,sp,48
    800017c2:	84aa                	mv	s1,a0
    800017c4:	892e                	mv	s2,a1
    800017c6:	89b2                	mv	s3,a2
    800017c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017ca:	eb6ff0ef          	jal	80000e80 <myproc>
  if(user_dst){
    800017ce:	cc99                	beqz	s1,800017ec <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800017d0:	86d2                	mv	a3,s4
    800017d2:	864e                	mv	a2,s3
    800017d4:	85ca                	mv	a1,s2
    800017d6:	6928                	ld	a0,80(a0)
    800017d8:	a42ff0ef          	jal	80000a1a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800017dc:	70a2                	ld	ra,40(sp)
    800017de:	7402                	ld	s0,32(sp)
    800017e0:	64e2                	ld	s1,24(sp)
    800017e2:	6942                	ld	s2,16(sp)
    800017e4:	69a2                	ld	s3,8(sp)
    800017e6:	6a02                	ld	s4,0(sp)
    800017e8:	6145                	addi	sp,sp,48
    800017ea:	8082                	ret
    memmove((char *)dst, src, len);
    800017ec:	000a061b          	sext.w	a2,s4
    800017f0:	85ce                	mv	a1,s3
    800017f2:	854a                	mv	a0,s2
    800017f4:	9f9fe0ef          	jal	800001ec <memmove>
    return 0;
    800017f8:	8526                	mv	a0,s1
    800017fa:	b7cd                	j	800017dc <either_copyout+0x2a>

00000000800017fc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800017fc:	7179                	addi	sp,sp,-48
    800017fe:	f406                	sd	ra,40(sp)
    80001800:	f022                	sd	s0,32(sp)
    80001802:	ec26                	sd	s1,24(sp)
    80001804:	e84a                	sd	s2,16(sp)
    80001806:	e44e                	sd	s3,8(sp)
    80001808:	e052                	sd	s4,0(sp)
    8000180a:	1800                	addi	s0,sp,48
    8000180c:	892a                	mv	s2,a0
    8000180e:	84ae                	mv	s1,a1
    80001810:	89b2                	mv	s3,a2
    80001812:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001814:	e6cff0ef          	jal	80000e80 <myproc>
  if(user_src){
    80001818:	cc99                	beqz	s1,80001836 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000181a:	86d2                	mv	a3,s4
    8000181c:	864e                	mv	a2,s3
    8000181e:	85ca                	mv	a1,s2
    80001820:	6928                	ld	a0,80(a0)
    80001822:	aceff0ef          	jal	80000af0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001826:	70a2                	ld	ra,40(sp)
    80001828:	7402                	ld	s0,32(sp)
    8000182a:	64e2                	ld	s1,24(sp)
    8000182c:	6942                	ld	s2,16(sp)
    8000182e:	69a2                	ld	s3,8(sp)
    80001830:	6a02                	ld	s4,0(sp)
    80001832:	6145                	addi	sp,sp,48
    80001834:	8082                	ret
    memmove(dst, (char*)src, len);
    80001836:	000a061b          	sext.w	a2,s4
    8000183a:	85ce                	mv	a1,s3
    8000183c:	854a                	mv	a0,s2
    8000183e:	9affe0ef          	jal	800001ec <memmove>
    return 0;
    80001842:	8526                	mv	a0,s1
    80001844:	b7cd                	j	80001826 <either_copyin+0x2a>

0000000080001846 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001846:	715d                	addi	sp,sp,-80
    80001848:	e486                	sd	ra,72(sp)
    8000184a:	e0a2                	sd	s0,64(sp)
    8000184c:	fc26                	sd	s1,56(sp)
    8000184e:	f84a                	sd	s2,48(sp)
    80001850:	f44e                	sd	s3,40(sp)
    80001852:	f052                	sd	s4,32(sp)
    80001854:	ec56                	sd	s5,24(sp)
    80001856:	e85a                	sd	s6,16(sp)
    80001858:	e45e                	sd	s7,8(sp)
    8000185a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000185c:	00005517          	auipc	a0,0x5
    80001860:	7bc50513          	addi	a0,a0,1980 # 80007018 <etext+0x18>
    80001864:	36d030ef          	jal	800053d0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001868:	00009497          	auipc	s1,0x9
    8000186c:	31048493          	addi	s1,s1,784 # 8000ab78 <proc+0x158>
    80001870:	0000f917          	auipc	s2,0xf
    80001874:	f0890913          	addi	s2,s2,-248 # 80010778 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001878:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000187a:	00006997          	auipc	s3,0x6
    8000187e:	9f698993          	addi	s3,s3,-1546 # 80007270 <etext+0x270>
    printf("%d %s %s", p->pid, state, p->name);
    80001882:	00006a97          	auipc	s5,0x6
    80001886:	9f6a8a93          	addi	s5,s5,-1546 # 80007278 <etext+0x278>
    printf("\n");
    8000188a:	00005a17          	auipc	s4,0x5
    8000188e:	78ea0a13          	addi	s4,s4,1934 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001892:	00006b97          	auipc	s7,0x6
    80001896:	ffeb8b93          	addi	s7,s7,-2 # 80007890 <states.0>
    8000189a:	a829                	j	800018b4 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000189c:	ed86a583          	lw	a1,-296(a3)
    800018a0:	8556                	mv	a0,s5
    800018a2:	32f030ef          	jal	800053d0 <printf>
    printf("\n");
    800018a6:	8552                	mv	a0,s4
    800018a8:	329030ef          	jal	800053d0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018ac:	17048493          	addi	s1,s1,368
    800018b0:	03248263          	beq	s1,s2,800018d4 <procdump+0x8e>
    if(p->state == UNUSED)
    800018b4:	86a6                	mv	a3,s1
    800018b6:	ec04a783          	lw	a5,-320(s1)
    800018ba:	dbed                	beqz	a5,800018ac <procdump+0x66>
      state = "???";
    800018bc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018be:	fcfb6fe3          	bltu	s6,a5,8000189c <procdump+0x56>
    800018c2:	02079713          	slli	a4,a5,0x20
    800018c6:	01d75793          	srli	a5,a4,0x1d
    800018ca:	97de                	add	a5,a5,s7
    800018cc:	6390                	ld	a2,0(a5)
    800018ce:	f679                	bnez	a2,8000189c <procdump+0x56>
      state = "???";
    800018d0:	864e                	mv	a2,s3
    800018d2:	b7e9                	j	8000189c <procdump+0x56>
  }
}
    800018d4:	60a6                	ld	ra,72(sp)
    800018d6:	6406                	ld	s0,64(sp)
    800018d8:	74e2                	ld	s1,56(sp)
    800018da:	7942                	ld	s2,48(sp)
    800018dc:	79a2                	ld	s3,40(sp)
    800018de:	7a02                	ld	s4,32(sp)
    800018e0:	6ae2                	ld	s5,24(sp)
    800018e2:	6b42                	ld	s6,16(sp)
    800018e4:	6ba2                	ld	s7,8(sp)
    800018e6:	6161                	addi	sp,sp,80
    800018e8:	8082                	ret

00000000800018ea <count_active_processes>:

// count the number of active processes
uint64 count_active_processes(void) {
    800018ea:	1141                	addi	sp,sp,-16
    800018ec:	e422                	sd	s0,8(sp)
    800018ee:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    800018f0:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++) {
    800018f2:	00009797          	auipc	a5,0x9
    800018f6:	12e78793          	addi	a5,a5,302 # 8000aa20 <proc>
    800018fa:	0000f697          	auipc	a3,0xf
    800018fe:	d2668693          	addi	a3,a3,-730 # 80010620 <tickslock>
    if (p->state != UNUSED) {
    80001902:	4f98                	lw	a4,24(a5)
      count += 1;
    80001904:	00e03733          	snez	a4,a4
    80001908:	953a                	add	a0,a0,a4
  for (p = proc; p < &proc[NPROC]; p++) {
    8000190a:	17078793          	addi	a5,a5,368
    8000190e:	fed79ae3          	bne	a5,a3,80001902 <count_active_processes+0x18>
    }
  }

  return count;
    80001912:	6422                	ld	s0,8(sp)
    80001914:	0141                	addi	sp,sp,16
    80001916:	8082                	ret

0000000080001918 <swtch>:
    80001918:	00153023          	sd	ra,0(a0)
    8000191c:	00253423          	sd	sp,8(a0)
    80001920:	e900                	sd	s0,16(a0)
    80001922:	ed04                	sd	s1,24(a0)
    80001924:	03253023          	sd	s2,32(a0)
    80001928:	03353423          	sd	s3,40(a0)
    8000192c:	03453823          	sd	s4,48(a0)
    80001930:	03553c23          	sd	s5,56(a0)
    80001934:	05653023          	sd	s6,64(a0)
    80001938:	05753423          	sd	s7,72(a0)
    8000193c:	05853823          	sd	s8,80(a0)
    80001940:	05953c23          	sd	s9,88(a0)
    80001944:	07a53023          	sd	s10,96(a0)
    80001948:	07b53423          	sd	s11,104(a0)
    8000194c:	0005b083          	ld	ra,0(a1)
    80001950:	0085b103          	ld	sp,8(a1)
    80001954:	6980                	ld	s0,16(a1)
    80001956:	6d84                	ld	s1,24(a1)
    80001958:	0205b903          	ld	s2,32(a1)
    8000195c:	0285b983          	ld	s3,40(a1)
    80001960:	0305ba03          	ld	s4,48(a1)
    80001964:	0385ba83          	ld	s5,56(a1)
    80001968:	0405bb03          	ld	s6,64(a1)
    8000196c:	0485bb83          	ld	s7,72(a1)
    80001970:	0505bc03          	ld	s8,80(a1)
    80001974:	0585bc83          	ld	s9,88(a1)
    80001978:	0605bd03          	ld	s10,96(a1)
    8000197c:	0685bd83          	ld	s11,104(a1)
    80001980:	8082                	ret

0000000080001982 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001982:	1141                	addi	sp,sp,-16
    80001984:	e406                	sd	ra,8(sp)
    80001986:	e022                	sd	s0,0(sp)
    80001988:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000198a:	00006597          	auipc	a1,0x6
    8000198e:	92e58593          	addi	a1,a1,-1746 # 800072b8 <etext+0x2b8>
    80001992:	0000f517          	auipc	a0,0xf
    80001996:	c8e50513          	addi	a0,a0,-882 # 80010620 <tickslock>
    8000199a:	7b7030ef          	jal	80005950 <initlock>
}
    8000199e:	60a2                	ld	ra,8(sp)
    800019a0:	6402                	ld	s0,0(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800019a6:	1141                	addi	sp,sp,-16
    800019a8:	e422                	sd	s0,8(sp)
    800019aa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019ac:	00003797          	auipc	a5,0x3
    800019b0:	f6478793          	addi	a5,a5,-156 # 80004910 <kernelvec>
    800019b4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800019b8:	6422                	ld	s0,8(sp)
    800019ba:	0141                	addi	sp,sp,16
    800019bc:	8082                	ret

00000000800019be <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800019be:	1141                	addi	sp,sp,-16
    800019c0:	e406                	sd	ra,8(sp)
    800019c2:	e022                	sd	s0,0(sp)
    800019c4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800019c6:	cbaff0ef          	jal	80000e80 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800019ce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019d0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800019d4:	00004697          	auipc	a3,0x4
    800019d8:	62c68693          	addi	a3,a3,1580 # 80006000 <_trampoline>
    800019dc:	00004717          	auipc	a4,0x4
    800019e0:	62470713          	addi	a4,a4,1572 # 80006000 <_trampoline>
    800019e4:	8f15                	sub	a4,a4,a3
    800019e6:	040007b7          	lui	a5,0x4000
    800019ea:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800019ec:	07b2                	slli	a5,a5,0xc
    800019ee:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800019f0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800019f4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800019f6:	18002673          	csrr	a2,satp
    800019fa:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800019fc:	6d30                	ld	a2,88(a0)
    800019fe:	6138                	ld	a4,64(a0)
    80001a00:	6585                	lui	a1,0x1
    80001a02:	972e                	add	a4,a4,a1
    80001a04:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001a06:	6d38                	ld	a4,88(a0)
    80001a08:	00000617          	auipc	a2,0x0
    80001a0c:	11060613          	addi	a2,a2,272 # 80001b18 <usertrap>
    80001a10:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001a12:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a14:	8612                	mv	a2,tp
    80001a16:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a18:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001a1c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001a20:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a24:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001a28:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001a2a:	6f18                	ld	a4,24(a4)
    80001a2c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a30:	6928                	ld	a0,80(a0)
    80001a32:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a34:	00004717          	auipc	a4,0x4
    80001a38:	66870713          	addi	a4,a4,1640 # 8000609c <userret>
    80001a3c:	8f15                	sub	a4,a4,a3
    80001a3e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a40:	577d                	li	a4,-1
    80001a42:	177e                	slli	a4,a4,0x3f
    80001a44:	8d59                	or	a0,a0,a4
    80001a46:	9782                	jalr	a5
}
    80001a48:	60a2                	ld	ra,8(sp)
    80001a4a:	6402                	ld	s0,0(sp)
    80001a4c:	0141                	addi	sp,sp,16
    80001a4e:	8082                	ret

0000000080001a50 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001a50:	1101                	addi	sp,sp,-32
    80001a52:	ec06                	sd	ra,24(sp)
    80001a54:	e822                	sd	s0,16(sp)
    80001a56:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001a58:	bfcff0ef          	jal	80000e54 <cpuid>
    80001a5c:	cd11                	beqz	a0,80001a78 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001a5e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001a62:	000f4737          	lui	a4,0xf4
    80001a66:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001a6a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001a6c:	14d79073          	csrw	stimecmp,a5
}
    80001a70:	60e2                	ld	ra,24(sp)
    80001a72:	6442                	ld	s0,16(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret
    80001a78:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001a7a:	0000f497          	auipc	s1,0xf
    80001a7e:	ba648493          	addi	s1,s1,-1114 # 80010620 <tickslock>
    80001a82:	8526                	mv	a0,s1
    80001a84:	74d030ef          	jal	800059d0 <acquire>
    ticks++;
    80001a88:	00009517          	auipc	a0,0x9
    80001a8c:	b3050513          	addi	a0,a0,-1232 # 8000a5b8 <ticks>
    80001a90:	411c                	lw	a5,0(a0)
    80001a92:	2785                	addiw	a5,a5,1
    80001a94:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001a96:	a0dff0ef          	jal	800014a2 <wakeup>
    release(&tickslock);
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	7cd030ef          	jal	80005a68 <release>
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	bf75                	j	80001a5e <clockintr+0xe>

0000000080001aa4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001aa4:	1101                	addi	sp,sp,-32
    80001aa6:	ec06                	sd	ra,24(sp)
    80001aa8:	e822                	sd	s0,16(sp)
    80001aaa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001aac:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001ab0:	57fd                	li	a5,-1
    80001ab2:	17fe                	slli	a5,a5,0x3f
    80001ab4:	07a5                	addi	a5,a5,9
    80001ab6:	00f70c63          	beq	a4,a5,80001ace <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001aba:	57fd                	li	a5,-1
    80001abc:	17fe                	slli	a5,a5,0x3f
    80001abe:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001ac0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001ac2:	04f70763          	beq	a4,a5,80001b10 <devintr+0x6c>
  }
}
    80001ac6:	60e2                	ld	ra,24(sp)
    80001ac8:	6442                	ld	s0,16(sp)
    80001aca:	6105                	addi	sp,sp,32
    80001acc:	8082                	ret
    80001ace:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001ad0:	6ed020ef          	jal	800049bc <plic_claim>
    80001ad4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001ad6:	47a9                	li	a5,10
    80001ad8:	00f50963          	beq	a0,a5,80001aea <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001adc:	4785                	li	a5,1
    80001ade:	00f50963          	beq	a0,a5,80001af0 <devintr+0x4c>
    return 1;
    80001ae2:	4505                	li	a0,1
    } else if(irq){
    80001ae4:	e889                	bnez	s1,80001af6 <devintr+0x52>
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	bff9                	j	80001ac6 <devintr+0x22>
      uartintr();
    80001aea:	62b030ef          	jal	80005914 <uartintr>
    if(irq)
    80001aee:	a819                	j	80001b04 <devintr+0x60>
      virtio_disk_intr();
    80001af0:	392030ef          	jal	80004e82 <virtio_disk_intr>
    if(irq)
    80001af4:	a801                	j	80001b04 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001af6:	85a6                	mv	a1,s1
    80001af8:	00005517          	auipc	a0,0x5
    80001afc:	7c850513          	addi	a0,a0,1992 # 800072c0 <etext+0x2c0>
    80001b00:	0d1030ef          	jal	800053d0 <printf>
      plic_complete(irq);
    80001b04:	8526                	mv	a0,s1
    80001b06:	6d7020ef          	jal	800049dc <plic_complete>
    return 1;
    80001b0a:	4505                	li	a0,1
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	bf65                	j	80001ac6 <devintr+0x22>
    clockintr();
    80001b10:	f41ff0ef          	jal	80001a50 <clockintr>
    return 2;
    80001b14:	4509                	li	a0,2
    80001b16:	bf45                	j	80001ac6 <devintr+0x22>

0000000080001b18 <usertrap>:
{
    80001b18:	1101                	addi	sp,sp,-32
    80001b1a:	ec06                	sd	ra,24(sp)
    80001b1c:	e822                	sd	s0,16(sp)
    80001b1e:	e426                	sd	s1,8(sp)
    80001b20:	e04a                	sd	s2,0(sp)
    80001b22:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b24:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001b28:	1007f793          	andi	a5,a5,256
    80001b2c:	ef85                	bnez	a5,80001b64 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b2e:	00003797          	auipc	a5,0x3
    80001b32:	de278793          	addi	a5,a5,-542 # 80004910 <kernelvec>
    80001b36:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001b3a:	b46ff0ef          	jal	80000e80 <myproc>
    80001b3e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001b40:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b42:	14102773          	csrr	a4,sepc
    80001b46:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b48:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001b4c:	47a1                	li	a5,8
    80001b4e:	02f70163          	beq	a4,a5,80001b70 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001b52:	f53ff0ef          	jal	80001aa4 <devintr>
    80001b56:	892a                	mv	s2,a0
    80001b58:	c135                	beqz	a0,80001bbc <usertrap+0xa4>
  if(killed(p))
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	b33ff0ef          	jal	8000168e <killed>
    80001b60:	cd1d                	beqz	a0,80001b9e <usertrap+0x86>
    80001b62:	a81d                	j	80001b98 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001b64:	00005517          	auipc	a0,0x5
    80001b68:	77c50513          	addi	a0,a0,1916 # 800072e0 <etext+0x2e0>
    80001b6c:	337030ef          	jal	800056a2 <panic>
    if(killed(p))
    80001b70:	b1fff0ef          	jal	8000168e <killed>
    80001b74:	e121                	bnez	a0,80001bb4 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	6f1c                	ld	a5,24(a4)
    80001b7a:	0791                	addi	a5,a5,4
    80001b7c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001b82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b86:	10079073          	csrw	sstatus,a5
    syscall();
    80001b8a:	248000ef          	jal	80001dd2 <syscall>
  if(killed(p))
    80001b8e:	8526                	mv	a0,s1
    80001b90:	affff0ef          	jal	8000168e <killed>
    80001b94:	c901                	beqz	a0,80001ba4 <usertrap+0x8c>
    80001b96:	4901                	li	s2,0
    exit(-1);
    80001b98:	557d                	li	a0,-1
    80001b9a:	9c9ff0ef          	jal	80001562 <exit>
  if(which_dev == 2)
    80001b9e:	4789                	li	a5,2
    80001ba0:	04f90563          	beq	s2,a5,80001bea <usertrap+0xd2>
  usertrapret();
    80001ba4:	e1bff0ef          	jal	800019be <usertrapret>
}
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6902                	ld	s2,0(sp)
    80001bb0:	6105                	addi	sp,sp,32
    80001bb2:	8082                	ret
      exit(-1);
    80001bb4:	557d                	li	a0,-1
    80001bb6:	9adff0ef          	jal	80001562 <exit>
    80001bba:	bf75                	j	80001b76 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bbc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001bc0:	5890                	lw	a2,48(s1)
    80001bc2:	00005517          	auipc	a0,0x5
    80001bc6:	73e50513          	addi	a0,a0,1854 # 80007300 <etext+0x300>
    80001bca:	007030ef          	jal	800053d0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001bd2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001bd6:	00005517          	auipc	a0,0x5
    80001bda:	75a50513          	addi	a0,a0,1882 # 80007330 <etext+0x330>
    80001bde:	7f2030ef          	jal	800053d0 <printf>
    setkilled(p);
    80001be2:	8526                	mv	a0,s1
    80001be4:	a87ff0ef          	jal	8000166a <setkilled>
    80001be8:	b75d                	j	80001b8e <usertrap+0x76>
    yield();
    80001bea:	841ff0ef          	jal	8000142a <yield>
    80001bee:	bf5d                	j	80001ba4 <usertrap+0x8c>

0000000080001bf0 <kerneltrap>:
{
    80001bf0:	7179                	addi	sp,sp,-48
    80001bf2:	f406                	sd	ra,40(sp)
    80001bf4:	f022                	sd	s0,32(sp)
    80001bf6:	ec26                	sd	s1,24(sp)
    80001bf8:	e84a                	sd	s2,16(sp)
    80001bfa:	e44e                	sd	s3,8(sp)
    80001bfc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001bfe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c02:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c06:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001c0a:	1004f793          	andi	a5,s1,256
    80001c0e:	c795                	beqz	a5,80001c3a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c10:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001c14:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001c16:	eb85                	bnez	a5,80001c46 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001c18:	e8dff0ef          	jal	80001aa4 <devintr>
    80001c1c:	c91d                	beqz	a0,80001c52 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001c1e:	4789                	li	a5,2
    80001c20:	04f50a63          	beq	a0,a5,80001c74 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c24:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c28:	10049073          	csrw	sstatus,s1
}
    80001c2c:	70a2                	ld	ra,40(sp)
    80001c2e:	7402                	ld	s0,32(sp)
    80001c30:	64e2                	ld	s1,24(sp)
    80001c32:	6942                	ld	s2,16(sp)
    80001c34:	69a2                	ld	s3,8(sp)
    80001c36:	6145                	addi	sp,sp,48
    80001c38:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001c3a:	00005517          	auipc	a0,0x5
    80001c3e:	71e50513          	addi	a0,a0,1822 # 80007358 <etext+0x358>
    80001c42:	261030ef          	jal	800056a2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001c46:	00005517          	auipc	a0,0x5
    80001c4a:	73a50513          	addi	a0,a0,1850 # 80007380 <etext+0x380>
    80001c4e:	255030ef          	jal	800056a2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c52:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001c56:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001c5a:	85ce                	mv	a1,s3
    80001c5c:	00005517          	auipc	a0,0x5
    80001c60:	74450513          	addi	a0,a0,1860 # 800073a0 <etext+0x3a0>
    80001c64:	76c030ef          	jal	800053d0 <printf>
    panic("kerneltrap");
    80001c68:	00005517          	auipc	a0,0x5
    80001c6c:	76050513          	addi	a0,a0,1888 # 800073c8 <etext+0x3c8>
    80001c70:	233030ef          	jal	800056a2 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001c74:	a0cff0ef          	jal	80000e80 <myproc>
    80001c78:	d555                	beqz	a0,80001c24 <kerneltrap+0x34>
    yield();
    80001c7a:	fb0ff0ef          	jal	8000142a <yield>
    80001c7e:	b75d                	j	80001c24 <kerneltrap+0x34>

0000000080001c80 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001c80:	1101                	addi	sp,sp,-32
    80001c82:	ec06                	sd	ra,24(sp)
    80001c84:	e822                	sd	s0,16(sp)
    80001c86:	e426                	sd	s1,8(sp)
    80001c88:	1000                	addi	s0,sp,32
    80001c8a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c8c:	9f4ff0ef          	jal	80000e80 <myproc>
  switch (n) {
    80001c90:	4795                	li	a5,5
    80001c92:	0497e163          	bltu	a5,s1,80001cd4 <argraw+0x54>
    80001c96:	048a                	slli	s1,s1,0x2
    80001c98:	00006717          	auipc	a4,0x6
    80001c9c:	c2870713          	addi	a4,a4,-984 # 800078c0 <states.0+0x30>
    80001ca0:	94ba                	add	s1,s1,a4
    80001ca2:	409c                	lw	a5,0(s1)
    80001ca4:	97ba                	add	a5,a5,a4
    80001ca6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ca8:	6d3c                	ld	a5,88(a0)
    80001caa:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001cac:	60e2                	ld	ra,24(sp)
    80001cae:	6442                	ld	s0,16(sp)
    80001cb0:	64a2                	ld	s1,8(sp)
    80001cb2:	6105                	addi	sp,sp,32
    80001cb4:	8082                	ret
    return p->trapframe->a1;
    80001cb6:	6d3c                	ld	a5,88(a0)
    80001cb8:	7fa8                	ld	a0,120(a5)
    80001cba:	bfcd                	j	80001cac <argraw+0x2c>
    return p->trapframe->a2;
    80001cbc:	6d3c                	ld	a5,88(a0)
    80001cbe:	63c8                	ld	a0,128(a5)
    80001cc0:	b7f5                	j	80001cac <argraw+0x2c>
    return p->trapframe->a3;
    80001cc2:	6d3c                	ld	a5,88(a0)
    80001cc4:	67c8                	ld	a0,136(a5)
    80001cc6:	b7dd                	j	80001cac <argraw+0x2c>
    return p->trapframe->a4;
    80001cc8:	6d3c                	ld	a5,88(a0)
    80001cca:	6bc8                	ld	a0,144(a5)
    80001ccc:	b7c5                	j	80001cac <argraw+0x2c>
    return p->trapframe->a5;
    80001cce:	6d3c                	ld	a5,88(a0)
    80001cd0:	6fc8                	ld	a0,152(a5)
    80001cd2:	bfe9                	j	80001cac <argraw+0x2c>
  panic("argraw");
    80001cd4:	00005517          	auipc	a0,0x5
    80001cd8:	70450513          	addi	a0,a0,1796 # 800073d8 <etext+0x3d8>
    80001cdc:	1c7030ef          	jal	800056a2 <panic>

0000000080001ce0 <fetchaddr>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	e04a                	sd	s2,0(sp)
    80001cea:	1000                	addi	s0,sp,32
    80001cec:	84aa                	mv	s1,a0
    80001cee:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001cf0:	990ff0ef          	jal	80000e80 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001cf4:	653c                	ld	a5,72(a0)
    80001cf6:	02f4f663          	bgeu	s1,a5,80001d22 <fetchaddr+0x42>
    80001cfa:	00848713          	addi	a4,s1,8
    80001cfe:	02e7e463          	bltu	a5,a4,80001d26 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001d02:	46a1                	li	a3,8
    80001d04:	8626                	mv	a2,s1
    80001d06:	85ca                	mv	a1,s2
    80001d08:	6928                	ld	a0,80(a0)
    80001d0a:	de7fe0ef          	jal	80000af0 <copyin>
    80001d0e:	00a03533          	snez	a0,a0
    80001d12:	40a00533          	neg	a0,a0
}
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6902                	ld	s2,0(sp)
    80001d1e:	6105                	addi	sp,sp,32
    80001d20:	8082                	ret
    return -1;
    80001d22:	557d                	li	a0,-1
    80001d24:	bfcd                	j	80001d16 <fetchaddr+0x36>
    80001d26:	557d                	li	a0,-1
    80001d28:	b7fd                	j	80001d16 <fetchaddr+0x36>

0000000080001d2a <fetchstr>:
{
    80001d2a:	7179                	addi	sp,sp,-48
    80001d2c:	f406                	sd	ra,40(sp)
    80001d2e:	f022                	sd	s0,32(sp)
    80001d30:	ec26                	sd	s1,24(sp)
    80001d32:	e84a                	sd	s2,16(sp)
    80001d34:	e44e                	sd	s3,8(sp)
    80001d36:	1800                	addi	s0,sp,48
    80001d38:	892a                	mv	s2,a0
    80001d3a:	84ae                	mv	s1,a1
    80001d3c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001d3e:	942ff0ef          	jal	80000e80 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001d42:	86ce                	mv	a3,s3
    80001d44:	864a                	mv	a2,s2
    80001d46:	85a6                	mv	a1,s1
    80001d48:	6928                	ld	a0,80(a0)
    80001d4a:	e2dfe0ef          	jal	80000b76 <copyinstr>
    80001d4e:	00054c63          	bltz	a0,80001d66 <fetchstr+0x3c>
  return strlen(buf);
    80001d52:	8526                	mv	a0,s1
    80001d54:	dacfe0ef          	jal	80000300 <strlen>
}
    80001d58:	70a2                	ld	ra,40(sp)
    80001d5a:	7402                	ld	s0,32(sp)
    80001d5c:	64e2                	ld	s1,24(sp)
    80001d5e:	6942                	ld	s2,16(sp)
    80001d60:	69a2                	ld	s3,8(sp)
    80001d62:	6145                	addi	sp,sp,48
    80001d64:	8082                	ret
    return -1;
    80001d66:	557d                	li	a0,-1
    80001d68:	bfc5                	j	80001d58 <fetchstr+0x2e>

0000000080001d6a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001d6a:	1101                	addi	sp,sp,-32
    80001d6c:	ec06                	sd	ra,24(sp)
    80001d6e:	e822                	sd	s0,16(sp)
    80001d70:	e426                	sd	s1,8(sp)
    80001d72:	1000                	addi	s0,sp,32
    80001d74:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d76:	f0bff0ef          	jal	80001c80 <argraw>
    80001d7a:	c088                	sw	a0,0(s1)
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret

0000000080001d86 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001d86:	1101                	addi	sp,sp,-32
    80001d88:	ec06                	sd	ra,24(sp)
    80001d8a:	e822                	sd	s0,16(sp)
    80001d8c:	e426                	sd	s1,8(sp)
    80001d8e:	1000                	addi	s0,sp,32
    80001d90:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001d92:	eefff0ef          	jal	80001c80 <argraw>
    80001d96:	e088                	sd	a0,0(s1)
}
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret

0000000080001da2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001da2:	7179                	addi	sp,sp,-48
    80001da4:	f406                	sd	ra,40(sp)
    80001da6:	f022                	sd	s0,32(sp)
    80001da8:	ec26                	sd	s1,24(sp)
    80001daa:	e84a                	sd	s2,16(sp)
    80001dac:	1800                	addi	s0,sp,48
    80001dae:	84ae                	mv	s1,a1
    80001db0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001db2:	fd840593          	addi	a1,s0,-40
    80001db6:	fd1ff0ef          	jal	80001d86 <argaddr>
  return fetchstr(addr, buf, max);
    80001dba:	864a                	mv	a2,s2
    80001dbc:	85a6                	mv	a1,s1
    80001dbe:	fd843503          	ld	a0,-40(s0)
    80001dc2:	f69ff0ef          	jal	80001d2a <fetchstr>
}
    80001dc6:	70a2                	ld	ra,40(sp)
    80001dc8:	7402                	ld	s0,32(sp)
    80001dca:	64e2                	ld	s1,24(sp)
    80001dcc:	6942                	ld	s2,16(sp)
    80001dce:	6145                	addi	sp,sp,48
    80001dd0:	8082                	ret

0000000080001dd2 <syscall>:
  [SYS_sysinfo] "sysinfo",
};

void
syscall(void)
{
    80001dd2:	7179                	addi	sp,sp,-48
    80001dd4:	f406                	sd	ra,40(sp)
    80001dd6:	f022                	sd	s0,32(sp)
    80001dd8:	ec26                	sd	s1,24(sp)
    80001dda:	e84a                	sd	s2,16(sp)
    80001ddc:	e44e                	sd	s3,8(sp)
    80001dde:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80001de0:	8a0ff0ef          	jal	80000e80 <myproc>
    80001de4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001de6:	05853903          	ld	s2,88(a0)
    80001dea:	0a893783          	ld	a5,168(s2)
    80001dee:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001df2:	37fd                	addiw	a5,a5,-1
    80001df4:	4761                	li	a4,24
    80001df6:	04f76563          	bltu	a4,a5,80001e40 <syscall+0x6e>
    80001dfa:	00399713          	slli	a4,s3,0x3
    80001dfe:	00006797          	auipc	a5,0x6
    80001e02:	ada78793          	addi	a5,a5,-1318 # 800078d8 <syscalls>
    80001e06:	97ba                	add	a5,a5,a4
    80001e08:	639c                	ld	a5,0(a5)
    80001e0a:	cb9d                	beqz	a5,80001e40 <syscall+0x6e>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001e0c:	9782                	jalr	a5
    80001e0e:	06a93823          	sd	a0,112(s2)

    if (p->trace_mask & (1 << num)) {
    80001e12:	1684a783          	lw	a5,360(s1)
    80001e16:	4137d7bb          	sraw	a5,a5,s3
    80001e1a:	8b85                	andi	a5,a5,1
    80001e1c:	cf9d                	beqz	a5,80001e5a <syscall+0x88>
      printf("%d: syscall %s -> %ld\n", p->pid, syscall_names[num], p->trapframe->a0);
    80001e1e:	6cb8                	ld	a4,88(s1)
    80001e20:	098e                	slli	s3,s3,0x3
    80001e22:	00006797          	auipc	a5,0x6
    80001e26:	ab678793          	addi	a5,a5,-1354 # 800078d8 <syscalls>
    80001e2a:	97ce                	add	a5,a5,s3
    80001e2c:	7b34                	ld	a3,112(a4)
    80001e2e:	6bf0                	ld	a2,208(a5)
    80001e30:	588c                	lw	a1,48(s1)
    80001e32:	00005517          	auipc	a0,0x5
    80001e36:	5ae50513          	addi	a0,a0,1454 # 800073e0 <etext+0x3e0>
    80001e3a:	596030ef          	jal	800053d0 <printf>
    80001e3e:	a831                	j	80001e5a <syscall+0x88>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001e40:	86ce                	mv	a3,s3
    80001e42:	15848613          	addi	a2,s1,344
    80001e46:	588c                	lw	a1,48(s1)
    80001e48:	00005517          	auipc	a0,0x5
    80001e4c:	5b050513          	addi	a0,a0,1456 # 800073f8 <etext+0x3f8>
    80001e50:	580030ef          	jal	800053d0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001e54:	6cbc                	ld	a5,88(s1)
    80001e56:	577d                	li	a4,-1
    80001e58:	fbb8                	sd	a4,112(a5)
  }
}
    80001e5a:	70a2                	ld	ra,40(sp)
    80001e5c:	7402                	ld	s0,32(sp)
    80001e5e:	64e2                	ld	s1,24(sp)
    80001e60:	6942                	ld	s2,16(sp)
    80001e62:	69a2                	ld	s3,8(sp)
    80001e64:	6145                	addi	sp,sp,48
    80001e66:	8082                	ret

0000000080001e68 <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80001e68:	1101                	addi	sp,sp,-32
    80001e6a:	ec06                	sd	ra,24(sp)
    80001e6c:	e822                	sd	s0,16(sp)
    80001e6e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001e70:	fec40593          	addi	a1,s0,-20
    80001e74:	4501                	li	a0,0
    80001e76:	ef5ff0ef          	jal	80001d6a <argint>
  exit(n);
    80001e7a:	fec42503          	lw	a0,-20(s0)
    80001e7e:	ee4ff0ef          	jal	80001562 <exit>
  return 0;  // not reached
}
    80001e82:	4501                	li	a0,0
    80001e84:	60e2                	ld	ra,24(sp)
    80001e86:	6442                	ld	s0,16(sp)
    80001e88:	6105                	addi	sp,sp,32
    80001e8a:	8082                	ret

0000000080001e8c <sys_getpid>:

uint64
sys_getpid(void)
{
    80001e8c:	1141                	addi	sp,sp,-16
    80001e8e:	e406                	sd	ra,8(sp)
    80001e90:	e022                	sd	s0,0(sp)
    80001e92:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001e94:	fedfe0ef          	jal	80000e80 <myproc>
}
    80001e98:	5908                	lw	a0,48(a0)
    80001e9a:	60a2                	ld	ra,8(sp)
    80001e9c:	6402                	ld	s0,0(sp)
    80001e9e:	0141                	addi	sp,sp,16
    80001ea0:	8082                	ret

0000000080001ea2 <sys_fork>:

uint64
sys_fork(void)
{
    80001ea2:	1141                	addi	sp,sp,-16
    80001ea4:	e406                	sd	ra,8(sp)
    80001ea6:	e022                	sd	s0,0(sp)
    80001ea8:	0800                	addi	s0,sp,16
  return fork();
    80001eaa:	afcff0ef          	jal	800011a6 <fork>
}
    80001eae:	60a2                	ld	ra,8(sp)
    80001eb0:	6402                	ld	s0,0(sp)
    80001eb2:	0141                	addi	sp,sp,16
    80001eb4:	8082                	ret

0000000080001eb6 <sys_wait>:

uint64
sys_wait(void)
{
    80001eb6:	1101                	addi	sp,sp,-32
    80001eb8:	ec06                	sd	ra,24(sp)
    80001eba:	e822                	sd	s0,16(sp)
    80001ebc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001ebe:	fe840593          	addi	a1,s0,-24
    80001ec2:	4501                	li	a0,0
    80001ec4:	ec3ff0ef          	jal	80001d86 <argaddr>
  return wait(p);
    80001ec8:	fe843503          	ld	a0,-24(s0)
    80001ecc:	fecff0ef          	jal	800016b8 <wait>
}
    80001ed0:	60e2                	ld	ra,24(sp)
    80001ed2:	6442                	ld	s0,16(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret

0000000080001ed8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001ee2:	fdc40593          	addi	a1,s0,-36
    80001ee6:	4501                	li	a0,0
    80001ee8:	e83ff0ef          	jal	80001d6a <argint>
  addr = myproc()->sz;
    80001eec:	f95fe0ef          	jal	80000e80 <myproc>
    80001ef0:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001ef2:	fdc42503          	lw	a0,-36(s0)
    80001ef6:	a60ff0ef          	jal	80001156 <growproc>
    80001efa:	00054863          	bltz	a0,80001f0a <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001efe:	8526                	mv	a0,s1
    80001f00:	70a2                	ld	ra,40(sp)
    80001f02:	7402                	ld	s0,32(sp)
    80001f04:	64e2                	ld	s1,24(sp)
    80001f06:	6145                	addi	sp,sp,48
    80001f08:	8082                	ret
    return -1;
    80001f0a:	54fd                	li	s1,-1
    80001f0c:	bfcd                	j	80001efe <sys_sbrk+0x26>

0000000080001f0e <sys_sleep>:

uint64
sys_sleep(void)
{
    80001f0e:	7139                	addi	sp,sp,-64
    80001f10:	fc06                	sd	ra,56(sp)
    80001f12:	f822                	sd	s0,48(sp)
    80001f14:	f04a                	sd	s2,32(sp)
    80001f16:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001f18:	fcc40593          	addi	a1,s0,-52
    80001f1c:	4501                	li	a0,0
    80001f1e:	e4dff0ef          	jal	80001d6a <argint>
  if(n < 0)
    80001f22:	fcc42783          	lw	a5,-52(s0)
    80001f26:	0607c763          	bltz	a5,80001f94 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001f2a:	0000e517          	auipc	a0,0xe
    80001f2e:	6f650513          	addi	a0,a0,1782 # 80010620 <tickslock>
    80001f32:	29f030ef          	jal	800059d0 <acquire>
  ticks0 = ticks;
    80001f36:	00008917          	auipc	s2,0x8
    80001f3a:	68292903          	lw	s2,1666(s2) # 8000a5b8 <ticks>
  while(ticks - ticks0 < n){
    80001f3e:	fcc42783          	lw	a5,-52(s0)
    80001f42:	cf8d                	beqz	a5,80001f7c <sys_sleep+0x6e>
    80001f44:	f426                	sd	s1,40(sp)
    80001f46:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001f48:	0000e997          	auipc	s3,0xe
    80001f4c:	6d898993          	addi	s3,s3,1752 # 80010620 <tickslock>
    80001f50:	00008497          	auipc	s1,0x8
    80001f54:	66848493          	addi	s1,s1,1640 # 8000a5b8 <ticks>
    if(killed(myproc())){
    80001f58:	f29fe0ef          	jal	80000e80 <myproc>
    80001f5c:	f32ff0ef          	jal	8000168e <killed>
    80001f60:	ed0d                	bnez	a0,80001f9a <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001f62:	85ce                	mv	a1,s3
    80001f64:	8526                	mv	a0,s1
    80001f66:	cf0ff0ef          	jal	80001456 <sleep>
  while(ticks - ticks0 < n){
    80001f6a:	409c                	lw	a5,0(s1)
    80001f6c:	412787bb          	subw	a5,a5,s2
    80001f70:	fcc42703          	lw	a4,-52(s0)
    80001f74:	fee7e2e3          	bltu	a5,a4,80001f58 <sys_sleep+0x4a>
    80001f78:	74a2                	ld	s1,40(sp)
    80001f7a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001f7c:	0000e517          	auipc	a0,0xe
    80001f80:	6a450513          	addi	a0,a0,1700 # 80010620 <tickslock>
    80001f84:	2e5030ef          	jal	80005a68 <release>
  return 0;
    80001f88:	4501                	li	a0,0
}
    80001f8a:	70e2                	ld	ra,56(sp)
    80001f8c:	7442                	ld	s0,48(sp)
    80001f8e:	7902                	ld	s2,32(sp)
    80001f90:	6121                	addi	sp,sp,64
    80001f92:	8082                	ret
    n = 0;
    80001f94:	fc042623          	sw	zero,-52(s0)
    80001f98:	bf49                	j	80001f2a <sys_sleep+0x1c>
      release(&tickslock);
    80001f9a:	0000e517          	auipc	a0,0xe
    80001f9e:	68650513          	addi	a0,a0,1670 # 80010620 <tickslock>
    80001fa2:	2c7030ef          	jal	80005a68 <release>
      return -1;
    80001fa6:	557d                	li	a0,-1
    80001fa8:	74a2                	ld	s1,40(sp)
    80001faa:	69e2                	ld	s3,24(sp)
    80001fac:	bff9                	j	80001f8a <sys_sleep+0x7c>

0000000080001fae <sys_kill>:

uint64
sys_kill(void)
{
    80001fae:	1101                	addi	sp,sp,-32
    80001fb0:	ec06                	sd	ra,24(sp)
    80001fb2:	e822                	sd	s0,16(sp)
    80001fb4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001fb6:	fec40593          	addi	a1,s0,-20
    80001fba:	4501                	li	a0,0
    80001fbc:	dafff0ef          	jal	80001d6a <argint>
  return kill(pid);
    80001fc0:	fec42503          	lw	a0,-20(s0)
    80001fc4:	e40ff0ef          	jal	80001604 <kill>
}
    80001fc8:	60e2                	ld	ra,24(sp)
    80001fca:	6442                	ld	s0,16(sp)
    80001fcc:	6105                	addi	sp,sp,32
    80001fce:	8082                	ret

0000000080001fd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001fd0:	1101                	addi	sp,sp,-32
    80001fd2:	ec06                	sd	ra,24(sp)
    80001fd4:	e822                	sd	s0,16(sp)
    80001fd6:	e426                	sd	s1,8(sp)
    80001fd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001fda:	0000e517          	auipc	a0,0xe
    80001fde:	64650513          	addi	a0,a0,1606 # 80010620 <tickslock>
    80001fe2:	1ef030ef          	jal	800059d0 <acquire>
  xticks = ticks;
    80001fe6:	00008497          	auipc	s1,0x8
    80001fea:	5d24a483          	lw	s1,1490(s1) # 8000a5b8 <ticks>
  release(&tickslock);
    80001fee:	0000e517          	auipc	a0,0xe
    80001ff2:	63250513          	addi	a0,a0,1586 # 80010620 <tickslock>
    80001ff6:	273030ef          	jal	80005a68 <release>
  return xticks;
}
    80001ffa:	02049513          	slli	a0,s1,0x20
    80001ffe:	9101                	srli	a0,a0,0x20
    80002000:	60e2                	ld	ra,24(sp)
    80002002:	6442                	ld	s0,16(sp)
    80002004:	64a2                	ld	s1,8(sp)
    80002006:	6105                	addi	sp,sp,32
    80002008:	8082                	ret

000000008000200a <sys_hello>:

uint64 sys_hello(void) {
    8000200a:	1141                	addi	sp,sp,-16
    8000200c:	e406                	sd	ra,8(sp)
    8000200e:	e022                	sd	s0,0(sp)
    80002010:	0800                	addi	s0,sp,16
  printf("Hello, world!\n");
    80002012:	00005517          	auipc	a0,0x5
    80002016:	4c650513          	addi	a0,a0,1222 # 800074d8 <etext+0x4d8>
    8000201a:	3b6030ef          	jal	800053d0 <printf>
  return 0;
}
    8000201e:	4501                	li	a0,0
    80002020:	60a2                	ld	ra,8(sp)
    80002022:	6402                	ld	s0,0(sp)
    80002024:	0141                	addi	sp,sp,16
    80002026:	8082                	ret

0000000080002028 <sys_xv6>:

uint64 sys_xv6(void) {
    80002028:	7179                	addi	sp,sp,-48
    8000202a:	f406                	sd	ra,40(sp)
    8000202c:	f022                	sd	s0,32(sp)
    8000202e:	1800                	addi	s0,sp,48
  int n;

  argint(0, &n);
    80002030:	fdc40593          	addi	a1,s0,-36
    80002034:	4501                	li	a0,0
    80002036:	d35ff0ef          	jal	80001d6a <argint>

  for (int i = 0; i < n; i++){
    8000203a:	fdc42783          	lw	a5,-36(s0)
    8000203e:	02f05363          	blez	a5,80002064 <sys_xv6+0x3c>
    80002042:	ec26                	sd	s1,24(sp)
    80002044:	e84a                	sd	s2,16(sp)
    80002046:	4481                	li	s1,0
    printf("Hello_xv6\n");
    80002048:	00005917          	auipc	s2,0x5
    8000204c:	4a090913          	addi	s2,s2,1184 # 800074e8 <etext+0x4e8>
    80002050:	854a                	mv	a0,s2
    80002052:	37e030ef          	jal	800053d0 <printf>
  for (int i = 0; i < n; i++){
    80002056:	2485                	addiw	s1,s1,1
    80002058:	fdc42783          	lw	a5,-36(s0)
    8000205c:	fef4cae3          	blt	s1,a5,80002050 <sys_xv6+0x28>
    80002060:	64e2                	ld	s1,24(sp)
    80002062:	6942                	ld	s2,16(sp)
  }
  return 0;
}
    80002064:	4501                	li	a0,0
    80002066:	70a2                	ld	ra,40(sp)
    80002068:	7402                	ld	s0,32(sp)
    8000206a:	6145                	addi	sp,sp,48
    8000206c:	8082                	ret

000000008000206e <sys_trace>:


uint64 sys_trace(void) {
    8000206e:	1101                	addi	sp,sp,-32
    80002070:	ec06                	sd	ra,24(sp)
    80002072:	e822                	sd	s0,16(sp)
    80002074:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80002076:	fec40593          	addi	a1,s0,-20
    8000207a:	4501                	li	a0,0
    8000207c:	cefff0ef          	jal	80001d6a <argint>
  struct proc *p = myproc();
    80002080:	e01fe0ef          	jal	80000e80 <myproc>
  p->trace_mask = mask;
    80002084:	fec42783          	lw	a5,-20(s0)
    80002088:	16f52423          	sw	a5,360(a0)
  return 0;
}
    8000208c:	4501                	li	a0,0
    8000208e:	60e2                	ld	ra,24(sp)
    80002090:	6442                	ld	s0,16(sp)
    80002092:	6105                	addi	sp,sp,32
    80002094:	8082                	ret

0000000080002096 <sys_sysinfo>:

uint64 sys_sysinfo(void) {
    80002096:	7139                	addi	sp,sp,-64
    80002098:	fc06                	sd	ra,56(sp)
    8000209a:	f822                	sd	s0,48(sp)
    8000209c:	f426                	sd	s1,40(sp)
    8000209e:	0080                	addi	s0,sp,64
  struct sysinfo info;
  struct proc *p = myproc();
    800020a0:	de1fe0ef          	jal	80000e80 <myproc>
    800020a4:	84aa                	mv	s1,a0
  uint64 addr;

  argaddr(0, &addr);
    800020a6:	fc040593          	addi	a1,s0,-64
    800020aa:	4501                	li	a0,0
    800020ac:	cdbff0ef          	jal	80001d86 <argaddr>

  info.freemem = kfree_memsize();
    800020b0:	89efe0ef          	jal	8000014e <kfree_memsize>
    800020b4:	fca43423          	sd	a0,-56(s0)
  info.nproc = count_active_processes();
    800020b8:	833ff0ef          	jal	800018ea <count_active_processes>
    800020bc:	fca43823          	sd	a0,-48(s0)
  info.nopenfiles = count_open_files();
    800020c0:	79c010ef          	jal	8000385c <count_open_files>
    800020c4:	fca43c23          	sd	a0,-40(s0)

  if (copyout(p->pagetable, addr, (char*)&info, sizeof(info)) < 0) {
    800020c8:	46e1                	li	a3,24
    800020ca:	fc840613          	addi	a2,s0,-56
    800020ce:	fc043583          	ld	a1,-64(s0)
    800020d2:	68a8                	ld	a0,80(s1)
    800020d4:	947fe0ef          	jal	80000a1a <copyout>
    return -1;
  }

  return 0;
    800020d8:	957d                	srai	a0,a0,0x3f
    800020da:	70e2                	ld	ra,56(sp)
    800020dc:	7442                	ld	s0,48(sp)
    800020de:	74a2                	ld	s1,40(sp)
    800020e0:	6121                	addi	sp,sp,64
    800020e2:	8082                	ret

00000000800020e4 <binit>:
} bcache;

//initialize cache 
void
binit(void)
{
    800020e4:	7179                	addi	sp,sp,-48
    800020e6:	f406                	sd	ra,40(sp)
    800020e8:	f022                	sd	s0,32(sp)
    800020ea:	ec26                	sd	s1,24(sp)
    800020ec:	e84a                	sd	s2,16(sp)
    800020ee:	e44e                	sd	s3,8(sp)
    800020f0:	e052                	sd	s4,0(sp)
    800020f2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache"); //initialize lock named "bcache"
    800020f4:	00005597          	auipc	a1,0x5
    800020f8:	40458593          	addi	a1,a1,1028 # 800074f8 <etext+0x4f8>
    800020fc:	0000e517          	auipc	a0,0xe
    80002100:	53c50513          	addi	a0,a0,1340 # 80010638 <bcache>
    80002104:	04d030ef          	jal	80005950 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002108:	00016797          	auipc	a5,0x16
    8000210c:	53078793          	addi	a5,a5,1328 # 80018638 <bcache+0x8000>
    80002110:	00016717          	auipc	a4,0x16
    80002114:	79070713          	addi	a4,a4,1936 # 800188a0 <bcache+0x8268>
    80002118:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000211c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002120:	0000e497          	auipc	s1,0xe
    80002124:	53048493          	addi	s1,s1,1328 # 80010650 <bcache+0x18>
    b->next = bcache.head.next;
    80002128:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000212a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    8000212c:	00005a17          	auipc	s4,0x5
    80002130:	3d4a0a13          	addi	s4,s4,980 # 80007500 <etext+0x500>
    b->next = bcache.head.next;
    80002134:	2b893783          	ld	a5,696(s2)
    80002138:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000213a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    8000213e:	85d2                	mv	a1,s4
    80002140:	01048513          	addi	a0,s1,16
    80002144:	248010ef          	jal	8000338c <initsleeplock>
    bcache.head.next->prev = b;
    80002148:	2b893783          	ld	a5,696(s2)
    8000214c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000214e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002152:	45848493          	addi	s1,s1,1112
    80002156:	fd349fe3          	bne	s1,s3,80002134 <binit+0x50>
  }
}
    8000215a:	70a2                	ld	ra,40(sp)
    8000215c:	7402                	ld	s0,32(sp)
    8000215e:	64e2                	ld	s1,24(sp)
    80002160:	6942                	ld	s2,16(sp)
    80002162:	69a2                	ld	s3,8(sp)
    80002164:	6a02                	ld	s4,0(sp)
    80002166:	6145                	addi	sp,sp,48
    80002168:	8082                	ret

000000008000216a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000216a:	7179                	addi	sp,sp,-48
    8000216c:	f406                	sd	ra,40(sp)
    8000216e:	f022                	sd	s0,32(sp)
    80002170:	ec26                	sd	s1,24(sp)
    80002172:	e84a                	sd	s2,16(sp)
    80002174:	e44e                	sd	s3,8(sp)
    80002176:	1800                	addi	s0,sp,48
    80002178:	892a                	mv	s2,a0
    8000217a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000217c:	0000e517          	auipc	a0,0xe
    80002180:	4bc50513          	addi	a0,a0,1212 # 80010638 <bcache>
    80002184:	04d030ef          	jal	800059d0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002188:	00016497          	auipc	s1,0x16
    8000218c:	7684b483          	ld	s1,1896(s1) # 800188f0 <bcache+0x82b8>
    80002190:	00016797          	auipc	a5,0x16
    80002194:	71078793          	addi	a5,a5,1808 # 800188a0 <bcache+0x8268>
    80002198:	02f48b63          	beq	s1,a5,800021ce <bread+0x64>
    8000219c:	873e                	mv	a4,a5
    8000219e:	a021                	j	800021a6 <bread+0x3c>
    800021a0:	68a4                	ld	s1,80(s1)
    800021a2:	02e48663          	beq	s1,a4,800021ce <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800021a6:	449c                	lw	a5,8(s1)
    800021a8:	ff279ce3          	bne	a5,s2,800021a0 <bread+0x36>
    800021ac:	44dc                	lw	a5,12(s1)
    800021ae:	ff3799e3          	bne	a5,s3,800021a0 <bread+0x36>
      b->refcnt++;
    800021b2:	40bc                	lw	a5,64(s1)
    800021b4:	2785                	addiw	a5,a5,1
    800021b6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800021b8:	0000e517          	auipc	a0,0xe
    800021bc:	48050513          	addi	a0,a0,1152 # 80010638 <bcache>
    800021c0:	0a9030ef          	jal	80005a68 <release>
      acquiresleep(&b->lock);
    800021c4:	01048513          	addi	a0,s1,16
    800021c8:	1fa010ef          	jal	800033c2 <acquiresleep>
      return b;
    800021cc:	a889                	j	8000221e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800021ce:	00016497          	auipc	s1,0x16
    800021d2:	71a4b483          	ld	s1,1818(s1) # 800188e8 <bcache+0x82b0>
    800021d6:	00016797          	auipc	a5,0x16
    800021da:	6ca78793          	addi	a5,a5,1738 # 800188a0 <bcache+0x8268>
    800021de:	00f48863          	beq	s1,a5,800021ee <bread+0x84>
    800021e2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800021e4:	40bc                	lw	a5,64(s1)
    800021e6:	cb91                	beqz	a5,800021fa <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800021e8:	64a4                	ld	s1,72(s1)
    800021ea:	fee49de3          	bne	s1,a4,800021e4 <bread+0x7a>
  panic("bget: no buffers"); //if there are no available buffer call panic.
    800021ee:	00005517          	auipc	a0,0x5
    800021f2:	31a50513          	addi	a0,a0,794 # 80007508 <etext+0x508>
    800021f6:	4ac030ef          	jal	800056a2 <panic>
      b->dev = dev;
    800021fa:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800021fe:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002202:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002206:	4785                	li	a5,1
    80002208:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000220a:	0000e517          	auipc	a0,0xe
    8000220e:	42e50513          	addi	a0,a0,1070 # 80010638 <bcache>
    80002212:	057030ef          	jal	80005a68 <release>
      acquiresleep(&b->lock);
    80002216:	01048513          	addi	a0,s1,16
    8000221a:	1a8010ef          	jal	800033c2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  //check if the data is valid or not
  if(!b->valid) {
    8000221e:	409c                	lw	a5,0(s1)
    80002220:	cb89                	beqz	a5,80002232 <bread+0xc8>
    virtio_disk_rw(b, 0); //write data into buffer
    b->valid = 1;
  }
  return b;
}
    80002222:	8526                	mv	a0,s1
    80002224:	70a2                	ld	ra,40(sp)
    80002226:	7402                	ld	s0,32(sp)
    80002228:	64e2                	ld	s1,24(sp)
    8000222a:	6942                	ld	s2,16(sp)
    8000222c:	69a2                	ld	s3,8(sp)
    8000222e:	6145                	addi	sp,sp,48
    80002230:	8082                	ret
    virtio_disk_rw(b, 0); //write data into buffer
    80002232:	4581                	li	a1,0
    80002234:	8526                	mv	a0,s1
    80002236:	23b020ef          	jal	80004c70 <virtio_disk_rw>
    b->valid = 1;
    8000223a:	4785                	li	a5,1
    8000223c:	c09c                	sw	a5,0(s1)
  return b;
    8000223e:	b7d5                	j	80002222 <bread+0xb8>

0000000080002240 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Synchronize the contents of buffer b with the block on disk.
void
bwrite(struct buf *b)
{
    80002240:	1101                	addi	sp,sp,-32
    80002242:	ec06                	sd	ra,24(sp)
    80002244:	e822                	sd	s0,16(sp)
    80002246:	e426                	sd	s1,8(sp)
    80002248:	1000                	addi	s0,sp,32
    8000224a:	84aa                	mv	s1,a0
  //check if buffer is locked by instance process
  if(!holdingsleep(&b->lock))
    8000224c:	0541                	addi	a0,a0,16
    8000224e:	1f2010ef          	jal	80003440 <holdingsleep>
    80002252:	c911                	beqz	a0,80002266 <bwrite+0x26>
    panic("bwrite"); //call panic
  virtio_disk_rw(b, 1); // write data into buffer
    80002254:	4585                	li	a1,1
    80002256:	8526                	mv	a0,s1
    80002258:	219020ef          	jal	80004c70 <virtio_disk_rw>
}
    8000225c:	60e2                	ld	ra,24(sp)
    8000225e:	6442                	ld	s0,16(sp)
    80002260:	64a2                	ld	s1,8(sp)
    80002262:	6105                	addi	sp,sp,32
    80002264:	8082                	ret
    panic("bwrite"); //call panic
    80002266:	00005517          	auipc	a0,0x5
    8000226a:	2ba50513          	addi	a0,a0,698 # 80007520 <etext+0x520>
    8000226e:	434030ef          	jal	800056a2 <panic>

0000000080002272 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002272:	1101                	addi	sp,sp,-32
    80002274:	ec06                	sd	ra,24(sp)
    80002276:	e822                	sd	s0,16(sp)
    80002278:	e426                	sd	s1,8(sp)
    8000227a:	e04a                	sd	s2,0(sp)
    8000227c:	1000                	addi	s0,sp,32
    8000227e:	84aa                	mv	s1,a0
  //check if buffer is lock
  if(!holdingsleep(&b->lock))
    80002280:	01050913          	addi	s2,a0,16
    80002284:	854a                	mv	a0,s2
    80002286:	1ba010ef          	jal	80003440 <holdingsleep>
    8000228a:	c135                	beqz	a0,800022ee <brelse+0x7c>
    panic("brelse"); // call panic
  //release lock buffer
  releasesleep(&b->lock);
    8000228c:	854a                	mv	a0,s2
    8000228e:	17a010ef          	jal	80003408 <releasesleep>

  //reduce refcnt
  acquire(&bcache.lock);
    80002292:	0000e517          	auipc	a0,0xe
    80002296:	3a650513          	addi	a0,a0,934 # 80010638 <bcache>
    8000229a:	736030ef          	jal	800059d0 <acquire>
  b->refcnt--;
    8000229e:	40bc                	lw	a5,64(s1)
    800022a0:	37fd                	addiw	a5,a5,-1
    800022a2:	0007871b          	sext.w	a4,a5
    800022a6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800022a8:	e71d                	bnez	a4,800022d6 <brelse+0x64>
    // no one is waiting for it and move it to LRU
    b->next->prev = b->prev;
    800022aa:	68b8                	ld	a4,80(s1)
    800022ac:	64bc                	ld	a5,72(s1)
    800022ae:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800022b0:	68b8                	ld	a4,80(s1)
    800022b2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800022b4:	00016797          	auipc	a5,0x16
    800022b8:	38478793          	addi	a5,a5,900 # 80018638 <bcache+0x8000>
    800022bc:	2b87b703          	ld	a4,696(a5)
    800022c0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800022c2:	00016717          	auipc	a4,0x16
    800022c6:	5de70713          	addi	a4,a4,1502 # 800188a0 <bcache+0x8268>
    800022ca:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800022cc:	2b87b703          	ld	a4,696(a5)
    800022d0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800022d2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800022d6:	0000e517          	auipc	a0,0xe
    800022da:	36250513          	addi	a0,a0,866 # 80010638 <bcache>
    800022de:	78a030ef          	jal	80005a68 <release>
}
    800022e2:	60e2                	ld	ra,24(sp)
    800022e4:	6442                	ld	s0,16(sp)
    800022e6:	64a2                	ld	s1,8(sp)
    800022e8:	6902                	ld	s2,0(sp)
    800022ea:	6105                	addi	sp,sp,32
    800022ec:	8082                	ret
    panic("brelse"); // call panic
    800022ee:	00005517          	auipc	a0,0x5
    800022f2:	23a50513          	addi	a0,a0,570 # 80007528 <etext+0x528>
    800022f6:	3ac030ef          	jal	800056a2 <panic>

00000000800022fa <bpin>:

//pin buffer to prevent buffer from reusing
void
bpin(struct buf *b) {
    800022fa:	1101                	addi	sp,sp,-32
    800022fc:	ec06                	sd	ra,24(sp)
    800022fe:	e822                	sd	s0,16(sp)
    80002300:	e426                	sd	s1,8(sp)
    80002302:	1000                	addi	s0,sp,32
    80002304:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002306:	0000e517          	auipc	a0,0xe
    8000230a:	33250513          	addi	a0,a0,818 # 80010638 <bcache>
    8000230e:	6c2030ef          	jal	800059d0 <acquire>
  b->refcnt++;
    80002312:	40bc                	lw	a5,64(s1)
    80002314:	2785                	addiw	a5,a5,1
    80002316:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002318:	0000e517          	auipc	a0,0xe
    8000231c:	32050513          	addi	a0,a0,800 # 80010638 <bcache>
    80002320:	748030ef          	jal	80005a68 <release>
}
    80002324:	60e2                	ld	ra,24(sp)
    80002326:	6442                	ld	s0,16(sp)
    80002328:	64a2                	ld	s1,8(sp)
    8000232a:	6105                	addi	sp,sp,32
    8000232c:	8082                	ret

000000008000232e <bunpin>:

//unpin buffer
void
bunpin(struct buf *b) {
    8000232e:	1101                	addi	sp,sp,-32
    80002330:	ec06                	sd	ra,24(sp)
    80002332:	e822                	sd	s0,16(sp)
    80002334:	e426                	sd	s1,8(sp)
    80002336:	1000                	addi	s0,sp,32
    80002338:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000233a:	0000e517          	auipc	a0,0xe
    8000233e:	2fe50513          	addi	a0,a0,766 # 80010638 <bcache>
    80002342:	68e030ef          	jal	800059d0 <acquire>
  b->refcnt--;
    80002346:	40bc                	lw	a5,64(s1)
    80002348:	37fd                	addiw	a5,a5,-1
    8000234a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000234c:	0000e517          	auipc	a0,0xe
    80002350:	2ec50513          	addi	a0,a0,748 # 80010638 <bcache>
    80002354:	714030ef          	jal	80005a68 <release>
}
    80002358:	60e2                	ld	ra,24(sp)
    8000235a:	6442                	ld	s0,16(sp)
    8000235c:	64a2                	ld	s1,8(sp)
    8000235e:	6105                	addi	sp,sp,32
    80002360:	8082                	ret

0000000080002362 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002362:	1101                	addi	sp,sp,-32
    80002364:	ec06                	sd	ra,24(sp)
    80002366:	e822                	sd	s0,16(sp)
    80002368:	e426                	sd	s1,8(sp)
    8000236a:	e04a                	sd	s2,0(sp)
    8000236c:	1000                	addi	s0,sp,32
    8000236e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002370:	00d5d59b          	srliw	a1,a1,0xd
    80002374:	00017797          	auipc	a5,0x17
    80002378:	9a07a783          	lw	a5,-1632(a5) # 80018d14 <sb+0x1c>
    8000237c:	9dbd                	addw	a1,a1,a5
    8000237e:	dedff0ef          	jal	8000216a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002382:	0074f713          	andi	a4,s1,7
    80002386:	4785                	li	a5,1
    80002388:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000238c:	14ce                	slli	s1,s1,0x33
    8000238e:	90d9                	srli	s1,s1,0x36
    80002390:	00950733          	add	a4,a0,s1
    80002394:	05874703          	lbu	a4,88(a4)
    80002398:	00e7f6b3          	and	a3,a5,a4
    8000239c:	c29d                	beqz	a3,800023c2 <bfree+0x60>
    8000239e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800023a0:	94aa                	add	s1,s1,a0
    800023a2:	fff7c793          	not	a5,a5
    800023a6:	8f7d                	and	a4,a4,a5
    800023a8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800023ac:	711000ef          	jal	800032bc <log_write>
  brelse(bp);
    800023b0:	854a                	mv	a0,s2
    800023b2:	ec1ff0ef          	jal	80002272 <brelse>
}
    800023b6:	60e2                	ld	ra,24(sp)
    800023b8:	6442                	ld	s0,16(sp)
    800023ba:	64a2                	ld	s1,8(sp)
    800023bc:	6902                	ld	s2,0(sp)
    800023be:	6105                	addi	sp,sp,32
    800023c0:	8082                	ret
    panic("freeing free block");
    800023c2:	00005517          	auipc	a0,0x5
    800023c6:	16e50513          	addi	a0,a0,366 # 80007530 <etext+0x530>
    800023ca:	2d8030ef          	jal	800056a2 <panic>

00000000800023ce <balloc>:
{
    800023ce:	711d                	addi	sp,sp,-96
    800023d0:	ec86                	sd	ra,88(sp)
    800023d2:	e8a2                	sd	s0,80(sp)
    800023d4:	e4a6                	sd	s1,72(sp)
    800023d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800023d8:	00017797          	auipc	a5,0x17
    800023dc:	9247a783          	lw	a5,-1756(a5) # 80018cfc <sb+0x4>
    800023e0:	0e078f63          	beqz	a5,800024de <balloc+0x110>
    800023e4:	e0ca                	sd	s2,64(sp)
    800023e6:	fc4e                	sd	s3,56(sp)
    800023e8:	f852                	sd	s4,48(sp)
    800023ea:	f456                	sd	s5,40(sp)
    800023ec:	f05a                	sd	s6,32(sp)
    800023ee:	ec5e                	sd	s7,24(sp)
    800023f0:	e862                	sd	s8,16(sp)
    800023f2:	e466                	sd	s9,8(sp)
    800023f4:	8baa                	mv	s7,a0
    800023f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800023f8:	00017b17          	auipc	s6,0x17
    800023fc:	900b0b13          	addi	s6,s6,-1792 # 80018cf8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002400:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002402:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002404:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002406:	6c89                	lui	s9,0x2
    80002408:	a0b5                	j	80002474 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000240a:	97ca                	add	a5,a5,s2
    8000240c:	8e55                	or	a2,a2,a3
    8000240e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002412:	854a                	mv	a0,s2
    80002414:	6a9000ef          	jal	800032bc <log_write>
        brelse(bp);
    80002418:	854a                	mv	a0,s2
    8000241a:	e59ff0ef          	jal	80002272 <brelse>
  bp = bread(dev, bno);
    8000241e:	85a6                	mv	a1,s1
    80002420:	855e                	mv	a0,s7
    80002422:	d49ff0ef          	jal	8000216a <bread>
    80002426:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002428:	40000613          	li	a2,1024
    8000242c:	4581                	li	a1,0
    8000242e:	05850513          	addi	a0,a0,88
    80002432:	d5ffd0ef          	jal	80000190 <memset>
  log_write(bp);
    80002436:	854a                	mv	a0,s2
    80002438:	685000ef          	jal	800032bc <log_write>
  brelse(bp);
    8000243c:	854a                	mv	a0,s2
    8000243e:	e35ff0ef          	jal	80002272 <brelse>
}
    80002442:	6906                	ld	s2,64(sp)
    80002444:	79e2                	ld	s3,56(sp)
    80002446:	7a42                	ld	s4,48(sp)
    80002448:	7aa2                	ld	s5,40(sp)
    8000244a:	7b02                	ld	s6,32(sp)
    8000244c:	6be2                	ld	s7,24(sp)
    8000244e:	6c42                	ld	s8,16(sp)
    80002450:	6ca2                	ld	s9,8(sp)
}
    80002452:	8526                	mv	a0,s1
    80002454:	60e6                	ld	ra,88(sp)
    80002456:	6446                	ld	s0,80(sp)
    80002458:	64a6                	ld	s1,72(sp)
    8000245a:	6125                	addi	sp,sp,96
    8000245c:	8082                	ret
    brelse(bp);
    8000245e:	854a                	mv	a0,s2
    80002460:	e13ff0ef          	jal	80002272 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002464:	015c87bb          	addw	a5,s9,s5
    80002468:	00078a9b          	sext.w	s5,a5
    8000246c:	004b2703          	lw	a4,4(s6)
    80002470:	04eaff63          	bgeu	s5,a4,800024ce <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002474:	41fad79b          	sraiw	a5,s5,0x1f
    80002478:	0137d79b          	srliw	a5,a5,0x13
    8000247c:	015787bb          	addw	a5,a5,s5
    80002480:	40d7d79b          	sraiw	a5,a5,0xd
    80002484:	01cb2583          	lw	a1,28(s6)
    80002488:	9dbd                	addw	a1,a1,a5
    8000248a:	855e                	mv	a0,s7
    8000248c:	cdfff0ef          	jal	8000216a <bread>
    80002490:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002492:	004b2503          	lw	a0,4(s6)
    80002496:	000a849b          	sext.w	s1,s5
    8000249a:	8762                	mv	a4,s8
    8000249c:	fca4f1e3          	bgeu	s1,a0,8000245e <balloc+0x90>
      m = 1 << (bi % 8);
    800024a0:	00777693          	andi	a3,a4,7
    800024a4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800024a8:	41f7579b          	sraiw	a5,a4,0x1f
    800024ac:	01d7d79b          	srliw	a5,a5,0x1d
    800024b0:	9fb9                	addw	a5,a5,a4
    800024b2:	4037d79b          	sraiw	a5,a5,0x3
    800024b6:	00f90633          	add	a2,s2,a5
    800024ba:	05864603          	lbu	a2,88(a2)
    800024be:	00c6f5b3          	and	a1,a3,a2
    800024c2:	d5a1                	beqz	a1,8000240a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800024c4:	2705                	addiw	a4,a4,1
    800024c6:	2485                	addiw	s1,s1,1
    800024c8:	fd471ae3          	bne	a4,s4,8000249c <balloc+0xce>
    800024cc:	bf49                	j	8000245e <balloc+0x90>
    800024ce:	6906                	ld	s2,64(sp)
    800024d0:	79e2                	ld	s3,56(sp)
    800024d2:	7a42                	ld	s4,48(sp)
    800024d4:	7aa2                	ld	s5,40(sp)
    800024d6:	7b02                	ld	s6,32(sp)
    800024d8:	6be2                	ld	s7,24(sp)
    800024da:	6c42                	ld	s8,16(sp)
    800024dc:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800024de:	00005517          	auipc	a0,0x5
    800024e2:	06a50513          	addi	a0,a0,106 # 80007548 <etext+0x548>
    800024e6:	6eb020ef          	jal	800053d0 <printf>
  return 0;
    800024ea:	4481                	li	s1,0
    800024ec:	b79d                	j	80002452 <balloc+0x84>

00000000800024ee <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800024ee:	7179                	addi	sp,sp,-48
    800024f0:	f406                	sd	ra,40(sp)
    800024f2:	f022                	sd	s0,32(sp)
    800024f4:	ec26                	sd	s1,24(sp)
    800024f6:	e84a                	sd	s2,16(sp)
    800024f8:	e44e                	sd	s3,8(sp)
    800024fa:	1800                	addi	s0,sp,48
    800024fc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800024fe:	47ad                	li	a5,11
    80002500:	02b7e663          	bltu	a5,a1,8000252c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002504:	02059793          	slli	a5,a1,0x20
    80002508:	01e7d593          	srli	a1,a5,0x1e
    8000250c:	00b504b3          	add	s1,a0,a1
    80002510:	0504a903          	lw	s2,80(s1)
    80002514:	06091a63          	bnez	s2,80002588 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002518:	4108                	lw	a0,0(a0)
    8000251a:	eb5ff0ef          	jal	800023ce <balloc>
    8000251e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002522:	06090363          	beqz	s2,80002588 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002526:	0524a823          	sw	s2,80(s1)
    8000252a:	a8b9                	j	80002588 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000252c:	ff45849b          	addiw	s1,a1,-12
    80002530:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002534:	0ff00793          	li	a5,255
    80002538:	06e7ee63          	bltu	a5,a4,800025b4 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000253c:	08052903          	lw	s2,128(a0)
    80002540:	00091d63          	bnez	s2,8000255a <bmap+0x6c>
      addr = balloc(ip->dev);
    80002544:	4108                	lw	a0,0(a0)
    80002546:	e89ff0ef          	jal	800023ce <balloc>
    8000254a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000254e:	02090d63          	beqz	s2,80002588 <bmap+0x9a>
    80002552:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002554:	0929a023          	sw	s2,128(s3)
    80002558:	a011                	j	8000255c <bmap+0x6e>
    8000255a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000255c:	85ca                	mv	a1,s2
    8000255e:	0009a503          	lw	a0,0(s3)
    80002562:	c09ff0ef          	jal	8000216a <bread>
    80002566:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002568:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000256c:	02049713          	slli	a4,s1,0x20
    80002570:	01e75593          	srli	a1,a4,0x1e
    80002574:	00b784b3          	add	s1,a5,a1
    80002578:	0004a903          	lw	s2,0(s1)
    8000257c:	00090e63          	beqz	s2,80002598 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002580:	8552                	mv	a0,s4
    80002582:	cf1ff0ef          	jal	80002272 <brelse>
    return addr;
    80002586:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002588:	854a                	mv	a0,s2
    8000258a:	70a2                	ld	ra,40(sp)
    8000258c:	7402                	ld	s0,32(sp)
    8000258e:	64e2                	ld	s1,24(sp)
    80002590:	6942                	ld	s2,16(sp)
    80002592:	69a2                	ld	s3,8(sp)
    80002594:	6145                	addi	sp,sp,48
    80002596:	8082                	ret
      addr = balloc(ip->dev);
    80002598:	0009a503          	lw	a0,0(s3)
    8000259c:	e33ff0ef          	jal	800023ce <balloc>
    800025a0:	0005091b          	sext.w	s2,a0
      if(addr){
    800025a4:	fc090ee3          	beqz	s2,80002580 <bmap+0x92>
        a[bn] = addr;
    800025a8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800025ac:	8552                	mv	a0,s4
    800025ae:	50f000ef          	jal	800032bc <log_write>
    800025b2:	b7f9                	j	80002580 <bmap+0x92>
    800025b4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800025b6:	00005517          	auipc	a0,0x5
    800025ba:	faa50513          	addi	a0,a0,-86 # 80007560 <etext+0x560>
    800025be:	0e4030ef          	jal	800056a2 <panic>

00000000800025c2 <iget>:
{
    800025c2:	7179                	addi	sp,sp,-48
    800025c4:	f406                	sd	ra,40(sp)
    800025c6:	f022                	sd	s0,32(sp)
    800025c8:	ec26                	sd	s1,24(sp)
    800025ca:	e84a                	sd	s2,16(sp)
    800025cc:	e44e                	sd	s3,8(sp)
    800025ce:	e052                	sd	s4,0(sp)
    800025d0:	1800                	addi	s0,sp,48
    800025d2:	89aa                	mv	s3,a0
    800025d4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800025d6:	00016517          	auipc	a0,0x16
    800025da:	74250513          	addi	a0,a0,1858 # 80018d18 <itable>
    800025de:	3f2030ef          	jal	800059d0 <acquire>
  empty = 0;
    800025e2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800025e4:	00016497          	auipc	s1,0x16
    800025e8:	74c48493          	addi	s1,s1,1868 # 80018d30 <itable+0x18>
    800025ec:	00018697          	auipc	a3,0x18
    800025f0:	1d468693          	addi	a3,a3,468 # 8001a7c0 <log>
    800025f4:	a039                	j	80002602 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800025f6:	02090963          	beqz	s2,80002628 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800025fa:	08848493          	addi	s1,s1,136
    800025fe:	02d48863          	beq	s1,a3,8000262e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002602:	449c                	lw	a5,8(s1)
    80002604:	fef059e3          	blez	a5,800025f6 <iget+0x34>
    80002608:	4098                	lw	a4,0(s1)
    8000260a:	ff3716e3          	bne	a4,s3,800025f6 <iget+0x34>
    8000260e:	40d8                	lw	a4,4(s1)
    80002610:	ff4713e3          	bne	a4,s4,800025f6 <iget+0x34>
      ip->ref++;
    80002614:	2785                	addiw	a5,a5,1
    80002616:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002618:	00016517          	auipc	a0,0x16
    8000261c:	70050513          	addi	a0,a0,1792 # 80018d18 <itable>
    80002620:	448030ef          	jal	80005a68 <release>
      return ip;
    80002624:	8926                	mv	s2,s1
    80002626:	a02d                	j	80002650 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002628:	fbe9                	bnez	a5,800025fa <iget+0x38>
      empty = ip;
    8000262a:	8926                	mv	s2,s1
    8000262c:	b7f9                	j	800025fa <iget+0x38>
  if(empty == 0)
    8000262e:	02090a63          	beqz	s2,80002662 <iget+0xa0>
  ip->dev = dev;
    80002632:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002636:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000263a:	4785                	li	a5,1
    8000263c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002640:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002644:	00016517          	auipc	a0,0x16
    80002648:	6d450513          	addi	a0,a0,1748 # 80018d18 <itable>
    8000264c:	41c030ef          	jal	80005a68 <release>
}
    80002650:	854a                	mv	a0,s2
    80002652:	70a2                	ld	ra,40(sp)
    80002654:	7402                	ld	s0,32(sp)
    80002656:	64e2                	ld	s1,24(sp)
    80002658:	6942                	ld	s2,16(sp)
    8000265a:	69a2                	ld	s3,8(sp)
    8000265c:	6a02                	ld	s4,0(sp)
    8000265e:	6145                	addi	sp,sp,48
    80002660:	8082                	ret
    panic("iget: no inodes");
    80002662:	00005517          	auipc	a0,0x5
    80002666:	f1650513          	addi	a0,a0,-234 # 80007578 <etext+0x578>
    8000266a:	038030ef          	jal	800056a2 <panic>

000000008000266e <fsinit>:
fsinit(int dev) {
    8000266e:	7179                	addi	sp,sp,-48
    80002670:	f406                	sd	ra,40(sp)
    80002672:	f022                	sd	s0,32(sp)
    80002674:	ec26                	sd	s1,24(sp)
    80002676:	e84a                	sd	s2,16(sp)
    80002678:	e44e                	sd	s3,8(sp)
    8000267a:	1800                	addi	s0,sp,48
    8000267c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000267e:	4585                	li	a1,1
    80002680:	aebff0ef          	jal	8000216a <bread>
    80002684:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002686:	00016997          	auipc	s3,0x16
    8000268a:	67298993          	addi	s3,s3,1650 # 80018cf8 <sb>
    8000268e:	02000613          	li	a2,32
    80002692:	05850593          	addi	a1,a0,88
    80002696:	854e                	mv	a0,s3
    80002698:	b55fd0ef          	jal	800001ec <memmove>
  brelse(bp);
    8000269c:	8526                	mv	a0,s1
    8000269e:	bd5ff0ef          	jal	80002272 <brelse>
  if(sb.magic != FSMAGIC)
    800026a2:	0009a703          	lw	a4,0(s3)
    800026a6:	102037b7          	lui	a5,0x10203
    800026aa:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800026ae:	02f71063          	bne	a4,a5,800026ce <fsinit+0x60>
  initlog(dev, &sb);
    800026b2:	00016597          	auipc	a1,0x16
    800026b6:	64658593          	addi	a1,a1,1606 # 80018cf8 <sb>
    800026ba:	854a                	mv	a0,s2
    800026bc:	1f9000ef          	jal	800030b4 <initlog>
}
    800026c0:	70a2                	ld	ra,40(sp)
    800026c2:	7402                	ld	s0,32(sp)
    800026c4:	64e2                	ld	s1,24(sp)
    800026c6:	6942                	ld	s2,16(sp)
    800026c8:	69a2                	ld	s3,8(sp)
    800026ca:	6145                	addi	sp,sp,48
    800026cc:	8082                	ret
    panic("invalid file system");
    800026ce:	00005517          	auipc	a0,0x5
    800026d2:	eba50513          	addi	a0,a0,-326 # 80007588 <etext+0x588>
    800026d6:	7cd020ef          	jal	800056a2 <panic>

00000000800026da <iinit>:
{
    800026da:	7179                	addi	sp,sp,-48
    800026dc:	f406                	sd	ra,40(sp)
    800026de:	f022                	sd	s0,32(sp)
    800026e0:	ec26                	sd	s1,24(sp)
    800026e2:	e84a                	sd	s2,16(sp)
    800026e4:	e44e                	sd	s3,8(sp)
    800026e6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800026e8:	00005597          	auipc	a1,0x5
    800026ec:	eb858593          	addi	a1,a1,-328 # 800075a0 <etext+0x5a0>
    800026f0:	00016517          	auipc	a0,0x16
    800026f4:	62850513          	addi	a0,a0,1576 # 80018d18 <itable>
    800026f8:	258030ef          	jal	80005950 <initlock>
  for(i = 0; i < NINODE; i++) {
    800026fc:	00016497          	auipc	s1,0x16
    80002700:	64448493          	addi	s1,s1,1604 # 80018d40 <itable+0x28>
    80002704:	00018997          	auipc	s3,0x18
    80002708:	0cc98993          	addi	s3,s3,204 # 8001a7d0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000270c:	00005917          	auipc	s2,0x5
    80002710:	e9c90913          	addi	s2,s2,-356 # 800075a8 <etext+0x5a8>
    80002714:	85ca                	mv	a1,s2
    80002716:	8526                	mv	a0,s1
    80002718:	475000ef          	jal	8000338c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000271c:	08848493          	addi	s1,s1,136
    80002720:	ff349ae3          	bne	s1,s3,80002714 <iinit+0x3a>
}
    80002724:	70a2                	ld	ra,40(sp)
    80002726:	7402                	ld	s0,32(sp)
    80002728:	64e2                	ld	s1,24(sp)
    8000272a:	6942                	ld	s2,16(sp)
    8000272c:	69a2                	ld	s3,8(sp)
    8000272e:	6145                	addi	sp,sp,48
    80002730:	8082                	ret

0000000080002732 <ialloc>:
{
    80002732:	7139                	addi	sp,sp,-64
    80002734:	fc06                	sd	ra,56(sp)
    80002736:	f822                	sd	s0,48(sp)
    80002738:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000273a:	00016717          	auipc	a4,0x16
    8000273e:	5ca72703          	lw	a4,1482(a4) # 80018d04 <sb+0xc>
    80002742:	4785                	li	a5,1
    80002744:	06e7f063          	bgeu	a5,a4,800027a4 <ialloc+0x72>
    80002748:	f426                	sd	s1,40(sp)
    8000274a:	f04a                	sd	s2,32(sp)
    8000274c:	ec4e                	sd	s3,24(sp)
    8000274e:	e852                	sd	s4,16(sp)
    80002750:	e456                	sd	s5,8(sp)
    80002752:	e05a                	sd	s6,0(sp)
    80002754:	8aaa                	mv	s5,a0
    80002756:	8b2e                	mv	s6,a1
    80002758:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000275a:	00016a17          	auipc	s4,0x16
    8000275e:	59ea0a13          	addi	s4,s4,1438 # 80018cf8 <sb>
    80002762:	00495593          	srli	a1,s2,0x4
    80002766:	018a2783          	lw	a5,24(s4)
    8000276a:	9dbd                	addw	a1,a1,a5
    8000276c:	8556                	mv	a0,s5
    8000276e:	9fdff0ef          	jal	8000216a <bread>
    80002772:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002774:	05850993          	addi	s3,a0,88
    80002778:	00f97793          	andi	a5,s2,15
    8000277c:	079a                	slli	a5,a5,0x6
    8000277e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002780:	00099783          	lh	a5,0(s3)
    80002784:	cb9d                	beqz	a5,800027ba <ialloc+0x88>
    brelse(bp);
    80002786:	aedff0ef          	jal	80002272 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000278a:	0905                	addi	s2,s2,1
    8000278c:	00ca2703          	lw	a4,12(s4)
    80002790:	0009079b          	sext.w	a5,s2
    80002794:	fce7e7e3          	bltu	a5,a4,80002762 <ialloc+0x30>
    80002798:	74a2                	ld	s1,40(sp)
    8000279a:	7902                	ld	s2,32(sp)
    8000279c:	69e2                	ld	s3,24(sp)
    8000279e:	6a42                	ld	s4,16(sp)
    800027a0:	6aa2                	ld	s5,8(sp)
    800027a2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800027a4:	00005517          	auipc	a0,0x5
    800027a8:	e0c50513          	addi	a0,a0,-500 # 800075b0 <etext+0x5b0>
    800027ac:	425020ef          	jal	800053d0 <printf>
  return 0;
    800027b0:	4501                	li	a0,0
}
    800027b2:	70e2                	ld	ra,56(sp)
    800027b4:	7442                	ld	s0,48(sp)
    800027b6:	6121                	addi	sp,sp,64
    800027b8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027ba:	04000613          	li	a2,64
    800027be:	4581                	li	a1,0
    800027c0:	854e                	mv	a0,s3
    800027c2:	9cffd0ef          	jal	80000190 <memset>
      dip->type = type;
    800027c6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027ca:	8526                	mv	a0,s1
    800027cc:	2f1000ef          	jal	800032bc <log_write>
      brelse(bp);
    800027d0:	8526                	mv	a0,s1
    800027d2:	aa1ff0ef          	jal	80002272 <brelse>
      return iget(dev, inum);
    800027d6:	0009059b          	sext.w	a1,s2
    800027da:	8556                	mv	a0,s5
    800027dc:	de7ff0ef          	jal	800025c2 <iget>
    800027e0:	74a2                	ld	s1,40(sp)
    800027e2:	7902                	ld	s2,32(sp)
    800027e4:	69e2                	ld	s3,24(sp)
    800027e6:	6a42                	ld	s4,16(sp)
    800027e8:	6aa2                	ld	s5,8(sp)
    800027ea:	6b02                	ld	s6,0(sp)
    800027ec:	b7d9                	j	800027b2 <ialloc+0x80>

00000000800027ee <iupdate>:
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	e04a                	sd	s2,0(sp)
    800027f8:	1000                	addi	s0,sp,32
    800027fa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800027fc:	415c                	lw	a5,4(a0)
    800027fe:	0047d79b          	srliw	a5,a5,0x4
    80002802:	00016597          	auipc	a1,0x16
    80002806:	50e5a583          	lw	a1,1294(a1) # 80018d10 <sb+0x18>
    8000280a:	9dbd                	addw	a1,a1,a5
    8000280c:	4108                	lw	a0,0(a0)
    8000280e:	95dff0ef          	jal	8000216a <bread>
    80002812:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002814:	05850793          	addi	a5,a0,88
    80002818:	40d8                	lw	a4,4(s1)
    8000281a:	8b3d                	andi	a4,a4,15
    8000281c:	071a                	slli	a4,a4,0x6
    8000281e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002820:	04449703          	lh	a4,68(s1)
    80002824:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002828:	04649703          	lh	a4,70(s1)
    8000282c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002830:	04849703          	lh	a4,72(s1)
    80002834:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002838:	04a49703          	lh	a4,74(s1)
    8000283c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002840:	44f8                	lw	a4,76(s1)
    80002842:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002844:	03400613          	li	a2,52
    80002848:	05048593          	addi	a1,s1,80
    8000284c:	00c78513          	addi	a0,a5,12
    80002850:	99dfd0ef          	jal	800001ec <memmove>
  log_write(bp);
    80002854:	854a                	mv	a0,s2
    80002856:	267000ef          	jal	800032bc <log_write>
  brelse(bp);
    8000285a:	854a                	mv	a0,s2
    8000285c:	a17ff0ef          	jal	80002272 <brelse>
}
    80002860:	60e2                	ld	ra,24(sp)
    80002862:	6442                	ld	s0,16(sp)
    80002864:	64a2                	ld	s1,8(sp)
    80002866:	6902                	ld	s2,0(sp)
    80002868:	6105                	addi	sp,sp,32
    8000286a:	8082                	ret

000000008000286c <idup>:
{
    8000286c:	1101                	addi	sp,sp,-32
    8000286e:	ec06                	sd	ra,24(sp)
    80002870:	e822                	sd	s0,16(sp)
    80002872:	e426                	sd	s1,8(sp)
    80002874:	1000                	addi	s0,sp,32
    80002876:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002878:	00016517          	auipc	a0,0x16
    8000287c:	4a050513          	addi	a0,a0,1184 # 80018d18 <itable>
    80002880:	150030ef          	jal	800059d0 <acquire>
  ip->ref++;
    80002884:	449c                	lw	a5,8(s1)
    80002886:	2785                	addiw	a5,a5,1
    80002888:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000288a:	00016517          	auipc	a0,0x16
    8000288e:	48e50513          	addi	a0,a0,1166 # 80018d18 <itable>
    80002892:	1d6030ef          	jal	80005a68 <release>
}
    80002896:	8526                	mv	a0,s1
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6105                	addi	sp,sp,32
    800028a0:	8082                	ret

00000000800028a2 <ilock>:
{
    800028a2:	1101                	addi	sp,sp,-32
    800028a4:	ec06                	sd	ra,24(sp)
    800028a6:	e822                	sd	s0,16(sp)
    800028a8:	e426                	sd	s1,8(sp)
    800028aa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028ac:	cd19                	beqz	a0,800028ca <ilock+0x28>
    800028ae:	84aa                	mv	s1,a0
    800028b0:	451c                	lw	a5,8(a0)
    800028b2:	00f05c63          	blez	a5,800028ca <ilock+0x28>
  acquiresleep(&ip->lock);
    800028b6:	0541                	addi	a0,a0,16
    800028b8:	30b000ef          	jal	800033c2 <acquiresleep>
  if(ip->valid == 0){
    800028bc:	40bc                	lw	a5,64(s1)
    800028be:	cf89                	beqz	a5,800028d8 <ilock+0x36>
}
    800028c0:	60e2                	ld	ra,24(sp)
    800028c2:	6442                	ld	s0,16(sp)
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret
    800028ca:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	cfc50513          	addi	a0,a0,-772 # 800075c8 <etext+0x5c8>
    800028d4:	5cf020ef          	jal	800056a2 <panic>
    800028d8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800028da:	40dc                	lw	a5,4(s1)
    800028dc:	0047d79b          	srliw	a5,a5,0x4
    800028e0:	00016597          	auipc	a1,0x16
    800028e4:	4305a583          	lw	a1,1072(a1) # 80018d10 <sb+0x18>
    800028e8:	9dbd                	addw	a1,a1,a5
    800028ea:	4088                	lw	a0,0(s1)
    800028ec:	87fff0ef          	jal	8000216a <bread>
    800028f0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800028f2:	05850593          	addi	a1,a0,88
    800028f6:	40dc                	lw	a5,4(s1)
    800028f8:	8bbd                	andi	a5,a5,15
    800028fa:	079a                	slli	a5,a5,0x6
    800028fc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800028fe:	00059783          	lh	a5,0(a1)
    80002902:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002906:	00259783          	lh	a5,2(a1)
    8000290a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000290e:	00459783          	lh	a5,4(a1)
    80002912:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002916:	00659783          	lh	a5,6(a1)
    8000291a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000291e:	459c                	lw	a5,8(a1)
    80002920:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002922:	03400613          	li	a2,52
    80002926:	05b1                	addi	a1,a1,12
    80002928:	05048513          	addi	a0,s1,80
    8000292c:	8c1fd0ef          	jal	800001ec <memmove>
    brelse(bp);
    80002930:	854a                	mv	a0,s2
    80002932:	941ff0ef          	jal	80002272 <brelse>
    ip->valid = 1;
    80002936:	4785                	li	a5,1
    80002938:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000293a:	04449783          	lh	a5,68(s1)
    8000293e:	c399                	beqz	a5,80002944 <ilock+0xa2>
    80002940:	6902                	ld	s2,0(sp)
    80002942:	bfbd                	j	800028c0 <ilock+0x1e>
      panic("ilock: no type");
    80002944:	00005517          	auipc	a0,0x5
    80002948:	c8c50513          	addi	a0,a0,-884 # 800075d0 <etext+0x5d0>
    8000294c:	557020ef          	jal	800056a2 <panic>

0000000080002950 <iunlock>:
{
    80002950:	1101                	addi	sp,sp,-32
    80002952:	ec06                	sd	ra,24(sp)
    80002954:	e822                	sd	s0,16(sp)
    80002956:	e426                	sd	s1,8(sp)
    80002958:	e04a                	sd	s2,0(sp)
    8000295a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000295c:	c505                	beqz	a0,80002984 <iunlock+0x34>
    8000295e:	84aa                	mv	s1,a0
    80002960:	01050913          	addi	s2,a0,16
    80002964:	854a                	mv	a0,s2
    80002966:	2db000ef          	jal	80003440 <holdingsleep>
    8000296a:	cd09                	beqz	a0,80002984 <iunlock+0x34>
    8000296c:	449c                	lw	a5,8(s1)
    8000296e:	00f05b63          	blez	a5,80002984 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002972:	854a                	mv	a0,s2
    80002974:	295000ef          	jal	80003408 <releasesleep>
}
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	64a2                	ld	s1,8(sp)
    8000297e:	6902                	ld	s2,0(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret
    panic("iunlock");
    80002984:	00005517          	auipc	a0,0x5
    80002988:	c5c50513          	addi	a0,a0,-932 # 800075e0 <etext+0x5e0>
    8000298c:	517020ef          	jal	800056a2 <panic>

0000000080002990 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002990:	7179                	addi	sp,sp,-48
    80002992:	f406                	sd	ra,40(sp)
    80002994:	f022                	sd	s0,32(sp)
    80002996:	ec26                	sd	s1,24(sp)
    80002998:	e84a                	sd	s2,16(sp)
    8000299a:	e44e                	sd	s3,8(sp)
    8000299c:	1800                	addi	s0,sp,48
    8000299e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029a0:	05050493          	addi	s1,a0,80
    800029a4:	08050913          	addi	s2,a0,128
    800029a8:	a021                	j	800029b0 <itrunc+0x20>
    800029aa:	0491                	addi	s1,s1,4
    800029ac:	01248b63          	beq	s1,s2,800029c2 <itrunc+0x32>
    if(ip->addrs[i]){
    800029b0:	408c                	lw	a1,0(s1)
    800029b2:	dde5                	beqz	a1,800029aa <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800029b4:	0009a503          	lw	a0,0(s3)
    800029b8:	9abff0ef          	jal	80002362 <bfree>
      ip->addrs[i] = 0;
    800029bc:	0004a023          	sw	zero,0(s1)
    800029c0:	b7ed                	j	800029aa <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029c2:	0809a583          	lw	a1,128(s3)
    800029c6:	ed89                	bnez	a1,800029e0 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029c8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029cc:	854e                	mv	a0,s3
    800029ce:	e21ff0ef          	jal	800027ee <iupdate>
}
    800029d2:	70a2                	ld	ra,40(sp)
    800029d4:	7402                	ld	s0,32(sp)
    800029d6:	64e2                	ld	s1,24(sp)
    800029d8:	6942                	ld	s2,16(sp)
    800029da:	69a2                	ld	s3,8(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret
    800029e0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800029e2:	0009a503          	lw	a0,0(s3)
    800029e6:	f84ff0ef          	jal	8000216a <bread>
    800029ea:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800029ec:	05850493          	addi	s1,a0,88
    800029f0:	45850913          	addi	s2,a0,1112
    800029f4:	a021                	j	800029fc <itrunc+0x6c>
    800029f6:	0491                	addi	s1,s1,4
    800029f8:	01248963          	beq	s1,s2,80002a0a <itrunc+0x7a>
      if(a[j])
    800029fc:	408c                	lw	a1,0(s1)
    800029fe:	dde5                	beqz	a1,800029f6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002a00:	0009a503          	lw	a0,0(s3)
    80002a04:	95fff0ef          	jal	80002362 <bfree>
    80002a08:	b7fd                	j	800029f6 <itrunc+0x66>
    brelse(bp);
    80002a0a:	8552                	mv	a0,s4
    80002a0c:	867ff0ef          	jal	80002272 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a10:	0809a583          	lw	a1,128(s3)
    80002a14:	0009a503          	lw	a0,0(s3)
    80002a18:	94bff0ef          	jal	80002362 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a1c:	0809a023          	sw	zero,128(s3)
    80002a20:	6a02                	ld	s4,0(sp)
    80002a22:	b75d                	j	800029c8 <itrunc+0x38>

0000000080002a24 <iput>:
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	e426                	sd	s1,8(sp)
    80002a2c:	1000                	addi	s0,sp,32
    80002a2e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a30:	00016517          	auipc	a0,0x16
    80002a34:	2e850513          	addi	a0,a0,744 # 80018d18 <itable>
    80002a38:	799020ef          	jal	800059d0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a3c:	4498                	lw	a4,8(s1)
    80002a3e:	4785                	li	a5,1
    80002a40:	02f70063          	beq	a4,a5,80002a60 <iput+0x3c>
  ip->ref--;
    80002a44:	449c                	lw	a5,8(s1)
    80002a46:	37fd                	addiw	a5,a5,-1
    80002a48:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a4a:	00016517          	auipc	a0,0x16
    80002a4e:	2ce50513          	addi	a0,a0,718 # 80018d18 <itable>
    80002a52:	016030ef          	jal	80005a68 <release>
}
    80002a56:	60e2                	ld	ra,24(sp)
    80002a58:	6442                	ld	s0,16(sp)
    80002a5a:	64a2                	ld	s1,8(sp)
    80002a5c:	6105                	addi	sp,sp,32
    80002a5e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a60:	40bc                	lw	a5,64(s1)
    80002a62:	d3ed                	beqz	a5,80002a44 <iput+0x20>
    80002a64:	04a49783          	lh	a5,74(s1)
    80002a68:	fff1                	bnez	a5,80002a44 <iput+0x20>
    80002a6a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002a6c:	01048913          	addi	s2,s1,16
    80002a70:	854a                	mv	a0,s2
    80002a72:	151000ef          	jal	800033c2 <acquiresleep>
    release(&itable.lock);
    80002a76:	00016517          	auipc	a0,0x16
    80002a7a:	2a250513          	addi	a0,a0,674 # 80018d18 <itable>
    80002a7e:	7eb020ef          	jal	80005a68 <release>
    itrunc(ip);
    80002a82:	8526                	mv	a0,s1
    80002a84:	f0dff0ef          	jal	80002990 <itrunc>
    ip->type = 0;
    80002a88:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	d61ff0ef          	jal	800027ee <iupdate>
    ip->valid = 0;
    80002a92:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002a96:	854a                	mv	a0,s2
    80002a98:	171000ef          	jal	80003408 <releasesleep>
    acquire(&itable.lock);
    80002a9c:	00016517          	auipc	a0,0x16
    80002aa0:	27c50513          	addi	a0,a0,636 # 80018d18 <itable>
    80002aa4:	72d020ef          	jal	800059d0 <acquire>
    80002aa8:	6902                	ld	s2,0(sp)
    80002aaa:	bf69                	j	80002a44 <iput+0x20>

0000000080002aac <iunlockput>:
{
    80002aac:	1101                	addi	sp,sp,-32
    80002aae:	ec06                	sd	ra,24(sp)
    80002ab0:	e822                	sd	s0,16(sp)
    80002ab2:	e426                	sd	s1,8(sp)
    80002ab4:	1000                	addi	s0,sp,32
    80002ab6:	84aa                	mv	s1,a0
  iunlock(ip);
    80002ab8:	e99ff0ef          	jal	80002950 <iunlock>
  iput(ip);
    80002abc:	8526                	mv	a0,s1
    80002abe:	f67ff0ef          	jal	80002a24 <iput>
}
    80002ac2:	60e2                	ld	ra,24(sp)
    80002ac4:	6442                	ld	s0,16(sp)
    80002ac6:	64a2                	ld	s1,8(sp)
    80002ac8:	6105                	addi	sp,sp,32
    80002aca:	8082                	ret

0000000080002acc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002acc:	1141                	addi	sp,sp,-16
    80002ace:	e422                	sd	s0,8(sp)
    80002ad0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002ad2:	411c                	lw	a5,0(a0)
    80002ad4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002ad6:	415c                	lw	a5,4(a0)
    80002ad8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002ada:	04451783          	lh	a5,68(a0)
    80002ade:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ae2:	04a51783          	lh	a5,74(a0)
    80002ae6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002aea:	04c56783          	lwu	a5,76(a0)
    80002aee:	e99c                	sd	a5,16(a1)
}
    80002af0:	6422                	ld	s0,8(sp)
    80002af2:	0141                	addi	sp,sp,16
    80002af4:	8082                	ret

0000000080002af6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002af6:	457c                	lw	a5,76(a0)
    80002af8:	0ed7eb63          	bltu	a5,a3,80002bee <readi+0xf8>
{
    80002afc:	7159                	addi	sp,sp,-112
    80002afe:	f486                	sd	ra,104(sp)
    80002b00:	f0a2                	sd	s0,96(sp)
    80002b02:	eca6                	sd	s1,88(sp)
    80002b04:	e0d2                	sd	s4,64(sp)
    80002b06:	fc56                	sd	s5,56(sp)
    80002b08:	f85a                	sd	s6,48(sp)
    80002b0a:	f45e                	sd	s7,40(sp)
    80002b0c:	1880                	addi	s0,sp,112
    80002b0e:	8b2a                	mv	s6,a0
    80002b10:	8bae                	mv	s7,a1
    80002b12:	8a32                	mv	s4,a2
    80002b14:	84b6                	mv	s1,a3
    80002b16:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002b18:	9f35                	addw	a4,a4,a3
    return 0;
    80002b1a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002b1c:	0cd76063          	bltu	a4,a3,80002bdc <readi+0xe6>
    80002b20:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002b22:	00e7f463          	bgeu	a5,a4,80002b2a <readi+0x34>
    n = ip->size - off;
    80002b26:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b2a:	080a8f63          	beqz	s5,80002bc8 <readi+0xd2>
    80002b2e:	e8ca                	sd	s2,80(sp)
    80002b30:	f062                	sd	s8,32(sp)
    80002b32:	ec66                	sd	s9,24(sp)
    80002b34:	e86a                	sd	s10,16(sp)
    80002b36:	e46e                	sd	s11,8(sp)
    80002b38:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b3a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002b3e:	5c7d                	li	s8,-1
    80002b40:	a80d                	j	80002b72 <readi+0x7c>
    80002b42:	020d1d93          	slli	s11,s10,0x20
    80002b46:	020ddd93          	srli	s11,s11,0x20
    80002b4a:	05890613          	addi	a2,s2,88
    80002b4e:	86ee                	mv	a3,s11
    80002b50:	963a                	add	a2,a2,a4
    80002b52:	85d2                	mv	a1,s4
    80002b54:	855e                	mv	a0,s7
    80002b56:	c5dfe0ef          	jal	800017b2 <either_copyout>
    80002b5a:	05850763          	beq	a0,s8,80002ba8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002b5e:	854a                	mv	a0,s2
    80002b60:	f12ff0ef          	jal	80002272 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b64:	013d09bb          	addw	s3,s10,s3
    80002b68:	009d04bb          	addw	s1,s10,s1
    80002b6c:	9a6e                	add	s4,s4,s11
    80002b6e:	0559f763          	bgeu	s3,s5,80002bbc <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002b72:	00a4d59b          	srliw	a1,s1,0xa
    80002b76:	855a                	mv	a0,s6
    80002b78:	977ff0ef          	jal	800024ee <bmap>
    80002b7c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002b80:	c5b1                	beqz	a1,80002bcc <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002b82:	000b2503          	lw	a0,0(s6)
    80002b86:	de4ff0ef          	jal	8000216a <bread>
    80002b8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b8c:	3ff4f713          	andi	a4,s1,1023
    80002b90:	40ec87bb          	subw	a5,s9,a4
    80002b94:	413a86bb          	subw	a3,s5,s3
    80002b98:	8d3e                	mv	s10,a5
    80002b9a:	2781                	sext.w	a5,a5
    80002b9c:	0006861b          	sext.w	a2,a3
    80002ba0:	faf671e3          	bgeu	a2,a5,80002b42 <readi+0x4c>
    80002ba4:	8d36                	mv	s10,a3
    80002ba6:	bf71                	j	80002b42 <readi+0x4c>
      brelse(bp);
    80002ba8:	854a                	mv	a0,s2
    80002baa:	ec8ff0ef          	jal	80002272 <brelse>
      tot = -1;
    80002bae:	59fd                	li	s3,-1
      break;
    80002bb0:	6946                	ld	s2,80(sp)
    80002bb2:	7c02                	ld	s8,32(sp)
    80002bb4:	6ce2                	ld	s9,24(sp)
    80002bb6:	6d42                	ld	s10,16(sp)
    80002bb8:	6da2                	ld	s11,8(sp)
    80002bba:	a831                	j	80002bd6 <readi+0xe0>
    80002bbc:	6946                	ld	s2,80(sp)
    80002bbe:	7c02                	ld	s8,32(sp)
    80002bc0:	6ce2                	ld	s9,24(sp)
    80002bc2:	6d42                	ld	s10,16(sp)
    80002bc4:	6da2                	ld	s11,8(sp)
    80002bc6:	a801                	j	80002bd6 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002bc8:	89d6                	mv	s3,s5
    80002bca:	a031                	j	80002bd6 <readi+0xe0>
    80002bcc:	6946                	ld	s2,80(sp)
    80002bce:	7c02                	ld	s8,32(sp)
    80002bd0:	6ce2                	ld	s9,24(sp)
    80002bd2:	6d42                	ld	s10,16(sp)
    80002bd4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002bd6:	0009851b          	sext.w	a0,s3
    80002bda:	69a6                	ld	s3,72(sp)
}
    80002bdc:	70a6                	ld	ra,104(sp)
    80002bde:	7406                	ld	s0,96(sp)
    80002be0:	64e6                	ld	s1,88(sp)
    80002be2:	6a06                	ld	s4,64(sp)
    80002be4:	7ae2                	ld	s5,56(sp)
    80002be6:	7b42                	ld	s6,48(sp)
    80002be8:	7ba2                	ld	s7,40(sp)
    80002bea:	6165                	addi	sp,sp,112
    80002bec:	8082                	ret
    return 0;
    80002bee:	4501                	li	a0,0
}
    80002bf0:	8082                	ret

0000000080002bf2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002bf2:	457c                	lw	a5,76(a0)
    80002bf4:	10d7e063          	bltu	a5,a3,80002cf4 <writei+0x102>
{
    80002bf8:	7159                	addi	sp,sp,-112
    80002bfa:	f486                	sd	ra,104(sp)
    80002bfc:	f0a2                	sd	s0,96(sp)
    80002bfe:	e8ca                	sd	s2,80(sp)
    80002c00:	e0d2                	sd	s4,64(sp)
    80002c02:	fc56                	sd	s5,56(sp)
    80002c04:	f85a                	sd	s6,48(sp)
    80002c06:	f45e                	sd	s7,40(sp)
    80002c08:	1880                	addi	s0,sp,112
    80002c0a:	8aaa                	mv	s5,a0
    80002c0c:	8bae                	mv	s7,a1
    80002c0e:	8a32                	mv	s4,a2
    80002c10:	8936                	mv	s2,a3
    80002c12:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002c14:	00e687bb          	addw	a5,a3,a4
    80002c18:	0ed7e063          	bltu	a5,a3,80002cf8 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002c1c:	00043737          	lui	a4,0x43
    80002c20:	0cf76e63          	bltu	a4,a5,80002cfc <writei+0x10a>
    80002c24:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c26:	0a0b0f63          	beqz	s6,80002ce4 <writei+0xf2>
    80002c2a:	eca6                	sd	s1,88(sp)
    80002c2c:	f062                	sd	s8,32(sp)
    80002c2e:	ec66                	sd	s9,24(sp)
    80002c30:	e86a                	sd	s10,16(sp)
    80002c32:	e46e                	sd	s11,8(sp)
    80002c34:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c36:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002c3a:	5c7d                	li	s8,-1
    80002c3c:	a825                	j	80002c74 <writei+0x82>
    80002c3e:	020d1d93          	slli	s11,s10,0x20
    80002c42:	020ddd93          	srli	s11,s11,0x20
    80002c46:	05848513          	addi	a0,s1,88
    80002c4a:	86ee                	mv	a3,s11
    80002c4c:	8652                	mv	a2,s4
    80002c4e:	85de                	mv	a1,s7
    80002c50:	953a                	add	a0,a0,a4
    80002c52:	babfe0ef          	jal	800017fc <either_copyin>
    80002c56:	05850a63          	beq	a0,s8,80002caa <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002c5a:	8526                	mv	a0,s1
    80002c5c:	660000ef          	jal	800032bc <log_write>
    brelse(bp);
    80002c60:	8526                	mv	a0,s1
    80002c62:	e10ff0ef          	jal	80002272 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c66:	013d09bb          	addw	s3,s10,s3
    80002c6a:	012d093b          	addw	s2,s10,s2
    80002c6e:	9a6e                	add	s4,s4,s11
    80002c70:	0569f063          	bgeu	s3,s6,80002cb0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002c74:	00a9559b          	srliw	a1,s2,0xa
    80002c78:	8556                	mv	a0,s5
    80002c7a:	875ff0ef          	jal	800024ee <bmap>
    80002c7e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002c82:	c59d                	beqz	a1,80002cb0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002c84:	000aa503          	lw	a0,0(s5)
    80002c88:	ce2ff0ef          	jal	8000216a <bread>
    80002c8c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c8e:	3ff97713          	andi	a4,s2,1023
    80002c92:	40ec87bb          	subw	a5,s9,a4
    80002c96:	413b06bb          	subw	a3,s6,s3
    80002c9a:	8d3e                	mv	s10,a5
    80002c9c:	2781                	sext.w	a5,a5
    80002c9e:	0006861b          	sext.w	a2,a3
    80002ca2:	f8f67ee3          	bgeu	a2,a5,80002c3e <writei+0x4c>
    80002ca6:	8d36                	mv	s10,a3
    80002ca8:	bf59                	j	80002c3e <writei+0x4c>
      brelse(bp);
    80002caa:	8526                	mv	a0,s1
    80002cac:	dc6ff0ef          	jal	80002272 <brelse>
  }

  if(off > ip->size)
    80002cb0:	04caa783          	lw	a5,76(s5)
    80002cb4:	0327fa63          	bgeu	a5,s2,80002ce8 <writei+0xf6>
    ip->size = off;
    80002cb8:	052aa623          	sw	s2,76(s5)
    80002cbc:	64e6                	ld	s1,88(sp)
    80002cbe:	7c02                	ld	s8,32(sp)
    80002cc0:	6ce2                	ld	s9,24(sp)
    80002cc2:	6d42                	ld	s10,16(sp)
    80002cc4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002cc6:	8556                	mv	a0,s5
    80002cc8:	b27ff0ef          	jal	800027ee <iupdate>

  return tot;
    80002ccc:	0009851b          	sext.w	a0,s3
    80002cd0:	69a6                	ld	s3,72(sp)
}
    80002cd2:	70a6                	ld	ra,104(sp)
    80002cd4:	7406                	ld	s0,96(sp)
    80002cd6:	6946                	ld	s2,80(sp)
    80002cd8:	6a06                	ld	s4,64(sp)
    80002cda:	7ae2                	ld	s5,56(sp)
    80002cdc:	7b42                	ld	s6,48(sp)
    80002cde:	7ba2                	ld	s7,40(sp)
    80002ce0:	6165                	addi	sp,sp,112
    80002ce2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ce4:	89da                	mv	s3,s6
    80002ce6:	b7c5                	j	80002cc6 <writei+0xd4>
    80002ce8:	64e6                	ld	s1,88(sp)
    80002cea:	7c02                	ld	s8,32(sp)
    80002cec:	6ce2                	ld	s9,24(sp)
    80002cee:	6d42                	ld	s10,16(sp)
    80002cf0:	6da2                	ld	s11,8(sp)
    80002cf2:	bfd1                	j	80002cc6 <writei+0xd4>
    return -1;
    80002cf4:	557d                	li	a0,-1
}
    80002cf6:	8082                	ret
    return -1;
    80002cf8:	557d                	li	a0,-1
    80002cfa:	bfe1                	j	80002cd2 <writei+0xe0>
    return -1;
    80002cfc:	557d                	li	a0,-1
    80002cfe:	bfd1                	j	80002cd2 <writei+0xe0>

0000000080002d00 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002d00:	1141                	addi	sp,sp,-16
    80002d02:	e406                	sd	ra,8(sp)
    80002d04:	e022                	sd	s0,0(sp)
    80002d06:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002d08:	4639                	li	a2,14
    80002d0a:	d52fd0ef          	jal	8000025c <strncmp>
}
    80002d0e:	60a2                	ld	ra,8(sp)
    80002d10:	6402                	ld	s0,0(sp)
    80002d12:	0141                	addi	sp,sp,16
    80002d14:	8082                	ret

0000000080002d16 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002d16:	7139                	addi	sp,sp,-64
    80002d18:	fc06                	sd	ra,56(sp)
    80002d1a:	f822                	sd	s0,48(sp)
    80002d1c:	f426                	sd	s1,40(sp)
    80002d1e:	f04a                	sd	s2,32(sp)
    80002d20:	ec4e                	sd	s3,24(sp)
    80002d22:	e852                	sd	s4,16(sp)
    80002d24:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002d26:	04451703          	lh	a4,68(a0)
    80002d2a:	4785                	li	a5,1
    80002d2c:	00f71a63          	bne	a4,a5,80002d40 <dirlookup+0x2a>
    80002d30:	892a                	mv	s2,a0
    80002d32:	89ae                	mv	s3,a1
    80002d34:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d36:	457c                	lw	a5,76(a0)
    80002d38:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002d3a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d3c:	e39d                	bnez	a5,80002d62 <dirlookup+0x4c>
    80002d3e:	a095                	j	80002da2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	8a850513          	addi	a0,a0,-1880 # 800075e8 <etext+0x5e8>
    80002d48:	15b020ef          	jal	800056a2 <panic>
      panic("dirlookup read");
    80002d4c:	00005517          	auipc	a0,0x5
    80002d50:	8b450513          	addi	a0,a0,-1868 # 80007600 <etext+0x600>
    80002d54:	14f020ef          	jal	800056a2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d58:	24c1                	addiw	s1,s1,16
    80002d5a:	04c92783          	lw	a5,76(s2)
    80002d5e:	04f4f163          	bgeu	s1,a5,80002da0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d62:	4741                	li	a4,16
    80002d64:	86a6                	mv	a3,s1
    80002d66:	fc040613          	addi	a2,s0,-64
    80002d6a:	4581                	li	a1,0
    80002d6c:	854a                	mv	a0,s2
    80002d6e:	d89ff0ef          	jal	80002af6 <readi>
    80002d72:	47c1                	li	a5,16
    80002d74:	fcf51ce3          	bne	a0,a5,80002d4c <dirlookup+0x36>
    if(de.inum == 0)
    80002d78:	fc045783          	lhu	a5,-64(s0)
    80002d7c:	dff1                	beqz	a5,80002d58 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002d7e:	fc240593          	addi	a1,s0,-62
    80002d82:	854e                	mv	a0,s3
    80002d84:	f7dff0ef          	jal	80002d00 <namecmp>
    80002d88:	f961                	bnez	a0,80002d58 <dirlookup+0x42>
      if(poff)
    80002d8a:	000a0463          	beqz	s4,80002d92 <dirlookup+0x7c>
        *poff = off;
    80002d8e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002d92:	fc045583          	lhu	a1,-64(s0)
    80002d96:	00092503          	lw	a0,0(s2)
    80002d9a:	829ff0ef          	jal	800025c2 <iget>
    80002d9e:	a011                	j	80002da2 <dirlookup+0x8c>
  return 0;
    80002da0:	4501                	li	a0,0
}
    80002da2:	70e2                	ld	ra,56(sp)
    80002da4:	7442                	ld	s0,48(sp)
    80002da6:	74a2                	ld	s1,40(sp)
    80002da8:	7902                	ld	s2,32(sp)
    80002daa:	69e2                	ld	s3,24(sp)
    80002dac:	6a42                	ld	s4,16(sp)
    80002dae:	6121                	addi	sp,sp,64
    80002db0:	8082                	ret

0000000080002db2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002db2:	711d                	addi	sp,sp,-96
    80002db4:	ec86                	sd	ra,88(sp)
    80002db6:	e8a2                	sd	s0,80(sp)
    80002db8:	e4a6                	sd	s1,72(sp)
    80002dba:	e0ca                	sd	s2,64(sp)
    80002dbc:	fc4e                	sd	s3,56(sp)
    80002dbe:	f852                	sd	s4,48(sp)
    80002dc0:	f456                	sd	s5,40(sp)
    80002dc2:	f05a                	sd	s6,32(sp)
    80002dc4:	ec5e                	sd	s7,24(sp)
    80002dc6:	e862                	sd	s8,16(sp)
    80002dc8:	e466                	sd	s9,8(sp)
    80002dca:	1080                	addi	s0,sp,96
    80002dcc:	84aa                	mv	s1,a0
    80002dce:	8b2e                	mv	s6,a1
    80002dd0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002dd2:	00054703          	lbu	a4,0(a0)
    80002dd6:	02f00793          	li	a5,47
    80002dda:	00f70e63          	beq	a4,a5,80002df6 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002dde:	8a2fe0ef          	jal	80000e80 <myproc>
    80002de2:	15053503          	ld	a0,336(a0)
    80002de6:	a87ff0ef          	jal	8000286c <idup>
    80002dea:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002dec:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002df0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002df2:	4b85                	li	s7,1
    80002df4:	a871                	j	80002e90 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002df6:	4585                	li	a1,1
    80002df8:	4505                	li	a0,1
    80002dfa:	fc8ff0ef          	jal	800025c2 <iget>
    80002dfe:	8a2a                	mv	s4,a0
    80002e00:	b7f5                	j	80002dec <namex+0x3a>
      iunlockput(ip);
    80002e02:	8552                	mv	a0,s4
    80002e04:	ca9ff0ef          	jal	80002aac <iunlockput>
      return 0;
    80002e08:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002e0a:	8552                	mv	a0,s4
    80002e0c:	60e6                	ld	ra,88(sp)
    80002e0e:	6446                	ld	s0,80(sp)
    80002e10:	64a6                	ld	s1,72(sp)
    80002e12:	6906                	ld	s2,64(sp)
    80002e14:	79e2                	ld	s3,56(sp)
    80002e16:	7a42                	ld	s4,48(sp)
    80002e18:	7aa2                	ld	s5,40(sp)
    80002e1a:	7b02                	ld	s6,32(sp)
    80002e1c:	6be2                	ld	s7,24(sp)
    80002e1e:	6c42                	ld	s8,16(sp)
    80002e20:	6ca2                	ld	s9,8(sp)
    80002e22:	6125                	addi	sp,sp,96
    80002e24:	8082                	ret
      iunlock(ip);
    80002e26:	8552                	mv	a0,s4
    80002e28:	b29ff0ef          	jal	80002950 <iunlock>
      return ip;
    80002e2c:	bff9                	j	80002e0a <namex+0x58>
      iunlockput(ip);
    80002e2e:	8552                	mv	a0,s4
    80002e30:	c7dff0ef          	jal	80002aac <iunlockput>
      return 0;
    80002e34:	8a4e                	mv	s4,s3
    80002e36:	bfd1                	j	80002e0a <namex+0x58>
  len = path - s;
    80002e38:	40998633          	sub	a2,s3,s1
    80002e3c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002e40:	099c5063          	bge	s8,s9,80002ec0 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002e44:	4639                	li	a2,14
    80002e46:	85a6                	mv	a1,s1
    80002e48:	8556                	mv	a0,s5
    80002e4a:	ba2fd0ef          	jal	800001ec <memmove>
    80002e4e:	84ce                	mv	s1,s3
  while(*path == '/')
    80002e50:	0004c783          	lbu	a5,0(s1)
    80002e54:	01279763          	bne	a5,s2,80002e62 <namex+0xb0>
    path++;
    80002e58:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e5a:	0004c783          	lbu	a5,0(s1)
    80002e5e:	ff278de3          	beq	a5,s2,80002e58 <namex+0xa6>
    ilock(ip);
    80002e62:	8552                	mv	a0,s4
    80002e64:	a3fff0ef          	jal	800028a2 <ilock>
    if(ip->type != T_DIR){
    80002e68:	044a1783          	lh	a5,68(s4)
    80002e6c:	f9779be3          	bne	a5,s7,80002e02 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002e70:	000b0563          	beqz	s6,80002e7a <namex+0xc8>
    80002e74:	0004c783          	lbu	a5,0(s1)
    80002e78:	d7dd                	beqz	a5,80002e26 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002e7a:	4601                	li	a2,0
    80002e7c:	85d6                	mv	a1,s5
    80002e7e:	8552                	mv	a0,s4
    80002e80:	e97ff0ef          	jal	80002d16 <dirlookup>
    80002e84:	89aa                	mv	s3,a0
    80002e86:	d545                	beqz	a0,80002e2e <namex+0x7c>
    iunlockput(ip);
    80002e88:	8552                	mv	a0,s4
    80002e8a:	c23ff0ef          	jal	80002aac <iunlockput>
    ip = next;
    80002e8e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002e90:	0004c783          	lbu	a5,0(s1)
    80002e94:	01279763          	bne	a5,s2,80002ea2 <namex+0xf0>
    path++;
    80002e98:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e9a:	0004c783          	lbu	a5,0(s1)
    80002e9e:	ff278de3          	beq	a5,s2,80002e98 <namex+0xe6>
  if(*path == 0)
    80002ea2:	cb8d                	beqz	a5,80002ed4 <namex+0x122>
  while(*path != '/' && *path != 0)
    80002ea4:	0004c783          	lbu	a5,0(s1)
    80002ea8:	89a6                	mv	s3,s1
  len = path - s;
    80002eaa:	4c81                	li	s9,0
    80002eac:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002eae:	01278963          	beq	a5,s2,80002ec0 <namex+0x10e>
    80002eb2:	d3d9                	beqz	a5,80002e38 <namex+0x86>
    path++;
    80002eb4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002eb6:	0009c783          	lbu	a5,0(s3)
    80002eba:	ff279ce3          	bne	a5,s2,80002eb2 <namex+0x100>
    80002ebe:	bfad                	j	80002e38 <namex+0x86>
    memmove(name, s, len);
    80002ec0:	2601                	sext.w	a2,a2
    80002ec2:	85a6                	mv	a1,s1
    80002ec4:	8556                	mv	a0,s5
    80002ec6:	b26fd0ef          	jal	800001ec <memmove>
    name[len] = 0;
    80002eca:	9cd6                	add	s9,s9,s5
    80002ecc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002ed0:	84ce                	mv	s1,s3
    80002ed2:	bfbd                	j	80002e50 <namex+0x9e>
  if(nameiparent){
    80002ed4:	f20b0be3          	beqz	s6,80002e0a <namex+0x58>
    iput(ip);
    80002ed8:	8552                	mv	a0,s4
    80002eda:	b4bff0ef          	jal	80002a24 <iput>
    return 0;
    80002ede:	4a01                	li	s4,0
    80002ee0:	b72d                	j	80002e0a <namex+0x58>

0000000080002ee2 <dirlink>:
{
    80002ee2:	7139                	addi	sp,sp,-64
    80002ee4:	fc06                	sd	ra,56(sp)
    80002ee6:	f822                	sd	s0,48(sp)
    80002ee8:	f04a                	sd	s2,32(sp)
    80002eea:	ec4e                	sd	s3,24(sp)
    80002eec:	e852                	sd	s4,16(sp)
    80002eee:	0080                	addi	s0,sp,64
    80002ef0:	892a                	mv	s2,a0
    80002ef2:	8a2e                	mv	s4,a1
    80002ef4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002ef6:	4601                	li	a2,0
    80002ef8:	e1fff0ef          	jal	80002d16 <dirlookup>
    80002efc:	e535                	bnez	a0,80002f68 <dirlink+0x86>
    80002efe:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f00:	04c92483          	lw	s1,76(s2)
    80002f04:	c48d                	beqz	s1,80002f2e <dirlink+0x4c>
    80002f06:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f08:	4741                	li	a4,16
    80002f0a:	86a6                	mv	a3,s1
    80002f0c:	fc040613          	addi	a2,s0,-64
    80002f10:	4581                	li	a1,0
    80002f12:	854a                	mv	a0,s2
    80002f14:	be3ff0ef          	jal	80002af6 <readi>
    80002f18:	47c1                	li	a5,16
    80002f1a:	04f51b63          	bne	a0,a5,80002f70 <dirlink+0x8e>
    if(de.inum == 0)
    80002f1e:	fc045783          	lhu	a5,-64(s0)
    80002f22:	c791                	beqz	a5,80002f2e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f24:	24c1                	addiw	s1,s1,16
    80002f26:	04c92783          	lw	a5,76(s2)
    80002f2a:	fcf4efe3          	bltu	s1,a5,80002f08 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002f2e:	4639                	li	a2,14
    80002f30:	85d2                	mv	a1,s4
    80002f32:	fc240513          	addi	a0,s0,-62
    80002f36:	b5cfd0ef          	jal	80000292 <strncpy>
  de.inum = inum;
    80002f3a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f3e:	4741                	li	a4,16
    80002f40:	86a6                	mv	a3,s1
    80002f42:	fc040613          	addi	a2,s0,-64
    80002f46:	4581                	li	a1,0
    80002f48:	854a                	mv	a0,s2
    80002f4a:	ca9ff0ef          	jal	80002bf2 <writei>
    80002f4e:	1541                	addi	a0,a0,-16
    80002f50:	00a03533          	snez	a0,a0
    80002f54:	40a00533          	neg	a0,a0
    80002f58:	74a2                	ld	s1,40(sp)
}
    80002f5a:	70e2                	ld	ra,56(sp)
    80002f5c:	7442                	ld	s0,48(sp)
    80002f5e:	7902                	ld	s2,32(sp)
    80002f60:	69e2                	ld	s3,24(sp)
    80002f62:	6a42                	ld	s4,16(sp)
    80002f64:	6121                	addi	sp,sp,64
    80002f66:	8082                	ret
    iput(ip);
    80002f68:	abdff0ef          	jal	80002a24 <iput>
    return -1;
    80002f6c:	557d                	li	a0,-1
    80002f6e:	b7f5                	j	80002f5a <dirlink+0x78>
      panic("dirlink read");
    80002f70:	00004517          	auipc	a0,0x4
    80002f74:	6a050513          	addi	a0,a0,1696 # 80007610 <etext+0x610>
    80002f78:	72a020ef          	jal	800056a2 <panic>

0000000080002f7c <namei>:

struct inode*
namei(char *path)
{
    80002f7c:	1101                	addi	sp,sp,-32
    80002f7e:	ec06                	sd	ra,24(sp)
    80002f80:	e822                	sd	s0,16(sp)
    80002f82:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002f84:	fe040613          	addi	a2,s0,-32
    80002f88:	4581                	li	a1,0
    80002f8a:	e29ff0ef          	jal	80002db2 <namex>
}
    80002f8e:	60e2                	ld	ra,24(sp)
    80002f90:	6442                	ld	s0,16(sp)
    80002f92:	6105                	addi	sp,sp,32
    80002f94:	8082                	ret

0000000080002f96 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002f96:	1141                	addi	sp,sp,-16
    80002f98:	e406                	sd	ra,8(sp)
    80002f9a:	e022                	sd	s0,0(sp)
    80002f9c:	0800                	addi	s0,sp,16
    80002f9e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002fa0:	4585                	li	a1,1
    80002fa2:	e11ff0ef          	jal	80002db2 <namex>
}
    80002fa6:	60a2                	ld	ra,8(sp)
    80002fa8:	6402                	ld	s0,0(sp)
    80002faa:	0141                	addi	sp,sp,16
    80002fac:	8082                	ret

0000000080002fae <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002fae:	1101                	addi	sp,sp,-32
    80002fb0:	ec06                	sd	ra,24(sp)
    80002fb2:	e822                	sd	s0,16(sp)
    80002fb4:	e426                	sd	s1,8(sp)
    80002fb6:	e04a                	sd	s2,0(sp)
    80002fb8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002fba:	00018917          	auipc	s2,0x18
    80002fbe:	80690913          	addi	s2,s2,-2042 # 8001a7c0 <log>
    80002fc2:	01892583          	lw	a1,24(s2)
    80002fc6:	02892503          	lw	a0,40(s2)
    80002fca:	9a0ff0ef          	jal	8000216a <bread>
    80002fce:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002fd0:	02c92603          	lw	a2,44(s2)
    80002fd4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002fd6:	00c05f63          	blez	a2,80002ff4 <write_head+0x46>
    80002fda:	00018717          	auipc	a4,0x18
    80002fde:	81670713          	addi	a4,a4,-2026 # 8001a7f0 <log+0x30>
    80002fe2:	87aa                	mv	a5,a0
    80002fe4:	060a                	slli	a2,a2,0x2
    80002fe6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002fe8:	4314                	lw	a3,0(a4)
    80002fea:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002fec:	0711                	addi	a4,a4,4
    80002fee:	0791                	addi	a5,a5,4
    80002ff0:	fec79ce3          	bne	a5,a2,80002fe8 <write_head+0x3a>
  }
  bwrite(buf);
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	a4aff0ef          	jal	80002240 <bwrite>
  brelse(buf);
    80002ffa:	8526                	mv	a0,s1
    80002ffc:	a76ff0ef          	jal	80002272 <brelse>
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6902                	ld	s2,0(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000300c:	00017797          	auipc	a5,0x17
    80003010:	7e07a783          	lw	a5,2016(a5) # 8001a7ec <log+0x2c>
    80003014:	08f05f63          	blez	a5,800030b2 <install_trans+0xa6>
{
    80003018:	7139                	addi	sp,sp,-64
    8000301a:	fc06                	sd	ra,56(sp)
    8000301c:	f822                	sd	s0,48(sp)
    8000301e:	f426                	sd	s1,40(sp)
    80003020:	f04a                	sd	s2,32(sp)
    80003022:	ec4e                	sd	s3,24(sp)
    80003024:	e852                	sd	s4,16(sp)
    80003026:	e456                	sd	s5,8(sp)
    80003028:	e05a                	sd	s6,0(sp)
    8000302a:	0080                	addi	s0,sp,64
    8000302c:	8b2a                	mv	s6,a0
    8000302e:	00017a97          	auipc	s5,0x17
    80003032:	7c2a8a93          	addi	s5,s5,1986 # 8001a7f0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003036:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003038:	00017997          	auipc	s3,0x17
    8000303c:	78898993          	addi	s3,s3,1928 # 8001a7c0 <log>
    80003040:	a829                	j	8000305a <install_trans+0x4e>
    brelse(lbuf);
    80003042:	854a                	mv	a0,s2
    80003044:	a2eff0ef          	jal	80002272 <brelse>
    brelse(dbuf);
    80003048:	8526                	mv	a0,s1
    8000304a:	a28ff0ef          	jal	80002272 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000304e:	2a05                	addiw	s4,s4,1
    80003050:	0a91                	addi	s5,s5,4
    80003052:	02c9a783          	lw	a5,44(s3)
    80003056:	04fa5463          	bge	s4,a5,8000309e <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000305a:	0189a583          	lw	a1,24(s3)
    8000305e:	014585bb          	addw	a1,a1,s4
    80003062:	2585                	addiw	a1,a1,1
    80003064:	0289a503          	lw	a0,40(s3)
    80003068:	902ff0ef          	jal	8000216a <bread>
    8000306c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000306e:	000aa583          	lw	a1,0(s5)
    80003072:	0289a503          	lw	a0,40(s3)
    80003076:	8f4ff0ef          	jal	8000216a <bread>
    8000307a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000307c:	40000613          	li	a2,1024
    80003080:	05890593          	addi	a1,s2,88
    80003084:	05850513          	addi	a0,a0,88
    80003088:	964fd0ef          	jal	800001ec <memmove>
    bwrite(dbuf);  // write dst to disk
    8000308c:	8526                	mv	a0,s1
    8000308e:	9b2ff0ef          	jal	80002240 <bwrite>
    if(recovering == 0)
    80003092:	fa0b18e3          	bnez	s6,80003042 <install_trans+0x36>
      bunpin(dbuf);
    80003096:	8526                	mv	a0,s1
    80003098:	a96ff0ef          	jal	8000232e <bunpin>
    8000309c:	b75d                	j	80003042 <install_trans+0x36>
}
    8000309e:	70e2                	ld	ra,56(sp)
    800030a0:	7442                	ld	s0,48(sp)
    800030a2:	74a2                	ld	s1,40(sp)
    800030a4:	7902                	ld	s2,32(sp)
    800030a6:	69e2                	ld	s3,24(sp)
    800030a8:	6a42                	ld	s4,16(sp)
    800030aa:	6aa2                	ld	s5,8(sp)
    800030ac:	6b02                	ld	s6,0(sp)
    800030ae:	6121                	addi	sp,sp,64
    800030b0:	8082                	ret
    800030b2:	8082                	ret

00000000800030b4 <initlog>:
{
    800030b4:	7179                	addi	sp,sp,-48
    800030b6:	f406                	sd	ra,40(sp)
    800030b8:	f022                	sd	s0,32(sp)
    800030ba:	ec26                	sd	s1,24(sp)
    800030bc:	e84a                	sd	s2,16(sp)
    800030be:	e44e                	sd	s3,8(sp)
    800030c0:	1800                	addi	s0,sp,48
    800030c2:	892a                	mv	s2,a0
    800030c4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800030c6:	00017497          	auipc	s1,0x17
    800030ca:	6fa48493          	addi	s1,s1,1786 # 8001a7c0 <log>
    800030ce:	00004597          	auipc	a1,0x4
    800030d2:	55258593          	addi	a1,a1,1362 # 80007620 <etext+0x620>
    800030d6:	8526                	mv	a0,s1
    800030d8:	079020ef          	jal	80005950 <initlock>
  log.start = sb->logstart;
    800030dc:	0149a583          	lw	a1,20(s3)
    800030e0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800030e2:	0109a783          	lw	a5,16(s3)
    800030e6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800030e8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800030ec:	854a                	mv	a0,s2
    800030ee:	87cff0ef          	jal	8000216a <bread>
  log.lh.n = lh->n;
    800030f2:	4d30                	lw	a2,88(a0)
    800030f4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800030f6:	00c05f63          	blez	a2,80003114 <initlog+0x60>
    800030fa:	87aa                	mv	a5,a0
    800030fc:	00017717          	auipc	a4,0x17
    80003100:	6f470713          	addi	a4,a4,1780 # 8001a7f0 <log+0x30>
    80003104:	060a                	slli	a2,a2,0x2
    80003106:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003108:	4ff4                	lw	a3,92(a5)
    8000310a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000310c:	0791                	addi	a5,a5,4
    8000310e:	0711                	addi	a4,a4,4
    80003110:	fec79ce3          	bne	a5,a2,80003108 <initlog+0x54>
  brelse(buf);
    80003114:	95eff0ef          	jal	80002272 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003118:	4505                	li	a0,1
    8000311a:	ef3ff0ef          	jal	8000300c <install_trans>
  log.lh.n = 0;
    8000311e:	00017797          	auipc	a5,0x17
    80003122:	6c07a723          	sw	zero,1742(a5) # 8001a7ec <log+0x2c>
  write_head(); // clear the log
    80003126:	e89ff0ef          	jal	80002fae <write_head>
}
    8000312a:	70a2                	ld	ra,40(sp)
    8000312c:	7402                	ld	s0,32(sp)
    8000312e:	64e2                	ld	s1,24(sp)
    80003130:	6942                	ld	s2,16(sp)
    80003132:	69a2                	ld	s3,8(sp)
    80003134:	6145                	addi	sp,sp,48
    80003136:	8082                	ret

0000000080003138 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003138:	1101                	addi	sp,sp,-32
    8000313a:	ec06                	sd	ra,24(sp)
    8000313c:	e822                	sd	s0,16(sp)
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	e04a                	sd	s2,0(sp)
    80003142:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003144:	00017517          	auipc	a0,0x17
    80003148:	67c50513          	addi	a0,a0,1660 # 8001a7c0 <log>
    8000314c:	085020ef          	jal	800059d0 <acquire>
  while(1){
    if(log.committing){
    80003150:	00017497          	auipc	s1,0x17
    80003154:	67048493          	addi	s1,s1,1648 # 8001a7c0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003158:	4979                	li	s2,30
    8000315a:	a029                	j	80003164 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000315c:	85a6                	mv	a1,s1
    8000315e:	8526                	mv	a0,s1
    80003160:	af6fe0ef          	jal	80001456 <sleep>
    if(log.committing){
    80003164:	50dc                	lw	a5,36(s1)
    80003166:	fbfd                	bnez	a5,8000315c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003168:	5098                	lw	a4,32(s1)
    8000316a:	2705                	addiw	a4,a4,1
    8000316c:	0027179b          	slliw	a5,a4,0x2
    80003170:	9fb9                	addw	a5,a5,a4
    80003172:	0017979b          	slliw	a5,a5,0x1
    80003176:	54d4                	lw	a3,44(s1)
    80003178:	9fb5                	addw	a5,a5,a3
    8000317a:	00f95763          	bge	s2,a5,80003188 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000317e:	85a6                	mv	a1,s1
    80003180:	8526                	mv	a0,s1
    80003182:	ad4fe0ef          	jal	80001456 <sleep>
    80003186:	bff9                	j	80003164 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003188:	00017517          	auipc	a0,0x17
    8000318c:	63850513          	addi	a0,a0,1592 # 8001a7c0 <log>
    80003190:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003192:	0d7020ef          	jal	80005a68 <release>
      break;
    }
  }
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	64a2                	ld	s1,8(sp)
    8000319c:	6902                	ld	s2,0(sp)
    8000319e:	6105                	addi	sp,sp,32
    800031a0:	8082                	ret

00000000800031a2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800031a2:	7139                	addi	sp,sp,-64
    800031a4:	fc06                	sd	ra,56(sp)
    800031a6:	f822                	sd	s0,48(sp)
    800031a8:	f426                	sd	s1,40(sp)
    800031aa:	f04a                	sd	s2,32(sp)
    800031ac:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800031ae:	00017497          	auipc	s1,0x17
    800031b2:	61248493          	addi	s1,s1,1554 # 8001a7c0 <log>
    800031b6:	8526                	mv	a0,s1
    800031b8:	019020ef          	jal	800059d0 <acquire>
  log.outstanding -= 1;
    800031bc:	509c                	lw	a5,32(s1)
    800031be:	37fd                	addiw	a5,a5,-1
    800031c0:	0007891b          	sext.w	s2,a5
    800031c4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800031c6:	50dc                	lw	a5,36(s1)
    800031c8:	ef9d                	bnez	a5,80003206 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800031ca:	04091763          	bnez	s2,80003218 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800031ce:	00017497          	auipc	s1,0x17
    800031d2:	5f248493          	addi	s1,s1,1522 # 8001a7c0 <log>
    800031d6:	4785                	li	a5,1
    800031d8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800031da:	8526                	mv	a0,s1
    800031dc:	08d020ef          	jal	80005a68 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800031e0:	54dc                	lw	a5,44(s1)
    800031e2:	04f04b63          	bgtz	a5,80003238 <end_op+0x96>
    acquire(&log.lock);
    800031e6:	00017497          	auipc	s1,0x17
    800031ea:	5da48493          	addi	s1,s1,1498 # 8001a7c0 <log>
    800031ee:	8526                	mv	a0,s1
    800031f0:	7e0020ef          	jal	800059d0 <acquire>
    log.committing = 0;
    800031f4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800031f8:	8526                	mv	a0,s1
    800031fa:	aa8fe0ef          	jal	800014a2 <wakeup>
    release(&log.lock);
    800031fe:	8526                	mv	a0,s1
    80003200:	069020ef          	jal	80005a68 <release>
}
    80003204:	a025                	j	8000322c <end_op+0x8a>
    80003206:	ec4e                	sd	s3,24(sp)
    80003208:	e852                	sd	s4,16(sp)
    8000320a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000320c:	00004517          	auipc	a0,0x4
    80003210:	41c50513          	addi	a0,a0,1052 # 80007628 <etext+0x628>
    80003214:	48e020ef          	jal	800056a2 <panic>
    wakeup(&log);
    80003218:	00017497          	auipc	s1,0x17
    8000321c:	5a848493          	addi	s1,s1,1448 # 8001a7c0 <log>
    80003220:	8526                	mv	a0,s1
    80003222:	a80fe0ef          	jal	800014a2 <wakeup>
  release(&log.lock);
    80003226:	8526                	mv	a0,s1
    80003228:	041020ef          	jal	80005a68 <release>
}
    8000322c:	70e2                	ld	ra,56(sp)
    8000322e:	7442                	ld	s0,48(sp)
    80003230:	74a2                	ld	s1,40(sp)
    80003232:	7902                	ld	s2,32(sp)
    80003234:	6121                	addi	sp,sp,64
    80003236:	8082                	ret
    80003238:	ec4e                	sd	s3,24(sp)
    8000323a:	e852                	sd	s4,16(sp)
    8000323c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000323e:	00017a97          	auipc	s5,0x17
    80003242:	5b2a8a93          	addi	s5,s5,1458 # 8001a7f0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003246:	00017a17          	auipc	s4,0x17
    8000324a:	57aa0a13          	addi	s4,s4,1402 # 8001a7c0 <log>
    8000324e:	018a2583          	lw	a1,24(s4)
    80003252:	012585bb          	addw	a1,a1,s2
    80003256:	2585                	addiw	a1,a1,1
    80003258:	028a2503          	lw	a0,40(s4)
    8000325c:	f0ffe0ef          	jal	8000216a <bread>
    80003260:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003262:	000aa583          	lw	a1,0(s5)
    80003266:	028a2503          	lw	a0,40(s4)
    8000326a:	f01fe0ef          	jal	8000216a <bread>
    8000326e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003270:	40000613          	li	a2,1024
    80003274:	05850593          	addi	a1,a0,88
    80003278:	05848513          	addi	a0,s1,88
    8000327c:	f71fc0ef          	jal	800001ec <memmove>
    bwrite(to);  // write the log
    80003280:	8526                	mv	a0,s1
    80003282:	fbffe0ef          	jal	80002240 <bwrite>
    brelse(from);
    80003286:	854e                	mv	a0,s3
    80003288:	febfe0ef          	jal	80002272 <brelse>
    brelse(to);
    8000328c:	8526                	mv	a0,s1
    8000328e:	fe5fe0ef          	jal	80002272 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003292:	2905                	addiw	s2,s2,1
    80003294:	0a91                	addi	s5,s5,4
    80003296:	02ca2783          	lw	a5,44(s4)
    8000329a:	faf94ae3          	blt	s2,a5,8000324e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000329e:	d11ff0ef          	jal	80002fae <write_head>
    install_trans(0); // Now install writes to home locations
    800032a2:	4501                	li	a0,0
    800032a4:	d69ff0ef          	jal	8000300c <install_trans>
    log.lh.n = 0;
    800032a8:	00017797          	auipc	a5,0x17
    800032ac:	5407a223          	sw	zero,1348(a5) # 8001a7ec <log+0x2c>
    write_head();    // Erase the transaction from the log
    800032b0:	cffff0ef          	jal	80002fae <write_head>
    800032b4:	69e2                	ld	s3,24(sp)
    800032b6:	6a42                	ld	s4,16(sp)
    800032b8:	6aa2                	ld	s5,8(sp)
    800032ba:	b735                	j	800031e6 <end_op+0x44>

00000000800032bc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800032bc:	1101                	addi	sp,sp,-32
    800032be:	ec06                	sd	ra,24(sp)
    800032c0:	e822                	sd	s0,16(sp)
    800032c2:	e426                	sd	s1,8(sp)
    800032c4:	e04a                	sd	s2,0(sp)
    800032c6:	1000                	addi	s0,sp,32
    800032c8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800032ca:	00017917          	auipc	s2,0x17
    800032ce:	4f690913          	addi	s2,s2,1270 # 8001a7c0 <log>
    800032d2:	854a                	mv	a0,s2
    800032d4:	6fc020ef          	jal	800059d0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800032d8:	02c92603          	lw	a2,44(s2)
    800032dc:	47f5                	li	a5,29
    800032de:	06c7c363          	blt	a5,a2,80003344 <log_write+0x88>
    800032e2:	00017797          	auipc	a5,0x17
    800032e6:	4fa7a783          	lw	a5,1274(a5) # 8001a7dc <log+0x1c>
    800032ea:	37fd                	addiw	a5,a5,-1
    800032ec:	04f65c63          	bge	a2,a5,80003344 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800032f0:	00017797          	auipc	a5,0x17
    800032f4:	4f07a783          	lw	a5,1264(a5) # 8001a7e0 <log+0x20>
    800032f8:	04f05c63          	blez	a5,80003350 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800032fc:	4781                	li	a5,0
    800032fe:	04c05f63          	blez	a2,8000335c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003302:	44cc                	lw	a1,12(s1)
    80003304:	00017717          	auipc	a4,0x17
    80003308:	4ec70713          	addi	a4,a4,1260 # 8001a7f0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000330c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000330e:	4314                	lw	a3,0(a4)
    80003310:	04b68663          	beq	a3,a1,8000335c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003314:	2785                	addiw	a5,a5,1
    80003316:	0711                	addi	a4,a4,4
    80003318:	fef61be3          	bne	a2,a5,8000330e <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000331c:	0621                	addi	a2,a2,8
    8000331e:	060a                	slli	a2,a2,0x2
    80003320:	00017797          	auipc	a5,0x17
    80003324:	4a078793          	addi	a5,a5,1184 # 8001a7c0 <log>
    80003328:	97b2                	add	a5,a5,a2
    8000332a:	44d8                	lw	a4,12(s1)
    8000332c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000332e:	8526                	mv	a0,s1
    80003330:	fcbfe0ef          	jal	800022fa <bpin>
    log.lh.n++;
    80003334:	00017717          	auipc	a4,0x17
    80003338:	48c70713          	addi	a4,a4,1164 # 8001a7c0 <log>
    8000333c:	575c                	lw	a5,44(a4)
    8000333e:	2785                	addiw	a5,a5,1
    80003340:	d75c                	sw	a5,44(a4)
    80003342:	a80d                	j	80003374 <log_write+0xb8>
    panic("too big a transaction");
    80003344:	00004517          	auipc	a0,0x4
    80003348:	2f450513          	addi	a0,a0,756 # 80007638 <etext+0x638>
    8000334c:	356020ef          	jal	800056a2 <panic>
    panic("log_write outside of trans");
    80003350:	00004517          	auipc	a0,0x4
    80003354:	30050513          	addi	a0,a0,768 # 80007650 <etext+0x650>
    80003358:	34a020ef          	jal	800056a2 <panic>
  log.lh.block[i] = b->blockno;
    8000335c:	00878693          	addi	a3,a5,8
    80003360:	068a                	slli	a3,a3,0x2
    80003362:	00017717          	auipc	a4,0x17
    80003366:	45e70713          	addi	a4,a4,1118 # 8001a7c0 <log>
    8000336a:	9736                	add	a4,a4,a3
    8000336c:	44d4                	lw	a3,12(s1)
    8000336e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003370:	faf60fe3          	beq	a2,a5,8000332e <log_write+0x72>
  }
  release(&log.lock);
    80003374:	00017517          	auipc	a0,0x17
    80003378:	44c50513          	addi	a0,a0,1100 # 8001a7c0 <log>
    8000337c:	6ec020ef          	jal	80005a68 <release>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	64a2                	ld	s1,8(sp)
    80003386:	6902                	ld	s2,0(sp)
    80003388:	6105                	addi	sp,sp,32
    8000338a:	8082                	ret

000000008000338c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000338c:	1101                	addi	sp,sp,-32
    8000338e:	ec06                	sd	ra,24(sp)
    80003390:	e822                	sd	s0,16(sp)
    80003392:	e426                	sd	s1,8(sp)
    80003394:	e04a                	sd	s2,0(sp)
    80003396:	1000                	addi	s0,sp,32
    80003398:	84aa                	mv	s1,a0
    8000339a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000339c:	00004597          	auipc	a1,0x4
    800033a0:	2d458593          	addi	a1,a1,724 # 80007670 <etext+0x670>
    800033a4:	0521                	addi	a0,a0,8
    800033a6:	5aa020ef          	jal	80005950 <initlock>
  lk->name = name;
    800033aa:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800033ae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800033b2:	0204a423          	sw	zero,40(s1)
}
    800033b6:	60e2                	ld	ra,24(sp)
    800033b8:	6442                	ld	s0,16(sp)
    800033ba:	64a2                	ld	s1,8(sp)
    800033bc:	6902                	ld	s2,0(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret

00000000800033c2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	e04a                	sd	s2,0(sp)
    800033cc:	1000                	addi	s0,sp,32
    800033ce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800033d0:	00850913          	addi	s2,a0,8
    800033d4:	854a                	mv	a0,s2
    800033d6:	5fa020ef          	jal	800059d0 <acquire>
  while (lk->locked) {
    800033da:	409c                	lw	a5,0(s1)
    800033dc:	c799                	beqz	a5,800033ea <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800033de:	85ca                	mv	a1,s2
    800033e0:	8526                	mv	a0,s1
    800033e2:	874fe0ef          	jal	80001456 <sleep>
  while (lk->locked) {
    800033e6:	409c                	lw	a5,0(s1)
    800033e8:	fbfd                	bnez	a5,800033de <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800033ea:	4785                	li	a5,1
    800033ec:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800033ee:	a93fd0ef          	jal	80000e80 <myproc>
    800033f2:	591c                	lw	a5,48(a0)
    800033f4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800033f6:	854a                	mv	a0,s2
    800033f8:	670020ef          	jal	80005a68 <release>
}
    800033fc:	60e2                	ld	ra,24(sp)
    800033fe:	6442                	ld	s0,16(sp)
    80003400:	64a2                	ld	s1,8(sp)
    80003402:	6902                	ld	s2,0(sp)
    80003404:	6105                	addi	sp,sp,32
    80003406:	8082                	ret

0000000080003408 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	e04a                	sd	s2,0(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003416:	00850913          	addi	s2,a0,8
    8000341a:	854a                	mv	a0,s2
    8000341c:	5b4020ef          	jal	800059d0 <acquire>
  lk->locked = 0;
    80003420:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003424:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003428:	8526                	mv	a0,s1
    8000342a:	878fe0ef          	jal	800014a2 <wakeup>
  release(&lk->lk);
    8000342e:	854a                	mv	a0,s2
    80003430:	638020ef          	jal	80005a68 <release>
}
    80003434:	60e2                	ld	ra,24(sp)
    80003436:	6442                	ld	s0,16(sp)
    80003438:	64a2                	ld	s1,8(sp)
    8000343a:	6902                	ld	s2,0(sp)
    8000343c:	6105                	addi	sp,sp,32
    8000343e:	8082                	ret

0000000080003440 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003440:	7179                	addi	sp,sp,-48
    80003442:	f406                	sd	ra,40(sp)
    80003444:	f022                	sd	s0,32(sp)
    80003446:	ec26                	sd	s1,24(sp)
    80003448:	e84a                	sd	s2,16(sp)
    8000344a:	1800                	addi	s0,sp,48
    8000344c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000344e:	00850913          	addi	s2,a0,8
    80003452:	854a                	mv	a0,s2
    80003454:	57c020ef          	jal	800059d0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003458:	409c                	lw	a5,0(s1)
    8000345a:	ef81                	bnez	a5,80003472 <holdingsleep+0x32>
    8000345c:	4481                	li	s1,0
  release(&lk->lk);
    8000345e:	854a                	mv	a0,s2
    80003460:	608020ef          	jal	80005a68 <release>
  return r;
}
    80003464:	8526                	mv	a0,s1
    80003466:	70a2                	ld	ra,40(sp)
    80003468:	7402                	ld	s0,32(sp)
    8000346a:	64e2                	ld	s1,24(sp)
    8000346c:	6942                	ld	s2,16(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret
    80003472:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003474:	0284a983          	lw	s3,40(s1)
    80003478:	a09fd0ef          	jal	80000e80 <myproc>
    8000347c:	5904                	lw	s1,48(a0)
    8000347e:	413484b3          	sub	s1,s1,s3
    80003482:	0014b493          	seqz	s1,s1
    80003486:	69a2                	ld	s3,8(sp)
    80003488:	bfd9                	j	8000345e <holdingsleep+0x1e>

000000008000348a <fileinit>:
} ftable;

// initialize file table 
void
fileinit(void)
{
    8000348a:	1141                	addi	sp,sp,-16
    8000348c:	e406                	sd	ra,8(sp)
    8000348e:	e022                	sd	s0,0(sp)
    80003490:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable"); //Initialize spinlock lock for ftable to synchronize access to file table.
    80003492:	00004597          	auipc	a1,0x4
    80003496:	1ee58593          	addi	a1,a1,494 # 80007680 <etext+0x680>
    8000349a:	00017517          	auipc	a0,0x17
    8000349e:	46e50513          	addi	a0,a0,1134 # 8001a908 <ftable>
    800034a2:	4ae020ef          	jal	80005950 <initlock>
}
    800034a6:	60a2                	ld	ra,8(sp)
    800034a8:	6402                	ld	s0,0(sp)
    800034aa:	0141                	addi	sp,sp,16
    800034ac:	8082                	ret

00000000800034ae <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800034ae:	1101                	addi	sp,sp,-32
    800034b0:	ec06                	sd	ra,24(sp)
    800034b2:	e822                	sd	s0,16(sp)
    800034b4:	e426                	sd	s1,8(sp)
    800034b6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800034b8:	00017517          	auipc	a0,0x17
    800034bc:	45050513          	addi	a0,a0,1104 # 8001a908 <ftable>
    800034c0:	510020ef          	jal	800059d0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034c4:	00017497          	auipc	s1,0x17
    800034c8:	45c48493          	addi	s1,s1,1116 # 8001a920 <ftable+0x18>
    800034cc:	00018717          	auipc	a4,0x18
    800034d0:	3f470713          	addi	a4,a4,1012 # 8001b8c0 <disk>
    //find file structure that are not used
    if(f->ref == 0){
    800034d4:	40dc                	lw	a5,4(s1)
    800034d6:	cf89                	beqz	a5,800034f0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800034d8:	02848493          	addi	s1,s1,40
    800034dc:	fee49ce3          	bne	s1,a4,800034d4 <filealloc+0x26>
      f->ref = 1; // mark that it has been used 
      release(&ftable.lock); // unlock
      return f;
    }
  }
  release(&ftable.lock); //unlock afer finding
    800034e0:	00017517          	auipc	a0,0x17
    800034e4:	42850513          	addi	a0,a0,1064 # 8001a908 <ftable>
    800034e8:	580020ef          	jal	80005a68 <release>
  return 0;
    800034ec:	4481                	li	s1,0
    800034ee:	a809                	j	80003500 <filealloc+0x52>
      f->ref = 1; // mark that it has been used 
    800034f0:	4785                	li	a5,1
    800034f2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock); // unlock
    800034f4:	00017517          	auipc	a0,0x17
    800034f8:	41450513          	addi	a0,a0,1044 # 8001a908 <ftable>
    800034fc:	56c020ef          	jal	80005a68 <release>
}
    80003500:	8526                	mv	a0,s1
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret

000000008000350c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000350c:	1101                	addi	sp,sp,-32
    8000350e:	ec06                	sd	ra,24(sp)
    80003510:	e822                	sd	s0,16(sp)
    80003512:	e426                	sd	s1,8(sp)
    80003514:	1000                	addi	s0,sp,32
    80003516:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003518:	00017517          	auipc	a0,0x17
    8000351c:	3f050513          	addi	a0,a0,1008 # 8001a908 <ftable>
    80003520:	4b0020ef          	jal	800059d0 <acquire>
  if(f->ref < 1)
    80003524:	40dc                	lw	a5,4(s1)
    80003526:	02f05063          	blez	a5,80003546 <filedup+0x3a>
    panic("filedup"); // panic cannot duplicate because it isnot used
  f->ref++; //duplicate
    8000352a:	2785                	addiw	a5,a5,1
    8000352c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000352e:	00017517          	auipc	a0,0x17
    80003532:	3da50513          	addi	a0,a0,986 # 8001a908 <ftable>
    80003536:	532020ef          	jal	80005a68 <release>
  return f;
}
    8000353a:	8526                	mv	a0,s1
    8000353c:	60e2                	ld	ra,24(sp)
    8000353e:	6442                	ld	s0,16(sp)
    80003540:	64a2                	ld	s1,8(sp)
    80003542:	6105                	addi	sp,sp,32
    80003544:	8082                	ret
    panic("filedup"); // panic cannot duplicate because it isnot used
    80003546:	00004517          	auipc	a0,0x4
    8000354a:	14250513          	addi	a0,a0,322 # 80007688 <etext+0x688>
    8000354e:	154020ef          	jal	800056a2 <panic>

0000000080003552 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.) and release.
void
fileclose(struct file *f)
{
    80003552:	7139                	addi	sp,sp,-64
    80003554:	fc06                	sd	ra,56(sp)
    80003556:	f822                	sd	s0,48(sp)
    80003558:	f426                	sd	s1,40(sp)
    8000355a:	0080                	addi	s0,sp,64
    8000355c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000355e:	00017517          	auipc	a0,0x17
    80003562:	3aa50513          	addi	a0,a0,938 # 8001a908 <ftable>
    80003566:	46a020ef          	jal	800059d0 <acquire>
  if(f->ref < 1)
    8000356a:	40dc                	lw	a5,4(s1)
    8000356c:	04f05a63          	blez	a5,800035c0 <fileclose+0x6e>
    panic("fileclose"); // panic cannot close because it is not used
  // release 1 duplicate
  if(--f->ref > 0){
    80003570:	37fd                	addiw	a5,a5,-1
    80003572:	0007871b          	sext.w	a4,a5
    80003576:	c0dc                	sw	a5,4(s1)
    80003578:	04e04e63          	bgtz	a4,800035d4 <fileclose+0x82>
    8000357c:	f04a                	sd	s2,32(sp)
    8000357e:	ec4e                	sd	s3,24(sp)
    80003580:	e852                	sd	s4,16(sp)
    80003582:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  //if ref = 0 close file.
  ff = *f;
    80003584:	0004a903          	lw	s2,0(s1)
    80003588:	0094ca83          	lbu	s5,9(s1)
    8000358c:	0104ba03          	ld	s4,16(s1)
    80003590:	0184b983          	ld	s3,24(s1)
  //reset member
  f->ref = 0;
    80003594:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003598:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000359c:	00017517          	auipc	a0,0x17
    800035a0:	36c50513          	addi	a0,a0,876 # 8001a908 <ftable>
    800035a4:	4c4020ef          	jal	80005a68 <release>

  //close pipe if open pipe
  if(ff.type == FD_PIPE){
    800035a8:	4785                	li	a5,1
    800035aa:	04f90063          	beq	s2,a5,800035ea <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800035ae:	3979                	addiw	s2,s2,-2
    800035b0:	4785                	li	a5,1
    800035b2:	0527f563          	bgeu	a5,s2,800035fc <fileclose+0xaa>
    800035b6:	7902                	ld	s2,32(sp)
    800035b8:	69e2                	ld	s3,24(sp)
    800035ba:	6a42                	ld	s4,16(sp)
    800035bc:	6aa2                	ld	s5,8(sp)
    800035be:	a00d                	j	800035e0 <fileclose+0x8e>
    800035c0:	f04a                	sd	s2,32(sp)
    800035c2:	ec4e                	sd	s3,24(sp)
    800035c4:	e852                	sd	s4,16(sp)
    800035c6:	e456                	sd	s5,8(sp)
    panic("fileclose"); // panic cannot close because it is not used
    800035c8:	00004517          	auipc	a0,0x4
    800035cc:	0c850513          	addi	a0,a0,200 # 80007690 <etext+0x690>
    800035d0:	0d2020ef          	jal	800056a2 <panic>
    release(&ftable.lock);
    800035d4:	00017517          	auipc	a0,0x17
    800035d8:	33450513          	addi	a0,a0,820 # 8001a908 <ftable>
    800035dc:	48c020ef          	jal	80005a68 <release>
    begin_op();
    iput(ff.ip); //release
    end_op();
  }
}
    800035e0:	70e2                	ld	ra,56(sp)
    800035e2:	7442                	ld	s0,48(sp)
    800035e4:	74a2                	ld	s1,40(sp)
    800035e6:	6121                	addi	sp,sp,64
    800035e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800035ea:	85d6                	mv	a1,s5
    800035ec:	8552                	mv	a0,s4
    800035ee:	386000ef          	jal	80003974 <pipeclose>
    800035f2:	7902                	ld	s2,32(sp)
    800035f4:	69e2                	ld	s3,24(sp)
    800035f6:	6a42                	ld	s4,16(sp)
    800035f8:	6aa2                	ld	s5,8(sp)
    800035fa:	b7dd                	j	800035e0 <fileclose+0x8e>
    begin_op();
    800035fc:	b3dff0ef          	jal	80003138 <begin_op>
    iput(ff.ip); //release
    80003600:	854e                	mv	a0,s3
    80003602:	c22ff0ef          	jal	80002a24 <iput>
    end_op();
    80003606:	b9dff0ef          	jal	800031a2 <end_op>
    8000360a:	7902                	ld	s2,32(sp)
    8000360c:	69e2                	ld	s3,24(sp)
    8000360e:	6a42                	ld	s4,16(sp)
    80003610:	6aa2                	ld	s5,8(sp)
    80003612:	b7f9                	j	800035e0 <fileclose+0x8e>

0000000080003614 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003614:	715d                	addi	sp,sp,-80
    80003616:	e486                	sd	ra,72(sp)
    80003618:	e0a2                	sd	s0,64(sp)
    8000361a:	fc26                	sd	s1,56(sp)
    8000361c:	f44e                	sd	s3,40(sp)
    8000361e:	0880                	addi	s0,sp,80
    80003620:	84aa                	mv	s1,a0
    80003622:	89ae                	mv	s3,a1
  struct proc *p = myproc(); //process structure
    80003624:	85dfd0ef          	jal	80000e80 <myproc>
  struct stat st; // static structure
  
  //get the metadata if the type is inode or device
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003628:	409c                	lw	a5,0(s1)
    8000362a:	37f9                	addiw	a5,a5,-2
    8000362c:	4705                	li	a4,1
    8000362e:	04f76063          	bltu	a4,a5,8000366e <filestat+0x5a>
    80003632:	f84a                	sd	s2,48(sp)
    80003634:	892a                	mv	s2,a0
    ilock(f->ip);
    80003636:	6c88                	ld	a0,24(s1)
    80003638:	a6aff0ef          	jal	800028a2 <ilock>
    stati(f->ip, &st); //get the data
    8000363c:	fb840593          	addi	a1,s0,-72
    80003640:	6c88                	ld	a0,24(s1)
    80003642:	c8aff0ef          	jal	80002acc <stati>
    iunlock(f->ip);
    80003646:	6c88                	ld	a0,24(s1)
    80003648:	b08ff0ef          	jal	80002950 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0) //Copy the obtained data to the user's memory space
    8000364c:	46e1                	li	a3,24
    8000364e:	fb840613          	addi	a2,s0,-72
    80003652:	85ce                	mv	a1,s3
    80003654:	05093503          	ld	a0,80(s2)
    80003658:	bc2fd0ef          	jal	80000a1a <copyout>
    8000365c:	41f5551b          	sraiw	a0,a0,0x1f
    80003660:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003662:	60a6                	ld	ra,72(sp)
    80003664:	6406                	ld	s0,64(sp)
    80003666:	74e2                	ld	s1,56(sp)
    80003668:	79a2                	ld	s3,40(sp)
    8000366a:	6161                	addi	sp,sp,80
    8000366c:	8082                	ret
  return -1;
    8000366e:	557d                	li	a0,-1
    80003670:	bfcd                	j	80003662 <filestat+0x4e>

0000000080003672 <fileread>:

// Read from file f and copy to address.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	e84a                	sd	s2,16(sp)
    8000367a:	1800                	addi	s0,sp,48
  int r = 0;
  // check if file can be read or not
  if(f->readable == 0)
    8000367c:	00854783          	lbu	a5,8(a0)
    80003680:	cfd1                	beqz	a5,8000371c <fileread+0xaa>
    80003682:	ec26                	sd	s1,24(sp)
    80003684:	e44e                	sd	s3,8(sp)
    80003686:	84aa                	mv	s1,a0
    80003688:	89ae                	mv	s3,a1
    8000368a:	8932                	mv	s2,a2
    return -1;

  //read pipe
  if(f->type == FD_PIPE){
    8000368c:	411c                	lw	a5,0(a0)
    8000368e:	4705                	li	a4,1
    80003690:	04e78363          	beq	a5,a4,800036d6 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  //read device
  } else if(f->type == FD_DEVICE){
    80003694:	470d                	li	a4,3
    80003696:	04e78763          	beq	a5,a4,800036e4 <fileread+0x72>
    //get the correct device to read from device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  //read inode  
  } else if(f->type == FD_INODE){
    8000369a:	4709                	li	a4,2
    8000369c:	06e79a63          	bne	a5,a4,80003710 <fileread+0x9e>
    ilock(f->ip);
    800036a0:	6d08                	ld	a0,24(a0)
    800036a2:	a00ff0ef          	jal	800028a2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800036a6:	874a                	mv	a4,s2
    800036a8:	5094                	lw	a3,32(s1)
    800036aa:	864e                	mv	a2,s3
    800036ac:	4585                	li	a1,1
    800036ae:	6c88                	ld	a0,24(s1)
    800036b0:	c46ff0ef          	jal	80002af6 <readi>
    800036b4:	892a                	mv	s2,a0
    800036b6:	00a05563          	blez	a0,800036c0 <fileread+0x4e>
      f->off += r;
    800036ba:	509c                	lw	a5,32(s1)
    800036bc:	9fa9                	addw	a5,a5,a0
    800036be:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800036c0:	6c88                	ld	a0,24(s1)
    800036c2:	a8eff0ef          	jal	80002950 <iunlock>
    800036c6:	64e2                	ld	s1,24(sp)
    800036c8:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800036ca:	854a                	mv	a0,s2
    800036cc:	70a2                	ld	ra,40(sp)
    800036ce:	7402                	ld	s0,32(sp)
    800036d0:	6942                	ld	s2,16(sp)
    800036d2:	6145                	addi	sp,sp,48
    800036d4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800036d6:	6908                	ld	a0,16(a0)
    800036d8:	3d8000ef          	jal	80003ab0 <piperead>
    800036dc:	892a                	mv	s2,a0
    800036de:	64e2                	ld	s1,24(sp)
    800036e0:	69a2                	ld	s3,8(sp)
    800036e2:	b7e5                	j	800036ca <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800036e4:	02451783          	lh	a5,36(a0)
    800036e8:	03079693          	slli	a3,a5,0x30
    800036ec:	92c1                	srli	a3,a3,0x30
    800036ee:	4725                	li	a4,9
    800036f0:	02d76863          	bltu	a4,a3,80003720 <fileread+0xae>
    800036f4:	0792                	slli	a5,a5,0x4
    800036f6:	00017717          	auipc	a4,0x17
    800036fa:	17270713          	addi	a4,a4,370 # 8001a868 <devsw>
    800036fe:	97ba                	add	a5,a5,a4
    80003700:	639c                	ld	a5,0(a5)
    80003702:	c39d                	beqz	a5,80003728 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003704:	4505                	li	a0,1
    80003706:	9782                	jalr	a5
    80003708:	892a                	mv	s2,a0
    8000370a:	64e2                	ld	s1,24(sp)
    8000370c:	69a2                	ld	s3,8(sp)
    8000370e:	bf75                	j	800036ca <fileread+0x58>
    panic("fileread");
    80003710:	00004517          	auipc	a0,0x4
    80003714:	f9050513          	addi	a0,a0,-112 # 800076a0 <etext+0x6a0>
    80003718:	78b010ef          	jal	800056a2 <panic>
    return -1;
    8000371c:	597d                	li	s2,-1
    8000371e:	b775                	j	800036ca <fileread+0x58>
      return -1;
    80003720:	597d                	li	s2,-1
    80003722:	64e2                	ld	s1,24(sp)
    80003724:	69a2                	ld	s3,8(sp)
    80003726:	b755                	j	800036ca <fileread+0x58>
    80003728:	597d                	li	s2,-1
    8000372a:	64e2                	ld	s1,24(sp)
    8000372c:	69a2                	ld	s3,8(sp)
    8000372e:	bf71                	j	800036ca <fileread+0x58>

0000000080003730 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;
  //check if the file can be writen or not
  if(f->writable == 0)
    80003730:	00954783          	lbu	a5,9(a0)
    80003734:	10078b63          	beqz	a5,8000384a <filewrite+0x11a>
{
    80003738:	715d                	addi	sp,sp,-80
    8000373a:	e486                	sd	ra,72(sp)
    8000373c:	e0a2                	sd	s0,64(sp)
    8000373e:	f84a                	sd	s2,48(sp)
    80003740:	f052                	sd	s4,32(sp)
    80003742:	e85a                	sd	s6,16(sp)
    80003744:	0880                	addi	s0,sp,80
    80003746:	892a                	mv	s2,a0
    80003748:	8b2e                	mv	s6,a1
    8000374a:	8a32                	mv	s4,a2
    return -1;

  //write to pipe
  if(f->type == FD_PIPE){
    8000374c:	411c                	lw	a5,0(a0)
    8000374e:	4705                	li	a4,1
    80003750:	02e78763          	beq	a5,a4,8000377e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003754:	470d                	li	a4,3
    80003756:	02e78863          	beq	a5,a4,80003786 <filewrite+0x56>
    //find the correct device from the device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000375a:	4709                	li	a4,2
    8000375c:	0ce79c63          	bne	a5,a4,80003834 <filewrite+0x104>
    80003760:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003762:	0ac05863          	blez	a2,80003812 <filewrite+0xe2>
    80003766:	fc26                	sd	s1,56(sp)
    80003768:	ec56                	sd	s5,24(sp)
    8000376a:	e45e                	sd	s7,8(sp)
    8000376c:	e062                	sd	s8,0(sp)
    int i = 0;
    8000376e:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80003770:	6b85                	lui	s7,0x1
    80003772:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003776:	6c05                	lui	s8,0x1
    80003778:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000377c:	a8b5                	j	800037f8 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000377e:	6908                	ld	a0,16(a0)
    80003780:	24c000ef          	jal	800039cc <pipewrite>
    80003784:	a04d                	j	80003826 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003786:	02451783          	lh	a5,36(a0)
    8000378a:	03079693          	slli	a3,a5,0x30
    8000378e:	92c1                	srli	a3,a3,0x30
    80003790:	4725                	li	a4,9
    80003792:	0ad76e63          	bltu	a4,a3,8000384e <filewrite+0x11e>
    80003796:	0792                	slli	a5,a5,0x4
    80003798:	00017717          	auipc	a4,0x17
    8000379c:	0d070713          	addi	a4,a4,208 # 8001a868 <devsw>
    800037a0:	97ba                	add	a5,a5,a4
    800037a2:	679c                	ld	a5,8(a5)
    800037a4:	c7dd                	beqz	a5,80003852 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800037a6:	4505                	li	a0,1
    800037a8:	9782                	jalr	a5
    800037aa:	a8b5                	j	80003826 <filewrite+0xf6>
      if(n1 > max)
    800037ac:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800037b0:	989ff0ef          	jal	80003138 <begin_op>
      ilock(f->ip);
    800037b4:	01893503          	ld	a0,24(s2)
    800037b8:	8eaff0ef          	jal	800028a2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800037bc:	8756                	mv	a4,s5
    800037be:	02092683          	lw	a3,32(s2)
    800037c2:	01698633          	add	a2,s3,s6
    800037c6:	4585                	li	a1,1
    800037c8:	01893503          	ld	a0,24(s2)
    800037cc:	c26ff0ef          	jal	80002bf2 <writei>
    800037d0:	84aa                	mv	s1,a0
    800037d2:	00a05763          	blez	a0,800037e0 <filewrite+0xb0>
        f->off += r;
    800037d6:	02092783          	lw	a5,32(s2)
    800037da:	9fa9                	addw	a5,a5,a0
    800037dc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800037e0:	01893503          	ld	a0,24(s2)
    800037e4:	96cff0ef          	jal	80002950 <iunlock>
      end_op();
    800037e8:	9bbff0ef          	jal	800031a2 <end_op>

      if(r != n1){
    800037ec:	029a9563          	bne	s5,s1,80003816 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800037f0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800037f4:	0149da63          	bge	s3,s4,80003808 <filewrite+0xd8>
      int n1 = n - i;
    800037f8:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800037fc:	0004879b          	sext.w	a5,s1
    80003800:	fafbd6e3          	bge	s7,a5,800037ac <filewrite+0x7c>
    80003804:	84e2                	mv	s1,s8
    80003806:	b75d                	j	800037ac <filewrite+0x7c>
    80003808:	74e2                	ld	s1,56(sp)
    8000380a:	6ae2                	ld	s5,24(sp)
    8000380c:	6ba2                	ld	s7,8(sp)
    8000380e:	6c02                	ld	s8,0(sp)
    80003810:	a039                	j	8000381e <filewrite+0xee>
    int i = 0;
    80003812:	4981                	li	s3,0
    80003814:	a029                	j	8000381e <filewrite+0xee>
    80003816:	74e2                	ld	s1,56(sp)
    80003818:	6ae2                	ld	s5,24(sp)
    8000381a:	6ba2                	ld	s7,8(sp)
    8000381c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000381e:	033a1c63          	bne	s4,s3,80003856 <filewrite+0x126>
    80003822:	8552                	mv	a0,s4
    80003824:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003826:	60a6                	ld	ra,72(sp)
    80003828:	6406                	ld	s0,64(sp)
    8000382a:	7942                	ld	s2,48(sp)
    8000382c:	7a02                	ld	s4,32(sp)
    8000382e:	6b42                	ld	s6,16(sp)
    80003830:	6161                	addi	sp,sp,80
    80003832:	8082                	ret
    80003834:	fc26                	sd	s1,56(sp)
    80003836:	f44e                	sd	s3,40(sp)
    80003838:	ec56                	sd	s5,24(sp)
    8000383a:	e45e                	sd	s7,8(sp)
    8000383c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000383e:	00004517          	auipc	a0,0x4
    80003842:	e7250513          	addi	a0,a0,-398 # 800076b0 <etext+0x6b0>
    80003846:	65d010ef          	jal	800056a2 <panic>
    return -1;
    8000384a:	557d                	li	a0,-1
}
    8000384c:	8082                	ret
      return -1;
    8000384e:	557d                	li	a0,-1
    80003850:	bfd9                	j	80003826 <filewrite+0xf6>
    80003852:	557d                	li	a0,-1
    80003854:	bfc9                	j	80003826 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80003856:	557d                	li	a0,-1
    80003858:	79a2                	ld	s3,40(sp)
    8000385a:	b7f1                	j	80003826 <filewrite+0xf6>

000000008000385c <count_open_files>:

uint64 count_open_files(void) {
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	1000                	addi	s0,sp,32
  uint64 count = 0;

  acquire(&ftable.lock);
    80003866:	00017517          	auipc	a0,0x17
    8000386a:	0a250513          	addi	a0,a0,162 # 8001a908 <ftable>
    8000386e:	162020ef          	jal	800059d0 <acquire>
  for (int i = 0; i < NFILE; i++) {
    80003872:	00017797          	auipc	a5,0x17
    80003876:	0b278793          	addi	a5,a5,178 # 8001a924 <ftable+0x1c>
    8000387a:	00018697          	auipc	a3,0x18
    8000387e:	04a68693          	addi	a3,a3,74 # 8001b8c4 <disk+0x4>
  uint64 count = 0;
    80003882:	4481                	li	s1,0
    if (ftable.file[i].ref > 0){
    80003884:	4398                	lw	a4,0(a5)
      count += 1;
    80003886:	00e02733          	sgtz	a4,a4
    8000388a:	94ba                	add	s1,s1,a4
  for (int i = 0; i < NFILE; i++) {
    8000388c:	02878793          	addi	a5,a5,40
    80003890:	fed79ae3          	bne	a5,a3,80003884 <count_open_files+0x28>
    }
  }
  release(&ftable.lock);
    80003894:	00017517          	auipc	a0,0x17
    80003898:	07450513          	addi	a0,a0,116 # 8001a908 <ftable>
    8000389c:	1cc020ef          	jal	80005a68 <release>

  return count;
    800038a0:	8526                	mv	a0,s1
    800038a2:	60e2                	ld	ra,24(sp)
    800038a4:	6442                	ld	s0,16(sp)
    800038a6:	64a2                	ld	s1,8(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <pipealloc>:
};

//nitializes a pipe, and returns two file descriptors: one for read and one for write 
int
pipealloc(struct file **f0, struct file **f1)
{
    800038ac:	7179                	addi	sp,sp,-48
    800038ae:	f406                	sd	ra,40(sp)
    800038b0:	f022                	sd	s0,32(sp)
    800038b2:	ec26                	sd	s1,24(sp)
    800038b4:	e052                	sd	s4,0(sp)
    800038b6:	1800                	addi	s0,sp,48
    800038b8:	84aa                	mv	s1,a0
    800038ba:	8a2e                	mv	s4,a1
  struct pipe *pi;

  //initialize file descriptors
  pi = 0;
  *f0 = *f1 = 0;
    800038bc:	0005b023          	sd	zero,0(a1)
    800038c0:	00053023          	sd	zero,0(a0)
  //allocate descriptors
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800038c4:	bebff0ef          	jal	800034ae <filealloc>
    800038c8:	e088                	sd	a0,0(s1)
    800038ca:	c549                	beqz	a0,80003954 <pipealloc+0xa8>
    800038cc:	be3ff0ef          	jal	800034ae <filealloc>
    800038d0:	00aa3023          	sd	a0,0(s4)
    800038d4:	cd25                	beqz	a0,8000394c <pipealloc+0xa0>
    800038d6:	e84a                	sd	s2,16(sp)
    goto bad;
  //allocate for pipe
  if((pi = (struct pipe*)kalloc()) == 0)
    800038d8:	827fc0ef          	jal	800000fe <kalloc>
    800038dc:	892a                	mv	s2,a0
    800038de:	c12d                	beqz	a0,80003940 <pipealloc+0x94>
    800038e0:	e44e                	sd	s3,8(sp)
    goto bad;
  //set up values
  pi->readopen = 1;
    800038e2:	4985                	li	s3,1
    800038e4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800038e8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800038ec:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800038f0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe"); // init lock
    800038f4:	00004597          	auipc	a1,0x4
    800038f8:	b3c58593          	addi	a1,a1,-1220 # 80007430 <etext+0x430>
    800038fc:	054020ef          	jal	80005950 <initlock>
  //set up values and link file with pipe
  (*f0)->type = FD_PIPE;
    80003900:	609c                	ld	a5,0(s1)
    80003902:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003906:	609c                	ld	a5,0(s1)
    80003908:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000390c:	609c                	ld	a5,0(s1)
    8000390e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003912:	609c                	ld	a5,0(s1)
    80003914:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003918:	000a3783          	ld	a5,0(s4)
    8000391c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003920:	000a3783          	ld	a5,0(s4)
    80003924:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003928:	000a3783          	ld	a5,0(s4)
    8000392c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003930:	000a3783          	ld	a5,0(s4)
    80003934:	0127b823          	sd	s2,16(a5)
  return 0;
    80003938:	4501                	li	a0,0
    8000393a:	6942                	ld	s2,16(sp)
    8000393c:	69a2                	ld	s3,8(sp)
    8000393e:	a01d                	j	80003964 <pipealloc+0xb8>

//exception
 bad:
  if(pi)
    kfree((char*)pi); //deallocate pipe
  if(*f0)
    80003940:	6088                	ld	a0,0(s1)
    80003942:	c119                	beqz	a0,80003948 <pipealloc+0x9c>
    80003944:	6942                	ld	s2,16(sp)
    80003946:	a029                	j	80003950 <pipealloc+0xa4>
    80003948:	6942                	ld	s2,16(sp)
    8000394a:	a029                	j	80003954 <pipealloc+0xa8>
    8000394c:	6088                	ld	a0,0(s1)
    8000394e:	c10d                	beqz	a0,80003970 <pipealloc+0xc4>
    fileclose(*f0); //close file and release
    80003950:	c03ff0ef          	jal	80003552 <fileclose>
  if(*f1)
    80003954:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003958:	557d                	li	a0,-1
  if(*f1)
    8000395a:	c789                	beqz	a5,80003964 <pipealloc+0xb8>
    fileclose(*f1);
    8000395c:	853e                	mv	a0,a5
    8000395e:	bf5ff0ef          	jal	80003552 <fileclose>
  return -1;
    80003962:	557d                	li	a0,-1
}
    80003964:	70a2                	ld	ra,40(sp)
    80003966:	7402                	ld	s0,32(sp)
    80003968:	64e2                	ld	s1,24(sp)
    8000396a:	6a02                	ld	s4,0(sp)
    8000396c:	6145                	addi	sp,sp,48
    8000396e:	8082                	ret
  return -1;
    80003970:	557d                	li	a0,-1
    80003972:	bfcd                	j	80003964 <pipealloc+0xb8>

0000000080003974 <pipeclose>:
//Close one end of the pipe (read or write). If both ends are closed, release the pipe's memory.
// writable = 1 => writable = 0
// writable = 0 => readable = 0
void
pipeclose(struct pipe *pi, int writable)
{
    80003974:	1101                	addi	sp,sp,-32
    80003976:	ec06                	sd	ra,24(sp)
    80003978:	e822                	sd	s0,16(sp)
    8000397a:	e426                	sd	s1,8(sp)
    8000397c:	e04a                	sd	s2,0(sp)
    8000397e:	1000                	addi	s0,sp,32
    80003980:	84aa                	mv	s1,a0
    80003982:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003984:	04c020ef          	jal	800059d0 <acquire>
  if(writable){
    80003988:	02090763          	beqz	s2,800039b6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000398c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread); // wake the reader up when the writer close
    80003990:	21848513          	addi	a0,s1,536
    80003994:	b0ffd0ef          	jal	800014a2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite); // wake the write up when the reader close
  }
  // if all are close, release the memory
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003998:	2204b783          	ld	a5,544(s1)
    8000399c:	e785                	bnez	a5,800039c4 <pipeclose+0x50>
    release(&pi->lock); // release lock
    8000399e:	8526                	mv	a0,s1
    800039a0:	0c8020ef          	jal	80005a68 <release>
    kfree((char*)pi); // deallocate
    800039a4:	8526                	mv	a0,s1
    800039a6:	e76fc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    800039aa:	60e2                	ld	ra,24(sp)
    800039ac:	6442                	ld	s0,16(sp)
    800039ae:	64a2                	ld	s1,8(sp)
    800039b0:	6902                	ld	s2,0(sp)
    800039b2:	6105                	addi	sp,sp,32
    800039b4:	8082                	ret
    pi->readopen = 0;
    800039b6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite); // wake the write up when the reader close
    800039ba:	21c48513          	addi	a0,s1,540
    800039be:	ae5fd0ef          	jal	800014a2 <wakeup>
    800039c2:	bfd9                	j	80003998 <pipeclose+0x24>
    release(&pi->lock);
    800039c4:	8526                	mv	a0,s1
    800039c6:	0a2020ef          	jal	80005a68 <release>
}
    800039ca:	b7c5                	j	800039aa <pipeclose+0x36>

00000000800039cc <pipewrite>:

//Writes data from the process's memory to the pipe.
int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800039cc:	711d                	addi	sp,sp,-96
    800039ce:	ec86                	sd	ra,88(sp)
    800039d0:	e8a2                	sd	s0,80(sp)
    800039d2:	e4a6                	sd	s1,72(sp)
    800039d4:	e0ca                	sd	s2,64(sp)
    800039d6:	fc4e                	sd	s3,56(sp)
    800039d8:	f852                	sd	s4,48(sp)
    800039da:	f456                	sd	s5,40(sp)
    800039dc:	1080                	addi	s0,sp,96
    800039de:	84aa                	mv	s1,a0
    800039e0:	8aae                	mv	s5,a1
    800039e2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800039e4:	c9cfd0ef          	jal	80000e80 <myproc>
    800039e8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800039ea:	8526                	mv	a0,s1
    800039ec:	7e5010ef          	jal	800059d0 <acquire>
  while(i < n){
    800039f0:	0b405a63          	blez	s4,80003aa4 <pipewrite+0xd8>
    800039f4:	f05a                	sd	s6,32(sp)
    800039f6:	ec5e                	sd	s7,24(sp)
    800039f8:	e862                	sd	s8,16(sp)
  int i = 0;
    800039fa:	4901                	li	s2,0
      wakeup(&pi->nread); //wake up reader
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    } else {
      char ch;
      //read each byte from the process's memory (copyin) and write to the pipe's circular buffer
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800039fc:	5b7d                	li	s6,-1
      wakeup(&pi->nread); //wake up reader
    800039fe:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    80003a02:	21c48b93          	addi	s7,s1,540
    80003a06:	a81d                	j	80003a3c <pipewrite+0x70>
      release(&pi->lock);
    80003a08:	8526                	mv	a0,s1
    80003a0a:	05e020ef          	jal	80005a68 <release>
      return -1;
    80003a0e:	597d                	li	s2,-1
    80003a10:	7b02                	ld	s6,32(sp)
    80003a12:	6be2                	ld	s7,24(sp)
    80003a14:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003a16:	854a                	mv	a0,s2
    80003a18:	60e6                	ld	ra,88(sp)
    80003a1a:	6446                	ld	s0,80(sp)
    80003a1c:	64a6                	ld	s1,72(sp)
    80003a1e:	6906                	ld	s2,64(sp)
    80003a20:	79e2                	ld	s3,56(sp)
    80003a22:	7a42                	ld	s4,48(sp)
    80003a24:	7aa2                	ld	s5,40(sp)
    80003a26:	6125                	addi	sp,sp,96
    80003a28:	8082                	ret
      wakeup(&pi->nread); //wake up reader
    80003a2a:	8562                	mv	a0,s8
    80003a2c:	a77fd0ef          	jal	800014a2 <wakeup>
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    80003a30:	85a6                	mv	a1,s1
    80003a32:	855e                	mv	a0,s7
    80003a34:	a23fd0ef          	jal	80001456 <sleep>
  while(i < n){
    80003a38:	05495b63          	bge	s2,s4,80003a8e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003a3c:	2204a783          	lw	a5,544(s1)
    80003a40:	d7e1                	beqz	a5,80003a08 <pipewrite+0x3c>
    80003a42:	854e                	mv	a0,s3
    80003a44:	c4bfd0ef          	jal	8000168e <killed>
    80003a48:	f161                	bnez	a0,80003a08 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full cannot write more
    80003a4a:	2184a783          	lw	a5,536(s1)
    80003a4e:	21c4a703          	lw	a4,540(s1)
    80003a52:	2007879b          	addiw	a5,a5,512
    80003a56:	fcf70ae3          	beq	a4,a5,80003a2a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003a5a:	4685                	li	a3,1
    80003a5c:	01590633          	add	a2,s2,s5
    80003a60:	faf40593          	addi	a1,s0,-81
    80003a64:	0509b503          	ld	a0,80(s3)
    80003a68:	888fd0ef          	jal	80000af0 <copyin>
    80003a6c:	03650e63          	beq	a0,s6,80003aa8 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003a70:	21c4a783          	lw	a5,540(s1)
    80003a74:	0017871b          	addiw	a4,a5,1
    80003a78:	20e4ae23          	sw	a4,540(s1)
    80003a7c:	1ff7f793          	andi	a5,a5,511
    80003a80:	97a6                	add	a5,a5,s1
    80003a82:	faf44703          	lbu	a4,-81(s0)
    80003a86:	00e78c23          	sb	a4,24(a5)
      i++;
    80003a8a:	2905                	addiw	s2,s2,1
    80003a8c:	b775                	j	80003a38 <pipewrite+0x6c>
    80003a8e:	7b02                	ld	s6,32(sp)
    80003a90:	6be2                	ld	s7,24(sp)
    80003a92:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003a94:	21848513          	addi	a0,s1,536
    80003a98:	a0bfd0ef          	jal	800014a2 <wakeup>
  release(&pi->lock);
    80003a9c:	8526                	mv	a0,s1
    80003a9e:	7cb010ef          	jal	80005a68 <release>
  return i;
    80003aa2:	bf95                	j	80003a16 <pipewrite+0x4a>
  int i = 0;
    80003aa4:	4901                	li	s2,0
    80003aa6:	b7fd                	j	80003a94 <pipewrite+0xc8>
    80003aa8:	7b02                	ld	s6,32(sp)
    80003aaa:	6be2                	ld	s7,24(sp)
    80003aac:	6c42                	ld	s8,16(sp)
    80003aae:	b7dd                	j	80003a94 <pipewrite+0xc8>

0000000080003ab0 <piperead>:

//Read data from the pipe into the process's memory.
int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003ab0:	715d                	addi	sp,sp,-80
    80003ab2:	e486                	sd	ra,72(sp)
    80003ab4:	e0a2                	sd	s0,64(sp)
    80003ab6:	fc26                	sd	s1,56(sp)
    80003ab8:	f84a                	sd	s2,48(sp)
    80003aba:	f44e                	sd	s3,40(sp)
    80003abc:	f052                	sd	s4,32(sp)
    80003abe:	ec56                	sd	s5,24(sp)
    80003ac0:	0880                	addi	s0,sp,80
    80003ac2:	84aa                	mv	s1,a0
    80003ac4:	892e                	mv	s2,a1
    80003ac6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003ac8:	bb8fd0ef          	jal	80000e80 <myproc>
    80003acc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003ace:	8526                	mv	a0,s1
    80003ad0:	701010ef          	jal	800059d0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003ad4:	2184a703          	lw	a4,536(s1)
    80003ad8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    //waiting
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003adc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003ae0:	02f71563          	bne	a4,a5,80003b0a <piperead+0x5a>
    80003ae4:	2244a783          	lw	a5,548(s1)
    80003ae8:	cb85                	beqz	a5,80003b18 <piperead+0x68>
    if(killed(pr)){
    80003aea:	8552                	mv	a0,s4
    80003aec:	ba3fd0ef          	jal	8000168e <killed>
    80003af0:	ed19                	bnez	a0,80003b0e <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003af2:	85a6                	mv	a1,s1
    80003af4:	854e                	mv	a0,s3
    80003af6:	961fd0ef          	jal	80001456 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003afa:	2184a703          	lw	a4,536(s1)
    80003afe:	21c4a783          	lw	a5,540(s1)
    80003b02:	fef701e3          	beq	a4,a5,80003ae4 <piperead+0x34>
    80003b06:	e85a                	sd	s6,16(sp)
    80003b08:	a809                	j	80003b1a <piperead+0x6a>
    80003b0a:	e85a                	sd	s6,16(sp)
    80003b0c:	a039                	j	80003b1a <piperead+0x6a>
      release(&pi->lock);
    80003b0e:	8526                	mv	a0,s1
    80003b10:	759010ef          	jal	80005a68 <release>
      return -1;
    80003b14:	59fd                	li	s3,-1
    80003b16:	a8b1                	j	80003b72 <piperead+0xc2>
    80003b18:	e85a                	sd	s6,16(sp)
  }
  //Read each byte from the pipe's circular buffer and write it to the process's memory (copyout).
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b1a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    //increasing nread after reading
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b1c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b1e:	05505263          	blez	s5,80003b62 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003b22:	2184a783          	lw	a5,536(s1)
    80003b26:	21c4a703          	lw	a4,540(s1)
    80003b2a:	02f70c63          	beq	a4,a5,80003b62 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003b2e:	0017871b          	addiw	a4,a5,1
    80003b32:	20e4ac23          	sw	a4,536(s1)
    80003b36:	1ff7f793          	andi	a5,a5,511
    80003b3a:	97a6                	add	a5,a5,s1
    80003b3c:	0187c783          	lbu	a5,24(a5)
    80003b40:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003b44:	4685                	li	a3,1
    80003b46:	fbf40613          	addi	a2,s0,-65
    80003b4a:	85ca                	mv	a1,s2
    80003b4c:	050a3503          	ld	a0,80(s4)
    80003b50:	ecbfc0ef          	jal	80000a1a <copyout>
    80003b54:	01650763          	beq	a0,s6,80003b62 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003b58:	2985                	addiw	s3,s3,1
    80003b5a:	0905                	addi	s2,s2,1
    80003b5c:	fd3a93e3          	bne	s5,s3,80003b22 <piperead+0x72>
    80003b60:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003b62:	21c48513          	addi	a0,s1,540
    80003b66:	93dfd0ef          	jal	800014a2 <wakeup>
  release(&pi->lock);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	6fd010ef          	jal	80005a68 <release>
    80003b70:	6b42                	ld	s6,16(sp)
  return i;
}
    80003b72:	854e                	mv	a0,s3
    80003b74:	60a6                	ld	ra,72(sp)
    80003b76:	6406                	ld	s0,64(sp)
    80003b78:	74e2                	ld	s1,56(sp)
    80003b7a:	7942                	ld	s2,48(sp)
    80003b7c:	79a2                	ld	s3,40(sp)
    80003b7e:	7a02                	ld	s4,32(sp)
    80003b80:	6ae2                	ld	s5,24(sp)
    80003b82:	6161                	addi	sp,sp,80
    80003b84:	8082                	ret

0000000080003b86 <flags2perm>:
//Load file contents into memory
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

//convert ELF flag into type of access  
int flags2perm(int flags)
{
    80003b86:	1141                	addi	sp,sp,-16
    80003b88:	e422                	sd	s0,8(sp)
    80003b8a:	0800                	addi	s0,sp,16
    80003b8c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003b8e:	8905                	andi	a0,a0,1
    80003b90:	050e                	slli	a0,a0,0x3
      perm = PTE_X; //execute access
    if(flags & 0x2)
    80003b92:	8b89                	andi	a5,a5,2
    80003b94:	c399                	beqz	a5,80003b9a <flags2perm+0x14>
      perm |= PTE_W; //write access
    80003b96:	00456513          	ori	a0,a0,4
    return perm;
}
    80003b9a:	6422                	ld	s0,8(sp)
    80003b9c:	0141                	addi	sp,sp,16
    80003b9e:	8082                	ret

0000000080003ba0 <exec>:

//execute file
int
exec(char *path, char **argv)
{
    80003ba0:	df010113          	addi	sp,sp,-528
    80003ba4:	20113423          	sd	ra,520(sp)
    80003ba8:	20813023          	sd	s0,512(sp)
    80003bac:	ffa6                	sd	s1,504(sp)
    80003bae:	fbca                	sd	s2,496(sp)
    80003bb0:	0c00                	addi	s0,sp,528
    80003bb2:	892a                	mv	s2,a0
    80003bb4:	dea43c23          	sd	a0,-520(s0)
    80003bb8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003bbc:	ac4fd0ef          	jal	80000e80 <myproc>
    80003bc0:	84aa                	mv	s1,a0

// open execute file
  begin_op(); //begin a transaction of file system
    80003bc2:	d76ff0ef          	jal	80003138 <begin_op>

  if((ip = namei(path)) == 0){ //find inode 
    80003bc6:	854a                	mv	a0,s2
    80003bc8:	bb4ff0ef          	jal	80002f7c <namei>
    80003bcc:	c931                	beqz	a0,80003c20 <exec+0x80>
    80003bce:	f3d2                	sd	s4,480(sp)
    80003bd0:	8a2a                	mv	s4,a0
    end_op(); // end transaction
    return -1;
  }
  ilock(ip); //lock inode to make sure that inode can not be modified during executing
    80003bd2:	cd1fe0ef          	jal	800028a2 <ilock>

  //read and check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) //read
    80003bd6:	04000713          	li	a4,64
    80003bda:	4681                	li	a3,0
    80003bdc:	e5040613          	addi	a2,s0,-432
    80003be0:	4581                	li	a1,0
    80003be2:	8552                	mv	a0,s4
    80003be4:	f13fe0ef          	jal	80002af6 <readi>
    80003be8:	04000793          	li	a5,64
    80003bec:	00f51a63          	bne	a0,a5,80003c00 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC) //check
    80003bf0:	e5042703          	lw	a4,-432(s0)
    80003bf4:	464c47b7          	lui	a5,0x464c4
    80003bf8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003bfc:	02f70663          	beq	a4,a5,80003c28 <exec+0x88>
//handle the unvalid
 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003c00:	8552                	mv	a0,s4
    80003c02:	eabfe0ef          	jal	80002aac <iunlockput>
    end_op();
    80003c06:	d9cff0ef          	jal	800031a2 <end_op>
  }
  return -1;
    80003c0a:	557d                	li	a0,-1
    80003c0c:	7a1e                	ld	s4,480(sp)
}
    80003c0e:	20813083          	ld	ra,520(sp)
    80003c12:	20013403          	ld	s0,512(sp)
    80003c16:	74fe                	ld	s1,504(sp)
    80003c18:	795e                	ld	s2,496(sp)
    80003c1a:	21010113          	addi	sp,sp,528
    80003c1e:	8082                	ret
    end_op(); // end transaction
    80003c20:	d82ff0ef          	jal	800031a2 <end_op>
    return -1;
    80003c24:	557d                	li	a0,-1
    80003c26:	b7e5                	j	80003c0e <exec+0x6e>
    80003c28:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0) //create new pagetable for executing
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	afcfd0ef          	jal	80000f28 <proc_pagetable>
    80003c30:	8b2a                	mv	s6,a0
    80003c32:	2c050e63          	beqz	a0,80003f0e <exec+0x36e>
    80003c36:	f7ce                	sd	s3,488(sp)
    80003c38:	efd6                	sd	s5,472(sp)
    80003c3a:	e7de                	sd	s7,456(sp)
    80003c3c:	e3e2                	sd	s8,448(sp)
    80003c3e:	ff66                	sd	s9,440(sp)
    80003c40:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c42:	e7042d03          	lw	s10,-400(s0)
    80003c46:	e8845783          	lhu	a5,-376(s0)
    80003c4a:	12078963          	beqz	a5,80003d7c <exec+0x1dc>
    80003c4e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003c50:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003c52:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003c54:	6c85                	lui	s9,0x1
    80003c56:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003c5a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003c5e:	6a85                	lui	s5,0x1
    80003c60:	a085                	j	80003cc0 <exec+0x120>
      panic("loadseg: address should exist");
    80003c62:	00004517          	auipc	a0,0x4
    80003c66:	a5e50513          	addi	a0,a0,-1442 # 800076c0 <etext+0x6c0>
    80003c6a:	239010ef          	jal	800056a2 <panic>
    if(sz - i < PGSIZE)
    80003c6e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003c70:	8726                	mv	a4,s1
    80003c72:	012c06bb          	addw	a3,s8,s2
    80003c76:	4581                	li	a1,0
    80003c78:	8552                	mv	a0,s4
    80003c7a:	e7dfe0ef          	jal	80002af6 <readi>
    80003c7e:	2501                	sext.w	a0,a0
    80003c80:	24a49d63          	bne	s1,a0,80003eda <exec+0x33a>
  for(i = 0; i < sz; i += PGSIZE){
    80003c84:	012a893b          	addw	s2,s5,s2
    80003c88:	03397363          	bgeu	s2,s3,80003cae <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003c8c:	02091593          	slli	a1,s2,0x20
    80003c90:	9181                	srli	a1,a1,0x20
    80003c92:	95de                	add	a1,a1,s7
    80003c94:	855a                	mv	a0,s6
    80003c96:	809fc0ef          	jal	8000049e <walkaddr>
    80003c9a:	862a                	mv	a2,a0
    if(pa == 0)
    80003c9c:	d179                	beqz	a0,80003c62 <exec+0xc2>
    if(sz - i < PGSIZE)
    80003c9e:	412984bb          	subw	s1,s3,s2
    80003ca2:	0004879b          	sext.w	a5,s1
    80003ca6:	fcfcf4e3          	bgeu	s9,a5,80003c6e <exec+0xce>
    80003caa:	84d6                	mv	s1,s5
    80003cac:	b7c9                	j	80003c6e <exec+0xce>
    sz = sz1;
    80003cae:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003cb2:	2d85                	addiw	s11,s11,1
    80003cb4:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003cb8:	e8845783          	lhu	a5,-376(s0)
    80003cbc:	08fdd063          	bge	s11,a5,80003d3c <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003cc0:	2d01                	sext.w	s10,s10
    80003cc2:	03800713          	li	a4,56
    80003cc6:	86ea                	mv	a3,s10
    80003cc8:	e1840613          	addi	a2,s0,-488
    80003ccc:	4581                	li	a1,0
    80003cce:	8552                	mv	a0,s4
    80003cd0:	e27fe0ef          	jal	80002af6 <readi>
    80003cd4:	03800793          	li	a5,56
    80003cd8:	1cf51963          	bne	a0,a5,80003eaa <exec+0x30a>
    if(ph.type != ELF_PROG_LOAD) //checks if a segment is the type to load into memory 
    80003cdc:	e1842783          	lw	a5,-488(s0)
    80003ce0:	4705                	li	a4,1
    80003ce2:	fce798e3          	bne	a5,a4,80003cb2 <exec+0x112>
    if(ph.memsz < ph.filesz) //memory size >= file size
    80003ce6:	e4043483          	ld	s1,-448(s0)
    80003cea:	e3843783          	ld	a5,-456(s0)
    80003cee:	1cf4e263          	bltu	s1,a5,80003eb2 <exec+0x312>
    if(ph.vaddr + ph.memsz < ph.vaddr) //address must align to the page size
    80003cf2:	e2843783          	ld	a5,-472(s0)
    80003cf6:	94be                	add	s1,s1,a5
    80003cf8:	1cf4e163          	bltu	s1,a5,80003eba <exec+0x31a>
    if(ph.vaddr % PGSIZE != 0)
    80003cfc:	df043703          	ld	a4,-528(s0)
    80003d00:	8ff9                	and	a5,a5,a4
    80003d02:	1c079063          	bnez	a5,80003ec2 <exec+0x322>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)//allocate memory for segment
    80003d06:	e1c42503          	lw	a0,-484(s0)
    80003d0a:	e7dff0ef          	jal	80003b86 <flags2perm>
    80003d0e:	86aa                	mv	a3,a0
    80003d10:	8626                	mv	a2,s1
    80003d12:	85ca                	mv	a1,s2
    80003d14:	855a                	mv	a0,s6
    80003d16:	af1fc0ef          	jal	80000806 <uvmalloc>
    80003d1a:	e0a43423          	sd	a0,-504(s0)
    80003d1e:	1a050663          	beqz	a0,80003eca <exec+0x32a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0) //Load file contents into memory
    80003d22:	e2843b83          	ld	s7,-472(s0)
    80003d26:	e2042c03          	lw	s8,-480(s0)
    80003d2a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003d2e:	00098463          	beqz	s3,80003d36 <exec+0x196>
    80003d32:	4901                	li	s2,0
    80003d34:	bfa1                	j	80003c8c <exec+0xec>
    sz = sz1;
    80003d36:	e0843903          	ld	s2,-504(s0)
    80003d3a:	bfa5                	j	80003cb2 <exec+0x112>
    80003d3c:	7dba                	ld	s11,424(sp)
  iunlockput(ip); //unlock ip
    80003d3e:	8552                	mv	a0,s4
    80003d40:	d6dfe0ef          	jal	80002aac <iunlockput>
  end_op(); // end transaction
    80003d44:	c5eff0ef          	jal	800031a2 <end_op>
  p = myproc();
    80003d48:	938fd0ef          	jal	80000e80 <myproc>
    80003d4c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003d4e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz); //round the value
    80003d52:	6985                	lui	s3,0x1
    80003d54:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003d56:	99ca                	add	s3,s3,s2
    80003d58:	77fd                	lui	a5,0xfffff
    80003d5a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0) //allocate stack space in memory.
    80003d5e:	4691                	li	a3,4
    80003d60:	660d                	lui	a2,0x3
    80003d62:	964e                	add	a2,a2,s3
    80003d64:	85ce                	mv	a1,s3
    80003d66:	855a                	mv	a0,s6
    80003d68:	a9ffc0ef          	jal	80000806 <uvmalloc>
    80003d6c:	892a                	mv	s2,a0
    80003d6e:	e0a43423          	sd	a0,-504(s0)
    80003d72:	e519                	bnez	a0,80003d80 <exec+0x1e0>
  if(pagetable)
    80003d74:	e1343423          	sd	s3,-504(s0)
    80003d78:	4a01                	li	s4,0
    80003d7a:	a28d                	j	80003edc <exec+0x33c>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d7c:	4901                	li	s2,0
    80003d7e:	b7c1                	j	80003d3e <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE); //makes the first page inaccessible, acting as a "stack guard".
    80003d80:	75f5                	lui	a1,0xffffd
    80003d82:	95aa                	add	a1,a1,a0
    80003d84:	855a                	mv	a0,s6
    80003d86:	c6bfc0ef          	jal	800009f0 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003d8a:	7bf9                	lui	s7,0xffffe
    80003d8c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003d8e:	e0043783          	ld	a5,-512(s0)
    80003d92:	6388                	ld	a0,0(a5)
    80003d94:	cd39                	beqz	a0,80003df2 <exec+0x252>
    80003d96:	e9040993          	addi	s3,s0,-368
    80003d9a:	f9040c13          	addi	s8,s0,-112
    80003d9e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003da0:	d60fc0ef          	jal	80000300 <strlen>
    80003da4:	0015079b          	addiw	a5,a0,1
    80003da8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003dac:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003db0:	13796163          	bltu	s2,s7,80003ed2 <exec+0x332>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003db4:	e0043d03          	ld	s10,-512(s0)
    80003db8:	000d3a03          	ld	s4,0(s10)
    80003dbc:	8552                	mv	a0,s4
    80003dbe:	d42fc0ef          	jal	80000300 <strlen>
    80003dc2:	0015069b          	addiw	a3,a0,1
    80003dc6:	8652                	mv	a2,s4
    80003dc8:	85ca                	mv	a1,s2
    80003dca:	855a                	mv	a0,s6
    80003dcc:	c4ffc0ef          	jal	80000a1a <copyout>
    80003dd0:	10054363          	bltz	a0,80003ed6 <exec+0x336>
    ustack[argc] = sp;
    80003dd4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003dd8:	0485                	addi	s1,s1,1
    80003dda:	008d0793          	addi	a5,s10,8
    80003dde:	e0f43023          	sd	a5,-512(s0)
    80003de2:	008d3503          	ld	a0,8(s10)
    80003de6:	c909                	beqz	a0,80003df8 <exec+0x258>
    if(argc >= MAXARG)
    80003de8:	09a1                	addi	s3,s3,8
    80003dea:	fb899be3          	bne	s3,s8,80003da0 <exec+0x200>
  ip = 0;
    80003dee:	4a01                	li	s4,0
    80003df0:	a0f5                	j	80003edc <exec+0x33c>
  sp = sz;
    80003df2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003df6:	4481                	li	s1,0
  ustack[argc] = 0;
    80003df8:	00349793          	slli	a5,s1,0x3
    80003dfc:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb490>
    80003e00:	97a2                	add	a5,a5,s0
    80003e02:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003e06:	00148693          	addi	a3,s1,1
    80003e0a:	068e                	slli	a3,a3,0x3
    80003e0c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003e10:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003e14:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003e18:	f5796ee3          	bltu	s2,s7,80003d74 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003e1c:	e9040613          	addi	a2,s0,-368
    80003e20:	85ca                	mv	a1,s2
    80003e22:	855a                	mv	a0,s6
    80003e24:	bf7fc0ef          	jal	80000a1a <copyout>
    80003e28:	0e054563          	bltz	a0,80003f12 <exec+0x372>
  p->trapframe->a1 = sp;
    80003e2c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003e30:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003e34:	df843783          	ld	a5,-520(s0)
    80003e38:	0007c703          	lbu	a4,0(a5)
    80003e3c:	cf11                	beqz	a4,80003e58 <exec+0x2b8>
    80003e3e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003e40:	02f00693          	li	a3,47
    80003e44:	a039                	j	80003e52 <exec+0x2b2>
      last = s+1;
    80003e46:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003e4a:	0785                	addi	a5,a5,1
    80003e4c:	fff7c703          	lbu	a4,-1(a5)
    80003e50:	c701                	beqz	a4,80003e58 <exec+0x2b8>
    if(*s == '/')
    80003e52:	fed71ce3          	bne	a4,a3,80003e4a <exec+0x2aa>
    80003e56:	bfc5                	j	80003e46 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003e58:	4641                	li	a2,16
    80003e5a:	df843583          	ld	a1,-520(s0)
    80003e5e:	158a8513          	addi	a0,s5,344
    80003e62:	c6cfc0ef          	jal	800002ce <safestrcpy>
  oldpagetable = p->pagetable;
    80003e66:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003e6a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003e6e:	e0843783          	ld	a5,-504(s0)
    80003e72:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003e76:	058ab783          	ld	a5,88(s5)
    80003e7a:	e6843703          	ld	a4,-408(s0)
    80003e7e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003e80:	058ab783          	ld	a5,88(s5)
    80003e84:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); //deallocate the old page table
    80003e88:	85e6                	mv	a1,s9
    80003e8a:	922fd0ef          	jal	80000fac <proc_freepagetable>
  vm_print(pagetable);
    80003e8e:	855a                	mv	a0,s6
    80003e90:	e4bfc0ef          	jal	80000cda <vm_print>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003e94:	0004851b          	sext.w	a0,s1
    80003e98:	79be                	ld	s3,488(sp)
    80003e9a:	7a1e                	ld	s4,480(sp)
    80003e9c:	6afe                	ld	s5,472(sp)
    80003e9e:	6b5e                	ld	s6,464(sp)
    80003ea0:	6bbe                	ld	s7,456(sp)
    80003ea2:	6c1e                	ld	s8,448(sp)
    80003ea4:	7cfa                	ld	s9,440(sp)
    80003ea6:	7d5a                	ld	s10,432(sp)
    80003ea8:	b39d                	j	80003c0e <exec+0x6e>
    80003eaa:	e1243423          	sd	s2,-504(s0)
    80003eae:	7dba                	ld	s11,424(sp)
    80003eb0:	a035                	j	80003edc <exec+0x33c>
    80003eb2:	e1243423          	sd	s2,-504(s0)
    80003eb6:	7dba                	ld	s11,424(sp)
    80003eb8:	a015                	j	80003edc <exec+0x33c>
    80003eba:	e1243423          	sd	s2,-504(s0)
    80003ebe:	7dba                	ld	s11,424(sp)
    80003ec0:	a831                	j	80003edc <exec+0x33c>
    80003ec2:	e1243423          	sd	s2,-504(s0)
    80003ec6:	7dba                	ld	s11,424(sp)
    80003ec8:	a811                	j	80003edc <exec+0x33c>
    80003eca:	e1243423          	sd	s2,-504(s0)
    80003ece:	7dba                	ld	s11,424(sp)
    80003ed0:	a031                	j	80003edc <exec+0x33c>
  ip = 0;
    80003ed2:	4a01                	li	s4,0
    80003ed4:	a021                	j	80003edc <exec+0x33c>
    80003ed6:	4a01                	li	s4,0
  if(pagetable)
    80003ed8:	a011                	j	80003edc <exec+0x33c>
    80003eda:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003edc:	e0843583          	ld	a1,-504(s0)
    80003ee0:	855a                	mv	a0,s6
    80003ee2:	8cafd0ef          	jal	80000fac <proc_freepagetable>
  return -1;
    80003ee6:	557d                	li	a0,-1
  if(ip){
    80003ee8:	000a1b63          	bnez	s4,80003efe <exec+0x35e>
    80003eec:	79be                	ld	s3,488(sp)
    80003eee:	7a1e                	ld	s4,480(sp)
    80003ef0:	6afe                	ld	s5,472(sp)
    80003ef2:	6b5e                	ld	s6,464(sp)
    80003ef4:	6bbe                	ld	s7,456(sp)
    80003ef6:	6c1e                	ld	s8,448(sp)
    80003ef8:	7cfa                	ld	s9,440(sp)
    80003efa:	7d5a                	ld	s10,432(sp)
    80003efc:	bb09                	j	80003c0e <exec+0x6e>
    80003efe:	79be                	ld	s3,488(sp)
    80003f00:	6afe                	ld	s5,472(sp)
    80003f02:	6b5e                	ld	s6,464(sp)
    80003f04:	6bbe                	ld	s7,456(sp)
    80003f06:	6c1e                	ld	s8,448(sp)
    80003f08:	7cfa                	ld	s9,440(sp)
    80003f0a:	7d5a                	ld	s10,432(sp)
    80003f0c:	b9d5                	j	80003c00 <exec+0x60>
    80003f0e:	6b5e                	ld	s6,464(sp)
    80003f10:	b9c5                	j	80003c00 <exec+0x60>
  sz = sz1;
    80003f12:	e0843983          	ld	s3,-504(s0)
    80003f16:	bdb9                	j	80003d74 <exec+0x1d4>

0000000080003f18 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003f18:	7179                	addi	sp,sp,-48
    80003f1a:	f406                	sd	ra,40(sp)
    80003f1c:	f022                	sd	s0,32(sp)
    80003f1e:	ec26                	sd	s1,24(sp)
    80003f20:	e84a                	sd	s2,16(sp)
    80003f22:	1800                	addi	s0,sp,48
    80003f24:	892e                	mv	s2,a1
    80003f26:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003f28:	fdc40593          	addi	a1,s0,-36
    80003f2c:	e3ffd0ef          	jal	80001d6a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003f30:	fdc42703          	lw	a4,-36(s0)
    80003f34:	47bd                	li	a5,15
    80003f36:	02e7e963          	bltu	a5,a4,80003f68 <argfd+0x50>
    80003f3a:	f47fc0ef          	jal	80000e80 <myproc>
    80003f3e:	fdc42703          	lw	a4,-36(s0)
    80003f42:	01a70793          	addi	a5,a4,26
    80003f46:	078e                	slli	a5,a5,0x3
    80003f48:	953e                	add	a0,a0,a5
    80003f4a:	611c                	ld	a5,0(a0)
    80003f4c:	c385                	beqz	a5,80003f6c <argfd+0x54>
    return -1;
  if(pfd)
    80003f4e:	00090463          	beqz	s2,80003f56 <argfd+0x3e>
    *pfd = fd;
    80003f52:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003f56:	4501                	li	a0,0
  if(pf)
    80003f58:	c091                	beqz	s1,80003f5c <argfd+0x44>
    *pf = f;
    80003f5a:	e09c                	sd	a5,0(s1)
}
    80003f5c:	70a2                	ld	ra,40(sp)
    80003f5e:	7402                	ld	s0,32(sp)
    80003f60:	64e2                	ld	s1,24(sp)
    80003f62:	6942                	ld	s2,16(sp)
    80003f64:	6145                	addi	sp,sp,48
    80003f66:	8082                	ret
    return -1;
    80003f68:	557d                	li	a0,-1
    80003f6a:	bfcd                	j	80003f5c <argfd+0x44>
    80003f6c:	557d                	li	a0,-1
    80003f6e:	b7fd                	j	80003f5c <argfd+0x44>

0000000080003f70 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003f70:	1101                	addi	sp,sp,-32
    80003f72:	ec06                	sd	ra,24(sp)
    80003f74:	e822                	sd	s0,16(sp)
    80003f76:	e426                	sd	s1,8(sp)
    80003f78:	1000                	addi	s0,sp,32
    80003f7a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003f7c:	f05fc0ef          	jal	80000e80 <myproc>
    80003f80:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003f82:	0d050793          	addi	a5,a0,208
    80003f86:	4501                	li	a0,0
    80003f88:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003f8a:	6398                	ld	a4,0(a5)
    80003f8c:	cb19                	beqz	a4,80003fa2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003f8e:	2505                	addiw	a0,a0,1
    80003f90:	07a1                	addi	a5,a5,8
    80003f92:	fed51ce3          	bne	a0,a3,80003f8a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003f96:	557d                	li	a0,-1
}
    80003f98:	60e2                	ld	ra,24(sp)
    80003f9a:	6442                	ld	s0,16(sp)
    80003f9c:	64a2                	ld	s1,8(sp)
    80003f9e:	6105                	addi	sp,sp,32
    80003fa0:	8082                	ret
      p->ofile[fd] = f;
    80003fa2:	01a50793          	addi	a5,a0,26
    80003fa6:	078e                	slli	a5,a5,0x3
    80003fa8:	963e                	add	a2,a2,a5
    80003faa:	e204                	sd	s1,0(a2)
      return fd;
    80003fac:	b7f5                	j	80003f98 <fdalloc+0x28>

0000000080003fae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003fae:	715d                	addi	sp,sp,-80
    80003fb0:	e486                	sd	ra,72(sp)
    80003fb2:	e0a2                	sd	s0,64(sp)
    80003fb4:	fc26                	sd	s1,56(sp)
    80003fb6:	f84a                	sd	s2,48(sp)
    80003fb8:	f44e                	sd	s3,40(sp)
    80003fba:	ec56                	sd	s5,24(sp)
    80003fbc:	e85a                	sd	s6,16(sp)
    80003fbe:	0880                	addi	s0,sp,80
    80003fc0:	8b2e                	mv	s6,a1
    80003fc2:	89b2                	mv	s3,a2
    80003fc4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003fc6:	fb040593          	addi	a1,s0,-80
    80003fca:	fcdfe0ef          	jal	80002f96 <nameiparent>
    80003fce:	84aa                	mv	s1,a0
    80003fd0:	10050a63          	beqz	a0,800040e4 <create+0x136>
    return 0;

  ilock(dp);
    80003fd4:	8cffe0ef          	jal	800028a2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fd8:	4601                	li	a2,0
    80003fda:	fb040593          	addi	a1,s0,-80
    80003fde:	8526                	mv	a0,s1
    80003fe0:	d37fe0ef          	jal	80002d16 <dirlookup>
    80003fe4:	8aaa                	mv	s5,a0
    80003fe6:	c129                	beqz	a0,80004028 <create+0x7a>
    iunlockput(dp);
    80003fe8:	8526                	mv	a0,s1
    80003fea:	ac3fe0ef          	jal	80002aac <iunlockput>
    ilock(ip);
    80003fee:	8556                	mv	a0,s5
    80003ff0:	8b3fe0ef          	jal	800028a2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003ff4:	4789                	li	a5,2
    80003ff6:	02fb1463          	bne	s6,a5,8000401e <create+0x70>
    80003ffa:	044ad783          	lhu	a5,68(s5)
    80003ffe:	37f9                	addiw	a5,a5,-2
    80004000:	17c2                	slli	a5,a5,0x30
    80004002:	93c1                	srli	a5,a5,0x30
    80004004:	4705                	li	a4,1
    80004006:	00f76c63          	bltu	a4,a5,8000401e <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000400a:	8556                	mv	a0,s5
    8000400c:	60a6                	ld	ra,72(sp)
    8000400e:	6406                	ld	s0,64(sp)
    80004010:	74e2                	ld	s1,56(sp)
    80004012:	7942                	ld	s2,48(sp)
    80004014:	79a2                	ld	s3,40(sp)
    80004016:	6ae2                	ld	s5,24(sp)
    80004018:	6b42                	ld	s6,16(sp)
    8000401a:	6161                	addi	sp,sp,80
    8000401c:	8082                	ret
    iunlockput(ip);
    8000401e:	8556                	mv	a0,s5
    80004020:	a8dfe0ef          	jal	80002aac <iunlockput>
    return 0;
    80004024:	4a81                	li	s5,0
    80004026:	b7d5                	j	8000400a <create+0x5c>
    80004028:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000402a:	85da                	mv	a1,s6
    8000402c:	4088                	lw	a0,0(s1)
    8000402e:	f04fe0ef          	jal	80002732 <ialloc>
    80004032:	8a2a                	mv	s4,a0
    80004034:	cd15                	beqz	a0,80004070 <create+0xc2>
  ilock(ip);
    80004036:	86dfe0ef          	jal	800028a2 <ilock>
  ip->major = major;
    8000403a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000403e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004042:	4905                	li	s2,1
    80004044:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004048:	8552                	mv	a0,s4
    8000404a:	fa4fe0ef          	jal	800027ee <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000404e:	032b0763          	beq	s6,s2,8000407c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004052:	004a2603          	lw	a2,4(s4)
    80004056:	fb040593          	addi	a1,s0,-80
    8000405a:	8526                	mv	a0,s1
    8000405c:	e87fe0ef          	jal	80002ee2 <dirlink>
    80004060:	06054563          	bltz	a0,800040ca <create+0x11c>
  iunlockput(dp);
    80004064:	8526                	mv	a0,s1
    80004066:	a47fe0ef          	jal	80002aac <iunlockput>
  return ip;
    8000406a:	8ad2                	mv	s5,s4
    8000406c:	7a02                	ld	s4,32(sp)
    8000406e:	bf71                	j	8000400a <create+0x5c>
    iunlockput(dp);
    80004070:	8526                	mv	a0,s1
    80004072:	a3bfe0ef          	jal	80002aac <iunlockput>
    return 0;
    80004076:	8ad2                	mv	s5,s4
    80004078:	7a02                	ld	s4,32(sp)
    8000407a:	bf41                	j	8000400a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000407c:	004a2603          	lw	a2,4(s4)
    80004080:	00003597          	auipc	a1,0x3
    80004084:	66058593          	addi	a1,a1,1632 # 800076e0 <etext+0x6e0>
    80004088:	8552                	mv	a0,s4
    8000408a:	e59fe0ef          	jal	80002ee2 <dirlink>
    8000408e:	02054e63          	bltz	a0,800040ca <create+0x11c>
    80004092:	40d0                	lw	a2,4(s1)
    80004094:	00003597          	auipc	a1,0x3
    80004098:	65458593          	addi	a1,a1,1620 # 800076e8 <etext+0x6e8>
    8000409c:	8552                	mv	a0,s4
    8000409e:	e45fe0ef          	jal	80002ee2 <dirlink>
    800040a2:	02054463          	bltz	a0,800040ca <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800040a6:	004a2603          	lw	a2,4(s4)
    800040aa:	fb040593          	addi	a1,s0,-80
    800040ae:	8526                	mv	a0,s1
    800040b0:	e33fe0ef          	jal	80002ee2 <dirlink>
    800040b4:	00054b63          	bltz	a0,800040ca <create+0x11c>
    dp->nlink++;  // for ".."
    800040b8:	04a4d783          	lhu	a5,74(s1)
    800040bc:	2785                	addiw	a5,a5,1
    800040be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800040c2:	8526                	mv	a0,s1
    800040c4:	f2afe0ef          	jal	800027ee <iupdate>
    800040c8:	bf71                	j	80004064 <create+0xb6>
  ip->nlink = 0;
    800040ca:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800040ce:	8552                	mv	a0,s4
    800040d0:	f1efe0ef          	jal	800027ee <iupdate>
  iunlockput(ip);
    800040d4:	8552                	mv	a0,s4
    800040d6:	9d7fe0ef          	jal	80002aac <iunlockput>
  iunlockput(dp);
    800040da:	8526                	mv	a0,s1
    800040dc:	9d1fe0ef          	jal	80002aac <iunlockput>
  return 0;
    800040e0:	7a02                	ld	s4,32(sp)
    800040e2:	b725                	j	8000400a <create+0x5c>
    return 0;
    800040e4:	8aaa                	mv	s5,a0
    800040e6:	b715                	j	8000400a <create+0x5c>

00000000800040e8 <sys_dup>:
{
    800040e8:	7179                	addi	sp,sp,-48
    800040ea:	f406                	sd	ra,40(sp)
    800040ec:	f022                	sd	s0,32(sp)
    800040ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800040f0:	fd840613          	addi	a2,s0,-40
    800040f4:	4581                	li	a1,0
    800040f6:	4501                	li	a0,0
    800040f8:	e21ff0ef          	jal	80003f18 <argfd>
    return -1;
    800040fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800040fe:	02054363          	bltz	a0,80004124 <sys_dup+0x3c>
    80004102:	ec26                	sd	s1,24(sp)
    80004104:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004106:	fd843903          	ld	s2,-40(s0)
    8000410a:	854a                	mv	a0,s2
    8000410c:	e65ff0ef          	jal	80003f70 <fdalloc>
    80004110:	84aa                	mv	s1,a0
    return -1;
    80004112:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004114:	00054d63          	bltz	a0,8000412e <sys_dup+0x46>
  filedup(f);
    80004118:	854a                	mv	a0,s2
    8000411a:	bf2ff0ef          	jal	8000350c <filedup>
  return fd;
    8000411e:	87a6                	mv	a5,s1
    80004120:	64e2                	ld	s1,24(sp)
    80004122:	6942                	ld	s2,16(sp)
}
    80004124:	853e                	mv	a0,a5
    80004126:	70a2                	ld	ra,40(sp)
    80004128:	7402                	ld	s0,32(sp)
    8000412a:	6145                	addi	sp,sp,48
    8000412c:	8082                	ret
    8000412e:	64e2                	ld	s1,24(sp)
    80004130:	6942                	ld	s2,16(sp)
    80004132:	bfcd                	j	80004124 <sys_dup+0x3c>

0000000080004134 <sys_read>:
{
    80004134:	7179                	addi	sp,sp,-48
    80004136:	f406                	sd	ra,40(sp)
    80004138:	f022                	sd	s0,32(sp)
    8000413a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000413c:	fd840593          	addi	a1,s0,-40
    80004140:	4505                	li	a0,1
    80004142:	c45fd0ef          	jal	80001d86 <argaddr>
  argint(2, &n);
    80004146:	fe440593          	addi	a1,s0,-28
    8000414a:	4509                	li	a0,2
    8000414c:	c1ffd0ef          	jal	80001d6a <argint>
  if(argfd(0, 0, &f) < 0)
    80004150:	fe840613          	addi	a2,s0,-24
    80004154:	4581                	li	a1,0
    80004156:	4501                	li	a0,0
    80004158:	dc1ff0ef          	jal	80003f18 <argfd>
    8000415c:	87aa                	mv	a5,a0
    return -1;
    8000415e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004160:	0007ca63          	bltz	a5,80004174 <sys_read+0x40>
  return fileread(f, p, n);
    80004164:	fe442603          	lw	a2,-28(s0)
    80004168:	fd843583          	ld	a1,-40(s0)
    8000416c:	fe843503          	ld	a0,-24(s0)
    80004170:	d02ff0ef          	jal	80003672 <fileread>
}
    80004174:	70a2                	ld	ra,40(sp)
    80004176:	7402                	ld	s0,32(sp)
    80004178:	6145                	addi	sp,sp,48
    8000417a:	8082                	ret

000000008000417c <sys_write>:
{
    8000417c:	7179                	addi	sp,sp,-48
    8000417e:	f406                	sd	ra,40(sp)
    80004180:	f022                	sd	s0,32(sp)
    80004182:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004184:	fd840593          	addi	a1,s0,-40
    80004188:	4505                	li	a0,1
    8000418a:	bfdfd0ef          	jal	80001d86 <argaddr>
  argint(2, &n);
    8000418e:	fe440593          	addi	a1,s0,-28
    80004192:	4509                	li	a0,2
    80004194:	bd7fd0ef          	jal	80001d6a <argint>
  if(argfd(0, 0, &f) < 0)
    80004198:	fe840613          	addi	a2,s0,-24
    8000419c:	4581                	li	a1,0
    8000419e:	4501                	li	a0,0
    800041a0:	d79ff0ef          	jal	80003f18 <argfd>
    800041a4:	87aa                	mv	a5,a0
    return -1;
    800041a6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800041a8:	0007ca63          	bltz	a5,800041bc <sys_write+0x40>
  return filewrite(f, p, n);
    800041ac:	fe442603          	lw	a2,-28(s0)
    800041b0:	fd843583          	ld	a1,-40(s0)
    800041b4:	fe843503          	ld	a0,-24(s0)
    800041b8:	d78ff0ef          	jal	80003730 <filewrite>
}
    800041bc:	70a2                	ld	ra,40(sp)
    800041be:	7402                	ld	s0,32(sp)
    800041c0:	6145                	addi	sp,sp,48
    800041c2:	8082                	ret

00000000800041c4 <sys_close>:
{
    800041c4:	1101                	addi	sp,sp,-32
    800041c6:	ec06                	sd	ra,24(sp)
    800041c8:	e822                	sd	s0,16(sp)
    800041ca:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800041cc:	fe040613          	addi	a2,s0,-32
    800041d0:	fec40593          	addi	a1,s0,-20
    800041d4:	4501                	li	a0,0
    800041d6:	d43ff0ef          	jal	80003f18 <argfd>
    return -1;
    800041da:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800041dc:	02054063          	bltz	a0,800041fc <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800041e0:	ca1fc0ef          	jal	80000e80 <myproc>
    800041e4:	fec42783          	lw	a5,-20(s0)
    800041e8:	07e9                	addi	a5,a5,26
    800041ea:	078e                	slli	a5,a5,0x3
    800041ec:	953e                	add	a0,a0,a5
    800041ee:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800041f2:	fe043503          	ld	a0,-32(s0)
    800041f6:	b5cff0ef          	jal	80003552 <fileclose>
  return 0;
    800041fa:	4781                	li	a5,0
}
    800041fc:	853e                	mv	a0,a5
    800041fe:	60e2                	ld	ra,24(sp)
    80004200:	6442                	ld	s0,16(sp)
    80004202:	6105                	addi	sp,sp,32
    80004204:	8082                	ret

0000000080004206 <sys_fstat>:
{
    80004206:	1101                	addi	sp,sp,-32
    80004208:	ec06                	sd	ra,24(sp)
    8000420a:	e822                	sd	s0,16(sp)
    8000420c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000420e:	fe040593          	addi	a1,s0,-32
    80004212:	4505                	li	a0,1
    80004214:	b73fd0ef          	jal	80001d86 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004218:	fe840613          	addi	a2,s0,-24
    8000421c:	4581                	li	a1,0
    8000421e:	4501                	li	a0,0
    80004220:	cf9ff0ef          	jal	80003f18 <argfd>
    80004224:	87aa                	mv	a5,a0
    return -1;
    80004226:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004228:	0007c863          	bltz	a5,80004238 <sys_fstat+0x32>
  return filestat(f, st);
    8000422c:	fe043583          	ld	a1,-32(s0)
    80004230:	fe843503          	ld	a0,-24(s0)
    80004234:	be0ff0ef          	jal	80003614 <filestat>
}
    80004238:	60e2                	ld	ra,24(sp)
    8000423a:	6442                	ld	s0,16(sp)
    8000423c:	6105                	addi	sp,sp,32
    8000423e:	8082                	ret

0000000080004240 <sys_link>:
{
    80004240:	7169                	addi	sp,sp,-304
    80004242:	f606                	sd	ra,296(sp)
    80004244:	f222                	sd	s0,288(sp)
    80004246:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004248:	08000613          	li	a2,128
    8000424c:	ed040593          	addi	a1,s0,-304
    80004250:	4501                	li	a0,0
    80004252:	b51fd0ef          	jal	80001da2 <argstr>
    return -1;
    80004256:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004258:	0c054e63          	bltz	a0,80004334 <sys_link+0xf4>
    8000425c:	08000613          	li	a2,128
    80004260:	f5040593          	addi	a1,s0,-176
    80004264:	4505                	li	a0,1
    80004266:	b3dfd0ef          	jal	80001da2 <argstr>
    return -1;
    8000426a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000426c:	0c054463          	bltz	a0,80004334 <sys_link+0xf4>
    80004270:	ee26                	sd	s1,280(sp)
  begin_op();
    80004272:	ec7fe0ef          	jal	80003138 <begin_op>
  if((ip = namei(old)) == 0){
    80004276:	ed040513          	addi	a0,s0,-304
    8000427a:	d03fe0ef          	jal	80002f7c <namei>
    8000427e:	84aa                	mv	s1,a0
    80004280:	c53d                	beqz	a0,800042ee <sys_link+0xae>
  ilock(ip);
    80004282:	e20fe0ef          	jal	800028a2 <ilock>
  if(ip->type == T_DIR){
    80004286:	04449703          	lh	a4,68(s1)
    8000428a:	4785                	li	a5,1
    8000428c:	06f70663          	beq	a4,a5,800042f8 <sys_link+0xb8>
    80004290:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004292:	04a4d783          	lhu	a5,74(s1)
    80004296:	2785                	addiw	a5,a5,1
    80004298:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000429c:	8526                	mv	a0,s1
    8000429e:	d50fe0ef          	jal	800027ee <iupdate>
  iunlock(ip);
    800042a2:	8526                	mv	a0,s1
    800042a4:	eacfe0ef          	jal	80002950 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800042a8:	fd040593          	addi	a1,s0,-48
    800042ac:	f5040513          	addi	a0,s0,-176
    800042b0:	ce7fe0ef          	jal	80002f96 <nameiparent>
    800042b4:	892a                	mv	s2,a0
    800042b6:	cd21                	beqz	a0,8000430e <sys_link+0xce>
  ilock(dp);
    800042b8:	deafe0ef          	jal	800028a2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800042bc:	00092703          	lw	a4,0(s2)
    800042c0:	409c                	lw	a5,0(s1)
    800042c2:	04f71363          	bne	a4,a5,80004308 <sys_link+0xc8>
    800042c6:	40d0                	lw	a2,4(s1)
    800042c8:	fd040593          	addi	a1,s0,-48
    800042cc:	854a                	mv	a0,s2
    800042ce:	c15fe0ef          	jal	80002ee2 <dirlink>
    800042d2:	02054b63          	bltz	a0,80004308 <sys_link+0xc8>
  iunlockput(dp);
    800042d6:	854a                	mv	a0,s2
    800042d8:	fd4fe0ef          	jal	80002aac <iunlockput>
  iput(ip);
    800042dc:	8526                	mv	a0,s1
    800042de:	f46fe0ef          	jal	80002a24 <iput>
  end_op();
    800042e2:	ec1fe0ef          	jal	800031a2 <end_op>
  return 0;
    800042e6:	4781                	li	a5,0
    800042e8:	64f2                	ld	s1,280(sp)
    800042ea:	6952                	ld	s2,272(sp)
    800042ec:	a0a1                	j	80004334 <sys_link+0xf4>
    end_op();
    800042ee:	eb5fe0ef          	jal	800031a2 <end_op>
    return -1;
    800042f2:	57fd                	li	a5,-1
    800042f4:	64f2                	ld	s1,280(sp)
    800042f6:	a83d                	j	80004334 <sys_link+0xf4>
    iunlockput(ip);
    800042f8:	8526                	mv	a0,s1
    800042fa:	fb2fe0ef          	jal	80002aac <iunlockput>
    end_op();
    800042fe:	ea5fe0ef          	jal	800031a2 <end_op>
    return -1;
    80004302:	57fd                	li	a5,-1
    80004304:	64f2                	ld	s1,280(sp)
    80004306:	a03d                	j	80004334 <sys_link+0xf4>
    iunlockput(dp);
    80004308:	854a                	mv	a0,s2
    8000430a:	fa2fe0ef          	jal	80002aac <iunlockput>
  ilock(ip);
    8000430e:	8526                	mv	a0,s1
    80004310:	d92fe0ef          	jal	800028a2 <ilock>
  ip->nlink--;
    80004314:	04a4d783          	lhu	a5,74(s1)
    80004318:	37fd                	addiw	a5,a5,-1
    8000431a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000431e:	8526                	mv	a0,s1
    80004320:	ccefe0ef          	jal	800027ee <iupdate>
  iunlockput(ip);
    80004324:	8526                	mv	a0,s1
    80004326:	f86fe0ef          	jal	80002aac <iunlockput>
  end_op();
    8000432a:	e79fe0ef          	jal	800031a2 <end_op>
  return -1;
    8000432e:	57fd                	li	a5,-1
    80004330:	64f2                	ld	s1,280(sp)
    80004332:	6952                	ld	s2,272(sp)
}
    80004334:	853e                	mv	a0,a5
    80004336:	70b2                	ld	ra,296(sp)
    80004338:	7412                	ld	s0,288(sp)
    8000433a:	6155                	addi	sp,sp,304
    8000433c:	8082                	ret

000000008000433e <sys_unlink>:
{
    8000433e:	7151                	addi	sp,sp,-240
    80004340:	f586                	sd	ra,232(sp)
    80004342:	f1a2                	sd	s0,224(sp)
    80004344:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004346:	08000613          	li	a2,128
    8000434a:	f3040593          	addi	a1,s0,-208
    8000434e:	4501                	li	a0,0
    80004350:	a53fd0ef          	jal	80001da2 <argstr>
    80004354:	16054063          	bltz	a0,800044b4 <sys_unlink+0x176>
    80004358:	eda6                	sd	s1,216(sp)
  begin_op();
    8000435a:	ddffe0ef          	jal	80003138 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000435e:	fb040593          	addi	a1,s0,-80
    80004362:	f3040513          	addi	a0,s0,-208
    80004366:	c31fe0ef          	jal	80002f96 <nameiparent>
    8000436a:	84aa                	mv	s1,a0
    8000436c:	c945                	beqz	a0,8000441c <sys_unlink+0xde>
  ilock(dp);
    8000436e:	d34fe0ef          	jal	800028a2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004372:	00003597          	auipc	a1,0x3
    80004376:	36e58593          	addi	a1,a1,878 # 800076e0 <etext+0x6e0>
    8000437a:	fb040513          	addi	a0,s0,-80
    8000437e:	983fe0ef          	jal	80002d00 <namecmp>
    80004382:	10050e63          	beqz	a0,8000449e <sys_unlink+0x160>
    80004386:	00003597          	auipc	a1,0x3
    8000438a:	36258593          	addi	a1,a1,866 # 800076e8 <etext+0x6e8>
    8000438e:	fb040513          	addi	a0,s0,-80
    80004392:	96ffe0ef          	jal	80002d00 <namecmp>
    80004396:	10050463          	beqz	a0,8000449e <sys_unlink+0x160>
    8000439a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000439c:	f2c40613          	addi	a2,s0,-212
    800043a0:	fb040593          	addi	a1,s0,-80
    800043a4:	8526                	mv	a0,s1
    800043a6:	971fe0ef          	jal	80002d16 <dirlookup>
    800043aa:	892a                	mv	s2,a0
    800043ac:	0e050863          	beqz	a0,8000449c <sys_unlink+0x15e>
  ilock(ip);
    800043b0:	cf2fe0ef          	jal	800028a2 <ilock>
  if(ip->nlink < 1)
    800043b4:	04a91783          	lh	a5,74(s2)
    800043b8:	06f05763          	blez	a5,80004426 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800043bc:	04491703          	lh	a4,68(s2)
    800043c0:	4785                	li	a5,1
    800043c2:	06f70963          	beq	a4,a5,80004434 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800043c6:	4641                	li	a2,16
    800043c8:	4581                	li	a1,0
    800043ca:	fc040513          	addi	a0,s0,-64
    800043ce:	dc3fb0ef          	jal	80000190 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043d2:	4741                	li	a4,16
    800043d4:	f2c42683          	lw	a3,-212(s0)
    800043d8:	fc040613          	addi	a2,s0,-64
    800043dc:	4581                	li	a1,0
    800043de:	8526                	mv	a0,s1
    800043e0:	813fe0ef          	jal	80002bf2 <writei>
    800043e4:	47c1                	li	a5,16
    800043e6:	08f51b63          	bne	a0,a5,8000447c <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800043ea:	04491703          	lh	a4,68(s2)
    800043ee:	4785                	li	a5,1
    800043f0:	08f70d63          	beq	a4,a5,8000448a <sys_unlink+0x14c>
  iunlockput(dp);
    800043f4:	8526                	mv	a0,s1
    800043f6:	eb6fe0ef          	jal	80002aac <iunlockput>
  ip->nlink--;
    800043fa:	04a95783          	lhu	a5,74(s2)
    800043fe:	37fd                	addiw	a5,a5,-1
    80004400:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004404:	854a                	mv	a0,s2
    80004406:	be8fe0ef          	jal	800027ee <iupdate>
  iunlockput(ip);
    8000440a:	854a                	mv	a0,s2
    8000440c:	ea0fe0ef          	jal	80002aac <iunlockput>
  end_op();
    80004410:	d93fe0ef          	jal	800031a2 <end_op>
  return 0;
    80004414:	4501                	li	a0,0
    80004416:	64ee                	ld	s1,216(sp)
    80004418:	694e                	ld	s2,208(sp)
    8000441a:	a849                	j	800044ac <sys_unlink+0x16e>
    end_op();
    8000441c:	d87fe0ef          	jal	800031a2 <end_op>
    return -1;
    80004420:	557d                	li	a0,-1
    80004422:	64ee                	ld	s1,216(sp)
    80004424:	a061                	j	800044ac <sys_unlink+0x16e>
    80004426:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004428:	00003517          	auipc	a0,0x3
    8000442c:	2c850513          	addi	a0,a0,712 # 800076f0 <etext+0x6f0>
    80004430:	272010ef          	jal	800056a2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004434:	04c92703          	lw	a4,76(s2)
    80004438:	02000793          	li	a5,32
    8000443c:	f8e7f5e3          	bgeu	a5,a4,800043c6 <sys_unlink+0x88>
    80004440:	e5ce                	sd	s3,200(sp)
    80004442:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004446:	4741                	li	a4,16
    80004448:	86ce                	mv	a3,s3
    8000444a:	f1840613          	addi	a2,s0,-232
    8000444e:	4581                	li	a1,0
    80004450:	854a                	mv	a0,s2
    80004452:	ea4fe0ef          	jal	80002af6 <readi>
    80004456:	47c1                	li	a5,16
    80004458:	00f51c63          	bne	a0,a5,80004470 <sys_unlink+0x132>
    if(de.inum != 0)
    8000445c:	f1845783          	lhu	a5,-232(s0)
    80004460:	efa1                	bnez	a5,800044b8 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004462:	29c1                	addiw	s3,s3,16
    80004464:	04c92783          	lw	a5,76(s2)
    80004468:	fcf9efe3          	bltu	s3,a5,80004446 <sys_unlink+0x108>
    8000446c:	69ae                	ld	s3,200(sp)
    8000446e:	bfa1                	j	800043c6 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004470:	00003517          	auipc	a0,0x3
    80004474:	29850513          	addi	a0,a0,664 # 80007708 <etext+0x708>
    80004478:	22a010ef          	jal	800056a2 <panic>
    8000447c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000447e:	00003517          	auipc	a0,0x3
    80004482:	2a250513          	addi	a0,a0,674 # 80007720 <etext+0x720>
    80004486:	21c010ef          	jal	800056a2 <panic>
    dp->nlink--;
    8000448a:	04a4d783          	lhu	a5,74(s1)
    8000448e:	37fd                	addiw	a5,a5,-1
    80004490:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004494:	8526                	mv	a0,s1
    80004496:	b58fe0ef          	jal	800027ee <iupdate>
    8000449a:	bfa9                	j	800043f4 <sys_unlink+0xb6>
    8000449c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000449e:	8526                	mv	a0,s1
    800044a0:	e0cfe0ef          	jal	80002aac <iunlockput>
  end_op();
    800044a4:	cfffe0ef          	jal	800031a2 <end_op>
  return -1;
    800044a8:	557d                	li	a0,-1
    800044aa:	64ee                	ld	s1,216(sp)
}
    800044ac:	70ae                	ld	ra,232(sp)
    800044ae:	740e                	ld	s0,224(sp)
    800044b0:	616d                	addi	sp,sp,240
    800044b2:	8082                	ret
    return -1;
    800044b4:	557d                	li	a0,-1
    800044b6:	bfdd                	j	800044ac <sys_unlink+0x16e>
    iunlockput(ip);
    800044b8:	854a                	mv	a0,s2
    800044ba:	df2fe0ef          	jal	80002aac <iunlockput>
    goto bad;
    800044be:	694e                	ld	s2,208(sp)
    800044c0:	69ae                	ld	s3,200(sp)
    800044c2:	bff1                	j	8000449e <sys_unlink+0x160>

00000000800044c4 <sys_open>:

uint64
sys_open(void)
{
    800044c4:	7131                	addi	sp,sp,-192
    800044c6:	fd06                	sd	ra,184(sp)
    800044c8:	f922                	sd	s0,176(sp)
    800044ca:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800044cc:	f4c40593          	addi	a1,s0,-180
    800044d0:	4505                	li	a0,1
    800044d2:	899fd0ef          	jal	80001d6a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044d6:	08000613          	li	a2,128
    800044da:	f5040593          	addi	a1,s0,-176
    800044de:	4501                	li	a0,0
    800044e0:	8c3fd0ef          	jal	80001da2 <argstr>
    800044e4:	87aa                	mv	a5,a0
    return -1;
    800044e6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800044e8:	0a07c263          	bltz	a5,8000458c <sys_open+0xc8>
    800044ec:	f526                	sd	s1,168(sp)

  begin_op();
    800044ee:	c4bfe0ef          	jal	80003138 <begin_op>

  if(omode & O_CREATE){
    800044f2:	f4c42783          	lw	a5,-180(s0)
    800044f6:	2007f793          	andi	a5,a5,512
    800044fa:	c3d5                	beqz	a5,8000459e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800044fc:	4681                	li	a3,0
    800044fe:	4601                	li	a2,0
    80004500:	4589                	li	a1,2
    80004502:	f5040513          	addi	a0,s0,-176
    80004506:	aa9ff0ef          	jal	80003fae <create>
    8000450a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000450c:	c541                	beqz	a0,80004594 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000450e:	04449703          	lh	a4,68(s1)
    80004512:	478d                	li	a5,3
    80004514:	00f71763          	bne	a4,a5,80004522 <sys_open+0x5e>
    80004518:	0464d703          	lhu	a4,70(s1)
    8000451c:	47a5                	li	a5,9
    8000451e:	0ae7ed63          	bltu	a5,a4,800045d8 <sys_open+0x114>
    80004522:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004524:	f8bfe0ef          	jal	800034ae <filealloc>
    80004528:	892a                	mv	s2,a0
    8000452a:	c179                	beqz	a0,800045f0 <sys_open+0x12c>
    8000452c:	ed4e                	sd	s3,152(sp)
    8000452e:	a43ff0ef          	jal	80003f70 <fdalloc>
    80004532:	89aa                	mv	s3,a0
    80004534:	0a054a63          	bltz	a0,800045e8 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004538:	04449703          	lh	a4,68(s1)
    8000453c:	478d                	li	a5,3
    8000453e:	0cf70263          	beq	a4,a5,80004602 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004542:	4789                	li	a5,2
    80004544:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004548:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000454c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004550:	f4c42783          	lw	a5,-180(s0)
    80004554:	0017c713          	xori	a4,a5,1
    80004558:	8b05                	andi	a4,a4,1
    8000455a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000455e:	0037f713          	andi	a4,a5,3
    80004562:	00e03733          	snez	a4,a4
    80004566:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000456a:	4007f793          	andi	a5,a5,1024
    8000456e:	c791                	beqz	a5,8000457a <sys_open+0xb6>
    80004570:	04449703          	lh	a4,68(s1)
    80004574:	4789                	li	a5,2
    80004576:	08f70d63          	beq	a4,a5,80004610 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000457a:	8526                	mv	a0,s1
    8000457c:	bd4fe0ef          	jal	80002950 <iunlock>
  end_op();
    80004580:	c23fe0ef          	jal	800031a2 <end_op>

  return fd;
    80004584:	854e                	mv	a0,s3
    80004586:	74aa                	ld	s1,168(sp)
    80004588:	790a                	ld	s2,160(sp)
    8000458a:	69ea                	ld	s3,152(sp)
}
    8000458c:	70ea                	ld	ra,184(sp)
    8000458e:	744a                	ld	s0,176(sp)
    80004590:	6129                	addi	sp,sp,192
    80004592:	8082                	ret
      end_op();
    80004594:	c0ffe0ef          	jal	800031a2 <end_op>
      return -1;
    80004598:	557d                	li	a0,-1
    8000459a:	74aa                	ld	s1,168(sp)
    8000459c:	bfc5                	j	8000458c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000459e:	f5040513          	addi	a0,s0,-176
    800045a2:	9dbfe0ef          	jal	80002f7c <namei>
    800045a6:	84aa                	mv	s1,a0
    800045a8:	c11d                	beqz	a0,800045ce <sys_open+0x10a>
    ilock(ip);
    800045aa:	af8fe0ef          	jal	800028a2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800045ae:	04449703          	lh	a4,68(s1)
    800045b2:	4785                	li	a5,1
    800045b4:	f4f71de3          	bne	a4,a5,8000450e <sys_open+0x4a>
    800045b8:	f4c42783          	lw	a5,-180(s0)
    800045bc:	d3bd                	beqz	a5,80004522 <sys_open+0x5e>
      iunlockput(ip);
    800045be:	8526                	mv	a0,s1
    800045c0:	cecfe0ef          	jal	80002aac <iunlockput>
      end_op();
    800045c4:	bdffe0ef          	jal	800031a2 <end_op>
      return -1;
    800045c8:	557d                	li	a0,-1
    800045ca:	74aa                	ld	s1,168(sp)
    800045cc:	b7c1                	j	8000458c <sys_open+0xc8>
      end_op();
    800045ce:	bd5fe0ef          	jal	800031a2 <end_op>
      return -1;
    800045d2:	557d                	li	a0,-1
    800045d4:	74aa                	ld	s1,168(sp)
    800045d6:	bf5d                	j	8000458c <sys_open+0xc8>
    iunlockput(ip);
    800045d8:	8526                	mv	a0,s1
    800045da:	cd2fe0ef          	jal	80002aac <iunlockput>
    end_op();
    800045de:	bc5fe0ef          	jal	800031a2 <end_op>
    return -1;
    800045e2:	557d                	li	a0,-1
    800045e4:	74aa                	ld	s1,168(sp)
    800045e6:	b75d                	j	8000458c <sys_open+0xc8>
      fileclose(f);
    800045e8:	854a                	mv	a0,s2
    800045ea:	f69fe0ef          	jal	80003552 <fileclose>
    800045ee:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800045f0:	8526                	mv	a0,s1
    800045f2:	cbafe0ef          	jal	80002aac <iunlockput>
    end_op();
    800045f6:	badfe0ef          	jal	800031a2 <end_op>
    return -1;
    800045fa:	557d                	li	a0,-1
    800045fc:	74aa                	ld	s1,168(sp)
    800045fe:	790a                	ld	s2,160(sp)
    80004600:	b771                	j	8000458c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004602:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004606:	04649783          	lh	a5,70(s1)
    8000460a:	02f91223          	sh	a5,36(s2)
    8000460e:	bf3d                	j	8000454c <sys_open+0x88>
    itrunc(ip);
    80004610:	8526                	mv	a0,s1
    80004612:	b7efe0ef          	jal	80002990 <itrunc>
    80004616:	b795                	j	8000457a <sys_open+0xb6>

0000000080004618 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004618:	7175                	addi	sp,sp,-144
    8000461a:	e506                	sd	ra,136(sp)
    8000461c:	e122                	sd	s0,128(sp)
    8000461e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004620:	b19fe0ef          	jal	80003138 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004624:	08000613          	li	a2,128
    80004628:	f7040593          	addi	a1,s0,-144
    8000462c:	4501                	li	a0,0
    8000462e:	f74fd0ef          	jal	80001da2 <argstr>
    80004632:	02054363          	bltz	a0,80004658 <sys_mkdir+0x40>
    80004636:	4681                	li	a3,0
    80004638:	4601                	li	a2,0
    8000463a:	4585                	li	a1,1
    8000463c:	f7040513          	addi	a0,s0,-144
    80004640:	96fff0ef          	jal	80003fae <create>
    80004644:	c911                	beqz	a0,80004658 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004646:	c66fe0ef          	jal	80002aac <iunlockput>
  end_op();
    8000464a:	b59fe0ef          	jal	800031a2 <end_op>
  return 0;
    8000464e:	4501                	li	a0,0
}
    80004650:	60aa                	ld	ra,136(sp)
    80004652:	640a                	ld	s0,128(sp)
    80004654:	6149                	addi	sp,sp,144
    80004656:	8082                	ret
    end_op();
    80004658:	b4bfe0ef          	jal	800031a2 <end_op>
    return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	bfcd                	j	80004650 <sys_mkdir+0x38>

0000000080004660 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004660:	7135                	addi	sp,sp,-160
    80004662:	ed06                	sd	ra,152(sp)
    80004664:	e922                	sd	s0,144(sp)
    80004666:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004668:	ad1fe0ef          	jal	80003138 <begin_op>
  argint(1, &major);
    8000466c:	f6c40593          	addi	a1,s0,-148
    80004670:	4505                	li	a0,1
    80004672:	ef8fd0ef          	jal	80001d6a <argint>
  argint(2, &minor);
    80004676:	f6840593          	addi	a1,s0,-152
    8000467a:	4509                	li	a0,2
    8000467c:	eeefd0ef          	jal	80001d6a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004680:	08000613          	li	a2,128
    80004684:	f7040593          	addi	a1,s0,-144
    80004688:	4501                	li	a0,0
    8000468a:	f18fd0ef          	jal	80001da2 <argstr>
    8000468e:	02054563          	bltz	a0,800046b8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004692:	f6841683          	lh	a3,-152(s0)
    80004696:	f6c41603          	lh	a2,-148(s0)
    8000469a:	458d                	li	a1,3
    8000469c:	f7040513          	addi	a0,s0,-144
    800046a0:	90fff0ef          	jal	80003fae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800046a4:	c911                	beqz	a0,800046b8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800046a6:	c06fe0ef          	jal	80002aac <iunlockput>
  end_op();
    800046aa:	af9fe0ef          	jal	800031a2 <end_op>
  return 0;
    800046ae:	4501                	li	a0,0
}
    800046b0:	60ea                	ld	ra,152(sp)
    800046b2:	644a                	ld	s0,144(sp)
    800046b4:	610d                	addi	sp,sp,160
    800046b6:	8082                	ret
    end_op();
    800046b8:	aebfe0ef          	jal	800031a2 <end_op>
    return -1;
    800046bc:	557d                	li	a0,-1
    800046be:	bfcd                	j	800046b0 <sys_mknod+0x50>

00000000800046c0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800046c0:	7135                	addi	sp,sp,-160
    800046c2:	ed06                	sd	ra,152(sp)
    800046c4:	e922                	sd	s0,144(sp)
    800046c6:	e14a                	sd	s2,128(sp)
    800046c8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800046ca:	fb6fc0ef          	jal	80000e80 <myproc>
    800046ce:	892a                	mv	s2,a0
  
  begin_op();
    800046d0:	a69fe0ef          	jal	80003138 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800046d4:	08000613          	li	a2,128
    800046d8:	f6040593          	addi	a1,s0,-160
    800046dc:	4501                	li	a0,0
    800046de:	ec4fd0ef          	jal	80001da2 <argstr>
    800046e2:	04054363          	bltz	a0,80004728 <sys_chdir+0x68>
    800046e6:	e526                	sd	s1,136(sp)
    800046e8:	f6040513          	addi	a0,s0,-160
    800046ec:	891fe0ef          	jal	80002f7c <namei>
    800046f0:	84aa                	mv	s1,a0
    800046f2:	c915                	beqz	a0,80004726 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800046f4:	9aefe0ef          	jal	800028a2 <ilock>
  if(ip->type != T_DIR){
    800046f8:	04449703          	lh	a4,68(s1)
    800046fc:	4785                	li	a5,1
    800046fe:	02f71963          	bne	a4,a5,80004730 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004702:	8526                	mv	a0,s1
    80004704:	a4cfe0ef          	jal	80002950 <iunlock>
  iput(p->cwd);
    80004708:	15093503          	ld	a0,336(s2)
    8000470c:	b18fe0ef          	jal	80002a24 <iput>
  end_op();
    80004710:	a93fe0ef          	jal	800031a2 <end_op>
  p->cwd = ip;
    80004714:	14993823          	sd	s1,336(s2)
  return 0;
    80004718:	4501                	li	a0,0
    8000471a:	64aa                	ld	s1,136(sp)
}
    8000471c:	60ea                	ld	ra,152(sp)
    8000471e:	644a                	ld	s0,144(sp)
    80004720:	690a                	ld	s2,128(sp)
    80004722:	610d                	addi	sp,sp,160
    80004724:	8082                	ret
    80004726:	64aa                	ld	s1,136(sp)
    end_op();
    80004728:	a7bfe0ef          	jal	800031a2 <end_op>
    return -1;
    8000472c:	557d                	li	a0,-1
    8000472e:	b7fd                	j	8000471c <sys_chdir+0x5c>
    iunlockput(ip);
    80004730:	8526                	mv	a0,s1
    80004732:	b7afe0ef          	jal	80002aac <iunlockput>
    end_op();
    80004736:	a6dfe0ef          	jal	800031a2 <end_op>
    return -1;
    8000473a:	557d                	li	a0,-1
    8000473c:	64aa                	ld	s1,136(sp)
    8000473e:	bff9                	j	8000471c <sys_chdir+0x5c>

0000000080004740 <sys_exec>:

uint64
sys_exec(void)
{
    80004740:	7121                	addi	sp,sp,-448
    80004742:	ff06                	sd	ra,440(sp)
    80004744:	fb22                	sd	s0,432(sp)
    80004746:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004748:	e4840593          	addi	a1,s0,-440
    8000474c:	4505                	li	a0,1
    8000474e:	e38fd0ef          	jal	80001d86 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004752:	08000613          	li	a2,128
    80004756:	f5040593          	addi	a1,s0,-176
    8000475a:	4501                	li	a0,0
    8000475c:	e46fd0ef          	jal	80001da2 <argstr>
    80004760:	87aa                	mv	a5,a0
    return -1;
    80004762:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004764:	0c07c463          	bltz	a5,8000482c <sys_exec+0xec>
    80004768:	f726                	sd	s1,424(sp)
    8000476a:	f34a                	sd	s2,416(sp)
    8000476c:	ef4e                	sd	s3,408(sp)
    8000476e:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004770:	10000613          	li	a2,256
    80004774:	4581                	li	a1,0
    80004776:	e5040513          	addi	a0,s0,-432
    8000477a:	a17fb0ef          	jal	80000190 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000477e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004782:	89a6                	mv	s3,s1
    80004784:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004786:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000478a:	00391513          	slli	a0,s2,0x3
    8000478e:	e4040593          	addi	a1,s0,-448
    80004792:	e4843783          	ld	a5,-440(s0)
    80004796:	953e                	add	a0,a0,a5
    80004798:	d48fd0ef          	jal	80001ce0 <fetchaddr>
    8000479c:	02054663          	bltz	a0,800047c8 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800047a0:	e4043783          	ld	a5,-448(s0)
    800047a4:	c3a9                	beqz	a5,800047e6 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800047a6:	959fb0ef          	jal	800000fe <kalloc>
    800047aa:	85aa                	mv	a1,a0
    800047ac:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800047b0:	cd01                	beqz	a0,800047c8 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800047b2:	6605                	lui	a2,0x1
    800047b4:	e4043503          	ld	a0,-448(s0)
    800047b8:	d72fd0ef          	jal	80001d2a <fetchstr>
    800047bc:	00054663          	bltz	a0,800047c8 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800047c0:	0905                	addi	s2,s2,1
    800047c2:	09a1                	addi	s3,s3,8
    800047c4:	fd4913e3          	bne	s2,s4,8000478a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047c8:	f5040913          	addi	s2,s0,-176
    800047cc:	6088                	ld	a0,0(s1)
    800047ce:	c931                	beqz	a0,80004822 <sys_exec+0xe2>
    kfree(argv[i]);
    800047d0:	84dfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800047d4:	04a1                	addi	s1,s1,8
    800047d6:	ff249be3          	bne	s1,s2,800047cc <sys_exec+0x8c>
  return -1;
    800047da:	557d                	li	a0,-1
    800047dc:	74ba                	ld	s1,424(sp)
    800047de:	791a                	ld	s2,416(sp)
    800047e0:	69fa                	ld	s3,408(sp)
    800047e2:	6a5a                	ld	s4,400(sp)
    800047e4:	a0a1                	j	8000482c <sys_exec+0xec>
      argv[i] = 0;
    800047e6:	0009079b          	sext.w	a5,s2
    800047ea:	078e                	slli	a5,a5,0x3
    800047ec:	fd078793          	addi	a5,a5,-48
    800047f0:	97a2                	add	a5,a5,s0
    800047f2:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800047f6:	e5040593          	addi	a1,s0,-432
    800047fa:	f5040513          	addi	a0,s0,-176
    800047fe:	ba2ff0ef          	jal	80003ba0 <exec>
    80004802:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004804:	f5040993          	addi	s3,s0,-176
    80004808:	6088                	ld	a0,0(s1)
    8000480a:	c511                	beqz	a0,80004816 <sys_exec+0xd6>
    kfree(argv[i]);
    8000480c:	811fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004810:	04a1                	addi	s1,s1,8
    80004812:	ff349be3          	bne	s1,s3,80004808 <sys_exec+0xc8>
  return ret;
    80004816:	854a                	mv	a0,s2
    80004818:	74ba                	ld	s1,424(sp)
    8000481a:	791a                	ld	s2,416(sp)
    8000481c:	69fa                	ld	s3,408(sp)
    8000481e:	6a5a                	ld	s4,400(sp)
    80004820:	a031                	j	8000482c <sys_exec+0xec>
  return -1;
    80004822:	557d                	li	a0,-1
    80004824:	74ba                	ld	s1,424(sp)
    80004826:	791a                	ld	s2,416(sp)
    80004828:	69fa                	ld	s3,408(sp)
    8000482a:	6a5a                	ld	s4,400(sp)
}
    8000482c:	70fa                	ld	ra,440(sp)
    8000482e:	745a                	ld	s0,432(sp)
    80004830:	6139                	addi	sp,sp,448
    80004832:	8082                	ret

0000000080004834 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004834:	7139                	addi	sp,sp,-64
    80004836:	fc06                	sd	ra,56(sp)
    80004838:	f822                	sd	s0,48(sp)
    8000483a:	f426                	sd	s1,40(sp)
    8000483c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000483e:	e42fc0ef          	jal	80000e80 <myproc>
    80004842:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004844:	fd840593          	addi	a1,s0,-40
    80004848:	4501                	li	a0,0
    8000484a:	d3cfd0ef          	jal	80001d86 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000484e:	fc840593          	addi	a1,s0,-56
    80004852:	fd040513          	addi	a0,s0,-48
    80004856:	856ff0ef          	jal	800038ac <pipealloc>
    return -1;
    8000485a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000485c:	0a054463          	bltz	a0,80004904 <sys_pipe+0xd0>
  fd0 = -1;
    80004860:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004864:	fd043503          	ld	a0,-48(s0)
    80004868:	f08ff0ef          	jal	80003f70 <fdalloc>
    8000486c:	fca42223          	sw	a0,-60(s0)
    80004870:	08054163          	bltz	a0,800048f2 <sys_pipe+0xbe>
    80004874:	fc843503          	ld	a0,-56(s0)
    80004878:	ef8ff0ef          	jal	80003f70 <fdalloc>
    8000487c:	fca42023          	sw	a0,-64(s0)
    80004880:	06054063          	bltz	a0,800048e0 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004884:	4691                	li	a3,4
    80004886:	fc440613          	addi	a2,s0,-60
    8000488a:	fd843583          	ld	a1,-40(s0)
    8000488e:	68a8                	ld	a0,80(s1)
    80004890:	98afc0ef          	jal	80000a1a <copyout>
    80004894:	00054e63          	bltz	a0,800048b0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004898:	4691                	li	a3,4
    8000489a:	fc040613          	addi	a2,s0,-64
    8000489e:	fd843583          	ld	a1,-40(s0)
    800048a2:	0591                	addi	a1,a1,4
    800048a4:	68a8                	ld	a0,80(s1)
    800048a6:	974fc0ef          	jal	80000a1a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800048aa:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800048ac:	04055c63          	bgez	a0,80004904 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800048b0:	fc442783          	lw	a5,-60(s0)
    800048b4:	07e9                	addi	a5,a5,26
    800048b6:	078e                	slli	a5,a5,0x3
    800048b8:	97a6                	add	a5,a5,s1
    800048ba:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800048be:	fc042783          	lw	a5,-64(s0)
    800048c2:	07e9                	addi	a5,a5,26
    800048c4:	078e                	slli	a5,a5,0x3
    800048c6:	94be                	add	s1,s1,a5
    800048c8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800048cc:	fd043503          	ld	a0,-48(s0)
    800048d0:	c83fe0ef          	jal	80003552 <fileclose>
    fileclose(wf);
    800048d4:	fc843503          	ld	a0,-56(s0)
    800048d8:	c7bfe0ef          	jal	80003552 <fileclose>
    return -1;
    800048dc:	57fd                	li	a5,-1
    800048de:	a01d                	j	80004904 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800048e0:	fc442783          	lw	a5,-60(s0)
    800048e4:	0007c763          	bltz	a5,800048f2 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800048e8:	07e9                	addi	a5,a5,26
    800048ea:	078e                	slli	a5,a5,0x3
    800048ec:	97a6                	add	a5,a5,s1
    800048ee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800048f2:	fd043503          	ld	a0,-48(s0)
    800048f6:	c5dfe0ef          	jal	80003552 <fileclose>
    fileclose(wf);
    800048fa:	fc843503          	ld	a0,-56(s0)
    800048fe:	c55fe0ef          	jal	80003552 <fileclose>
    return -1;
    80004902:	57fd                	li	a5,-1
}
    80004904:	853e                	mv	a0,a5
    80004906:	70e2                	ld	ra,56(sp)
    80004908:	7442                	ld	s0,48(sp)
    8000490a:	74a2                	ld	s1,40(sp)
    8000490c:	6121                	addi	sp,sp,64
    8000490e:	8082                	ret

0000000080004910 <kernelvec>:
    80004910:	7111                	addi	sp,sp,-256
    80004912:	e006                	sd	ra,0(sp)
    80004914:	e40a                	sd	sp,8(sp)
    80004916:	e80e                	sd	gp,16(sp)
    80004918:	ec12                	sd	tp,24(sp)
    8000491a:	f016                	sd	t0,32(sp)
    8000491c:	f41a                	sd	t1,40(sp)
    8000491e:	f81e                	sd	t2,48(sp)
    80004920:	e4aa                	sd	a0,72(sp)
    80004922:	e8ae                	sd	a1,80(sp)
    80004924:	ecb2                	sd	a2,88(sp)
    80004926:	f0b6                	sd	a3,96(sp)
    80004928:	f4ba                	sd	a4,104(sp)
    8000492a:	f8be                	sd	a5,112(sp)
    8000492c:	fcc2                	sd	a6,120(sp)
    8000492e:	e146                	sd	a7,128(sp)
    80004930:	edf2                	sd	t3,216(sp)
    80004932:	f1f6                	sd	t4,224(sp)
    80004934:	f5fa                	sd	t5,232(sp)
    80004936:	f9fe                	sd	t6,240(sp)
    80004938:	ab8fd0ef          	jal	80001bf0 <kerneltrap>
    8000493c:	6082                	ld	ra,0(sp)
    8000493e:	6122                	ld	sp,8(sp)
    80004940:	61c2                	ld	gp,16(sp)
    80004942:	7282                	ld	t0,32(sp)
    80004944:	7322                	ld	t1,40(sp)
    80004946:	73c2                	ld	t2,48(sp)
    80004948:	6526                	ld	a0,72(sp)
    8000494a:	65c6                	ld	a1,80(sp)
    8000494c:	6666                	ld	a2,88(sp)
    8000494e:	7686                	ld	a3,96(sp)
    80004950:	7726                	ld	a4,104(sp)
    80004952:	77c6                	ld	a5,112(sp)
    80004954:	7866                	ld	a6,120(sp)
    80004956:	688a                	ld	a7,128(sp)
    80004958:	6e6e                	ld	t3,216(sp)
    8000495a:	7e8e                	ld	t4,224(sp)
    8000495c:	7f2e                	ld	t5,232(sp)
    8000495e:	7fce                	ld	t6,240(sp)
    80004960:	6111                	addi	sp,sp,256
    80004962:	10200073          	sret
	...

000000008000496e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000496e:	1141                	addi	sp,sp,-16
    80004970:	e422                	sd	s0,8(sp)
    80004972:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004974:	0c0007b7          	lui	a5,0xc000
    80004978:	4705                	li	a4,1
    8000497a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000497c:	0c0007b7          	lui	a5,0xc000
    80004980:	c3d8                	sw	a4,4(a5)
}
    80004982:	6422                	ld	s0,8(sp)
    80004984:	0141                	addi	sp,sp,16
    80004986:	8082                	ret

0000000080004988 <plicinithart>:

void
plicinithart(void)
{
    80004988:	1141                	addi	sp,sp,-16
    8000498a:	e406                	sd	ra,8(sp)
    8000498c:	e022                	sd	s0,0(sp)
    8000498e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004990:	cc4fc0ef          	jal	80000e54 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004994:	0085171b          	slliw	a4,a0,0x8
    80004998:	0c0027b7          	lui	a5,0xc002
    8000499c:	97ba                	add	a5,a5,a4
    8000499e:	40200713          	li	a4,1026
    800049a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800049a6:	00d5151b          	slliw	a0,a0,0xd
    800049aa:	0c2017b7          	lui	a5,0xc201
    800049ae:	97aa                	add	a5,a5,a0
    800049b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800049bc:	1141                	addi	sp,sp,-16
    800049be:	e406                	sd	ra,8(sp)
    800049c0:	e022                	sd	s0,0(sp)
    800049c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800049c4:	c90fc0ef          	jal	80000e54 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800049c8:	00d5151b          	slliw	a0,a0,0xd
    800049cc:	0c2017b7          	lui	a5,0xc201
    800049d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800049d2:	43c8                	lw	a0,4(a5)
    800049d4:	60a2                	ld	ra,8(sp)
    800049d6:	6402                	ld	s0,0(sp)
    800049d8:	0141                	addi	sp,sp,16
    800049da:	8082                	ret

00000000800049dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800049dc:	1101                	addi	sp,sp,-32
    800049de:	ec06                	sd	ra,24(sp)
    800049e0:	e822                	sd	s0,16(sp)
    800049e2:	e426                	sd	s1,8(sp)
    800049e4:	1000                	addi	s0,sp,32
    800049e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800049e8:	c6cfc0ef          	jal	80000e54 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800049ec:	00d5151b          	slliw	a0,a0,0xd
    800049f0:	0c2017b7          	lui	a5,0xc201
    800049f4:	97aa                	add	a5,a5,a0
    800049f6:	c3c4                	sw	s1,4(a5)
}
    800049f8:	60e2                	ld	ra,24(sp)
    800049fa:	6442                	ld	s0,16(sp)
    800049fc:	64a2                	ld	s1,8(sp)
    800049fe:	6105                	addi	sp,sp,32
    80004a00:	8082                	ret

0000000080004a02 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004a02:	1141                	addi	sp,sp,-16
    80004a04:	e406                	sd	ra,8(sp)
    80004a06:	e022                	sd	s0,0(sp)
    80004a08:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004a0a:	479d                	li	a5,7
    80004a0c:	04a7ca63          	blt	a5,a0,80004a60 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004a10:	00017797          	auipc	a5,0x17
    80004a14:	eb078793          	addi	a5,a5,-336 # 8001b8c0 <disk>
    80004a18:	97aa                	add	a5,a5,a0
    80004a1a:	0187c783          	lbu	a5,24(a5)
    80004a1e:	e7b9                	bnez	a5,80004a6c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004a20:	00451693          	slli	a3,a0,0x4
    80004a24:	00017797          	auipc	a5,0x17
    80004a28:	e9c78793          	addi	a5,a5,-356 # 8001b8c0 <disk>
    80004a2c:	6398                	ld	a4,0(a5)
    80004a2e:	9736                	add	a4,a4,a3
    80004a30:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004a34:	6398                	ld	a4,0(a5)
    80004a36:	9736                	add	a4,a4,a3
    80004a38:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004a3c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004a40:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004a44:	97aa                	add	a5,a5,a0
    80004a46:	4705                	li	a4,1
    80004a48:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004a4c:	00017517          	auipc	a0,0x17
    80004a50:	e8c50513          	addi	a0,a0,-372 # 8001b8d8 <disk+0x18>
    80004a54:	a4ffc0ef          	jal	800014a2 <wakeup>
}
    80004a58:	60a2                	ld	ra,8(sp)
    80004a5a:	6402                	ld	s0,0(sp)
    80004a5c:	0141                	addi	sp,sp,16
    80004a5e:	8082                	ret
    panic("free_desc 1");
    80004a60:	00003517          	auipc	a0,0x3
    80004a64:	cd050513          	addi	a0,a0,-816 # 80007730 <etext+0x730>
    80004a68:	43b000ef          	jal	800056a2 <panic>
    panic("free_desc 2");
    80004a6c:	00003517          	auipc	a0,0x3
    80004a70:	cd450513          	addi	a0,a0,-812 # 80007740 <etext+0x740>
    80004a74:	42f000ef          	jal	800056a2 <panic>

0000000080004a78 <virtio_disk_init>:
{
    80004a78:	1101                	addi	sp,sp,-32
    80004a7a:	ec06                	sd	ra,24(sp)
    80004a7c:	e822                	sd	s0,16(sp)
    80004a7e:	e426                	sd	s1,8(sp)
    80004a80:	e04a                	sd	s2,0(sp)
    80004a82:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004a84:	00003597          	auipc	a1,0x3
    80004a88:	ccc58593          	addi	a1,a1,-820 # 80007750 <etext+0x750>
    80004a8c:	00017517          	auipc	a0,0x17
    80004a90:	f5c50513          	addi	a0,a0,-164 # 8001b9e8 <disk+0x128>
    80004a94:	6bd000ef          	jal	80005950 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004a98:	100017b7          	lui	a5,0x10001
    80004a9c:	4398                	lw	a4,0(a5)
    80004a9e:	2701                	sext.w	a4,a4
    80004aa0:	747277b7          	lui	a5,0x74727
    80004aa4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004aa8:	18f71063          	bne	a4,a5,80004c28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004aac:	100017b7          	lui	a5,0x10001
    80004ab0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004ab2:	439c                	lw	a5,0(a5)
    80004ab4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004ab6:	4709                	li	a4,2
    80004ab8:	16e79863          	bne	a5,a4,80004c28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004abc:	100017b7          	lui	a5,0x10001
    80004ac0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004ac2:	439c                	lw	a5,0(a5)
    80004ac4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004ac6:	16e79163          	bne	a5,a4,80004c28 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004aca:	100017b7          	lui	a5,0x10001
    80004ace:	47d8                	lw	a4,12(a5)
    80004ad0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004ad2:	554d47b7          	lui	a5,0x554d4
    80004ad6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004ada:	14f71763          	bne	a4,a5,80004c28 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ade:	100017b7          	lui	a5,0x10001
    80004ae2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ae6:	4705                	li	a4,1
    80004ae8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004aea:	470d                	li	a4,3
    80004aec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004aee:	10001737          	lui	a4,0x10001
    80004af2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004af4:	c7ffe737          	lui	a4,0xc7ffe
    80004af8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdac5f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004afc:	8ef9                	and	a3,a3,a4
    80004afe:	10001737          	lui	a4,0x10001
    80004b02:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b04:	472d                	li	a4,11
    80004b06:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b08:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004b0c:	439c                	lw	a5,0(a5)
    80004b0e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004b12:	8ba1                	andi	a5,a5,8
    80004b14:	12078063          	beqz	a5,80004c34 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004b18:	100017b7          	lui	a5,0x10001
    80004b1c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004b20:	100017b7          	lui	a5,0x10001
    80004b24:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004b28:	439c                	lw	a5,0(a5)
    80004b2a:	2781                	sext.w	a5,a5
    80004b2c:	10079a63          	bnez	a5,80004c40 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004b30:	100017b7          	lui	a5,0x10001
    80004b34:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004b38:	439c                	lw	a5,0(a5)
    80004b3a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004b3c:	10078863          	beqz	a5,80004c4c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004b40:	471d                	li	a4,7
    80004b42:	10f77b63          	bgeu	a4,a5,80004c58 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004b46:	db8fb0ef          	jal	800000fe <kalloc>
    80004b4a:	00017497          	auipc	s1,0x17
    80004b4e:	d7648493          	addi	s1,s1,-650 # 8001b8c0 <disk>
    80004b52:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004b54:	daafb0ef          	jal	800000fe <kalloc>
    80004b58:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004b5a:	da4fb0ef          	jal	800000fe <kalloc>
    80004b5e:	87aa                	mv	a5,a0
    80004b60:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004b62:	6088                	ld	a0,0(s1)
    80004b64:	10050063          	beqz	a0,80004c64 <virtio_disk_init+0x1ec>
    80004b68:	00017717          	auipc	a4,0x17
    80004b6c:	d6073703          	ld	a4,-672(a4) # 8001b8c8 <disk+0x8>
    80004b70:	0e070a63          	beqz	a4,80004c64 <virtio_disk_init+0x1ec>
    80004b74:	0e078863          	beqz	a5,80004c64 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004b78:	6605                	lui	a2,0x1
    80004b7a:	4581                	li	a1,0
    80004b7c:	e14fb0ef          	jal	80000190 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004b80:	00017497          	auipc	s1,0x17
    80004b84:	d4048493          	addi	s1,s1,-704 # 8001b8c0 <disk>
    80004b88:	6605                	lui	a2,0x1
    80004b8a:	4581                	li	a1,0
    80004b8c:	6488                	ld	a0,8(s1)
    80004b8e:	e02fb0ef          	jal	80000190 <memset>
  memset(disk.used, 0, PGSIZE);
    80004b92:	6605                	lui	a2,0x1
    80004b94:	4581                	li	a1,0
    80004b96:	6888                	ld	a0,16(s1)
    80004b98:	df8fb0ef          	jal	80000190 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004b9c:	100017b7          	lui	a5,0x10001
    80004ba0:	4721                	li	a4,8
    80004ba2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004ba4:	4098                	lw	a4,0(s1)
    80004ba6:	100017b7          	lui	a5,0x10001
    80004baa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004bae:	40d8                	lw	a4,4(s1)
    80004bb0:	100017b7          	lui	a5,0x10001
    80004bb4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004bb8:	649c                	ld	a5,8(s1)
    80004bba:	0007869b          	sext.w	a3,a5
    80004bbe:	10001737          	lui	a4,0x10001
    80004bc2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004bc6:	9781                	srai	a5,a5,0x20
    80004bc8:	10001737          	lui	a4,0x10001
    80004bcc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004bd0:	689c                	ld	a5,16(s1)
    80004bd2:	0007869b          	sext.w	a3,a5
    80004bd6:	10001737          	lui	a4,0x10001
    80004bda:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004bde:	9781                	srai	a5,a5,0x20
    80004be0:	10001737          	lui	a4,0x10001
    80004be4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004be8:	10001737          	lui	a4,0x10001
    80004bec:	4785                	li	a5,1
    80004bee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004bf0:	00f48c23          	sb	a5,24(s1)
    80004bf4:	00f48ca3          	sb	a5,25(s1)
    80004bf8:	00f48d23          	sb	a5,26(s1)
    80004bfc:	00f48da3          	sb	a5,27(s1)
    80004c00:	00f48e23          	sb	a5,28(s1)
    80004c04:	00f48ea3          	sb	a5,29(s1)
    80004c08:	00f48f23          	sb	a5,30(s1)
    80004c0c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004c10:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004c14:	100017b7          	lui	a5,0x10001
    80004c18:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004c1c:	60e2                	ld	ra,24(sp)
    80004c1e:	6442                	ld	s0,16(sp)
    80004c20:	64a2                	ld	s1,8(sp)
    80004c22:	6902                	ld	s2,0(sp)
    80004c24:	6105                	addi	sp,sp,32
    80004c26:	8082                	ret
    panic("could not find virtio disk");
    80004c28:	00003517          	auipc	a0,0x3
    80004c2c:	b3850513          	addi	a0,a0,-1224 # 80007760 <etext+0x760>
    80004c30:	273000ef          	jal	800056a2 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004c34:	00003517          	auipc	a0,0x3
    80004c38:	b4c50513          	addi	a0,a0,-1204 # 80007780 <etext+0x780>
    80004c3c:	267000ef          	jal	800056a2 <panic>
    panic("virtio disk should not be ready");
    80004c40:	00003517          	auipc	a0,0x3
    80004c44:	b6050513          	addi	a0,a0,-1184 # 800077a0 <etext+0x7a0>
    80004c48:	25b000ef          	jal	800056a2 <panic>
    panic("virtio disk has no queue 0");
    80004c4c:	00003517          	auipc	a0,0x3
    80004c50:	b7450513          	addi	a0,a0,-1164 # 800077c0 <etext+0x7c0>
    80004c54:	24f000ef          	jal	800056a2 <panic>
    panic("virtio disk max queue too short");
    80004c58:	00003517          	auipc	a0,0x3
    80004c5c:	b8850513          	addi	a0,a0,-1144 # 800077e0 <etext+0x7e0>
    80004c60:	243000ef          	jal	800056a2 <panic>
    panic("virtio disk kalloc");
    80004c64:	00003517          	auipc	a0,0x3
    80004c68:	b9c50513          	addi	a0,a0,-1124 # 80007800 <etext+0x800>
    80004c6c:	237000ef          	jal	800056a2 <panic>

0000000080004c70 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004c70:	7159                	addi	sp,sp,-112
    80004c72:	f486                	sd	ra,104(sp)
    80004c74:	f0a2                	sd	s0,96(sp)
    80004c76:	eca6                	sd	s1,88(sp)
    80004c78:	e8ca                	sd	s2,80(sp)
    80004c7a:	e4ce                	sd	s3,72(sp)
    80004c7c:	e0d2                	sd	s4,64(sp)
    80004c7e:	fc56                	sd	s5,56(sp)
    80004c80:	f85a                	sd	s6,48(sp)
    80004c82:	f45e                	sd	s7,40(sp)
    80004c84:	f062                	sd	s8,32(sp)
    80004c86:	ec66                	sd	s9,24(sp)
    80004c88:	1880                	addi	s0,sp,112
    80004c8a:	8a2a                	mv	s4,a0
    80004c8c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004c8e:	00c52c83          	lw	s9,12(a0)
    80004c92:	001c9c9b          	slliw	s9,s9,0x1
    80004c96:	1c82                	slli	s9,s9,0x20
    80004c98:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004c9c:	00017517          	auipc	a0,0x17
    80004ca0:	d4c50513          	addi	a0,a0,-692 # 8001b9e8 <disk+0x128>
    80004ca4:	52d000ef          	jal	800059d0 <acquire>
  for(int i = 0; i < 3; i++){
    80004ca8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004caa:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004cac:	00017b17          	auipc	s6,0x17
    80004cb0:	c14b0b13          	addi	s6,s6,-1004 # 8001b8c0 <disk>
  for(int i = 0; i < 3; i++){
    80004cb4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004cb6:	00017c17          	auipc	s8,0x17
    80004cba:	d32c0c13          	addi	s8,s8,-718 # 8001b9e8 <disk+0x128>
    80004cbe:	a8b9                	j	80004d1c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004cc0:	00fb0733          	add	a4,s6,a5
    80004cc4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004cc8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004cca:	0207c563          	bltz	a5,80004cf4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004cce:	2905                	addiw	s2,s2,1
    80004cd0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004cd2:	05590963          	beq	s2,s5,80004d24 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004cd6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004cd8:	00017717          	auipc	a4,0x17
    80004cdc:	be870713          	addi	a4,a4,-1048 # 8001b8c0 <disk>
    80004ce0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004ce2:	01874683          	lbu	a3,24(a4)
    80004ce6:	fee9                	bnez	a3,80004cc0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004ce8:	2785                	addiw	a5,a5,1
    80004cea:	0705                	addi	a4,a4,1
    80004cec:	fe979be3          	bne	a5,s1,80004ce2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004cf0:	57fd                	li	a5,-1
    80004cf2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004cf4:	01205d63          	blez	s2,80004d0e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004cf8:	f9042503          	lw	a0,-112(s0)
    80004cfc:	d07ff0ef          	jal	80004a02 <free_desc>
      for(int j = 0; j < i; j++)
    80004d00:	4785                	li	a5,1
    80004d02:	0127d663          	bge	a5,s2,80004d0e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004d06:	f9442503          	lw	a0,-108(s0)
    80004d0a:	cf9ff0ef          	jal	80004a02 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004d0e:	85e2                	mv	a1,s8
    80004d10:	00017517          	auipc	a0,0x17
    80004d14:	bc850513          	addi	a0,a0,-1080 # 8001b8d8 <disk+0x18>
    80004d18:	f3efc0ef          	jal	80001456 <sleep>
  for(int i = 0; i < 3; i++){
    80004d1c:	f9040613          	addi	a2,s0,-112
    80004d20:	894e                	mv	s2,s3
    80004d22:	bf55                	j	80004cd6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d24:	f9042503          	lw	a0,-112(s0)
    80004d28:	00451693          	slli	a3,a0,0x4

  if(write)
    80004d2c:	00017797          	auipc	a5,0x17
    80004d30:	b9478793          	addi	a5,a5,-1132 # 8001b8c0 <disk>
    80004d34:	00a50713          	addi	a4,a0,10
    80004d38:	0712                	slli	a4,a4,0x4
    80004d3a:	973e                	add	a4,a4,a5
    80004d3c:	01703633          	snez	a2,s7
    80004d40:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004d42:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004d46:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d4a:	6398                	ld	a4,0(a5)
    80004d4c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004d4e:	0a868613          	addi	a2,a3,168
    80004d52:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004d54:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004d56:	6390                	ld	a2,0(a5)
    80004d58:	00d605b3          	add	a1,a2,a3
    80004d5c:	4741                	li	a4,16
    80004d5e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004d60:	4805                	li	a6,1
    80004d62:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004d66:	f9442703          	lw	a4,-108(s0)
    80004d6a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004d6e:	0712                	slli	a4,a4,0x4
    80004d70:	963a                	add	a2,a2,a4
    80004d72:	058a0593          	addi	a1,s4,88
    80004d76:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004d78:	0007b883          	ld	a7,0(a5)
    80004d7c:	9746                	add	a4,a4,a7
    80004d7e:	40000613          	li	a2,1024
    80004d82:	c710                	sw	a2,8(a4)
  if(write)
    80004d84:	001bb613          	seqz	a2,s7
    80004d88:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004d8c:	00166613          	ori	a2,a2,1
    80004d90:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004d94:	f9842583          	lw	a1,-104(s0)
    80004d98:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004d9c:	00250613          	addi	a2,a0,2
    80004da0:	0612                	slli	a2,a2,0x4
    80004da2:	963e                	add	a2,a2,a5
    80004da4:	577d                	li	a4,-1
    80004da6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004daa:	0592                	slli	a1,a1,0x4
    80004dac:	98ae                	add	a7,a7,a1
    80004dae:	03068713          	addi	a4,a3,48
    80004db2:	973e                	add	a4,a4,a5
    80004db4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004db8:	6398                	ld	a4,0(a5)
    80004dba:	972e                	add	a4,a4,a1
    80004dbc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004dc0:	4689                	li	a3,2
    80004dc2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004dc6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004dca:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004dce:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004dd2:	6794                	ld	a3,8(a5)
    80004dd4:	0026d703          	lhu	a4,2(a3)
    80004dd8:	8b1d                	andi	a4,a4,7
    80004dda:	0706                	slli	a4,a4,0x1
    80004ddc:	96ba                	add	a3,a3,a4
    80004dde:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004de2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004de6:	6798                	ld	a4,8(a5)
    80004de8:	00275783          	lhu	a5,2(a4)
    80004dec:	2785                	addiw	a5,a5,1
    80004dee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004df2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004df6:	100017b7          	lui	a5,0x10001
    80004dfa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004dfe:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004e02:	00017917          	auipc	s2,0x17
    80004e06:	be690913          	addi	s2,s2,-1050 # 8001b9e8 <disk+0x128>
  while(b->disk == 1) {
    80004e0a:	4485                	li	s1,1
    80004e0c:	01079a63          	bne	a5,a6,80004e20 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004e10:	85ca                	mv	a1,s2
    80004e12:	8552                	mv	a0,s4
    80004e14:	e42fc0ef          	jal	80001456 <sleep>
  while(b->disk == 1) {
    80004e18:	004a2783          	lw	a5,4(s4)
    80004e1c:	fe978ae3          	beq	a5,s1,80004e10 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004e20:	f9042903          	lw	s2,-112(s0)
    80004e24:	00290713          	addi	a4,s2,2
    80004e28:	0712                	slli	a4,a4,0x4
    80004e2a:	00017797          	auipc	a5,0x17
    80004e2e:	a9678793          	addi	a5,a5,-1386 # 8001b8c0 <disk>
    80004e32:	97ba                	add	a5,a5,a4
    80004e34:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004e38:	00017997          	auipc	s3,0x17
    80004e3c:	a8898993          	addi	s3,s3,-1400 # 8001b8c0 <disk>
    80004e40:	00491713          	slli	a4,s2,0x4
    80004e44:	0009b783          	ld	a5,0(s3)
    80004e48:	97ba                	add	a5,a5,a4
    80004e4a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004e4e:	854a                	mv	a0,s2
    80004e50:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004e54:	bafff0ef          	jal	80004a02 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004e58:	8885                	andi	s1,s1,1
    80004e5a:	f0fd                	bnez	s1,80004e40 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004e5c:	00017517          	auipc	a0,0x17
    80004e60:	b8c50513          	addi	a0,a0,-1140 # 8001b9e8 <disk+0x128>
    80004e64:	405000ef          	jal	80005a68 <release>
}
    80004e68:	70a6                	ld	ra,104(sp)
    80004e6a:	7406                	ld	s0,96(sp)
    80004e6c:	64e6                	ld	s1,88(sp)
    80004e6e:	6946                	ld	s2,80(sp)
    80004e70:	69a6                	ld	s3,72(sp)
    80004e72:	6a06                	ld	s4,64(sp)
    80004e74:	7ae2                	ld	s5,56(sp)
    80004e76:	7b42                	ld	s6,48(sp)
    80004e78:	7ba2                	ld	s7,40(sp)
    80004e7a:	7c02                	ld	s8,32(sp)
    80004e7c:	6ce2                	ld	s9,24(sp)
    80004e7e:	6165                	addi	sp,sp,112
    80004e80:	8082                	ret

0000000080004e82 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004e82:	1101                	addi	sp,sp,-32
    80004e84:	ec06                	sd	ra,24(sp)
    80004e86:	e822                	sd	s0,16(sp)
    80004e88:	e426                	sd	s1,8(sp)
    80004e8a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004e8c:	00017497          	auipc	s1,0x17
    80004e90:	a3448493          	addi	s1,s1,-1484 # 8001b8c0 <disk>
    80004e94:	00017517          	auipc	a0,0x17
    80004e98:	b5450513          	addi	a0,a0,-1196 # 8001b9e8 <disk+0x128>
    80004e9c:	335000ef          	jal	800059d0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004ea0:	100017b7          	lui	a5,0x10001
    80004ea4:	53b8                	lw	a4,96(a5)
    80004ea6:	8b0d                	andi	a4,a4,3
    80004ea8:	100017b7          	lui	a5,0x10001
    80004eac:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004eae:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004eb2:	689c                	ld	a5,16(s1)
    80004eb4:	0204d703          	lhu	a4,32(s1)
    80004eb8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004ebc:	04f70663          	beq	a4,a5,80004f08 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004ec0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004ec4:	6898                	ld	a4,16(s1)
    80004ec6:	0204d783          	lhu	a5,32(s1)
    80004eca:	8b9d                	andi	a5,a5,7
    80004ecc:	078e                	slli	a5,a5,0x3
    80004ece:	97ba                	add	a5,a5,a4
    80004ed0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004ed2:	00278713          	addi	a4,a5,2
    80004ed6:	0712                	slli	a4,a4,0x4
    80004ed8:	9726                	add	a4,a4,s1
    80004eda:	01074703          	lbu	a4,16(a4)
    80004ede:	e321                	bnez	a4,80004f1e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004ee0:	0789                	addi	a5,a5,2
    80004ee2:	0792                	slli	a5,a5,0x4
    80004ee4:	97a6                	add	a5,a5,s1
    80004ee6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004ee8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004eec:	db6fc0ef          	jal	800014a2 <wakeup>

    disk.used_idx += 1;
    80004ef0:	0204d783          	lhu	a5,32(s1)
    80004ef4:	2785                	addiw	a5,a5,1
    80004ef6:	17c2                	slli	a5,a5,0x30
    80004ef8:	93c1                	srli	a5,a5,0x30
    80004efa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004efe:	6898                	ld	a4,16(s1)
    80004f00:	00275703          	lhu	a4,2(a4)
    80004f04:	faf71ee3          	bne	a4,a5,80004ec0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004f08:	00017517          	auipc	a0,0x17
    80004f0c:	ae050513          	addi	a0,a0,-1312 # 8001b9e8 <disk+0x128>
    80004f10:	359000ef          	jal	80005a68 <release>
}
    80004f14:	60e2                	ld	ra,24(sp)
    80004f16:	6442                	ld	s0,16(sp)
    80004f18:	64a2                	ld	s1,8(sp)
    80004f1a:	6105                	addi	sp,sp,32
    80004f1c:	8082                	ret
      panic("virtio_disk_intr status");
    80004f1e:	00003517          	auipc	a0,0x3
    80004f22:	8fa50513          	addi	a0,a0,-1798 # 80007818 <etext+0x818>
    80004f26:	77c000ef          	jal	800056a2 <panic>

0000000080004f2a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004f2a:	1141                	addi	sp,sp,-16
    80004f2c:	e422                	sd	s0,8(sp)
    80004f2e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004f30:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004f34:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004f38:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004f3c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004f40:	577d                	li	a4,-1
    80004f42:	177e                	slli	a4,a4,0x3f
    80004f44:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004f46:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004f4a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004f4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004f52:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004f56:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004f5a:	000f4737          	lui	a4,0xf4
    80004f5e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004f62:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004f64:	14d79073          	csrw	stimecmp,a5
}
    80004f68:	6422                	ld	s0,8(sp)
    80004f6a:	0141                	addi	sp,sp,16
    80004f6c:	8082                	ret

0000000080004f6e <start>:
{
    80004f6e:	1141                	addi	sp,sp,-16
    80004f70:	e406                	sd	ra,8(sp)
    80004f72:	e022                	sd	s0,0(sp)
    80004f74:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004f76:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004f7a:	7779                	lui	a4,0xffffe
    80004f7c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdacff>
    80004f80:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004f82:	6705                	lui	a4,0x1
    80004f84:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004f88:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004f8a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004f8e:	ffffb797          	auipc	a5,0xffffb
    80004f92:	39c78793          	addi	a5,a5,924 # 8000032a <main>
    80004f96:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004f9a:	4781                	li	a5,0
    80004f9c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004fa0:	67c1                	lui	a5,0x10
    80004fa2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004fa4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004fa8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004fac:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004fb0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004fb4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004fb8:	57fd                	li	a5,-1
    80004fba:	83a9                	srli	a5,a5,0xa
    80004fbc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004fc0:	47bd                	li	a5,15
    80004fc2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004fc6:	f65ff0ef          	jal	80004f2a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004fca:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004fce:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004fd0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004fd2:	30200073          	mret
}
    80004fd6:	60a2                	ld	ra,8(sp)
    80004fd8:	6402                	ld	s0,0(sp)
    80004fda:	0141                	addi	sp,sp,16
    80004fdc:	8082                	ret

0000000080004fde <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004fde:	715d                	addi	sp,sp,-80
    80004fe0:	e486                	sd	ra,72(sp)
    80004fe2:	e0a2                	sd	s0,64(sp)
    80004fe4:	f84a                	sd	s2,48(sp)
    80004fe6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004fe8:	04c05263          	blez	a2,8000502c <consolewrite+0x4e>
    80004fec:	fc26                	sd	s1,56(sp)
    80004fee:	f44e                	sd	s3,40(sp)
    80004ff0:	f052                	sd	s4,32(sp)
    80004ff2:	ec56                	sd	s5,24(sp)
    80004ff4:	8a2a                	mv	s4,a0
    80004ff6:	84ae                	mv	s1,a1
    80004ff8:	89b2                	mv	s3,a2
    80004ffa:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004ffc:	5afd                	li	s5,-1
    80004ffe:	4685                	li	a3,1
    80005000:	8626                	mv	a2,s1
    80005002:	85d2                	mv	a1,s4
    80005004:	fbf40513          	addi	a0,s0,-65
    80005008:	ff4fc0ef          	jal	800017fc <either_copyin>
    8000500c:	03550263          	beq	a0,s5,80005030 <consolewrite+0x52>
      break;
    uartputc(c);
    80005010:	fbf44503          	lbu	a0,-65(s0)
    80005014:	035000ef          	jal	80005848 <uartputc>
  for(i = 0; i < n; i++){
    80005018:	2905                	addiw	s2,s2,1
    8000501a:	0485                	addi	s1,s1,1
    8000501c:	ff2991e3          	bne	s3,s2,80004ffe <consolewrite+0x20>
    80005020:	894e                	mv	s2,s3
    80005022:	74e2                	ld	s1,56(sp)
    80005024:	79a2                	ld	s3,40(sp)
    80005026:	7a02                	ld	s4,32(sp)
    80005028:	6ae2                	ld	s5,24(sp)
    8000502a:	a039                	j	80005038 <consolewrite+0x5a>
    8000502c:	4901                	li	s2,0
    8000502e:	a029                	j	80005038 <consolewrite+0x5a>
    80005030:	74e2                	ld	s1,56(sp)
    80005032:	79a2                	ld	s3,40(sp)
    80005034:	7a02                	ld	s4,32(sp)
    80005036:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80005038:	854a                	mv	a0,s2
    8000503a:	60a6                	ld	ra,72(sp)
    8000503c:	6406                	ld	s0,64(sp)
    8000503e:	7942                	ld	s2,48(sp)
    80005040:	6161                	addi	sp,sp,80
    80005042:	8082                	ret

0000000080005044 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005044:	711d                	addi	sp,sp,-96
    80005046:	ec86                	sd	ra,88(sp)
    80005048:	e8a2                	sd	s0,80(sp)
    8000504a:	e4a6                	sd	s1,72(sp)
    8000504c:	e0ca                	sd	s2,64(sp)
    8000504e:	fc4e                	sd	s3,56(sp)
    80005050:	f852                	sd	s4,48(sp)
    80005052:	f456                	sd	s5,40(sp)
    80005054:	f05a                	sd	s6,32(sp)
    80005056:	1080                	addi	s0,sp,96
    80005058:	8aaa                	mv	s5,a0
    8000505a:	8a2e                	mv	s4,a1
    8000505c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000505e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005062:	0001f517          	auipc	a0,0x1f
    80005066:	99e50513          	addi	a0,a0,-1634 # 80023a00 <cons>
    8000506a:	167000ef          	jal	800059d0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000506e:	0001f497          	auipc	s1,0x1f
    80005072:	99248493          	addi	s1,s1,-1646 # 80023a00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005076:	0001f917          	auipc	s2,0x1f
    8000507a:	a2290913          	addi	s2,s2,-1502 # 80023a98 <cons+0x98>
  while(n > 0){
    8000507e:	0b305d63          	blez	s3,80005138 <consoleread+0xf4>
    while(cons.r == cons.w){
    80005082:	0984a783          	lw	a5,152(s1)
    80005086:	09c4a703          	lw	a4,156(s1)
    8000508a:	0af71263          	bne	a4,a5,8000512e <consoleread+0xea>
      if(killed(myproc())){
    8000508e:	df3fb0ef          	jal	80000e80 <myproc>
    80005092:	dfcfc0ef          	jal	8000168e <killed>
    80005096:	e12d                	bnez	a0,800050f8 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80005098:	85a6                	mv	a1,s1
    8000509a:	854a                	mv	a0,s2
    8000509c:	bbafc0ef          	jal	80001456 <sleep>
    while(cons.r == cons.w){
    800050a0:	0984a783          	lw	a5,152(s1)
    800050a4:	09c4a703          	lw	a4,156(s1)
    800050a8:	fef703e3          	beq	a4,a5,8000508e <consoleread+0x4a>
    800050ac:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800050ae:	0001f717          	auipc	a4,0x1f
    800050b2:	95270713          	addi	a4,a4,-1710 # 80023a00 <cons>
    800050b6:	0017869b          	addiw	a3,a5,1
    800050ba:	08d72c23          	sw	a3,152(a4)
    800050be:	07f7f693          	andi	a3,a5,127
    800050c2:	9736                	add	a4,a4,a3
    800050c4:	01874703          	lbu	a4,24(a4)
    800050c8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800050cc:	4691                	li	a3,4
    800050ce:	04db8663          	beq	s7,a3,8000511a <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800050d2:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800050d6:	4685                	li	a3,1
    800050d8:	faf40613          	addi	a2,s0,-81
    800050dc:	85d2                	mv	a1,s4
    800050de:	8556                	mv	a0,s5
    800050e0:	ed2fc0ef          	jal	800017b2 <either_copyout>
    800050e4:	57fd                	li	a5,-1
    800050e6:	04f50863          	beq	a0,a5,80005136 <consoleread+0xf2>
      break;

    dst++;
    800050ea:	0a05                	addi	s4,s4,1
    --n;
    800050ec:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800050ee:	47a9                	li	a5,10
    800050f0:	04fb8d63          	beq	s7,a5,8000514a <consoleread+0x106>
    800050f4:	6be2                	ld	s7,24(sp)
    800050f6:	b761                	j	8000507e <consoleread+0x3a>
        release(&cons.lock);
    800050f8:	0001f517          	auipc	a0,0x1f
    800050fc:	90850513          	addi	a0,a0,-1784 # 80023a00 <cons>
    80005100:	169000ef          	jal	80005a68 <release>
        return -1;
    80005104:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80005106:	60e6                	ld	ra,88(sp)
    80005108:	6446                	ld	s0,80(sp)
    8000510a:	64a6                	ld	s1,72(sp)
    8000510c:	6906                	ld	s2,64(sp)
    8000510e:	79e2                	ld	s3,56(sp)
    80005110:	7a42                	ld	s4,48(sp)
    80005112:	7aa2                	ld	s5,40(sp)
    80005114:	7b02                	ld	s6,32(sp)
    80005116:	6125                	addi	sp,sp,96
    80005118:	8082                	ret
      if(n < target){
    8000511a:	0009871b          	sext.w	a4,s3
    8000511e:	01677a63          	bgeu	a4,s6,80005132 <consoleread+0xee>
        cons.r--;
    80005122:	0001f717          	auipc	a4,0x1f
    80005126:	96f72b23          	sw	a5,-1674(a4) # 80023a98 <cons+0x98>
    8000512a:	6be2                	ld	s7,24(sp)
    8000512c:	a031                	j	80005138 <consoleread+0xf4>
    8000512e:	ec5e                	sd	s7,24(sp)
    80005130:	bfbd                	j	800050ae <consoleread+0x6a>
    80005132:	6be2                	ld	s7,24(sp)
    80005134:	a011                	j	80005138 <consoleread+0xf4>
    80005136:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005138:	0001f517          	auipc	a0,0x1f
    8000513c:	8c850513          	addi	a0,a0,-1848 # 80023a00 <cons>
    80005140:	129000ef          	jal	80005a68 <release>
  return target - n;
    80005144:	413b053b          	subw	a0,s6,s3
    80005148:	bf7d                	j	80005106 <consoleread+0xc2>
    8000514a:	6be2                	ld	s7,24(sp)
    8000514c:	b7f5                	j	80005138 <consoleread+0xf4>

000000008000514e <consputc>:
{
    8000514e:	1141                	addi	sp,sp,-16
    80005150:	e406                	sd	ra,8(sp)
    80005152:	e022                	sd	s0,0(sp)
    80005154:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005156:	10000793          	li	a5,256
    8000515a:	00f50863          	beq	a0,a5,8000516a <consputc+0x1c>
    uartputc_sync(c);
    8000515e:	604000ef          	jal	80005762 <uartputc_sync>
}
    80005162:	60a2                	ld	ra,8(sp)
    80005164:	6402                	ld	s0,0(sp)
    80005166:	0141                	addi	sp,sp,16
    80005168:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000516a:	4521                	li	a0,8
    8000516c:	5f6000ef          	jal	80005762 <uartputc_sync>
    80005170:	02000513          	li	a0,32
    80005174:	5ee000ef          	jal	80005762 <uartputc_sync>
    80005178:	4521                	li	a0,8
    8000517a:	5e8000ef          	jal	80005762 <uartputc_sync>
    8000517e:	b7d5                	j	80005162 <consputc+0x14>

0000000080005180 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005180:	1101                	addi	sp,sp,-32
    80005182:	ec06                	sd	ra,24(sp)
    80005184:	e822                	sd	s0,16(sp)
    80005186:	e426                	sd	s1,8(sp)
    80005188:	1000                	addi	s0,sp,32
    8000518a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000518c:	0001f517          	auipc	a0,0x1f
    80005190:	87450513          	addi	a0,a0,-1932 # 80023a00 <cons>
    80005194:	03d000ef          	jal	800059d0 <acquire>

  switch(c){
    80005198:	47d5                	li	a5,21
    8000519a:	08f48f63          	beq	s1,a5,80005238 <consoleintr+0xb8>
    8000519e:	0297c563          	blt	a5,s1,800051c8 <consoleintr+0x48>
    800051a2:	47a1                	li	a5,8
    800051a4:	0ef48463          	beq	s1,a5,8000528c <consoleintr+0x10c>
    800051a8:	47c1                	li	a5,16
    800051aa:	10f49563          	bne	s1,a5,800052b4 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800051ae:	e98fc0ef          	jal	80001846 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800051b2:	0001f517          	auipc	a0,0x1f
    800051b6:	84e50513          	addi	a0,a0,-1970 # 80023a00 <cons>
    800051ba:	0af000ef          	jal	80005a68 <release>
}
    800051be:	60e2                	ld	ra,24(sp)
    800051c0:	6442                	ld	s0,16(sp)
    800051c2:	64a2                	ld	s1,8(sp)
    800051c4:	6105                	addi	sp,sp,32
    800051c6:	8082                	ret
  switch(c){
    800051c8:	07f00793          	li	a5,127
    800051cc:	0cf48063          	beq	s1,a5,8000528c <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051d0:	0001f717          	auipc	a4,0x1f
    800051d4:	83070713          	addi	a4,a4,-2000 # 80023a00 <cons>
    800051d8:	0a072783          	lw	a5,160(a4)
    800051dc:	09872703          	lw	a4,152(a4)
    800051e0:	9f99                	subw	a5,a5,a4
    800051e2:	07f00713          	li	a4,127
    800051e6:	fcf766e3          	bltu	a4,a5,800051b2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800051ea:	47b5                	li	a5,13
    800051ec:	0cf48763          	beq	s1,a5,800052ba <consoleintr+0x13a>
      consputc(c);
    800051f0:	8526                	mv	a0,s1
    800051f2:	f5dff0ef          	jal	8000514e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051f6:	0001f797          	auipc	a5,0x1f
    800051fa:	80a78793          	addi	a5,a5,-2038 # 80023a00 <cons>
    800051fe:	0a07a683          	lw	a3,160(a5)
    80005202:	0016871b          	addiw	a4,a3,1
    80005206:	0007061b          	sext.w	a2,a4
    8000520a:	0ae7a023          	sw	a4,160(a5)
    8000520e:	07f6f693          	andi	a3,a3,127
    80005212:	97b6                	add	a5,a5,a3
    80005214:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005218:	47a9                	li	a5,10
    8000521a:	0cf48563          	beq	s1,a5,800052e4 <consoleintr+0x164>
    8000521e:	4791                	li	a5,4
    80005220:	0cf48263          	beq	s1,a5,800052e4 <consoleintr+0x164>
    80005224:	0001f797          	auipc	a5,0x1f
    80005228:	8747a783          	lw	a5,-1932(a5) # 80023a98 <cons+0x98>
    8000522c:	9f1d                	subw	a4,a4,a5
    8000522e:	08000793          	li	a5,128
    80005232:	f8f710e3          	bne	a4,a5,800051b2 <consoleintr+0x32>
    80005236:	a07d                	j	800052e4 <consoleintr+0x164>
    80005238:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000523a:	0001e717          	auipc	a4,0x1e
    8000523e:	7c670713          	addi	a4,a4,1990 # 80023a00 <cons>
    80005242:	0a072783          	lw	a5,160(a4)
    80005246:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000524a:	0001e497          	auipc	s1,0x1e
    8000524e:	7b648493          	addi	s1,s1,1974 # 80023a00 <cons>
    while(cons.e != cons.w &&
    80005252:	4929                	li	s2,10
    80005254:	02f70863          	beq	a4,a5,80005284 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005258:	37fd                	addiw	a5,a5,-1
    8000525a:	07f7f713          	andi	a4,a5,127
    8000525e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005260:	01874703          	lbu	a4,24(a4)
    80005264:	03270263          	beq	a4,s2,80005288 <consoleintr+0x108>
      cons.e--;
    80005268:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000526c:	10000513          	li	a0,256
    80005270:	edfff0ef          	jal	8000514e <consputc>
    while(cons.e != cons.w &&
    80005274:	0a04a783          	lw	a5,160(s1)
    80005278:	09c4a703          	lw	a4,156(s1)
    8000527c:	fcf71ee3          	bne	a4,a5,80005258 <consoleintr+0xd8>
    80005280:	6902                	ld	s2,0(sp)
    80005282:	bf05                	j	800051b2 <consoleintr+0x32>
    80005284:	6902                	ld	s2,0(sp)
    80005286:	b735                	j	800051b2 <consoleintr+0x32>
    80005288:	6902                	ld	s2,0(sp)
    8000528a:	b725                	j	800051b2 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000528c:	0001e717          	auipc	a4,0x1e
    80005290:	77470713          	addi	a4,a4,1908 # 80023a00 <cons>
    80005294:	0a072783          	lw	a5,160(a4)
    80005298:	09c72703          	lw	a4,156(a4)
    8000529c:	f0f70be3          	beq	a4,a5,800051b2 <consoleintr+0x32>
      cons.e--;
    800052a0:	37fd                	addiw	a5,a5,-1
    800052a2:	0001e717          	auipc	a4,0x1e
    800052a6:	7ef72f23          	sw	a5,2046(a4) # 80023aa0 <cons+0xa0>
      consputc(BACKSPACE);
    800052aa:	10000513          	li	a0,256
    800052ae:	ea1ff0ef          	jal	8000514e <consputc>
    800052b2:	b701                	j	800051b2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800052b4:	ee048fe3          	beqz	s1,800051b2 <consoleintr+0x32>
    800052b8:	bf21                	j	800051d0 <consoleintr+0x50>
      consputc(c);
    800052ba:	4529                	li	a0,10
    800052bc:	e93ff0ef          	jal	8000514e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800052c0:	0001e797          	auipc	a5,0x1e
    800052c4:	74078793          	addi	a5,a5,1856 # 80023a00 <cons>
    800052c8:	0a07a703          	lw	a4,160(a5)
    800052cc:	0017069b          	addiw	a3,a4,1
    800052d0:	0006861b          	sext.w	a2,a3
    800052d4:	0ad7a023          	sw	a3,160(a5)
    800052d8:	07f77713          	andi	a4,a4,127
    800052dc:	97ba                	add	a5,a5,a4
    800052de:	4729                	li	a4,10
    800052e0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800052e4:	0001e797          	auipc	a5,0x1e
    800052e8:	7ac7ac23          	sw	a2,1976(a5) # 80023a9c <cons+0x9c>
        wakeup(&cons.r);
    800052ec:	0001e517          	auipc	a0,0x1e
    800052f0:	7ac50513          	addi	a0,a0,1964 # 80023a98 <cons+0x98>
    800052f4:	9aefc0ef          	jal	800014a2 <wakeup>
    800052f8:	bd6d                	j	800051b2 <consoleintr+0x32>

00000000800052fa <consoleinit>:

void
consoleinit(void)
{
    800052fa:	1141                	addi	sp,sp,-16
    800052fc:	e406                	sd	ra,8(sp)
    800052fe:	e022                	sd	s0,0(sp)
    80005300:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005302:	00002597          	auipc	a1,0x2
    80005306:	52e58593          	addi	a1,a1,1326 # 80007830 <etext+0x830>
    8000530a:	0001e517          	auipc	a0,0x1e
    8000530e:	6f650513          	addi	a0,a0,1782 # 80023a00 <cons>
    80005312:	63e000ef          	jal	80005950 <initlock>

  uartinit();
    80005316:	3f4000ef          	jal	8000570a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000531a:	00015797          	auipc	a5,0x15
    8000531e:	54e78793          	addi	a5,a5,1358 # 8001a868 <devsw>
    80005322:	00000717          	auipc	a4,0x0
    80005326:	d2270713          	addi	a4,a4,-734 # 80005044 <consoleread>
    8000532a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000532c:	00000717          	auipc	a4,0x0
    80005330:	cb270713          	addi	a4,a4,-846 # 80004fde <consolewrite>
    80005334:	ef98                	sd	a4,24(a5)
}
    80005336:	60a2                	ld	ra,8(sp)
    80005338:	6402                	ld	s0,0(sp)
    8000533a:	0141                	addi	sp,sp,16
    8000533c:	8082                	ret

000000008000533e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000533e:	7179                	addi	sp,sp,-48
    80005340:	f406                	sd	ra,40(sp)
    80005342:	f022                	sd	s0,32(sp)
    80005344:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005346:	c219                	beqz	a2,8000534c <printint+0xe>
    80005348:	08054063          	bltz	a0,800053c8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000534c:	4881                	li	a7,0
    8000534e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005352:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005354:	00002617          	auipc	a2,0x2
    80005358:	72460613          	addi	a2,a2,1828 # 80007a78 <digits>
    8000535c:	883e                	mv	a6,a5
    8000535e:	2785                	addiw	a5,a5,1
    80005360:	02b57733          	remu	a4,a0,a1
    80005364:	9732                	add	a4,a4,a2
    80005366:	00074703          	lbu	a4,0(a4)
    8000536a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000536e:	872a                	mv	a4,a0
    80005370:	02b55533          	divu	a0,a0,a1
    80005374:	0685                	addi	a3,a3,1
    80005376:	feb773e3          	bgeu	a4,a1,8000535c <printint+0x1e>

  if(sign)
    8000537a:	00088a63          	beqz	a7,8000538e <printint+0x50>
    buf[i++] = '-';
    8000537e:	1781                	addi	a5,a5,-32
    80005380:	97a2                	add	a5,a5,s0
    80005382:	02d00713          	li	a4,45
    80005386:	fee78823          	sb	a4,-16(a5)
    8000538a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000538e:	02f05963          	blez	a5,800053c0 <printint+0x82>
    80005392:	ec26                	sd	s1,24(sp)
    80005394:	e84a                	sd	s2,16(sp)
    80005396:	fd040713          	addi	a4,s0,-48
    8000539a:	00f704b3          	add	s1,a4,a5
    8000539e:	fff70913          	addi	s2,a4,-1
    800053a2:	993e                	add	s2,s2,a5
    800053a4:	37fd                	addiw	a5,a5,-1
    800053a6:	1782                	slli	a5,a5,0x20
    800053a8:	9381                	srli	a5,a5,0x20
    800053aa:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800053ae:	fff4c503          	lbu	a0,-1(s1)
    800053b2:	d9dff0ef          	jal	8000514e <consputc>
  while(--i >= 0)
    800053b6:	14fd                	addi	s1,s1,-1
    800053b8:	ff249be3          	bne	s1,s2,800053ae <printint+0x70>
    800053bc:	64e2                	ld	s1,24(sp)
    800053be:	6942                	ld	s2,16(sp)
}
    800053c0:	70a2                	ld	ra,40(sp)
    800053c2:	7402                	ld	s0,32(sp)
    800053c4:	6145                	addi	sp,sp,48
    800053c6:	8082                	ret
    x = -xx;
    800053c8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800053cc:	4885                	li	a7,1
    x = -xx;
    800053ce:	b741                	j	8000534e <printint+0x10>

00000000800053d0 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800053d0:	7155                	addi	sp,sp,-208
    800053d2:	e506                	sd	ra,136(sp)
    800053d4:	e122                	sd	s0,128(sp)
    800053d6:	f0d2                	sd	s4,96(sp)
    800053d8:	0900                	addi	s0,sp,144
    800053da:	8a2a                	mv	s4,a0
    800053dc:	e40c                	sd	a1,8(s0)
    800053de:	e810                	sd	a2,16(s0)
    800053e0:	ec14                	sd	a3,24(s0)
    800053e2:	f018                	sd	a4,32(s0)
    800053e4:	f41c                	sd	a5,40(s0)
    800053e6:	03043823          	sd	a6,48(s0)
    800053ea:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800053ee:	0001e797          	auipc	a5,0x1e
    800053f2:	6d27a783          	lw	a5,1746(a5) # 80023ac0 <pr+0x18>
    800053f6:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800053fa:	e3a1                	bnez	a5,8000543a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800053fc:	00840793          	addi	a5,s0,8
    80005400:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005404:	00054503          	lbu	a0,0(a0)
    80005408:	26050763          	beqz	a0,80005676 <printf+0x2a6>
    8000540c:	fca6                	sd	s1,120(sp)
    8000540e:	f8ca                	sd	s2,112(sp)
    80005410:	f4ce                	sd	s3,104(sp)
    80005412:	ecd6                	sd	s5,88(sp)
    80005414:	e8da                	sd	s6,80(sp)
    80005416:	e0e2                	sd	s8,64(sp)
    80005418:	fc66                	sd	s9,56(sp)
    8000541a:	f86a                	sd	s10,48(sp)
    8000541c:	f46e                	sd	s11,40(sp)
    8000541e:	4981                	li	s3,0
    if(cx != '%'){
    80005420:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005424:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005428:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000542c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005430:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005434:	07000d93          	li	s11,112
    80005438:	a815                	j	8000546c <printf+0x9c>
    acquire(&pr.lock);
    8000543a:	0001e517          	auipc	a0,0x1e
    8000543e:	66e50513          	addi	a0,a0,1646 # 80023aa8 <pr>
    80005442:	58e000ef          	jal	800059d0 <acquire>
  va_start(ap, fmt);
    80005446:	00840793          	addi	a5,s0,8
    8000544a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000544e:	000a4503          	lbu	a0,0(s4)
    80005452:	fd4d                	bnez	a0,8000540c <printf+0x3c>
    80005454:	a481                	j	80005694 <printf+0x2c4>
      consputc(cx);
    80005456:	cf9ff0ef          	jal	8000514e <consputc>
      continue;
    8000545a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000545c:	0014899b          	addiw	s3,s1,1
    80005460:	013a07b3          	add	a5,s4,s3
    80005464:	0007c503          	lbu	a0,0(a5)
    80005468:	1e050b63          	beqz	a0,8000565e <printf+0x28e>
    if(cx != '%'){
    8000546c:	ff5515e3          	bne	a0,s5,80005456 <printf+0x86>
    i++;
    80005470:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005474:	009a07b3          	add	a5,s4,s1
    80005478:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000547c:	1e090163          	beqz	s2,8000565e <printf+0x28e>
    80005480:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005484:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80005486:	c789                	beqz	a5,80005490 <printf+0xc0>
    80005488:	009a0733          	add	a4,s4,s1
    8000548c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005490:	03690763          	beq	s2,s6,800054be <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80005494:	05890163          	beq	s2,s8,800054d6 <printf+0x106>
    } else if(c0 == 'u'){
    80005498:	0d990b63          	beq	s2,s9,8000556e <printf+0x19e>
    } else if(c0 == 'x'){
    8000549c:	13a90163          	beq	s2,s10,800055be <printf+0x1ee>
    } else if(c0 == 'p'){
    800054a0:	13b90b63          	beq	s2,s11,800055d6 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800054a4:	07300793          	li	a5,115
    800054a8:	16f90a63          	beq	s2,a5,8000561c <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800054ac:	1b590463          	beq	s2,s5,80005654 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800054b0:	8556                	mv	a0,s5
    800054b2:	c9dff0ef          	jal	8000514e <consputc>
      consputc(c0);
    800054b6:	854a                	mv	a0,s2
    800054b8:	c97ff0ef          	jal	8000514e <consputc>
    800054bc:	b745                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800054be:	f8843783          	ld	a5,-120(s0)
    800054c2:	00878713          	addi	a4,a5,8
    800054c6:	f8e43423          	sd	a4,-120(s0)
    800054ca:	4605                	li	a2,1
    800054cc:	45a9                	li	a1,10
    800054ce:	4388                	lw	a0,0(a5)
    800054d0:	e6fff0ef          	jal	8000533e <printint>
    800054d4:	b761                	j	8000545c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800054d6:	03678663          	beq	a5,s6,80005502 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800054da:	05878263          	beq	a5,s8,8000551e <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800054de:	0b978463          	beq	a5,s9,80005586 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800054e2:	fda797e3          	bne	a5,s10,800054b0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800054e6:	f8843783          	ld	a5,-120(s0)
    800054ea:	00878713          	addi	a4,a5,8
    800054ee:	f8e43423          	sd	a4,-120(s0)
    800054f2:	4601                	li	a2,0
    800054f4:	45c1                	li	a1,16
    800054f6:	6388                	ld	a0,0(a5)
    800054f8:	e47ff0ef          	jal	8000533e <printint>
      i += 1;
    800054fc:	0029849b          	addiw	s1,s3,2
    80005500:	bfb1                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005502:	f8843783          	ld	a5,-120(s0)
    80005506:	00878713          	addi	a4,a5,8
    8000550a:	f8e43423          	sd	a4,-120(s0)
    8000550e:	4605                	li	a2,1
    80005510:	45a9                	li	a1,10
    80005512:	6388                	ld	a0,0(a5)
    80005514:	e2bff0ef          	jal	8000533e <printint>
      i += 1;
    80005518:	0029849b          	addiw	s1,s3,2
    8000551c:	b781                	j	8000545c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000551e:	06400793          	li	a5,100
    80005522:	02f68863          	beq	a3,a5,80005552 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005526:	07500793          	li	a5,117
    8000552a:	06f68c63          	beq	a3,a5,800055a2 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000552e:	07800793          	li	a5,120
    80005532:	f6f69fe3          	bne	a3,a5,800054b0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005536:	f8843783          	ld	a5,-120(s0)
    8000553a:	00878713          	addi	a4,a5,8
    8000553e:	f8e43423          	sd	a4,-120(s0)
    80005542:	4601                	li	a2,0
    80005544:	45c1                	li	a1,16
    80005546:	6388                	ld	a0,0(a5)
    80005548:	df7ff0ef          	jal	8000533e <printint>
      i += 2;
    8000554c:	0039849b          	addiw	s1,s3,3
    80005550:	b731                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005552:	f8843783          	ld	a5,-120(s0)
    80005556:	00878713          	addi	a4,a5,8
    8000555a:	f8e43423          	sd	a4,-120(s0)
    8000555e:	4605                	li	a2,1
    80005560:	45a9                	li	a1,10
    80005562:	6388                	ld	a0,0(a5)
    80005564:	ddbff0ef          	jal	8000533e <printint>
      i += 2;
    80005568:	0039849b          	addiw	s1,s3,3
    8000556c:	bdc5                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000556e:	f8843783          	ld	a5,-120(s0)
    80005572:	00878713          	addi	a4,a5,8
    80005576:	f8e43423          	sd	a4,-120(s0)
    8000557a:	4601                	li	a2,0
    8000557c:	45a9                	li	a1,10
    8000557e:	4388                	lw	a0,0(a5)
    80005580:	dbfff0ef          	jal	8000533e <printint>
    80005584:	bde1                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80005586:	f8843783          	ld	a5,-120(s0)
    8000558a:	00878713          	addi	a4,a5,8
    8000558e:	f8e43423          	sd	a4,-120(s0)
    80005592:	4601                	li	a2,0
    80005594:	45a9                	li	a1,10
    80005596:	6388                	ld	a0,0(a5)
    80005598:	da7ff0ef          	jal	8000533e <printint>
      i += 1;
    8000559c:	0029849b          	addiw	s1,s3,2
    800055a0:	bd75                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800055a2:	f8843783          	ld	a5,-120(s0)
    800055a6:	00878713          	addi	a4,a5,8
    800055aa:	f8e43423          	sd	a4,-120(s0)
    800055ae:	4601                	li	a2,0
    800055b0:	45a9                	li	a1,10
    800055b2:	6388                	ld	a0,0(a5)
    800055b4:	d8bff0ef          	jal	8000533e <printint>
      i += 2;
    800055b8:	0039849b          	addiw	s1,s3,3
    800055bc:	b545                	j	8000545c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800055be:	f8843783          	ld	a5,-120(s0)
    800055c2:	00878713          	addi	a4,a5,8
    800055c6:	f8e43423          	sd	a4,-120(s0)
    800055ca:	4601                	li	a2,0
    800055cc:	45c1                	li	a1,16
    800055ce:	4388                	lw	a0,0(a5)
    800055d0:	d6fff0ef          	jal	8000533e <printint>
    800055d4:	b561                	j	8000545c <printf+0x8c>
    800055d6:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800055d8:	f8843783          	ld	a5,-120(s0)
    800055dc:	00878713          	addi	a4,a5,8
    800055e0:	f8e43423          	sd	a4,-120(s0)
    800055e4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800055e8:	03000513          	li	a0,48
    800055ec:	b63ff0ef          	jal	8000514e <consputc>
  consputc('x');
    800055f0:	07800513          	li	a0,120
    800055f4:	b5bff0ef          	jal	8000514e <consputc>
    800055f8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800055fa:	00002b97          	auipc	s7,0x2
    800055fe:	47eb8b93          	addi	s7,s7,1150 # 80007a78 <digits>
    80005602:	03c9d793          	srli	a5,s3,0x3c
    80005606:	97de                	add	a5,a5,s7
    80005608:	0007c503          	lbu	a0,0(a5)
    8000560c:	b43ff0ef          	jal	8000514e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005610:	0992                	slli	s3,s3,0x4
    80005612:	397d                	addiw	s2,s2,-1
    80005614:	fe0917e3          	bnez	s2,80005602 <printf+0x232>
    80005618:	6ba6                	ld	s7,72(sp)
    8000561a:	b589                	j	8000545c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000561c:	f8843783          	ld	a5,-120(s0)
    80005620:	00878713          	addi	a4,a5,8
    80005624:	f8e43423          	sd	a4,-120(s0)
    80005628:	0007b903          	ld	s2,0(a5)
    8000562c:	00090d63          	beqz	s2,80005646 <printf+0x276>
      for(; *s; s++)
    80005630:	00094503          	lbu	a0,0(s2)
    80005634:	e20504e3          	beqz	a0,8000545c <printf+0x8c>
        consputc(*s);
    80005638:	b17ff0ef          	jal	8000514e <consputc>
      for(; *s; s++)
    8000563c:	0905                	addi	s2,s2,1
    8000563e:	00094503          	lbu	a0,0(s2)
    80005642:	f97d                	bnez	a0,80005638 <printf+0x268>
    80005644:	bd21                	j	8000545c <printf+0x8c>
        s = "(null)";
    80005646:	00002917          	auipc	s2,0x2
    8000564a:	1f290913          	addi	s2,s2,498 # 80007838 <etext+0x838>
      for(; *s; s++)
    8000564e:	02800513          	li	a0,40
    80005652:	b7dd                	j	80005638 <printf+0x268>
      consputc('%');
    80005654:	02500513          	li	a0,37
    80005658:	af7ff0ef          	jal	8000514e <consputc>
    8000565c:	b501                	j	8000545c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000565e:	f7843783          	ld	a5,-136(s0)
    80005662:	e385                	bnez	a5,80005682 <printf+0x2b2>
    80005664:	74e6                	ld	s1,120(sp)
    80005666:	7946                	ld	s2,112(sp)
    80005668:	79a6                	ld	s3,104(sp)
    8000566a:	6ae6                	ld	s5,88(sp)
    8000566c:	6b46                	ld	s6,80(sp)
    8000566e:	6c06                	ld	s8,64(sp)
    80005670:	7ce2                	ld	s9,56(sp)
    80005672:	7d42                	ld	s10,48(sp)
    80005674:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80005676:	4501                	li	a0,0
    80005678:	60aa                	ld	ra,136(sp)
    8000567a:	640a                	ld	s0,128(sp)
    8000567c:	7a06                	ld	s4,96(sp)
    8000567e:	6169                	addi	sp,sp,208
    80005680:	8082                	ret
    80005682:	74e6                	ld	s1,120(sp)
    80005684:	7946                	ld	s2,112(sp)
    80005686:	79a6                	ld	s3,104(sp)
    80005688:	6ae6                	ld	s5,88(sp)
    8000568a:	6b46                	ld	s6,80(sp)
    8000568c:	6c06                	ld	s8,64(sp)
    8000568e:	7ce2                	ld	s9,56(sp)
    80005690:	7d42                	ld	s10,48(sp)
    80005692:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80005694:	0001e517          	auipc	a0,0x1e
    80005698:	41450513          	addi	a0,a0,1044 # 80023aa8 <pr>
    8000569c:	3cc000ef          	jal	80005a68 <release>
    800056a0:	bfd9                	j	80005676 <printf+0x2a6>

00000000800056a2 <panic>:

void
panic(char *s)
{
    800056a2:	1101                	addi	sp,sp,-32
    800056a4:	ec06                	sd	ra,24(sp)
    800056a6:	e822                	sd	s0,16(sp)
    800056a8:	e426                	sd	s1,8(sp)
    800056aa:	1000                	addi	s0,sp,32
    800056ac:	84aa                	mv	s1,a0
  pr.locking = 0;
    800056ae:	0001e797          	auipc	a5,0x1e
    800056b2:	4007a923          	sw	zero,1042(a5) # 80023ac0 <pr+0x18>
  printf("panic: ");
    800056b6:	00002517          	auipc	a0,0x2
    800056ba:	18a50513          	addi	a0,a0,394 # 80007840 <etext+0x840>
    800056be:	d13ff0ef          	jal	800053d0 <printf>
  printf("%s\n", s);
    800056c2:	85a6                	mv	a1,s1
    800056c4:	00002517          	auipc	a0,0x2
    800056c8:	18450513          	addi	a0,a0,388 # 80007848 <etext+0x848>
    800056cc:	d05ff0ef          	jal	800053d0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800056d0:	4785                	li	a5,1
    800056d2:	00005717          	auipc	a4,0x5
    800056d6:	eef72523          	sw	a5,-278(a4) # 8000a5bc <panicked>
  for(;;)
    800056da:	a001                	j	800056da <panic+0x38>

00000000800056dc <printfinit>:
    ;
}

void
printfinit(void)
{
    800056dc:	1101                	addi	sp,sp,-32
    800056de:	ec06                	sd	ra,24(sp)
    800056e0:	e822                	sd	s0,16(sp)
    800056e2:	e426                	sd	s1,8(sp)
    800056e4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800056e6:	0001e497          	auipc	s1,0x1e
    800056ea:	3c248493          	addi	s1,s1,962 # 80023aa8 <pr>
    800056ee:	00002597          	auipc	a1,0x2
    800056f2:	16258593          	addi	a1,a1,354 # 80007850 <etext+0x850>
    800056f6:	8526                	mv	a0,s1
    800056f8:	258000ef          	jal	80005950 <initlock>
  pr.locking = 1;
    800056fc:	4785                	li	a5,1
    800056fe:	cc9c                	sw	a5,24(s1)
}
    80005700:	60e2                	ld	ra,24(sp)
    80005702:	6442                	ld	s0,16(sp)
    80005704:	64a2                	ld	s1,8(sp)
    80005706:	6105                	addi	sp,sp,32
    80005708:	8082                	ret

000000008000570a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000570a:	1141                	addi	sp,sp,-16
    8000570c:	e406                	sd	ra,8(sp)
    8000570e:	e022                	sd	s0,0(sp)
    80005710:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005712:	100007b7          	lui	a5,0x10000
    80005716:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000571a:	10000737          	lui	a4,0x10000
    8000571e:	f8000693          	li	a3,-128
    80005722:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005726:	468d                	li	a3,3
    80005728:	10000637          	lui	a2,0x10000
    8000572c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005730:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005734:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005738:	10000737          	lui	a4,0x10000
    8000573c:	461d                	li	a2,7
    8000573e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005742:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005746:	00002597          	auipc	a1,0x2
    8000574a:	11258593          	addi	a1,a1,274 # 80007858 <etext+0x858>
    8000574e:	0001e517          	auipc	a0,0x1e
    80005752:	37a50513          	addi	a0,a0,890 # 80023ac8 <uart_tx_lock>
    80005756:	1fa000ef          	jal	80005950 <initlock>
}
    8000575a:	60a2                	ld	ra,8(sp)
    8000575c:	6402                	ld	s0,0(sp)
    8000575e:	0141                	addi	sp,sp,16
    80005760:	8082                	ret

0000000080005762 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005762:	1101                	addi	sp,sp,-32
    80005764:	ec06                	sd	ra,24(sp)
    80005766:	e822                	sd	s0,16(sp)
    80005768:	e426                	sd	s1,8(sp)
    8000576a:	1000                	addi	s0,sp,32
    8000576c:	84aa                	mv	s1,a0
  push_off();
    8000576e:	222000ef          	jal	80005990 <push_off>

  if(panicked){
    80005772:	00005797          	auipc	a5,0x5
    80005776:	e4a7a783          	lw	a5,-438(a5) # 8000a5bc <panicked>
    8000577a:	e795                	bnez	a5,800057a6 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000577c:	10000737          	lui	a4,0x10000
    80005780:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005782:	00074783          	lbu	a5,0(a4)
    80005786:	0207f793          	andi	a5,a5,32
    8000578a:	dfe5                	beqz	a5,80005782 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000578c:	0ff4f513          	zext.b	a0,s1
    80005790:	100007b7          	lui	a5,0x10000
    80005794:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005798:	27c000ef          	jal	80005a14 <pop_off>
}
    8000579c:	60e2                	ld	ra,24(sp)
    8000579e:	6442                	ld	s0,16(sp)
    800057a0:	64a2                	ld	s1,8(sp)
    800057a2:	6105                	addi	sp,sp,32
    800057a4:	8082                	ret
    for(;;)
    800057a6:	a001                	j	800057a6 <uartputc_sync+0x44>

00000000800057a8 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800057a8:	00005797          	auipc	a5,0x5
    800057ac:	e187b783          	ld	a5,-488(a5) # 8000a5c0 <uart_tx_r>
    800057b0:	00005717          	auipc	a4,0x5
    800057b4:	e1873703          	ld	a4,-488(a4) # 8000a5c8 <uart_tx_w>
    800057b8:	08f70263          	beq	a4,a5,8000583c <uartstart+0x94>
{
    800057bc:	7139                	addi	sp,sp,-64
    800057be:	fc06                	sd	ra,56(sp)
    800057c0:	f822                	sd	s0,48(sp)
    800057c2:	f426                	sd	s1,40(sp)
    800057c4:	f04a                	sd	s2,32(sp)
    800057c6:	ec4e                	sd	s3,24(sp)
    800057c8:	e852                	sd	s4,16(sp)
    800057ca:	e456                	sd	s5,8(sp)
    800057cc:	e05a                	sd	s6,0(sp)
    800057ce:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800057d0:	10000937          	lui	s2,0x10000
    800057d4:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800057d6:	0001ea97          	auipc	s5,0x1e
    800057da:	2f2a8a93          	addi	s5,s5,754 # 80023ac8 <uart_tx_lock>
    uart_tx_r += 1;
    800057de:	00005497          	auipc	s1,0x5
    800057e2:	de248493          	addi	s1,s1,-542 # 8000a5c0 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800057e6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800057ea:	00005997          	auipc	s3,0x5
    800057ee:	dde98993          	addi	s3,s3,-546 # 8000a5c8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800057f2:	00094703          	lbu	a4,0(s2)
    800057f6:	02077713          	andi	a4,a4,32
    800057fa:	c71d                	beqz	a4,80005828 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800057fc:	01f7f713          	andi	a4,a5,31
    80005800:	9756                	add	a4,a4,s5
    80005802:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80005806:	0785                	addi	a5,a5,1
    80005808:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    8000580a:	8526                	mv	a0,s1
    8000580c:	c97fb0ef          	jal	800014a2 <wakeup>
    WriteReg(THR, c);
    80005810:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80005814:	609c                	ld	a5,0(s1)
    80005816:	0009b703          	ld	a4,0(s3)
    8000581a:	fcf71ce3          	bne	a4,a5,800057f2 <uartstart+0x4a>
      ReadReg(ISR);
    8000581e:	100007b7          	lui	a5,0x10000
    80005822:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005824:	0007c783          	lbu	a5,0(a5)
  }
}
    80005828:	70e2                	ld	ra,56(sp)
    8000582a:	7442                	ld	s0,48(sp)
    8000582c:	74a2                	ld	s1,40(sp)
    8000582e:	7902                	ld	s2,32(sp)
    80005830:	69e2                	ld	s3,24(sp)
    80005832:	6a42                	ld	s4,16(sp)
    80005834:	6aa2                	ld	s5,8(sp)
    80005836:	6b02                	ld	s6,0(sp)
    80005838:	6121                	addi	sp,sp,64
    8000583a:	8082                	ret
      ReadReg(ISR);
    8000583c:	100007b7          	lui	a5,0x10000
    80005840:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005842:	0007c783          	lbu	a5,0(a5)
      return;
    80005846:	8082                	ret

0000000080005848 <uartputc>:
{
    80005848:	7179                	addi	sp,sp,-48
    8000584a:	f406                	sd	ra,40(sp)
    8000584c:	f022                	sd	s0,32(sp)
    8000584e:	ec26                	sd	s1,24(sp)
    80005850:	e84a                	sd	s2,16(sp)
    80005852:	e44e                	sd	s3,8(sp)
    80005854:	e052                	sd	s4,0(sp)
    80005856:	1800                	addi	s0,sp,48
    80005858:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000585a:	0001e517          	auipc	a0,0x1e
    8000585e:	26e50513          	addi	a0,a0,622 # 80023ac8 <uart_tx_lock>
    80005862:	16e000ef          	jal	800059d0 <acquire>
  if(panicked){
    80005866:	00005797          	auipc	a5,0x5
    8000586a:	d567a783          	lw	a5,-682(a5) # 8000a5bc <panicked>
    8000586e:	efbd                	bnez	a5,800058ec <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005870:	00005717          	auipc	a4,0x5
    80005874:	d5873703          	ld	a4,-680(a4) # 8000a5c8 <uart_tx_w>
    80005878:	00005797          	auipc	a5,0x5
    8000587c:	d487b783          	ld	a5,-696(a5) # 8000a5c0 <uart_tx_r>
    80005880:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005884:	0001e997          	auipc	s3,0x1e
    80005888:	24498993          	addi	s3,s3,580 # 80023ac8 <uart_tx_lock>
    8000588c:	00005497          	auipc	s1,0x5
    80005890:	d3448493          	addi	s1,s1,-716 # 8000a5c0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005894:	00005917          	auipc	s2,0x5
    80005898:	d3490913          	addi	s2,s2,-716 # 8000a5c8 <uart_tx_w>
    8000589c:	00e79d63          	bne	a5,a4,800058b6 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800058a0:	85ce                	mv	a1,s3
    800058a2:	8526                	mv	a0,s1
    800058a4:	bb3fb0ef          	jal	80001456 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800058a8:	00093703          	ld	a4,0(s2)
    800058ac:	609c                	ld	a5,0(s1)
    800058ae:	02078793          	addi	a5,a5,32
    800058b2:	fee787e3          	beq	a5,a4,800058a0 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800058b6:	0001e497          	auipc	s1,0x1e
    800058ba:	21248493          	addi	s1,s1,530 # 80023ac8 <uart_tx_lock>
    800058be:	01f77793          	andi	a5,a4,31
    800058c2:	97a6                	add	a5,a5,s1
    800058c4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800058c8:	0705                	addi	a4,a4,1
    800058ca:	00005797          	auipc	a5,0x5
    800058ce:	cee7bf23          	sd	a4,-770(a5) # 8000a5c8 <uart_tx_w>
  uartstart();
    800058d2:	ed7ff0ef          	jal	800057a8 <uartstart>
  release(&uart_tx_lock);
    800058d6:	8526                	mv	a0,s1
    800058d8:	190000ef          	jal	80005a68 <release>
}
    800058dc:	70a2                	ld	ra,40(sp)
    800058de:	7402                	ld	s0,32(sp)
    800058e0:	64e2                	ld	s1,24(sp)
    800058e2:	6942                	ld	s2,16(sp)
    800058e4:	69a2                	ld	s3,8(sp)
    800058e6:	6a02                	ld	s4,0(sp)
    800058e8:	6145                	addi	sp,sp,48
    800058ea:	8082                	ret
    for(;;)
    800058ec:	a001                	j	800058ec <uartputc+0xa4>

00000000800058ee <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800058ee:	1141                	addi	sp,sp,-16
    800058f0:	e422                	sd	s0,8(sp)
    800058f2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800058f4:	100007b7          	lui	a5,0x10000
    800058f8:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800058fa:	0007c783          	lbu	a5,0(a5)
    800058fe:	8b85                	andi	a5,a5,1
    80005900:	cb81                	beqz	a5,80005910 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005902:	100007b7          	lui	a5,0x10000
    80005906:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000590a:	6422                	ld	s0,8(sp)
    8000590c:	0141                	addi	sp,sp,16
    8000590e:	8082                	ret
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	bfe5                	j	8000590a <uartgetc+0x1c>

0000000080005914 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005914:	1101                	addi	sp,sp,-32
    80005916:	ec06                	sd	ra,24(sp)
    80005918:	e822                	sd	s0,16(sp)
    8000591a:	e426                	sd	s1,8(sp)
    8000591c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000591e:	54fd                	li	s1,-1
    80005920:	a019                	j	80005926 <uartintr+0x12>
      break;
    consoleintr(c);
    80005922:	85fff0ef          	jal	80005180 <consoleintr>
    int c = uartgetc();
    80005926:	fc9ff0ef          	jal	800058ee <uartgetc>
    if(c == -1)
    8000592a:	fe951ce3          	bne	a0,s1,80005922 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000592e:	0001e497          	auipc	s1,0x1e
    80005932:	19a48493          	addi	s1,s1,410 # 80023ac8 <uart_tx_lock>
    80005936:	8526                	mv	a0,s1
    80005938:	098000ef          	jal	800059d0 <acquire>
  uartstart();
    8000593c:	e6dff0ef          	jal	800057a8 <uartstart>
  release(&uart_tx_lock);
    80005940:	8526                	mv	a0,s1
    80005942:	126000ef          	jal	80005a68 <release>
}
    80005946:	60e2                	ld	ra,24(sp)
    80005948:	6442                	ld	s0,16(sp)
    8000594a:	64a2                	ld	s1,8(sp)
    8000594c:	6105                	addi	sp,sp,32
    8000594e:	8082                	ret

0000000080005950 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005950:	1141                	addi	sp,sp,-16
    80005952:	e422                	sd	s0,8(sp)
    80005954:	0800                	addi	s0,sp,16
  lk->name = name;
    80005956:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005958:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000595c:	00053823          	sd	zero,16(a0)
}
    80005960:	6422                	ld	s0,8(sp)
    80005962:	0141                	addi	sp,sp,16
    80005964:	8082                	ret

0000000080005966 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005966:	411c                	lw	a5,0(a0)
    80005968:	e399                	bnez	a5,8000596e <holding+0x8>
    8000596a:	4501                	li	a0,0
  return r;
}
    8000596c:	8082                	ret
{
    8000596e:	1101                	addi	sp,sp,-32
    80005970:	ec06                	sd	ra,24(sp)
    80005972:	e822                	sd	s0,16(sp)
    80005974:	e426                	sd	s1,8(sp)
    80005976:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005978:	6904                	ld	s1,16(a0)
    8000597a:	ceafb0ef          	jal	80000e64 <mycpu>
    8000597e:	40a48533          	sub	a0,s1,a0
    80005982:	00153513          	seqz	a0,a0
}
    80005986:	60e2                	ld	ra,24(sp)
    80005988:	6442                	ld	s0,16(sp)
    8000598a:	64a2                	ld	s1,8(sp)
    8000598c:	6105                	addi	sp,sp,32
    8000598e:	8082                	ret

0000000080005990 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005990:	1101                	addi	sp,sp,-32
    80005992:	ec06                	sd	ra,24(sp)
    80005994:	e822                	sd	s0,16(sp)
    80005996:	e426                	sd	s1,8(sp)
    80005998:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000599a:	100024f3          	csrr	s1,sstatus
    8000599e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800059a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800059a4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800059a8:	cbcfb0ef          	jal	80000e64 <mycpu>
    800059ac:	5d3c                	lw	a5,120(a0)
    800059ae:	cb99                	beqz	a5,800059c4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800059b0:	cb4fb0ef          	jal	80000e64 <mycpu>
    800059b4:	5d3c                	lw	a5,120(a0)
    800059b6:	2785                	addiw	a5,a5,1
    800059b8:	dd3c                	sw	a5,120(a0)
}
    800059ba:	60e2                	ld	ra,24(sp)
    800059bc:	6442                	ld	s0,16(sp)
    800059be:	64a2                	ld	s1,8(sp)
    800059c0:	6105                	addi	sp,sp,32
    800059c2:	8082                	ret
    mycpu()->intena = old;
    800059c4:	ca0fb0ef          	jal	80000e64 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800059c8:	8085                	srli	s1,s1,0x1
    800059ca:	8885                	andi	s1,s1,1
    800059cc:	dd64                	sw	s1,124(a0)
    800059ce:	b7cd                	j	800059b0 <push_off+0x20>

00000000800059d0 <acquire>:
{
    800059d0:	1101                	addi	sp,sp,-32
    800059d2:	ec06                	sd	ra,24(sp)
    800059d4:	e822                	sd	s0,16(sp)
    800059d6:	e426                	sd	s1,8(sp)
    800059d8:	1000                	addi	s0,sp,32
    800059da:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800059dc:	fb5ff0ef          	jal	80005990 <push_off>
  if(holding(lk))
    800059e0:	8526                	mv	a0,s1
    800059e2:	f85ff0ef          	jal	80005966 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059e6:	4705                	li	a4,1
  if(holding(lk))
    800059e8:	e105                	bnez	a0,80005a08 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800059ea:	87ba                	mv	a5,a4
    800059ec:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800059f0:	2781                	sext.w	a5,a5
    800059f2:	ffe5                	bnez	a5,800059ea <acquire+0x1a>
  __sync_synchronize();
    800059f4:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    800059f8:	c6cfb0ef          	jal	80000e64 <mycpu>
    800059fc:	e888                	sd	a0,16(s1)
}
    800059fe:	60e2                	ld	ra,24(sp)
    80005a00:	6442                	ld	s0,16(sp)
    80005a02:	64a2                	ld	s1,8(sp)
    80005a04:	6105                	addi	sp,sp,32
    80005a06:	8082                	ret
    panic("acquire");
    80005a08:	00002517          	auipc	a0,0x2
    80005a0c:	e5850513          	addi	a0,a0,-424 # 80007860 <etext+0x860>
    80005a10:	c93ff0ef          	jal	800056a2 <panic>

0000000080005a14 <pop_off>:

void
pop_off(void)
{
    80005a14:	1141                	addi	sp,sp,-16
    80005a16:	e406                	sd	ra,8(sp)
    80005a18:	e022                	sd	s0,0(sp)
    80005a1a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005a1c:	c48fb0ef          	jal	80000e64 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a20:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005a24:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005a26:	e78d                	bnez	a5,80005a50 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005a28:	5d3c                	lw	a5,120(a0)
    80005a2a:	02f05963          	blez	a5,80005a5c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005a2e:	37fd                	addiw	a5,a5,-1
    80005a30:	0007871b          	sext.w	a4,a5
    80005a34:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005a36:	eb09                	bnez	a4,80005a48 <pop_off+0x34>
    80005a38:	5d7c                	lw	a5,124(a0)
    80005a3a:	c799                	beqz	a5,80005a48 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005a3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005a40:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005a44:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005a48:	60a2                	ld	ra,8(sp)
    80005a4a:	6402                	ld	s0,0(sp)
    80005a4c:	0141                	addi	sp,sp,16
    80005a4e:	8082                	ret
    panic("pop_off - interruptible");
    80005a50:	00002517          	auipc	a0,0x2
    80005a54:	e1850513          	addi	a0,a0,-488 # 80007868 <etext+0x868>
    80005a58:	c4bff0ef          	jal	800056a2 <panic>
    panic("pop_off");
    80005a5c:	00002517          	auipc	a0,0x2
    80005a60:	e2450513          	addi	a0,a0,-476 # 80007880 <etext+0x880>
    80005a64:	c3fff0ef          	jal	800056a2 <panic>

0000000080005a68 <release>:
{
    80005a68:	1101                	addi	sp,sp,-32
    80005a6a:	ec06                	sd	ra,24(sp)
    80005a6c:	e822                	sd	s0,16(sp)
    80005a6e:	e426                	sd	s1,8(sp)
    80005a70:	1000                	addi	s0,sp,32
    80005a72:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005a74:	ef3ff0ef          	jal	80005966 <holding>
    80005a78:	c105                	beqz	a0,80005a98 <release+0x30>
  lk->cpu = 0;
    80005a7a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005a7e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005a82:	0310000f          	fence	rw,w
    80005a86:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005a8a:	f8bff0ef          	jal	80005a14 <pop_off>
}
    80005a8e:	60e2                	ld	ra,24(sp)
    80005a90:	6442                	ld	s0,16(sp)
    80005a92:	64a2                	ld	s1,8(sp)
    80005a94:	6105                	addi	sp,sp,32
    80005a96:	8082                	ret
    panic("release");
    80005a98:	00002517          	auipc	a0,0x2
    80005a9c:	df050513          	addi	a0,a0,-528 # 80007888 <etext+0x888>
    80005aa0:	c03ff0ef          	jal	800056a2 <panic>
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
