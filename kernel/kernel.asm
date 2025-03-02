
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	4d013103          	ld	sp,1232(sp) # 8000a4d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	689040ef          	jal	80004e9e <start>

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
    80000034:	a2078793          	addi	a5,a5,-1504 # 80023a50 <end>
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
    80000050:	4d490913          	addi	s2,s2,1236 # 8000a520 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	0ab050ef          	jal	80005900 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	133050ef          	jal	80005998 <release>
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
    8000007e:	554050ef          	jal	800055d2 <panic>

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
    800000de:	44650513          	addi	a0,a0,1094 # 8000a520 <kmem>
    800000e2:	79e050ef          	jal	80005880 <initlock>
  freerange(end, (void*)PHYSTOP); //release a range of page from "end" to phystop = put a range to free list pf page
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00024517          	auipc	a0,0x24
    800000ee:	96650513          	addi	a0,a0,-1690 # 80023a50 <end>
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
    8000010c:	41848493          	addi	s1,s1,1048 # 8000a520 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	7ee050ef          	jal	80005900 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	40450513          	addi	a0,a0,1028 # 8000a520 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	073050ef          	jal	80005998 <release>

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
    80000144:	3e050513          	addi	a0,a0,992 # 8000a520 <kmem>
    80000148:	051050ef          	jal	80005998 <release>
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
    8000015c:	3c848493          	addi	s1,s1,968 # 8000a520 <kmem>
    80000160:	8526                	mv	a0,s1
    80000162:	79e050ef          	jal	80005900 <acquire>

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
    80000178:	3ac50513          	addi	a0,a0,940 # 8000a520 <kmem>
    8000017c:	01d050ef          	jal	80005998 <release>
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
    80000332:	24b000ef          	jal	80000d7c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000336:	0000a717          	auipc	a4,0xa
    8000033a:	1ba70713          	addi	a4,a4,442 # 8000a4f0 <started>
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
    8000034a:	233000ef          	jal	80000d7c <cpuid>
    8000034e:	85aa                	mv	a1,a0
    80000350:	00007517          	auipc	a0,0x7
    80000354:	ce850513          	addi	a0,a0,-792 # 80007038 <etext+0x38>
    80000358:	7a9040ef          	jal	80005300 <printf>
    kvminithart();    // turn on paging
    8000035c:	080000ef          	jal	800003dc <kvminithart>
    trapinithart();   // install kernel trap vector
    80000360:	56e010ef          	jal	800018ce <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000364:	554040ef          	jal	800048b8 <plicinithart>
  }

  scheduler();        
    80000368:	67d000ef          	jal	800011e4 <scheduler>
    consoleinit();
    8000036c:	6bf040ef          	jal	8000522a <consoleinit>
    printfinit();
    80000370:	29c050ef          	jal	8000560c <printfinit>
    printf("\n");
    80000374:	00007517          	auipc	a0,0x7
    80000378:	ca450513          	addi	a0,a0,-860 # 80007018 <etext+0x18>
    8000037c:	785040ef          	jal	80005300 <printf>
    printf("xv6 kernel is booting\n");
    80000380:	00007517          	auipc	a0,0x7
    80000384:	ca050513          	addi	a0,a0,-864 # 80007020 <etext+0x20>
    80000388:	779040ef          	jal	80005300 <printf>
    printf("\n");
    8000038c:	00007517          	auipc	a0,0x7
    80000390:	c8c50513          	addi	a0,a0,-884 # 80007018 <etext+0x18>
    80000394:	76d040ef          	jal	80005300 <printf>
    kinit();         // physical page allocator
    80000398:	d33ff0ef          	jal	800000ca <kinit>
    kvminit();       // create kernel page table
    8000039c:	2ca000ef          	jal	80000666 <kvminit>
    kvminithart();   // turn on paging
    800003a0:	03c000ef          	jal	800003dc <kvminithart>
    procinit();      // process table
    800003a4:	123000ef          	jal	80000cc6 <procinit>
    trapinit();      // trap vectors
    800003a8:	502010ef          	jal	800018aa <trapinit>
    trapinithart();  // install kernel trap vector
    800003ac:	522010ef          	jal	800018ce <trapinithart>
    plicinit();      // set up interrupt controller
    800003b0:	4ee040ef          	jal	8000489e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003b4:	504040ef          	jal	800048b8 <plicinithart>
    binit();         // buffer cache
    800003b8:	455010ef          	jal	8000200c <binit>
    iinit();         // inode table
    800003bc:	246020ef          	jal	80002602 <iinit>
    fileinit();      // file table
    800003c0:	7f3020ef          	jal	800033b2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800003c4:	5e4040ef          	jal	800049a8 <virtio_disk_init>
    userinit();      // first user process
    800003c8:	449000ef          	jal	80001010 <userinit>
    __sync_synchronize();
    800003cc:	0330000f          	fence	rw,rw
    started = 1;
    800003d0:	4785                	li	a5,1
    800003d2:	0000a717          	auipc	a4,0xa
    800003d6:	10f72f23          	sw	a5,286(a4) # 8000a4f0 <started>
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
    800003ea:	1127b783          	ld	a5,274(a5) # 8000a4f8 <kernel_pagetable>
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
    80000432:	1a0050ef          	jal	800055d2 <panic>
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
    80000458:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb5a7>
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
    80000548:	08a050ef          	jal	800055d2 <panic>
    panic("mappages: size not aligned");
    8000054c:	00007517          	auipc	a0,0x7
    80000550:	b2c50513          	addi	a0,a0,-1236 # 80007078 <etext+0x78>
    80000554:	07e050ef          	jal	800055d2 <panic>
    panic("mappages: size");
    80000558:	00007517          	auipc	a0,0x7
    8000055c:	b4050513          	addi	a0,a0,-1216 # 80007098 <etext+0x98>
    80000560:	072050ef          	jal	800055d2 <panic>
      panic("mappages: remap");
    80000564:	00007517          	auipc	a0,0x7
    80000568:	b4450513          	addi	a0,a0,-1212 # 800070a8 <etext+0xa8>
    8000056c:	066050ef          	jal	800055d2 <panic>
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
    800005b0:	022050ef          	jal	800055d2 <panic>

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
    80000654:	5da000ef          	jal	80000c2e <proc_mapstacks>
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
    80000676:	e8a7b323          	sd	a0,-378(a5) # 8000a4f8 <kernel_pagetable>
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
    800006ca:	709040ef          	jal	800055d2 <panic>
      panic("uvmunmap: walk");
    800006ce:	00007517          	auipc	a0,0x7
    800006d2:	a0a50513          	addi	a0,a0,-1526 # 800070d8 <etext+0xd8>
    800006d6:	6fd040ef          	jal	800055d2 <panic>
      panic("uvmunmap: not mapped");
    800006da:	00007517          	auipc	a0,0x7
    800006de:	a0e50513          	addi	a0,a0,-1522 # 800070e8 <etext+0xe8>
    800006e2:	6f1040ef          	jal	800055d2 <panic>
      panic("uvmunmap: not a leaf");
    800006e6:	00007517          	auipc	a0,0x7
    800006ea:	a1a50513          	addi	a0,a0,-1510 # 80007100 <etext+0x100>
    800006ee:	6e5040ef          	jal	800055d2 <panic>
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
    800007be:	615040ef          	jal	800055d2 <panic>

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
    800008f2:	4e1040ef          	jal	800055d2 <panic>
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
    800009b0:	423040ef          	jal	800055d2 <panic>
      panic("uvmcopy: page not present");
    800009b4:	00006517          	auipc	a0,0x6
    800009b8:	7b450513          	addi	a0,a0,1972 # 80007168 <etext+0x168>
    800009bc:	417040ef          	jal	800055d2 <panic>
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
    80000a16:	3bd040ef          	jal	800055d2 <panic>

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

0000000080000c2e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000c2e:	7139                	addi	sp,sp,-64
    80000c30:	fc06                	sd	ra,56(sp)
    80000c32:	f822                	sd	s0,48(sp)
    80000c34:	f426                	sd	s1,40(sp)
    80000c36:	f04a                	sd	s2,32(sp)
    80000c38:	ec4e                	sd	s3,24(sp)
    80000c3a:	e852                	sd	s4,16(sp)
    80000c3c:	e456                	sd	s5,8(sp)
    80000c3e:	e05a                	sd	s6,0(sp)
    80000c40:	0080                	addi	s0,sp,64
    80000c42:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c44:	0000a497          	auipc	s1,0xa
    80000c48:	d2c48493          	addi	s1,s1,-724 # 8000a970 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c4c:	8b26                	mv	s6,s1
    80000c4e:	ff4df937          	lui	s2,0xff4df
    80000c52:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baf6d>
    80000c56:	0936                	slli	s2,s2,0xd
    80000c58:	6f590913          	addi	s2,s2,1781
    80000c5c:	0936                	slli	s2,s2,0xd
    80000c5e:	bd390913          	addi	s2,s2,-1069
    80000c62:	0932                	slli	s2,s2,0xc
    80000c64:	7a790913          	addi	s2,s2,1959
    80000c68:	040009b7          	lui	s3,0x4000
    80000c6c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c6e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c70:	00010a97          	auipc	s5,0x10
    80000c74:	900a8a93          	addi	s5,s5,-1792 # 80010570 <tickslock>
    char *pa = kalloc();
    80000c78:	c86ff0ef          	jal	800000fe <kalloc>
    80000c7c:	862a                	mv	a2,a0
    if(pa == 0)
    80000c7e:	cd15                	beqz	a0,80000cba <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c80:	416485b3          	sub	a1,s1,s6
    80000c84:	8591                	srai	a1,a1,0x4
    80000c86:	032585b3          	mul	a1,a1,s2
    80000c8a:	2585                	addiw	a1,a1,1
    80000c8c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c90:	4719                	li	a4,6
    80000c92:	6685                	lui	a3,0x1
    80000c94:	40b985b3          	sub	a1,s3,a1
    80000c98:	8552                	mv	a0,s4
    80000c9a:	8f3ff0ef          	jal	8000058c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c9e:	17048493          	addi	s1,s1,368
    80000ca2:	fd549be3          	bne	s1,s5,80000c78 <proc_mapstacks+0x4a>
  }
}
    80000ca6:	70e2                	ld	ra,56(sp)
    80000ca8:	7442                	ld	s0,48(sp)
    80000caa:	74a2                	ld	s1,40(sp)
    80000cac:	7902                	ld	s2,32(sp)
    80000cae:	69e2                	ld	s3,24(sp)
    80000cb0:	6a42                	ld	s4,16(sp)
    80000cb2:	6aa2                	ld	s5,8(sp)
    80000cb4:	6b02                	ld	s6,0(sp)
    80000cb6:	6121                	addi	sp,sp,64
    80000cb8:	8082                	ret
      panic("kalloc");
    80000cba:	00006517          	auipc	a0,0x6
    80000cbe:	4de50513          	addi	a0,a0,1246 # 80007198 <etext+0x198>
    80000cc2:	111040ef          	jal	800055d2 <panic>

0000000080000cc6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000cc6:	7139                	addi	sp,sp,-64
    80000cc8:	fc06                	sd	ra,56(sp)
    80000cca:	f822                	sd	s0,48(sp)
    80000ccc:	f426                	sd	s1,40(sp)
    80000cce:	f04a                	sd	s2,32(sp)
    80000cd0:	ec4e                	sd	s3,24(sp)
    80000cd2:	e852                	sd	s4,16(sp)
    80000cd4:	e456                	sd	s5,8(sp)
    80000cd6:	e05a                	sd	s6,0(sp)
    80000cd8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000cda:	00006597          	auipc	a1,0x6
    80000cde:	4c658593          	addi	a1,a1,1222 # 800071a0 <etext+0x1a0>
    80000ce2:	0000a517          	auipc	a0,0xa
    80000ce6:	85e50513          	addi	a0,a0,-1954 # 8000a540 <pid_lock>
    80000cea:	397040ef          	jal	80005880 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cee:	00006597          	auipc	a1,0x6
    80000cf2:	4ba58593          	addi	a1,a1,1210 # 800071a8 <etext+0x1a8>
    80000cf6:	0000a517          	auipc	a0,0xa
    80000cfa:	86250513          	addi	a0,a0,-1950 # 8000a558 <wait_lock>
    80000cfe:	383040ef          	jal	80005880 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d02:	0000a497          	auipc	s1,0xa
    80000d06:	c6e48493          	addi	s1,s1,-914 # 8000a970 <proc>
      initlock(&p->lock, "proc");
    80000d0a:	00006b17          	auipc	s6,0x6
    80000d0e:	4aeb0b13          	addi	s6,s6,1198 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000d12:	8aa6                	mv	s5,s1
    80000d14:	ff4df937          	lui	s2,0xff4df
    80000d18:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4baf6d>
    80000d1c:	0936                	slli	s2,s2,0xd
    80000d1e:	6f590913          	addi	s2,s2,1781
    80000d22:	0936                	slli	s2,s2,0xd
    80000d24:	bd390913          	addi	s2,s2,-1069
    80000d28:	0932                	slli	s2,s2,0xc
    80000d2a:	7a790913          	addi	s2,s2,1959
    80000d2e:	040009b7          	lui	s3,0x4000
    80000d32:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d34:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d36:	00010a17          	auipc	s4,0x10
    80000d3a:	83aa0a13          	addi	s4,s4,-1990 # 80010570 <tickslock>
      initlock(&p->lock, "proc");
    80000d3e:	85da                	mv	a1,s6
    80000d40:	8526                	mv	a0,s1
    80000d42:	33f040ef          	jal	80005880 <initlock>
      p->state = UNUSED;
    80000d46:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d4a:	415487b3          	sub	a5,s1,s5
    80000d4e:	8791                	srai	a5,a5,0x4
    80000d50:	032787b3          	mul	a5,a5,s2
    80000d54:	2785                	addiw	a5,a5,1
    80000d56:	00d7979b          	slliw	a5,a5,0xd
    80000d5a:	40f987b3          	sub	a5,s3,a5
    80000d5e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d60:	17048493          	addi	s1,s1,368
    80000d64:	fd449de3          	bne	s1,s4,80000d3e <procinit+0x78>
  }
}
    80000d68:	70e2                	ld	ra,56(sp)
    80000d6a:	7442                	ld	s0,48(sp)
    80000d6c:	74a2                	ld	s1,40(sp)
    80000d6e:	7902                	ld	s2,32(sp)
    80000d70:	69e2                	ld	s3,24(sp)
    80000d72:	6a42                	ld	s4,16(sp)
    80000d74:	6aa2                	ld	s5,8(sp)
    80000d76:	6b02                	ld	s6,0(sp)
    80000d78:	6121                	addi	sp,sp,64
    80000d7a:	8082                	ret

0000000080000d7c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e422                	sd	s0,8(sp)
    80000d80:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d82:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d84:	2501                	sext.w	a0,a0
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret

0000000080000d8c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e422                	sd	s0,8(sp)
    80000d90:	0800                	addi	s0,sp,16
    80000d92:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d94:	2781                	sext.w	a5,a5
    80000d96:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d98:	00009517          	auipc	a0,0x9
    80000d9c:	7d850513          	addi	a0,a0,2008 # 8000a570 <cpus>
    80000da0:	953e                	add	a0,a0,a5
    80000da2:	6422                	ld	s0,8(sp)
    80000da4:	0141                	addi	sp,sp,16
    80000da6:	8082                	ret

0000000080000da8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000da8:	1101                	addi	sp,sp,-32
    80000daa:	ec06                	sd	ra,24(sp)
    80000dac:	e822                	sd	s0,16(sp)
    80000dae:	e426                	sd	s1,8(sp)
    80000db0:	1000                	addi	s0,sp,32
  push_off();
    80000db2:	30f040ef          	jal	800058c0 <push_off>
    80000db6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000db8:	2781                	sext.w	a5,a5
    80000dba:	079e                	slli	a5,a5,0x7
    80000dbc:	00009717          	auipc	a4,0x9
    80000dc0:	78470713          	addi	a4,a4,1924 # 8000a540 <pid_lock>
    80000dc4:	97ba                	add	a5,a5,a4
    80000dc6:	7b84                	ld	s1,48(a5)
  pop_off();
    80000dc8:	37d040ef          	jal	80005944 <pop_off>
  return p;
}
    80000dcc:	8526                	mv	a0,s1
    80000dce:	60e2                	ld	ra,24(sp)
    80000dd0:	6442                	ld	s0,16(sp)
    80000dd2:	64a2                	ld	s1,8(sp)
    80000dd4:	6105                	addi	sp,sp,32
    80000dd6:	8082                	ret

0000000080000dd8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e406                	sd	ra,8(sp)
    80000ddc:	e022                	sd	s0,0(sp)
    80000dde:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000de0:	fc9ff0ef          	jal	80000da8 <myproc>
    80000de4:	3b5040ef          	jal	80005998 <release>

  if (first) {
    80000de8:	00009797          	auipc	a5,0x9
    80000dec:	6987a783          	lw	a5,1688(a5) # 8000a480 <first.1>
    80000df0:	e799                	bnez	a5,80000dfe <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000df2:	2f5000ef          	jal	800018e6 <usertrapret>
}
    80000df6:	60a2                	ld	ra,8(sp)
    80000df8:	6402                	ld	s0,0(sp)
    80000dfa:	0141                	addi	sp,sp,16
    80000dfc:	8082                	ret
    fsinit(ROOTDEV);
    80000dfe:	4505                	li	a0,1
    80000e00:	796010ef          	jal	80002596 <fsinit>
    first = 0;
    80000e04:	00009797          	auipc	a5,0x9
    80000e08:	6607ae23          	sw	zero,1660(a5) # 8000a480 <first.1>
    __sync_synchronize();
    80000e0c:	0330000f          	fence	rw,rw
    80000e10:	b7cd                	j	80000df2 <forkret+0x1a>

0000000080000e12 <allocpid>:
{
    80000e12:	1101                	addi	sp,sp,-32
    80000e14:	ec06                	sd	ra,24(sp)
    80000e16:	e822                	sd	s0,16(sp)
    80000e18:	e426                	sd	s1,8(sp)
    80000e1a:	e04a                	sd	s2,0(sp)
    80000e1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000e1e:	00009917          	auipc	s2,0x9
    80000e22:	72290913          	addi	s2,s2,1826 # 8000a540 <pid_lock>
    80000e26:	854a                	mv	a0,s2
    80000e28:	2d9040ef          	jal	80005900 <acquire>
  pid = nextpid;
    80000e2c:	00009797          	auipc	a5,0x9
    80000e30:	65878793          	addi	a5,a5,1624 # 8000a484 <nextpid>
    80000e34:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e36:	0014871b          	addiw	a4,s1,1
    80000e3a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e3c:	854a                	mv	a0,s2
    80000e3e:	35b040ef          	jal	80005998 <release>
}
    80000e42:	8526                	mv	a0,s1
    80000e44:	60e2                	ld	ra,24(sp)
    80000e46:	6442                	ld	s0,16(sp)
    80000e48:	64a2                	ld	s1,8(sp)
    80000e4a:	6902                	ld	s2,0(sp)
    80000e4c:	6105                	addi	sp,sp,32
    80000e4e:	8082                	ret

0000000080000e50 <proc_pagetable>:
{
    80000e50:	1101                	addi	sp,sp,-32
    80000e52:	ec06                	sd	ra,24(sp)
    80000e54:	e822                	sd	s0,16(sp)
    80000e56:	e426                	sd	s1,8(sp)
    80000e58:	e04a                	sd	s2,0(sp)
    80000e5a:	1000                	addi	s0,sp,32
    80000e5c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000e5e:	8e1ff0ef          	jal	8000073e <uvmcreate>
    80000e62:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000e64:	cd05                	beqz	a0,80000e9c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000e66:	4729                	li	a4,10
    80000e68:	00005697          	auipc	a3,0x5
    80000e6c:	19868693          	addi	a3,a3,408 # 80006000 <_trampoline>
    80000e70:	6605                	lui	a2,0x1
    80000e72:	040005b7          	lui	a1,0x4000
    80000e76:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000e78:	05b2                	slli	a1,a1,0xc
    80000e7a:	e62ff0ef          	jal	800004dc <mappages>
    80000e7e:	02054663          	bltz	a0,80000eaa <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000e82:	4719                	li	a4,6
    80000e84:	05893683          	ld	a3,88(s2)
    80000e88:	6605                	lui	a2,0x1
    80000e8a:	020005b7          	lui	a1,0x2000
    80000e8e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000e90:	05b6                	slli	a1,a1,0xd
    80000e92:	8526                	mv	a0,s1
    80000e94:	e48ff0ef          	jal	800004dc <mappages>
    80000e98:	00054f63          	bltz	a0,80000eb6 <proc_pagetable+0x66>
}
    80000e9c:	8526                	mv	a0,s1
    80000e9e:	60e2                	ld	ra,24(sp)
    80000ea0:	6442                	ld	s0,16(sp)
    80000ea2:	64a2                	ld	s1,8(sp)
    80000ea4:	6902                	ld	s2,0(sp)
    80000ea6:	6105                	addi	sp,sp,32
    80000ea8:	8082                	ret
    uvmfree(pagetable, 0);
    80000eaa:	4581                	li	a1,0
    80000eac:	8526                	mv	a0,s1
    80000eae:	a5fff0ef          	jal	8000090c <uvmfree>
    return 0;
    80000eb2:	4481                	li	s1,0
    80000eb4:	b7e5                	j	80000e9c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000eb6:	4681                	li	a3,0
    80000eb8:	4605                	li	a2,1
    80000eba:	040005b7          	lui	a1,0x4000
    80000ebe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ec0:	05b2                	slli	a1,a1,0xc
    80000ec2:	8526                	mv	a0,s1
    80000ec4:	fbeff0ef          	jal	80000682 <uvmunmap>
    uvmfree(pagetable, 0);
    80000ec8:	4581                	li	a1,0
    80000eca:	8526                	mv	a0,s1
    80000ecc:	a41ff0ef          	jal	8000090c <uvmfree>
    return 0;
    80000ed0:	4481                	li	s1,0
    80000ed2:	b7e9                	j	80000e9c <proc_pagetable+0x4c>

0000000080000ed4 <proc_freepagetable>:
{
    80000ed4:	1101                	addi	sp,sp,-32
    80000ed6:	ec06                	sd	ra,24(sp)
    80000ed8:	e822                	sd	s0,16(sp)
    80000eda:	e426                	sd	s1,8(sp)
    80000edc:	e04a                	sd	s2,0(sp)
    80000ede:	1000                	addi	s0,sp,32
    80000ee0:	84aa                	mv	s1,a0
    80000ee2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ee4:	4681                	li	a3,0
    80000ee6:	4605                	li	a2,1
    80000ee8:	040005b7          	lui	a1,0x4000
    80000eec:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000eee:	05b2                	slli	a1,a1,0xc
    80000ef0:	f92ff0ef          	jal	80000682 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000ef4:	4681                	li	a3,0
    80000ef6:	4605                	li	a2,1
    80000ef8:	020005b7          	lui	a1,0x2000
    80000efc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000efe:	05b6                	slli	a1,a1,0xd
    80000f00:	8526                	mv	a0,s1
    80000f02:	f80ff0ef          	jal	80000682 <uvmunmap>
  uvmfree(pagetable, sz);
    80000f06:	85ca                	mv	a1,s2
    80000f08:	8526                	mv	a0,s1
    80000f0a:	a03ff0ef          	jal	8000090c <uvmfree>
}
    80000f0e:	60e2                	ld	ra,24(sp)
    80000f10:	6442                	ld	s0,16(sp)
    80000f12:	64a2                	ld	s1,8(sp)
    80000f14:	6902                	ld	s2,0(sp)
    80000f16:	6105                	addi	sp,sp,32
    80000f18:	8082                	ret

0000000080000f1a <freeproc>:
{
    80000f1a:	1101                	addi	sp,sp,-32
    80000f1c:	ec06                	sd	ra,24(sp)
    80000f1e:	e822                	sd	s0,16(sp)
    80000f20:	e426                	sd	s1,8(sp)
    80000f22:	1000                	addi	s0,sp,32
    80000f24:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000f26:	6d28                	ld	a0,88(a0)
    80000f28:	c119                	beqz	a0,80000f2e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000f2a:	8f2ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000f2e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000f32:	68a8                	ld	a0,80(s1)
    80000f34:	c501                	beqz	a0,80000f3c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000f36:	64ac                	ld	a1,72(s1)
    80000f38:	f9dff0ef          	jal	80000ed4 <proc_freepagetable>
  p->pagetable = 0;
    80000f3c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000f40:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f44:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f48:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f4c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f50:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000f54:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000f58:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000f5c:	0004ac23          	sw	zero,24(s1)
}
    80000f60:	60e2                	ld	ra,24(sp)
    80000f62:	6442                	ld	s0,16(sp)
    80000f64:	64a2                	ld	s1,8(sp)
    80000f66:	6105                	addi	sp,sp,32
    80000f68:	8082                	ret

0000000080000f6a <allocproc>:
{
    80000f6a:	1101                	addi	sp,sp,-32
    80000f6c:	ec06                	sd	ra,24(sp)
    80000f6e:	e822                	sd	s0,16(sp)
    80000f70:	e426                	sd	s1,8(sp)
    80000f72:	e04a                	sd	s2,0(sp)
    80000f74:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f76:	0000a497          	auipc	s1,0xa
    80000f7a:	9fa48493          	addi	s1,s1,-1542 # 8000a970 <proc>
    80000f7e:	0000f917          	auipc	s2,0xf
    80000f82:	5f290913          	addi	s2,s2,1522 # 80010570 <tickslock>
    acquire(&p->lock);
    80000f86:	8526                	mv	a0,s1
    80000f88:	179040ef          	jal	80005900 <acquire>
    if(p->state == UNUSED) {
    80000f8c:	4c9c                	lw	a5,24(s1)
    80000f8e:	cb91                	beqz	a5,80000fa2 <allocproc+0x38>
      release(&p->lock);
    80000f90:	8526                	mv	a0,s1
    80000f92:	207040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f96:	17048493          	addi	s1,s1,368
    80000f9a:	ff2496e3          	bne	s1,s2,80000f86 <allocproc+0x1c>
  return 0;
    80000f9e:	4481                	li	s1,0
    80000fa0:	a089                	j	80000fe2 <allocproc+0x78>
  p->pid = allocpid();
    80000fa2:	e71ff0ef          	jal	80000e12 <allocpid>
    80000fa6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000fa8:	4785                	li	a5,1
    80000faa:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000fac:	952ff0ef          	jal	800000fe <kalloc>
    80000fb0:	892a                	mv	s2,a0
    80000fb2:	eca8                	sd	a0,88(s1)
    80000fb4:	cd15                	beqz	a0,80000ff0 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	e99ff0ef          	jal	80000e50 <proc_pagetable>
    80000fbc:	892a                	mv	s2,a0
    80000fbe:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000fc0:	c121                	beqz	a0,80001000 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000fc2:	07000613          	li	a2,112
    80000fc6:	4581                	li	a1,0
    80000fc8:	06048513          	addi	a0,s1,96
    80000fcc:	9c4ff0ef          	jal	80000190 <memset>
  p->context.ra = (uint64)forkret;
    80000fd0:	00000797          	auipc	a5,0x0
    80000fd4:	e0878793          	addi	a5,a5,-504 # 80000dd8 <forkret>
    80000fd8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000fda:	60bc                	ld	a5,64(s1)
    80000fdc:	6705                	lui	a4,0x1
    80000fde:	97ba                	add	a5,a5,a4
    80000fe0:	f4bc                	sd	a5,104(s1)
}
    80000fe2:	8526                	mv	a0,s1
    80000fe4:	60e2                	ld	ra,24(sp)
    80000fe6:	6442                	ld	s0,16(sp)
    80000fe8:	64a2                	ld	s1,8(sp)
    80000fea:	6902                	ld	s2,0(sp)
    80000fec:	6105                	addi	sp,sp,32
    80000fee:	8082                	ret
    freeproc(p);
    80000ff0:	8526                	mv	a0,s1
    80000ff2:	f29ff0ef          	jal	80000f1a <freeproc>
    release(&p->lock);
    80000ff6:	8526                	mv	a0,s1
    80000ff8:	1a1040ef          	jal	80005998 <release>
    return 0;
    80000ffc:	84ca                	mv	s1,s2
    80000ffe:	b7d5                	j	80000fe2 <allocproc+0x78>
    freeproc(p);
    80001000:	8526                	mv	a0,s1
    80001002:	f19ff0ef          	jal	80000f1a <freeproc>
    release(&p->lock);
    80001006:	8526                	mv	a0,s1
    80001008:	191040ef          	jal	80005998 <release>
    return 0;
    8000100c:	84ca                	mv	s1,s2
    8000100e:	bfd1                	j	80000fe2 <allocproc+0x78>

0000000080001010 <userinit>:
{
    80001010:	1101                	addi	sp,sp,-32
    80001012:	ec06                	sd	ra,24(sp)
    80001014:	e822                	sd	s0,16(sp)
    80001016:	e426                	sd	s1,8(sp)
    80001018:	1000                	addi	s0,sp,32
  p = allocproc();
    8000101a:	f51ff0ef          	jal	80000f6a <allocproc>
    8000101e:	84aa                	mv	s1,a0
  initproc = p;
    80001020:	00009797          	auipc	a5,0x9
    80001024:	4ea7b023          	sd	a0,1248(a5) # 8000a500 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001028:	03400613          	li	a2,52
    8000102c:	00009597          	auipc	a1,0x9
    80001030:	46458593          	addi	a1,a1,1124 # 8000a490 <initcode>
    80001034:	6928                	ld	a0,80(a0)
    80001036:	f2eff0ef          	jal	80000764 <uvmfirst>
  p->sz = PGSIZE;
    8000103a:	6785                	lui	a5,0x1
    8000103c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000103e:	6cb8                	ld	a4,88(s1)
    80001040:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001044:	6cb8                	ld	a4,88(s1)
    80001046:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001048:	4641                	li	a2,16
    8000104a:	00006597          	auipc	a1,0x6
    8000104e:	17658593          	addi	a1,a1,374 # 800071c0 <etext+0x1c0>
    80001052:	15848513          	addi	a0,s1,344
    80001056:	a78ff0ef          	jal	800002ce <safestrcpy>
  p->cwd = namei("/");
    8000105a:	00006517          	auipc	a0,0x6
    8000105e:	17650513          	addi	a0,a0,374 # 800071d0 <etext+0x1d0>
    80001062:	643010ef          	jal	80002ea4 <namei>
    80001066:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000106a:	478d                	li	a5,3
    8000106c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000106e:	8526                	mv	a0,s1
    80001070:	129040ef          	jal	80005998 <release>
}
    80001074:	60e2                	ld	ra,24(sp)
    80001076:	6442                	ld	s0,16(sp)
    80001078:	64a2                	ld	s1,8(sp)
    8000107a:	6105                	addi	sp,sp,32
    8000107c:	8082                	ret

000000008000107e <growproc>:
{
    8000107e:	1101                	addi	sp,sp,-32
    80001080:	ec06                	sd	ra,24(sp)
    80001082:	e822                	sd	s0,16(sp)
    80001084:	e426                	sd	s1,8(sp)
    80001086:	e04a                	sd	s2,0(sp)
    80001088:	1000                	addi	s0,sp,32
    8000108a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000108c:	d1dff0ef          	jal	80000da8 <myproc>
    80001090:	84aa                	mv	s1,a0
  sz = p->sz;
    80001092:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001094:	01204c63          	bgtz	s2,800010ac <growproc+0x2e>
  } else if(n < 0){
    80001098:	02094463          	bltz	s2,800010c0 <growproc+0x42>
  p->sz = sz;
    8000109c:	e4ac                	sd	a1,72(s1)
  return 0;
    8000109e:	4501                	li	a0,0
}
    800010a0:	60e2                	ld	ra,24(sp)
    800010a2:	6442                	ld	s0,16(sp)
    800010a4:	64a2                	ld	s1,8(sp)
    800010a6:	6902                	ld	s2,0(sp)
    800010a8:	6105                	addi	sp,sp,32
    800010aa:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010ac:	4691                	li	a3,4
    800010ae:	00b90633          	add	a2,s2,a1
    800010b2:	6928                	ld	a0,80(a0)
    800010b4:	f52ff0ef          	jal	80000806 <uvmalloc>
    800010b8:	85aa                	mv	a1,a0
    800010ba:	f16d                	bnez	a0,8000109c <growproc+0x1e>
      return -1;
    800010bc:	557d                	li	a0,-1
    800010be:	b7cd                	j	800010a0 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010c0:	00b90633          	add	a2,s2,a1
    800010c4:	6928                	ld	a0,80(a0)
    800010c6:	efcff0ef          	jal	800007c2 <uvmdealloc>
    800010ca:	85aa                	mv	a1,a0
    800010cc:	bfc1                	j	8000109c <growproc+0x1e>

00000000800010ce <fork>:
{
    800010ce:	7139                	addi	sp,sp,-64
    800010d0:	fc06                	sd	ra,56(sp)
    800010d2:	f822                	sd	s0,48(sp)
    800010d4:	f04a                	sd	s2,32(sp)
    800010d6:	e456                	sd	s5,8(sp)
    800010d8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800010da:	ccfff0ef          	jal	80000da8 <myproc>
    800010de:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800010e0:	e8bff0ef          	jal	80000f6a <allocproc>
    800010e4:	0e050e63          	beqz	a0,800011e0 <fork+0x112>
    800010e8:	ec4e                	sd	s3,24(sp)
    800010ea:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010ec:	048ab603          	ld	a2,72(s5)
    800010f0:	692c                	ld	a1,80(a0)
    800010f2:	050ab503          	ld	a0,80(s5)
    800010f6:	849ff0ef          	jal	8000093e <uvmcopy>
    800010fa:	04054e63          	bltz	a0,80001156 <fork+0x88>
    800010fe:	f426                	sd	s1,40(sp)
    80001100:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001102:	048ab783          	ld	a5,72(s5)
    80001106:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000110a:	058ab683          	ld	a3,88(s5)
    8000110e:	87b6                	mv	a5,a3
    80001110:	0589b703          	ld	a4,88(s3)
    80001114:	12068693          	addi	a3,a3,288
    80001118:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000111c:	6788                	ld	a0,8(a5)
    8000111e:	6b8c                	ld	a1,16(a5)
    80001120:	6f90                	ld	a2,24(a5)
    80001122:	01073023          	sd	a6,0(a4)
    80001126:	e708                	sd	a0,8(a4)
    80001128:	eb0c                	sd	a1,16(a4)
    8000112a:	ef10                	sd	a2,24(a4)
    8000112c:	02078793          	addi	a5,a5,32
    80001130:	02070713          	addi	a4,a4,32
    80001134:	fed792e3          	bne	a5,a3,80001118 <fork+0x4a>
  np->trace_mask = p->trace_mask;
    80001138:	168aa783          	lw	a5,360(s5)
    8000113c:	16f9a423          	sw	a5,360(s3)
  np->trapframe->a0 = 0;
    80001140:	0589b783          	ld	a5,88(s3)
    80001144:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001148:	0d0a8493          	addi	s1,s5,208
    8000114c:	0d098913          	addi	s2,s3,208
    80001150:	150a8a13          	addi	s4,s5,336
    80001154:	a831                	j	80001170 <fork+0xa2>
    freeproc(np);
    80001156:	854e                	mv	a0,s3
    80001158:	dc3ff0ef          	jal	80000f1a <freeproc>
    release(&np->lock);
    8000115c:	854e                	mv	a0,s3
    8000115e:	03b040ef          	jal	80005998 <release>
    return -1;
    80001162:	597d                	li	s2,-1
    80001164:	69e2                	ld	s3,24(sp)
    80001166:	a0b5                	j	800011d2 <fork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001168:	04a1                	addi	s1,s1,8
    8000116a:	0921                	addi	s2,s2,8
    8000116c:	01448963          	beq	s1,s4,8000117e <fork+0xb0>
    if(p->ofile[i])
    80001170:	6088                	ld	a0,0(s1)
    80001172:	d97d                	beqz	a0,80001168 <fork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001174:	2c0020ef          	jal	80003434 <filedup>
    80001178:	00a93023          	sd	a0,0(s2)
    8000117c:	b7f5                	j	80001168 <fork+0x9a>
  np->cwd = idup(p->cwd);
    8000117e:	150ab503          	ld	a0,336(s5)
    80001182:	612010ef          	jal	80002794 <idup>
    80001186:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000118a:	4641                	li	a2,16
    8000118c:	158a8593          	addi	a1,s5,344
    80001190:	15898513          	addi	a0,s3,344
    80001194:	93aff0ef          	jal	800002ce <safestrcpy>
  pid = np->pid;
    80001198:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000119c:	854e                	mv	a0,s3
    8000119e:	7fa040ef          	jal	80005998 <release>
  acquire(&wait_lock);
    800011a2:	00009497          	auipc	s1,0x9
    800011a6:	3b648493          	addi	s1,s1,950 # 8000a558 <wait_lock>
    800011aa:	8526                	mv	a0,s1
    800011ac:	754040ef          	jal	80005900 <acquire>
  np->parent = p;
    800011b0:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800011b4:	8526                	mv	a0,s1
    800011b6:	7e2040ef          	jal	80005998 <release>
  acquire(&np->lock);
    800011ba:	854e                	mv	a0,s3
    800011bc:	744040ef          	jal	80005900 <acquire>
  np->state = RUNNABLE;
    800011c0:	478d                	li	a5,3
    800011c2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800011c6:	854e                	mv	a0,s3
    800011c8:	7d0040ef          	jal	80005998 <release>
  return pid;
    800011cc:	74a2                	ld	s1,40(sp)
    800011ce:	69e2                	ld	s3,24(sp)
    800011d0:	6a42                	ld	s4,16(sp)
}
    800011d2:	854a                	mv	a0,s2
    800011d4:	70e2                	ld	ra,56(sp)
    800011d6:	7442                	ld	s0,48(sp)
    800011d8:	7902                	ld	s2,32(sp)
    800011da:	6aa2                	ld	s5,8(sp)
    800011dc:	6121                	addi	sp,sp,64
    800011de:	8082                	ret
    return -1;
    800011e0:	597d                	li	s2,-1
    800011e2:	bfc5                	j	800011d2 <fork+0x104>

00000000800011e4 <scheduler>:
{
    800011e4:	715d                	addi	sp,sp,-80
    800011e6:	e486                	sd	ra,72(sp)
    800011e8:	e0a2                	sd	s0,64(sp)
    800011ea:	fc26                	sd	s1,56(sp)
    800011ec:	f84a                	sd	s2,48(sp)
    800011ee:	f44e                	sd	s3,40(sp)
    800011f0:	f052                	sd	s4,32(sp)
    800011f2:	ec56                	sd	s5,24(sp)
    800011f4:	e85a                	sd	s6,16(sp)
    800011f6:	e45e                	sd	s7,8(sp)
    800011f8:	e062                	sd	s8,0(sp)
    800011fa:	0880                	addi	s0,sp,80
    800011fc:	8792                	mv	a5,tp
  int id = r_tp();
    800011fe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001200:	00779b13          	slli	s6,a5,0x7
    80001204:	00009717          	auipc	a4,0x9
    80001208:	33c70713          	addi	a4,a4,828 # 8000a540 <pid_lock>
    8000120c:	975a                	add	a4,a4,s6
    8000120e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001212:	00009717          	auipc	a4,0x9
    80001216:	36670713          	addi	a4,a4,870 # 8000a578 <cpus+0x8>
    8000121a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000121c:	4c11                	li	s8,4
        c->proc = p;
    8000121e:	079e                	slli	a5,a5,0x7
    80001220:	00009a17          	auipc	s4,0x9
    80001224:	320a0a13          	addi	s4,s4,800 # 8000a540 <pid_lock>
    80001228:	9a3e                	add	s4,s4,a5
        found = 1;
    8000122a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000122c:	0000f997          	auipc	s3,0xf
    80001230:	34498993          	addi	s3,s3,836 # 80010570 <tickslock>
    80001234:	a0a9                	j	8000127e <scheduler+0x9a>
      release(&p->lock);
    80001236:	8526                	mv	a0,s1
    80001238:	760040ef          	jal	80005998 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000123c:	17048493          	addi	s1,s1,368
    80001240:	03348563          	beq	s1,s3,8000126a <scheduler+0x86>
      acquire(&p->lock);
    80001244:	8526                	mv	a0,s1
    80001246:	6ba040ef          	jal	80005900 <acquire>
      if(p->state == RUNNABLE) {
    8000124a:	4c9c                	lw	a5,24(s1)
    8000124c:	ff2795e3          	bne	a5,s2,80001236 <scheduler+0x52>
        p->state = RUNNING;
    80001250:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001254:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001258:	06048593          	addi	a1,s1,96
    8000125c:	855a                	mv	a0,s6
    8000125e:	5e2000ef          	jal	80001840 <swtch>
        c->proc = 0;
    80001262:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001266:	8ade                	mv	s5,s7
    80001268:	b7f9                	j	80001236 <scheduler+0x52>
    if(found == 0) {
    8000126a:	000a9a63          	bnez	s5,8000127e <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000126e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001272:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001276:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000127a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000127e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001282:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001286:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000128a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000128c:	00009497          	auipc	s1,0x9
    80001290:	6e448493          	addi	s1,s1,1764 # 8000a970 <proc>
      if(p->state == RUNNABLE) {
    80001294:	490d                	li	s2,3
    80001296:	b77d                	j	80001244 <scheduler+0x60>

0000000080001298 <sched>:
{
    80001298:	7179                	addi	sp,sp,-48
    8000129a:	f406                	sd	ra,40(sp)
    8000129c:	f022                	sd	s0,32(sp)
    8000129e:	ec26                	sd	s1,24(sp)
    800012a0:	e84a                	sd	s2,16(sp)
    800012a2:	e44e                	sd	s3,8(sp)
    800012a4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012a6:	b03ff0ef          	jal	80000da8 <myproc>
    800012aa:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800012ac:	5ea040ef          	jal	80005896 <holding>
    800012b0:	c92d                	beqz	a0,80001322 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012b2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800012b4:	2781                	sext.w	a5,a5
    800012b6:	079e                	slli	a5,a5,0x7
    800012b8:	00009717          	auipc	a4,0x9
    800012bc:	28870713          	addi	a4,a4,648 # 8000a540 <pid_lock>
    800012c0:	97ba                	add	a5,a5,a4
    800012c2:	0a87a703          	lw	a4,168(a5)
    800012c6:	4785                	li	a5,1
    800012c8:	06f71363          	bne	a4,a5,8000132e <sched+0x96>
  if(p->state == RUNNING)
    800012cc:	4c98                	lw	a4,24(s1)
    800012ce:	4791                	li	a5,4
    800012d0:	06f70563          	beq	a4,a5,8000133a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800012d8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800012da:	e7b5                	bnez	a5,80001346 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012dc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800012de:	00009917          	auipc	s2,0x9
    800012e2:	26290913          	addi	s2,s2,610 # 8000a540 <pid_lock>
    800012e6:	2781                	sext.w	a5,a5
    800012e8:	079e                	slli	a5,a5,0x7
    800012ea:	97ca                	add	a5,a5,s2
    800012ec:	0ac7a983          	lw	s3,172(a5)
    800012f0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012f2:	2781                	sext.w	a5,a5
    800012f4:	079e                	slli	a5,a5,0x7
    800012f6:	00009597          	auipc	a1,0x9
    800012fa:	28258593          	addi	a1,a1,642 # 8000a578 <cpus+0x8>
    800012fe:	95be                	add	a1,a1,a5
    80001300:	06048513          	addi	a0,s1,96
    80001304:	53c000ef          	jal	80001840 <swtch>
    80001308:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000130a:	2781                	sext.w	a5,a5
    8000130c:	079e                	slli	a5,a5,0x7
    8000130e:	993e                	add	s2,s2,a5
    80001310:	0b392623          	sw	s3,172(s2)
}
    80001314:	70a2                	ld	ra,40(sp)
    80001316:	7402                	ld	s0,32(sp)
    80001318:	64e2                	ld	s1,24(sp)
    8000131a:	6942                	ld	s2,16(sp)
    8000131c:	69a2                	ld	s3,8(sp)
    8000131e:	6145                	addi	sp,sp,48
    80001320:	8082                	ret
    panic("sched p->lock");
    80001322:	00006517          	auipc	a0,0x6
    80001326:	eb650513          	addi	a0,a0,-330 # 800071d8 <etext+0x1d8>
    8000132a:	2a8040ef          	jal	800055d2 <panic>
    panic("sched locks");
    8000132e:	00006517          	auipc	a0,0x6
    80001332:	eba50513          	addi	a0,a0,-326 # 800071e8 <etext+0x1e8>
    80001336:	29c040ef          	jal	800055d2 <panic>
    panic("sched running");
    8000133a:	00006517          	auipc	a0,0x6
    8000133e:	ebe50513          	addi	a0,a0,-322 # 800071f8 <etext+0x1f8>
    80001342:	290040ef          	jal	800055d2 <panic>
    panic("sched interruptible");
    80001346:	00006517          	auipc	a0,0x6
    8000134a:	ec250513          	addi	a0,a0,-318 # 80007208 <etext+0x208>
    8000134e:	284040ef          	jal	800055d2 <panic>

0000000080001352 <yield>:
{
    80001352:	1101                	addi	sp,sp,-32
    80001354:	ec06                	sd	ra,24(sp)
    80001356:	e822                	sd	s0,16(sp)
    80001358:	e426                	sd	s1,8(sp)
    8000135a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000135c:	a4dff0ef          	jal	80000da8 <myproc>
    80001360:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001362:	59e040ef          	jal	80005900 <acquire>
  p->state = RUNNABLE;
    80001366:	478d                	li	a5,3
    80001368:	cc9c                	sw	a5,24(s1)
  sched();
    8000136a:	f2fff0ef          	jal	80001298 <sched>
  release(&p->lock);
    8000136e:	8526                	mv	a0,s1
    80001370:	628040ef          	jal	80005998 <release>
}
    80001374:	60e2                	ld	ra,24(sp)
    80001376:	6442                	ld	s0,16(sp)
    80001378:	64a2                	ld	s1,8(sp)
    8000137a:	6105                	addi	sp,sp,32
    8000137c:	8082                	ret

000000008000137e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000137e:	7179                	addi	sp,sp,-48
    80001380:	f406                	sd	ra,40(sp)
    80001382:	f022                	sd	s0,32(sp)
    80001384:	ec26                	sd	s1,24(sp)
    80001386:	e84a                	sd	s2,16(sp)
    80001388:	e44e                	sd	s3,8(sp)
    8000138a:	1800                	addi	s0,sp,48
    8000138c:	89aa                	mv	s3,a0
    8000138e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001390:	a19ff0ef          	jal	80000da8 <myproc>
    80001394:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001396:	56a040ef          	jal	80005900 <acquire>
  release(lk);
    8000139a:	854a                	mv	a0,s2
    8000139c:	5fc040ef          	jal	80005998 <release>

  // Go to sleep.
  p->chan = chan;
    800013a0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800013a4:	4789                	li	a5,2
    800013a6:	cc9c                	sw	a5,24(s1)

  sched();
    800013a8:	ef1ff0ef          	jal	80001298 <sched>

  // Tidy up.
  p->chan = 0;
    800013ac:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800013b0:	8526                	mv	a0,s1
    800013b2:	5e6040ef          	jal	80005998 <release>
  acquire(lk);
    800013b6:	854a                	mv	a0,s2
    800013b8:	548040ef          	jal	80005900 <acquire>
}
    800013bc:	70a2                	ld	ra,40(sp)
    800013be:	7402                	ld	s0,32(sp)
    800013c0:	64e2                	ld	s1,24(sp)
    800013c2:	6942                	ld	s2,16(sp)
    800013c4:	69a2                	ld	s3,8(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret

00000000800013ca <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800013ca:	7139                	addi	sp,sp,-64
    800013cc:	fc06                	sd	ra,56(sp)
    800013ce:	f822                	sd	s0,48(sp)
    800013d0:	f426                	sd	s1,40(sp)
    800013d2:	f04a                	sd	s2,32(sp)
    800013d4:	ec4e                	sd	s3,24(sp)
    800013d6:	e852                	sd	s4,16(sp)
    800013d8:	e456                	sd	s5,8(sp)
    800013da:	0080                	addi	s0,sp,64
    800013dc:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800013de:	00009497          	auipc	s1,0x9
    800013e2:	59248493          	addi	s1,s1,1426 # 8000a970 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800013e6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800013e8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013ea:	0000f917          	auipc	s2,0xf
    800013ee:	18690913          	addi	s2,s2,390 # 80010570 <tickslock>
    800013f2:	a801                	j	80001402 <wakeup+0x38>
      }
      release(&p->lock);
    800013f4:	8526                	mv	a0,s1
    800013f6:	5a2040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013fa:	17048493          	addi	s1,s1,368
    800013fe:	03248263          	beq	s1,s2,80001422 <wakeup+0x58>
    if(p != myproc()){
    80001402:	9a7ff0ef          	jal	80000da8 <myproc>
    80001406:	fea48ae3          	beq	s1,a0,800013fa <wakeup+0x30>
      acquire(&p->lock);
    8000140a:	8526                	mv	a0,s1
    8000140c:	4f4040ef          	jal	80005900 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001410:	4c9c                	lw	a5,24(s1)
    80001412:	ff3791e3          	bne	a5,s3,800013f4 <wakeup+0x2a>
    80001416:	709c                	ld	a5,32(s1)
    80001418:	fd479ee3          	bne	a5,s4,800013f4 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000141c:	0154ac23          	sw	s5,24(s1)
    80001420:	bfd1                	j	800013f4 <wakeup+0x2a>
    }
  }
}
    80001422:	70e2                	ld	ra,56(sp)
    80001424:	7442                	ld	s0,48(sp)
    80001426:	74a2                	ld	s1,40(sp)
    80001428:	7902                	ld	s2,32(sp)
    8000142a:	69e2                	ld	s3,24(sp)
    8000142c:	6a42                	ld	s4,16(sp)
    8000142e:	6aa2                	ld	s5,8(sp)
    80001430:	6121                	addi	sp,sp,64
    80001432:	8082                	ret

0000000080001434 <reparent>:
{
    80001434:	7179                	addi	sp,sp,-48
    80001436:	f406                	sd	ra,40(sp)
    80001438:	f022                	sd	s0,32(sp)
    8000143a:	ec26                	sd	s1,24(sp)
    8000143c:	e84a                	sd	s2,16(sp)
    8000143e:	e44e                	sd	s3,8(sp)
    80001440:	e052                	sd	s4,0(sp)
    80001442:	1800                	addi	s0,sp,48
    80001444:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001446:	00009497          	auipc	s1,0x9
    8000144a:	52a48493          	addi	s1,s1,1322 # 8000a970 <proc>
      pp->parent = initproc;
    8000144e:	00009a17          	auipc	s4,0x9
    80001452:	0b2a0a13          	addi	s4,s4,178 # 8000a500 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001456:	0000f997          	auipc	s3,0xf
    8000145a:	11a98993          	addi	s3,s3,282 # 80010570 <tickslock>
    8000145e:	a029                	j	80001468 <reparent+0x34>
    80001460:	17048493          	addi	s1,s1,368
    80001464:	01348b63          	beq	s1,s3,8000147a <reparent+0x46>
    if(pp->parent == p){
    80001468:	7c9c                	ld	a5,56(s1)
    8000146a:	ff279be3          	bne	a5,s2,80001460 <reparent+0x2c>
      pp->parent = initproc;
    8000146e:	000a3503          	ld	a0,0(s4)
    80001472:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001474:	f57ff0ef          	jal	800013ca <wakeup>
    80001478:	b7e5                	j	80001460 <reparent+0x2c>
}
    8000147a:	70a2                	ld	ra,40(sp)
    8000147c:	7402                	ld	s0,32(sp)
    8000147e:	64e2                	ld	s1,24(sp)
    80001480:	6942                	ld	s2,16(sp)
    80001482:	69a2                	ld	s3,8(sp)
    80001484:	6a02                	ld	s4,0(sp)
    80001486:	6145                	addi	sp,sp,48
    80001488:	8082                	ret

000000008000148a <exit>:
{
    8000148a:	7179                	addi	sp,sp,-48
    8000148c:	f406                	sd	ra,40(sp)
    8000148e:	f022                	sd	s0,32(sp)
    80001490:	ec26                	sd	s1,24(sp)
    80001492:	e84a                	sd	s2,16(sp)
    80001494:	e44e                	sd	s3,8(sp)
    80001496:	e052                	sd	s4,0(sp)
    80001498:	1800                	addi	s0,sp,48
    8000149a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000149c:	90dff0ef          	jal	80000da8 <myproc>
    800014a0:	89aa                	mv	s3,a0
  if(p == initproc)
    800014a2:	00009797          	auipc	a5,0x9
    800014a6:	05e7b783          	ld	a5,94(a5) # 8000a500 <initproc>
    800014aa:	0d050493          	addi	s1,a0,208
    800014ae:	15050913          	addi	s2,a0,336
    800014b2:	00a79f63          	bne	a5,a0,800014d0 <exit+0x46>
    panic("init exiting");
    800014b6:	00006517          	auipc	a0,0x6
    800014ba:	d6a50513          	addi	a0,a0,-662 # 80007220 <etext+0x220>
    800014be:	114040ef          	jal	800055d2 <panic>
      fileclose(f);
    800014c2:	7b9010ef          	jal	8000347a <fileclose>
      p->ofile[fd] = 0;
    800014c6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800014ca:	04a1                	addi	s1,s1,8
    800014cc:	01248563          	beq	s1,s2,800014d6 <exit+0x4c>
    if(p->ofile[fd]){
    800014d0:	6088                	ld	a0,0(s1)
    800014d2:	f965                	bnez	a0,800014c2 <exit+0x38>
    800014d4:	bfdd                	j	800014ca <exit+0x40>
  begin_op();
    800014d6:	38b010ef          	jal	80003060 <begin_op>
  iput(p->cwd);
    800014da:	1509b503          	ld	a0,336(s3)
    800014de:	46e010ef          	jal	8000294c <iput>
  end_op();
    800014e2:	3e9010ef          	jal	800030ca <end_op>
  p->cwd = 0;
    800014e6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014ea:	00009497          	auipc	s1,0x9
    800014ee:	06e48493          	addi	s1,s1,110 # 8000a558 <wait_lock>
    800014f2:	8526                	mv	a0,s1
    800014f4:	40c040ef          	jal	80005900 <acquire>
  reparent(p);
    800014f8:	854e                	mv	a0,s3
    800014fa:	f3bff0ef          	jal	80001434 <reparent>
  wakeup(p->parent);
    800014fe:	0389b503          	ld	a0,56(s3)
    80001502:	ec9ff0ef          	jal	800013ca <wakeup>
  acquire(&p->lock);
    80001506:	854e                	mv	a0,s3
    80001508:	3f8040ef          	jal	80005900 <acquire>
  p->xstate = status;
    8000150c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001510:	4795                	li	a5,5
    80001512:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001516:	8526                	mv	a0,s1
    80001518:	480040ef          	jal	80005998 <release>
  sched();
    8000151c:	d7dff0ef          	jal	80001298 <sched>
  panic("zombie exit");
    80001520:	00006517          	auipc	a0,0x6
    80001524:	d1050513          	addi	a0,a0,-752 # 80007230 <etext+0x230>
    80001528:	0aa040ef          	jal	800055d2 <panic>

000000008000152c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000152c:	7179                	addi	sp,sp,-48
    8000152e:	f406                	sd	ra,40(sp)
    80001530:	f022                	sd	s0,32(sp)
    80001532:	ec26                	sd	s1,24(sp)
    80001534:	e84a                	sd	s2,16(sp)
    80001536:	e44e                	sd	s3,8(sp)
    80001538:	1800                	addi	s0,sp,48
    8000153a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000153c:	00009497          	auipc	s1,0x9
    80001540:	43448493          	addi	s1,s1,1076 # 8000a970 <proc>
    80001544:	0000f997          	auipc	s3,0xf
    80001548:	02c98993          	addi	s3,s3,44 # 80010570 <tickslock>
    acquire(&p->lock);
    8000154c:	8526                	mv	a0,s1
    8000154e:	3b2040ef          	jal	80005900 <acquire>
    if(p->pid == pid){
    80001552:	589c                	lw	a5,48(s1)
    80001554:	01278b63          	beq	a5,s2,8000156a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001558:	8526                	mv	a0,s1
    8000155a:	43e040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000155e:	17048493          	addi	s1,s1,368
    80001562:	ff3495e3          	bne	s1,s3,8000154c <kill+0x20>
  }
  return -1;
    80001566:	557d                	li	a0,-1
    80001568:	a819                	j	8000157e <kill+0x52>
      p->killed = 1;
    8000156a:	4785                	li	a5,1
    8000156c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000156e:	4c98                	lw	a4,24(s1)
    80001570:	4789                	li	a5,2
    80001572:	00f70d63          	beq	a4,a5,8000158c <kill+0x60>
      release(&p->lock);
    80001576:	8526                	mv	a0,s1
    80001578:	420040ef          	jal	80005998 <release>
      return 0;
    8000157c:	4501                	li	a0,0
}
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	6145                	addi	sp,sp,48
    8000158a:	8082                	ret
        p->state = RUNNABLE;
    8000158c:	478d                	li	a5,3
    8000158e:	cc9c                	sw	a5,24(s1)
    80001590:	b7dd                	j	80001576 <kill+0x4a>

0000000080001592 <setkilled>:

void
setkilled(struct proc *p)
{
    80001592:	1101                	addi	sp,sp,-32
    80001594:	ec06                	sd	ra,24(sp)
    80001596:	e822                	sd	s0,16(sp)
    80001598:	e426                	sd	s1,8(sp)
    8000159a:	1000                	addi	s0,sp,32
    8000159c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000159e:	362040ef          	jal	80005900 <acquire>
  p->killed = 1;
    800015a2:	4785                	li	a5,1
    800015a4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800015a6:	8526                	mv	a0,s1
    800015a8:	3f0040ef          	jal	80005998 <release>
}
    800015ac:	60e2                	ld	ra,24(sp)
    800015ae:	6442                	ld	s0,16(sp)
    800015b0:	64a2                	ld	s1,8(sp)
    800015b2:	6105                	addi	sp,sp,32
    800015b4:	8082                	ret

00000000800015b6 <killed>:

int
killed(struct proc *p)
{
    800015b6:	1101                	addi	sp,sp,-32
    800015b8:	ec06                	sd	ra,24(sp)
    800015ba:	e822                	sd	s0,16(sp)
    800015bc:	e426                	sd	s1,8(sp)
    800015be:	e04a                	sd	s2,0(sp)
    800015c0:	1000                	addi	s0,sp,32
    800015c2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800015c4:	33c040ef          	jal	80005900 <acquire>
  k = p->killed;
    800015c8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800015cc:	8526                	mv	a0,s1
    800015ce:	3ca040ef          	jal	80005998 <release>
  return k;
}
    800015d2:	854a                	mv	a0,s2
    800015d4:	60e2                	ld	ra,24(sp)
    800015d6:	6442                	ld	s0,16(sp)
    800015d8:	64a2                	ld	s1,8(sp)
    800015da:	6902                	ld	s2,0(sp)
    800015dc:	6105                	addi	sp,sp,32
    800015de:	8082                	ret

00000000800015e0 <wait>:
{
    800015e0:	715d                	addi	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	e062                	sd	s8,0(sp)
    800015f6:	0880                	addi	s0,sp,80
    800015f8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015fa:	faeff0ef          	jal	80000da8 <myproc>
    800015fe:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001600:	00009517          	auipc	a0,0x9
    80001604:	f5850513          	addi	a0,a0,-168 # 8000a558 <wait_lock>
    80001608:	2f8040ef          	jal	80005900 <acquire>
    havekids = 0;
    8000160c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000160e:	4a15                	li	s4,5
        havekids = 1;
    80001610:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001612:	0000f997          	auipc	s3,0xf
    80001616:	f5e98993          	addi	s3,s3,-162 # 80010570 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000161a:	00009c17          	auipc	s8,0x9
    8000161e:	f3ec0c13          	addi	s8,s8,-194 # 8000a558 <wait_lock>
    80001622:	a871                	j	800016be <wait+0xde>
          pid = pp->pid;
    80001624:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001628:	000b0c63          	beqz	s6,80001640 <wait+0x60>
    8000162c:	4691                	li	a3,4
    8000162e:	02c48613          	addi	a2,s1,44
    80001632:	85da                	mv	a1,s6
    80001634:	05093503          	ld	a0,80(s2)
    80001638:	be2ff0ef          	jal	80000a1a <copyout>
    8000163c:	02054b63          	bltz	a0,80001672 <wait+0x92>
          freeproc(pp);
    80001640:	8526                	mv	a0,s1
    80001642:	8d9ff0ef          	jal	80000f1a <freeproc>
          release(&pp->lock);
    80001646:	8526                	mv	a0,s1
    80001648:	350040ef          	jal	80005998 <release>
          release(&wait_lock);
    8000164c:	00009517          	auipc	a0,0x9
    80001650:	f0c50513          	addi	a0,a0,-244 # 8000a558 <wait_lock>
    80001654:	344040ef          	jal	80005998 <release>
}
    80001658:	854e                	mv	a0,s3
    8000165a:	60a6                	ld	ra,72(sp)
    8000165c:	6406                	ld	s0,64(sp)
    8000165e:	74e2                	ld	s1,56(sp)
    80001660:	7942                	ld	s2,48(sp)
    80001662:	79a2                	ld	s3,40(sp)
    80001664:	7a02                	ld	s4,32(sp)
    80001666:	6ae2                	ld	s5,24(sp)
    80001668:	6b42                	ld	s6,16(sp)
    8000166a:	6ba2                	ld	s7,8(sp)
    8000166c:	6c02                	ld	s8,0(sp)
    8000166e:	6161                	addi	sp,sp,80
    80001670:	8082                	ret
            release(&pp->lock);
    80001672:	8526                	mv	a0,s1
    80001674:	324040ef          	jal	80005998 <release>
            release(&wait_lock);
    80001678:	00009517          	auipc	a0,0x9
    8000167c:	ee050513          	addi	a0,a0,-288 # 8000a558 <wait_lock>
    80001680:	318040ef          	jal	80005998 <release>
            return -1;
    80001684:	59fd                	li	s3,-1
    80001686:	bfc9                	j	80001658 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001688:	17048493          	addi	s1,s1,368
    8000168c:	03348063          	beq	s1,s3,800016ac <wait+0xcc>
      if(pp->parent == p){
    80001690:	7c9c                	ld	a5,56(s1)
    80001692:	ff279be3          	bne	a5,s2,80001688 <wait+0xa8>
        acquire(&pp->lock);
    80001696:	8526                	mv	a0,s1
    80001698:	268040ef          	jal	80005900 <acquire>
        if(pp->state == ZOMBIE){
    8000169c:	4c9c                	lw	a5,24(s1)
    8000169e:	f94783e3          	beq	a5,s4,80001624 <wait+0x44>
        release(&pp->lock);
    800016a2:	8526                	mv	a0,s1
    800016a4:	2f4040ef          	jal	80005998 <release>
        havekids = 1;
    800016a8:	8756                	mv	a4,s5
    800016aa:	bff9                	j	80001688 <wait+0xa8>
    if(!havekids || killed(p)){
    800016ac:	cf19                	beqz	a4,800016ca <wait+0xea>
    800016ae:	854a                	mv	a0,s2
    800016b0:	f07ff0ef          	jal	800015b6 <killed>
    800016b4:	e919                	bnez	a0,800016ca <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016b6:	85e2                	mv	a1,s8
    800016b8:	854a                	mv	a0,s2
    800016ba:	cc5ff0ef          	jal	8000137e <sleep>
    havekids = 0;
    800016be:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016c0:	00009497          	auipc	s1,0x9
    800016c4:	2b048493          	addi	s1,s1,688 # 8000a970 <proc>
    800016c8:	b7e1                	j	80001690 <wait+0xb0>
      release(&wait_lock);
    800016ca:	00009517          	auipc	a0,0x9
    800016ce:	e8e50513          	addi	a0,a0,-370 # 8000a558 <wait_lock>
    800016d2:	2c6040ef          	jal	80005998 <release>
      return -1;
    800016d6:	59fd                	li	s3,-1
    800016d8:	b741                	j	80001658 <wait+0x78>

00000000800016da <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800016da:	7179                	addi	sp,sp,-48
    800016dc:	f406                	sd	ra,40(sp)
    800016de:	f022                	sd	s0,32(sp)
    800016e0:	ec26                	sd	s1,24(sp)
    800016e2:	e84a                	sd	s2,16(sp)
    800016e4:	e44e                	sd	s3,8(sp)
    800016e6:	e052                	sd	s4,0(sp)
    800016e8:	1800                	addi	s0,sp,48
    800016ea:	84aa                	mv	s1,a0
    800016ec:	892e                	mv	s2,a1
    800016ee:	89b2                	mv	s3,a2
    800016f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016f2:	eb6ff0ef          	jal	80000da8 <myproc>
  if(user_dst){
    800016f6:	cc99                	beqz	s1,80001714 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800016f8:	86d2                	mv	a3,s4
    800016fa:	864e                	mv	a2,s3
    800016fc:	85ca                	mv	a1,s2
    800016fe:	6928                	ld	a0,80(a0)
    80001700:	b1aff0ef          	jal	80000a1a <copyout>
  } else {
    memmove((char *)dst, src, len);
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
    memmove((char *)dst, src, len);
    80001714:	000a061b          	sext.w	a2,s4
    80001718:	85ce                	mv	a1,s3
    8000171a:	854a                	mv	a0,s2
    8000171c:	ad1fe0ef          	jal	800001ec <memmove>
    return 0;
    80001720:	8526                	mv	a0,s1
    80001722:	b7cd                	j	80001704 <either_copyout+0x2a>

0000000080001724 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001724:	7179                	addi	sp,sp,-48
    80001726:	f406                	sd	ra,40(sp)
    80001728:	f022                	sd	s0,32(sp)
    8000172a:	ec26                	sd	s1,24(sp)
    8000172c:	e84a                	sd	s2,16(sp)
    8000172e:	e44e                	sd	s3,8(sp)
    80001730:	e052                	sd	s4,0(sp)
    80001732:	1800                	addi	s0,sp,48
    80001734:	892a                	mv	s2,a0
    80001736:	84ae                	mv	s1,a1
    80001738:	89b2                	mv	s3,a2
    8000173a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000173c:	e6cff0ef          	jal	80000da8 <myproc>
  if(user_src){
    80001740:	cc99                	beqz	s1,8000175e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001742:	86d2                	mv	a3,s4
    80001744:	864e                	mv	a2,s3
    80001746:	85ca                	mv	a1,s2
    80001748:	6928                	ld	a0,80(a0)
    8000174a:	ba6ff0ef          	jal	80000af0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000174e:	70a2                	ld	ra,40(sp)
    80001750:	7402                	ld	s0,32(sp)
    80001752:	64e2                	ld	s1,24(sp)
    80001754:	6942                	ld	s2,16(sp)
    80001756:	69a2                	ld	s3,8(sp)
    80001758:	6a02                	ld	s4,0(sp)
    8000175a:	6145                	addi	sp,sp,48
    8000175c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000175e:	000a061b          	sext.w	a2,s4
    80001762:	85ce                	mv	a1,s3
    80001764:	854a                	mv	a0,s2
    80001766:	a87fe0ef          	jal	800001ec <memmove>
    return 0;
    8000176a:	8526                	mv	a0,s1
    8000176c:	b7cd                	j	8000174e <either_copyin+0x2a>

000000008000176e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000176e:	715d                	addi	sp,sp,-80
    80001770:	e486                	sd	ra,72(sp)
    80001772:	e0a2                	sd	s0,64(sp)
    80001774:	fc26                	sd	s1,56(sp)
    80001776:	f84a                	sd	s2,48(sp)
    80001778:	f44e                	sd	s3,40(sp)
    8000177a:	f052                	sd	s4,32(sp)
    8000177c:	ec56                	sd	s5,24(sp)
    8000177e:	e85a                	sd	s6,16(sp)
    80001780:	e45e                	sd	s7,8(sp)
    80001782:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001784:	00006517          	auipc	a0,0x6
    80001788:	89450513          	addi	a0,a0,-1900 # 80007018 <etext+0x18>
    8000178c:	375030ef          	jal	80005300 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001790:	00009497          	auipc	s1,0x9
    80001794:	33848493          	addi	s1,s1,824 # 8000aac8 <proc+0x158>
    80001798:	0000f917          	auipc	s2,0xf
    8000179c:	f3090913          	addi	s2,s2,-208 # 800106c8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017a0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800017a2:	00006997          	auipc	s3,0x6
    800017a6:	a9e98993          	addi	s3,s3,-1378 # 80007240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800017aa:	00006a97          	auipc	s5,0x6
    800017ae:	a9ea8a93          	addi	s5,s5,-1378 # 80007248 <etext+0x248>
    printf("\n");
    800017b2:	00006a17          	auipc	s4,0x6
    800017b6:	866a0a13          	addi	s4,s4,-1946 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017ba:	00006b97          	auipc	s7,0x6
    800017be:	0a6b8b93          	addi	s7,s7,166 # 80007860 <states.0>
    800017c2:	a829                	j	800017dc <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800017c4:	ed86a583          	lw	a1,-296(a3)
    800017c8:	8556                	mv	a0,s5
    800017ca:	337030ef          	jal	80005300 <printf>
    printf("\n");
    800017ce:	8552                	mv	a0,s4
    800017d0:	331030ef          	jal	80005300 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800017d4:	17048493          	addi	s1,s1,368
    800017d8:	03248263          	beq	s1,s2,800017fc <procdump+0x8e>
    if(p->state == UNUSED)
    800017dc:	86a6                	mv	a3,s1
    800017de:	ec04a783          	lw	a5,-320(s1)
    800017e2:	dbed                	beqz	a5,800017d4 <procdump+0x66>
      state = "???";
    800017e4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017e6:	fcfb6fe3          	bltu	s6,a5,800017c4 <procdump+0x56>
    800017ea:	02079713          	slli	a4,a5,0x20
    800017ee:	01d75793          	srli	a5,a4,0x1d
    800017f2:	97de                	add	a5,a5,s7
    800017f4:	6390                	ld	a2,0(a5)
    800017f6:	f679                	bnez	a2,800017c4 <procdump+0x56>
      state = "???";
    800017f8:	864e                	mv	a2,s3
    800017fa:	b7e9                	j	800017c4 <procdump+0x56>
  }
}
    800017fc:	60a6                	ld	ra,72(sp)
    800017fe:	6406                	ld	s0,64(sp)
    80001800:	74e2                	ld	s1,56(sp)
    80001802:	7942                	ld	s2,48(sp)
    80001804:	79a2                	ld	s3,40(sp)
    80001806:	7a02                	ld	s4,32(sp)
    80001808:	6ae2                	ld	s5,24(sp)
    8000180a:	6b42                	ld	s6,16(sp)
    8000180c:	6ba2                	ld	s7,8(sp)
    8000180e:	6161                	addi	sp,sp,80
    80001810:	8082                	ret

0000000080001812 <count_active_processes>:

// count the number of active processes
uint64 count_active_processes(void) {
    80001812:	1141                	addi	sp,sp,-16
    80001814:	e422                	sd	s0,8(sp)
    80001816:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    80001818:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++) {
    8000181a:	00009797          	auipc	a5,0x9
    8000181e:	15678793          	addi	a5,a5,342 # 8000a970 <proc>
    80001822:	0000f697          	auipc	a3,0xf
    80001826:	d4e68693          	addi	a3,a3,-690 # 80010570 <tickslock>
    if (p->state != UNUSED) {
    8000182a:	4f98                	lw	a4,24(a5)
      count += 1;
    8000182c:	00e03733          	snez	a4,a4
    80001830:	953a                	add	a0,a0,a4
  for (p = proc; p < &proc[NPROC]; p++) {
    80001832:	17078793          	addi	a5,a5,368
    80001836:	fed79ae3          	bne	a5,a3,8000182a <count_active_processes+0x18>
    }
  }

  return count;
    8000183a:	6422                	ld	s0,8(sp)
    8000183c:	0141                	addi	sp,sp,16
    8000183e:	8082                	ret

0000000080001840 <swtch>:
    80001840:	00153023          	sd	ra,0(a0)
    80001844:	00253423          	sd	sp,8(a0)
    80001848:	e900                	sd	s0,16(a0)
    8000184a:	ed04                	sd	s1,24(a0)
    8000184c:	03253023          	sd	s2,32(a0)
    80001850:	03353423          	sd	s3,40(a0)
    80001854:	03453823          	sd	s4,48(a0)
    80001858:	03553c23          	sd	s5,56(a0)
    8000185c:	05653023          	sd	s6,64(a0)
    80001860:	05753423          	sd	s7,72(a0)
    80001864:	05853823          	sd	s8,80(a0)
    80001868:	05953c23          	sd	s9,88(a0)
    8000186c:	07a53023          	sd	s10,96(a0)
    80001870:	07b53423          	sd	s11,104(a0)
    80001874:	0005b083          	ld	ra,0(a1)
    80001878:	0085b103          	ld	sp,8(a1)
    8000187c:	6980                	ld	s0,16(a1)
    8000187e:	6d84                	ld	s1,24(a1)
    80001880:	0205b903          	ld	s2,32(a1)
    80001884:	0285b983          	ld	s3,40(a1)
    80001888:	0305ba03          	ld	s4,48(a1)
    8000188c:	0385ba83          	ld	s5,56(a1)
    80001890:	0405bb03          	ld	s6,64(a1)
    80001894:	0485bb83          	ld	s7,72(a1)
    80001898:	0505bc03          	ld	s8,80(a1)
    8000189c:	0585bc83          	ld	s9,88(a1)
    800018a0:	0605bd03          	ld	s10,96(a1)
    800018a4:	0685bd83          	ld	s11,104(a1)
    800018a8:	8082                	ret

00000000800018aa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800018aa:	1141                	addi	sp,sp,-16
    800018ac:	e406                	sd	ra,8(sp)
    800018ae:	e022                	sd	s0,0(sp)
    800018b0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800018b2:	00006597          	auipc	a1,0x6
    800018b6:	9d658593          	addi	a1,a1,-1578 # 80007288 <etext+0x288>
    800018ba:	0000f517          	auipc	a0,0xf
    800018be:	cb650513          	addi	a0,a0,-842 # 80010570 <tickslock>
    800018c2:	7bf030ef          	jal	80005880 <initlock>
}
    800018c6:	60a2                	ld	ra,8(sp)
    800018c8:	6402                	ld	s0,0(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800018ce:	1141                	addi	sp,sp,-16
    800018d0:	e422                	sd	s0,8(sp)
    800018d2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018d4:	00003797          	auipc	a5,0x3
    800018d8:	f6c78793          	addi	a5,a5,-148 # 80004840 <kernelvec>
    800018dc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800018e0:	6422                	ld	s0,8(sp)
    800018e2:	0141                	addi	sp,sp,16
    800018e4:	8082                	ret

00000000800018e6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800018e6:	1141                	addi	sp,sp,-16
    800018e8:	e406                	sd	ra,8(sp)
    800018ea:	e022                	sd	s0,0(sp)
    800018ec:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800018ee:	cbaff0ef          	jal	80000da8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800018f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800018f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800018f8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800018fc:	00004697          	auipc	a3,0x4
    80001900:	70468693          	addi	a3,a3,1796 # 80006000 <_trampoline>
    80001904:	00004717          	auipc	a4,0x4
    80001908:	6fc70713          	addi	a4,a4,1788 # 80006000 <_trampoline>
    8000190c:	8f15                	sub	a4,a4,a3
    8000190e:	040007b7          	lui	a5,0x4000
    80001912:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001914:	07b2                	slli	a5,a5,0xc
    80001916:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001918:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000191c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000191e:	18002673          	csrr	a2,satp
    80001922:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001924:	6d30                	ld	a2,88(a0)
    80001926:	6138                	ld	a4,64(a0)
    80001928:	6585                	lui	a1,0x1
    8000192a:	972e                	add	a4,a4,a1
    8000192c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000192e:	6d38                	ld	a4,88(a0)
    80001930:	00000617          	auipc	a2,0x0
    80001934:	11060613          	addi	a2,a2,272 # 80001a40 <usertrap>
    80001938:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000193a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000193c:	8612                	mv	a2,tp
    8000193e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001940:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001944:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001948:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000194c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001950:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001952:	6f18                	ld	a4,24(a4)
    80001954:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	6928                	ld	a0,80(a0)
    8000195a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	00004717          	auipc	a4,0x4
    80001960:	74070713          	addi	a4,a4,1856 # 8000609c <userret>
    80001964:	8f15                	sub	a4,a4,a3
    80001966:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001968:	577d                	li	a4,-1
    8000196a:	177e                	slli	a4,a4,0x3f
    8000196c:	8d59                	or	a0,a0,a4
    8000196e:	9782                	jalr	a5
}
    80001970:	60a2                	ld	ra,8(sp)
    80001972:	6402                	ld	s0,0(sp)
    80001974:	0141                	addi	sp,sp,16
    80001976:	8082                	ret

0000000080001978 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001978:	1101                	addi	sp,sp,-32
    8000197a:	ec06                	sd	ra,24(sp)
    8000197c:	e822                	sd	s0,16(sp)
    8000197e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001980:	bfcff0ef          	jal	80000d7c <cpuid>
    80001984:	cd11                	beqz	a0,800019a0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001986:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000198a:	000f4737          	lui	a4,0xf4
    8000198e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001992:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001994:	14d79073          	csrw	stimecmp,a5
}
    80001998:	60e2                	ld	ra,24(sp)
    8000199a:	6442                	ld	s0,16(sp)
    8000199c:	6105                	addi	sp,sp,32
    8000199e:	8082                	ret
    800019a0:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800019a2:	0000f497          	auipc	s1,0xf
    800019a6:	bce48493          	addi	s1,s1,-1074 # 80010570 <tickslock>
    800019aa:	8526                	mv	a0,s1
    800019ac:	755030ef          	jal	80005900 <acquire>
    ticks++;
    800019b0:	00009517          	auipc	a0,0x9
    800019b4:	b5850513          	addi	a0,a0,-1192 # 8000a508 <ticks>
    800019b8:	411c                	lw	a5,0(a0)
    800019ba:	2785                	addiw	a5,a5,1
    800019bc:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800019be:	a0dff0ef          	jal	800013ca <wakeup>
    release(&tickslock);
    800019c2:	8526                	mv	a0,s1
    800019c4:	7d5030ef          	jal	80005998 <release>
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	bf75                	j	80001986 <clockintr+0xe>

00000000800019cc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800019cc:	1101                	addi	sp,sp,-32
    800019ce:	ec06                	sd	ra,24(sp)
    800019d0:	e822                	sd	s0,16(sp)
    800019d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019d4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800019d8:	57fd                	li	a5,-1
    800019da:	17fe                	slli	a5,a5,0x3f
    800019dc:	07a5                	addi	a5,a5,9
    800019de:	00f70c63          	beq	a4,a5,800019f6 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800019e2:	57fd                	li	a5,-1
    800019e4:	17fe                	slli	a5,a5,0x3f
    800019e6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800019e8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800019ea:	04f70763          	beq	a4,a5,80001a38 <devintr+0x6c>
  }
}
    800019ee:	60e2                	ld	ra,24(sp)
    800019f0:	6442                	ld	s0,16(sp)
    800019f2:	6105                	addi	sp,sp,32
    800019f4:	8082                	ret
    800019f6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800019f8:	6f5020ef          	jal	800048ec <plic_claim>
    800019fc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800019fe:	47a9                	li	a5,10
    80001a00:	00f50963          	beq	a0,a5,80001a12 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001a04:	4785                	li	a5,1
    80001a06:	00f50963          	beq	a0,a5,80001a18 <devintr+0x4c>
    return 1;
    80001a0a:	4505                	li	a0,1
    } else if(irq){
    80001a0c:	e889                	bnez	s1,80001a1e <devintr+0x52>
    80001a0e:	64a2                	ld	s1,8(sp)
    80001a10:	bff9                	j	800019ee <devintr+0x22>
      uartintr();
    80001a12:	633030ef          	jal	80005844 <uartintr>
    if(irq)
    80001a16:	a819                	j	80001a2c <devintr+0x60>
      virtio_disk_intr();
    80001a18:	39a030ef          	jal	80004db2 <virtio_disk_intr>
    if(irq)
    80001a1c:	a801                	j	80001a2c <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a1e:	85a6                	mv	a1,s1
    80001a20:	00006517          	auipc	a0,0x6
    80001a24:	87050513          	addi	a0,a0,-1936 # 80007290 <etext+0x290>
    80001a28:	0d9030ef          	jal	80005300 <printf>
      plic_complete(irq);
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	6df020ef          	jal	8000490c <plic_complete>
    return 1;
    80001a32:	4505                	li	a0,1
    80001a34:	64a2                	ld	s1,8(sp)
    80001a36:	bf65                	j	800019ee <devintr+0x22>
    clockintr();
    80001a38:	f41ff0ef          	jal	80001978 <clockintr>
    return 2;
    80001a3c:	4509                	li	a0,2
    80001a3e:	bf45                	j	800019ee <devintr+0x22>

0000000080001a40 <usertrap>:
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	e04a                	sd	s2,0(sp)
    80001a4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a4c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001a50:	1007f793          	andi	a5,a5,256
    80001a54:	ef85                	bnez	a5,80001a8c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a56:	00003797          	auipc	a5,0x3
    80001a5a:	dea78793          	addi	a5,a5,-534 # 80004840 <kernelvec>
    80001a5e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001a62:	b46ff0ef          	jal	80000da8 <myproc>
    80001a66:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001a68:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a6a:	14102773          	csrr	a4,sepc
    80001a6e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a70:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a74:	47a1                	li	a5,8
    80001a76:	02f70163          	beq	a4,a5,80001a98 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001a7a:	f53ff0ef          	jal	800019cc <devintr>
    80001a7e:	892a                	mv	s2,a0
    80001a80:	c135                	beqz	a0,80001ae4 <usertrap+0xa4>
  if(killed(p))
    80001a82:	8526                	mv	a0,s1
    80001a84:	b33ff0ef          	jal	800015b6 <killed>
    80001a88:	cd1d                	beqz	a0,80001ac6 <usertrap+0x86>
    80001a8a:	a81d                	j	80001ac0 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001a8c:	00006517          	auipc	a0,0x6
    80001a90:	82450513          	addi	a0,a0,-2012 # 800072b0 <etext+0x2b0>
    80001a94:	33f030ef          	jal	800055d2 <panic>
    if(killed(p))
    80001a98:	b1fff0ef          	jal	800015b6 <killed>
    80001a9c:	e121                	bnez	a0,80001adc <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001a9e:	6cb8                	ld	a4,88(s1)
    80001aa0:	6f1c                	ld	a5,24(a4)
    80001aa2:	0791                	addi	a5,a5,4
    80001aa4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001aa6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001aaa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001aae:	10079073          	csrw	sstatus,a5
    syscall();
    80001ab2:	248000ef          	jal	80001cfa <syscall>
  if(killed(p))
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	affff0ef          	jal	800015b6 <killed>
    80001abc:	c901                	beqz	a0,80001acc <usertrap+0x8c>
    80001abe:	4901                	li	s2,0
    exit(-1);
    80001ac0:	557d                	li	a0,-1
    80001ac2:	9c9ff0ef          	jal	8000148a <exit>
  if(which_dev == 2)
    80001ac6:	4789                	li	a5,2
    80001ac8:	04f90563          	beq	s2,a5,80001b12 <usertrap+0xd2>
  usertrapret();
    80001acc:	e1bff0ef          	jal	800018e6 <usertrapret>
}
    80001ad0:	60e2                	ld	ra,24(sp)
    80001ad2:	6442                	ld	s0,16(sp)
    80001ad4:	64a2                	ld	s1,8(sp)
    80001ad6:	6902                	ld	s2,0(sp)
    80001ad8:	6105                	addi	sp,sp,32
    80001ada:	8082                	ret
      exit(-1);
    80001adc:	557d                	li	a0,-1
    80001ade:	9adff0ef          	jal	8000148a <exit>
    80001ae2:	bf75                	j	80001a9e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ae4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001ae8:	5890                	lw	a2,48(s1)
    80001aea:	00005517          	auipc	a0,0x5
    80001aee:	7e650513          	addi	a0,a0,2022 # 800072d0 <etext+0x2d0>
    80001af2:	00f030ef          	jal	80005300 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001af6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001afa:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001afe:	00006517          	auipc	a0,0x6
    80001b02:	80250513          	addi	a0,a0,-2046 # 80007300 <etext+0x300>
    80001b06:	7fa030ef          	jal	80005300 <printf>
    setkilled(p);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	a87ff0ef          	jal	80001592 <setkilled>
    80001b10:	b75d                	j	80001ab6 <usertrap+0x76>
    yield();
    80001b12:	841ff0ef          	jal	80001352 <yield>
    80001b16:	bf5d                	j	80001acc <usertrap+0x8c>

0000000080001b18 <kerneltrap>:
{
    80001b18:	7179                	addi	sp,sp,-48
    80001b1a:	f406                	sd	ra,40(sp)
    80001b1c:	f022                	sd	s0,32(sp)
    80001b1e:	ec26                	sd	s1,24(sp)
    80001b20:	e84a                	sd	s2,16(sp)
    80001b22:	e44e                	sd	s3,8(sp)
    80001b24:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b26:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b2a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b2e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b32:	1004f793          	andi	a5,s1,256
    80001b36:	c795                	beqz	a5,80001b62 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b38:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b3c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b3e:	eb85                	bnez	a5,80001b6e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b40:	e8dff0ef          	jal	800019cc <devintr>
    80001b44:	c91d                	beqz	a0,80001b7a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b46:	4789                	li	a5,2
    80001b48:	04f50a63          	beq	a0,a5,80001b9c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b4c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b50:	10049073          	csrw	sstatus,s1
}
    80001b54:	70a2                	ld	ra,40(sp)
    80001b56:	7402                	ld	s0,32(sp)
    80001b58:	64e2                	ld	s1,24(sp)
    80001b5a:	6942                	ld	s2,16(sp)
    80001b5c:	69a2                	ld	s3,8(sp)
    80001b5e:	6145                	addi	sp,sp,48
    80001b60:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001b62:	00005517          	auipc	a0,0x5
    80001b66:	7c650513          	addi	a0,a0,1990 # 80007328 <etext+0x328>
    80001b6a:	269030ef          	jal	800055d2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001b6e:	00005517          	auipc	a0,0x5
    80001b72:	7e250513          	addi	a0,a0,2018 # 80007350 <etext+0x350>
    80001b76:	25d030ef          	jal	800055d2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b7a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b7e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001b82:	85ce                	mv	a1,s3
    80001b84:	00005517          	auipc	a0,0x5
    80001b88:	7ec50513          	addi	a0,a0,2028 # 80007370 <etext+0x370>
    80001b8c:	774030ef          	jal	80005300 <printf>
    panic("kerneltrap");
    80001b90:	00006517          	auipc	a0,0x6
    80001b94:	80850513          	addi	a0,a0,-2040 # 80007398 <etext+0x398>
    80001b98:	23b030ef          	jal	800055d2 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001b9c:	a0cff0ef          	jal	80000da8 <myproc>
    80001ba0:	d555                	beqz	a0,80001b4c <kerneltrap+0x34>
    yield();
    80001ba2:	fb0ff0ef          	jal	80001352 <yield>
    80001ba6:	b75d                	j	80001b4c <kerneltrap+0x34>

0000000080001ba8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	1000                	addi	s0,sp,32
    80001bb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bb4:	9f4ff0ef          	jal	80000da8 <myproc>
  switch (n) {
    80001bb8:	4795                	li	a5,5
    80001bba:	0497e163          	bltu	a5,s1,80001bfc <argraw+0x54>
    80001bbe:	048a                	slli	s1,s1,0x2
    80001bc0:	00006717          	auipc	a4,0x6
    80001bc4:	cd070713          	addi	a4,a4,-816 # 80007890 <states.0+0x30>
    80001bc8:	94ba                	add	s1,s1,a4
    80001bca:	409c                	lw	a5,0(s1)
    80001bcc:	97ba                	add	a5,a5,a4
    80001bce:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001bd0:	6d3c                	ld	a5,88(a0)
    80001bd2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6105                	addi	sp,sp,32
    80001bdc:	8082                	ret
    return p->trapframe->a1;
    80001bde:	6d3c                	ld	a5,88(a0)
    80001be0:	7fa8                	ld	a0,120(a5)
    80001be2:	bfcd                	j	80001bd4 <argraw+0x2c>
    return p->trapframe->a2;
    80001be4:	6d3c                	ld	a5,88(a0)
    80001be6:	63c8                	ld	a0,128(a5)
    80001be8:	b7f5                	j	80001bd4 <argraw+0x2c>
    return p->trapframe->a3;
    80001bea:	6d3c                	ld	a5,88(a0)
    80001bec:	67c8                	ld	a0,136(a5)
    80001bee:	b7dd                	j	80001bd4 <argraw+0x2c>
    return p->trapframe->a4;
    80001bf0:	6d3c                	ld	a5,88(a0)
    80001bf2:	6bc8                	ld	a0,144(a5)
    80001bf4:	b7c5                	j	80001bd4 <argraw+0x2c>
    return p->trapframe->a5;
    80001bf6:	6d3c                	ld	a5,88(a0)
    80001bf8:	6fc8                	ld	a0,152(a5)
    80001bfa:	bfe9                	j	80001bd4 <argraw+0x2c>
  panic("argraw");
    80001bfc:	00005517          	auipc	a0,0x5
    80001c00:	7ac50513          	addi	a0,a0,1964 # 800073a8 <etext+0x3a8>
    80001c04:	1cf030ef          	jal	800055d2 <panic>

0000000080001c08 <fetchaddr>:
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	e04a                	sd	s2,0(sp)
    80001c12:	1000                	addi	s0,sp,32
    80001c14:	84aa                	mv	s1,a0
    80001c16:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c18:	990ff0ef          	jal	80000da8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c1c:	653c                	ld	a5,72(a0)
    80001c1e:	02f4f663          	bgeu	s1,a5,80001c4a <fetchaddr+0x42>
    80001c22:	00848713          	addi	a4,s1,8
    80001c26:	02e7e463          	bltu	a5,a4,80001c4e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c2a:	46a1                	li	a3,8
    80001c2c:	8626                	mv	a2,s1
    80001c2e:	85ca                	mv	a1,s2
    80001c30:	6928                	ld	a0,80(a0)
    80001c32:	ebffe0ef          	jal	80000af0 <copyin>
    80001c36:	00a03533          	snez	a0,a0
    80001c3a:	40a00533          	neg	a0,a0
}
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6902                	ld	s2,0(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret
    return -1;
    80001c4a:	557d                	li	a0,-1
    80001c4c:	bfcd                	j	80001c3e <fetchaddr+0x36>
    80001c4e:	557d                	li	a0,-1
    80001c50:	b7fd                	j	80001c3e <fetchaddr+0x36>

0000000080001c52 <fetchstr>:
{
    80001c52:	7179                	addi	sp,sp,-48
    80001c54:	f406                	sd	ra,40(sp)
    80001c56:	f022                	sd	s0,32(sp)
    80001c58:	ec26                	sd	s1,24(sp)
    80001c5a:	e84a                	sd	s2,16(sp)
    80001c5c:	e44e                	sd	s3,8(sp)
    80001c5e:	1800                	addi	s0,sp,48
    80001c60:	892a                	mv	s2,a0
    80001c62:	84ae                	mv	s1,a1
    80001c64:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001c66:	942ff0ef          	jal	80000da8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001c6a:	86ce                	mv	a3,s3
    80001c6c:	864a                	mv	a2,s2
    80001c6e:	85a6                	mv	a1,s1
    80001c70:	6928                	ld	a0,80(a0)
    80001c72:	f05fe0ef          	jal	80000b76 <copyinstr>
    80001c76:	00054c63          	bltz	a0,80001c8e <fetchstr+0x3c>
  return strlen(buf);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	e84fe0ef          	jal	80000300 <strlen>
}
    80001c80:	70a2                	ld	ra,40(sp)
    80001c82:	7402                	ld	s0,32(sp)
    80001c84:	64e2                	ld	s1,24(sp)
    80001c86:	6942                	ld	s2,16(sp)
    80001c88:	69a2                	ld	s3,8(sp)
    80001c8a:	6145                	addi	sp,sp,48
    80001c8c:	8082                	ret
    return -1;
    80001c8e:	557d                	li	a0,-1
    80001c90:	bfc5                	j	80001c80 <fetchstr+0x2e>

0000000080001c92 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	1000                	addi	s0,sp,32
    80001c9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c9e:	f0bff0ef          	jal	80001ba8 <argraw>
    80001ca2:	c088                	sw	a0,0(s1)
}
    80001ca4:	60e2                	ld	ra,24(sp)
    80001ca6:	6442                	ld	s0,16(sp)
    80001ca8:	64a2                	ld	s1,8(sp)
    80001caa:	6105                	addi	sp,sp,32
    80001cac:	8082                	ret

0000000080001cae <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001cae:	1101                	addi	sp,sp,-32
    80001cb0:	ec06                	sd	ra,24(sp)
    80001cb2:	e822                	sd	s0,16(sp)
    80001cb4:	e426                	sd	s1,8(sp)
    80001cb6:	1000                	addi	s0,sp,32
    80001cb8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cba:	eefff0ef          	jal	80001ba8 <argraw>
    80001cbe:	e088                	sd	a0,0(s1)
}
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret

0000000080001cca <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001cca:	7179                	addi	sp,sp,-48
    80001ccc:	f406                	sd	ra,40(sp)
    80001cce:	f022                	sd	s0,32(sp)
    80001cd0:	ec26                	sd	s1,24(sp)
    80001cd2:	e84a                	sd	s2,16(sp)
    80001cd4:	1800                	addi	s0,sp,48
    80001cd6:	84ae                	mv	s1,a1
    80001cd8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001cda:	fd840593          	addi	a1,s0,-40
    80001cde:	fd1ff0ef          	jal	80001cae <argaddr>
  return fetchstr(addr, buf, max);
    80001ce2:	864a                	mv	a2,s2
    80001ce4:	85a6                	mv	a1,s1
    80001ce6:	fd843503          	ld	a0,-40(s0)
    80001cea:	f69ff0ef          	jal	80001c52 <fetchstr>
}
    80001cee:	70a2                	ld	ra,40(sp)
    80001cf0:	7402                	ld	s0,32(sp)
    80001cf2:	64e2                	ld	s1,24(sp)
    80001cf4:	6942                	ld	s2,16(sp)
    80001cf6:	6145                	addi	sp,sp,48
    80001cf8:	8082                	ret

0000000080001cfa <syscall>:
  [SYS_sysinfo] "sysinfo",
};

void
syscall(void)
{
    80001cfa:	7179                	addi	sp,sp,-48
    80001cfc:	f406                	sd	ra,40(sp)
    80001cfe:	f022                	sd	s0,32(sp)
    80001d00:	ec26                	sd	s1,24(sp)
    80001d02:	e84a                	sd	s2,16(sp)
    80001d04:	e44e                	sd	s3,8(sp)
    80001d06:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80001d08:	8a0ff0ef          	jal	80000da8 <myproc>
    80001d0c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d0e:	05853903          	ld	s2,88(a0)
    80001d12:	0a893783          	ld	a5,168(s2)
    80001d16:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d1a:	37fd                	addiw	a5,a5,-1
    80001d1c:	4761                	li	a4,24
    80001d1e:	04f76563          	bltu	a4,a5,80001d68 <syscall+0x6e>
    80001d22:	00399713          	slli	a4,s3,0x3
    80001d26:	00006797          	auipc	a5,0x6
    80001d2a:	b8278793          	addi	a5,a5,-1150 # 800078a8 <syscalls>
    80001d2e:	97ba                	add	a5,a5,a4
    80001d30:	639c                	ld	a5,0(a5)
    80001d32:	cb9d                	beqz	a5,80001d68 <syscall+0x6e>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001d34:	9782                	jalr	a5
    80001d36:	06a93823          	sd	a0,112(s2)

    if (p->trace_mask & (1 << num)) {
    80001d3a:	1684a783          	lw	a5,360(s1)
    80001d3e:	4137d7bb          	sraw	a5,a5,s3
    80001d42:	8b85                	andi	a5,a5,1
    80001d44:	cf9d                	beqz	a5,80001d82 <syscall+0x88>
      printf("%d: syscall %s -> %ld\n", p->pid, syscall_names[num], p->trapframe->a0);
    80001d46:	6cb8                	ld	a4,88(s1)
    80001d48:	098e                	slli	s3,s3,0x3
    80001d4a:	00006797          	auipc	a5,0x6
    80001d4e:	b5e78793          	addi	a5,a5,-1186 # 800078a8 <syscalls>
    80001d52:	97ce                	add	a5,a5,s3
    80001d54:	7b34                	ld	a3,112(a4)
    80001d56:	6bf0                	ld	a2,208(a5)
    80001d58:	588c                	lw	a1,48(s1)
    80001d5a:	00005517          	auipc	a0,0x5
    80001d5e:	65650513          	addi	a0,a0,1622 # 800073b0 <etext+0x3b0>
    80001d62:	59e030ef          	jal	80005300 <printf>
    80001d66:	a831                	j	80001d82 <syscall+0x88>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001d68:	86ce                	mv	a3,s3
    80001d6a:	15848613          	addi	a2,s1,344
    80001d6e:	588c                	lw	a1,48(s1)
    80001d70:	00005517          	auipc	a0,0x5
    80001d74:	65850513          	addi	a0,a0,1624 # 800073c8 <etext+0x3c8>
    80001d78:	588030ef          	jal	80005300 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001d7c:	6cbc                	ld	a5,88(s1)
    80001d7e:	577d                	li	a4,-1
    80001d80:	fbb8                	sd	a4,112(a5)
  }
}
    80001d82:	70a2                	ld	ra,40(sp)
    80001d84:	7402                	ld	s0,32(sp)
    80001d86:	64e2                	ld	s1,24(sp)
    80001d88:	6942                	ld	s2,16(sp)
    80001d8a:	69a2                	ld	s3,8(sp)
    80001d8c:	6145                	addi	sp,sp,48
    80001d8e:	8082                	ret

0000000080001d90 <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80001d90:	1101                	addi	sp,sp,-32
    80001d92:	ec06                	sd	ra,24(sp)
    80001d94:	e822                	sd	s0,16(sp)
    80001d96:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001d98:	fec40593          	addi	a1,s0,-20
    80001d9c:	4501                	li	a0,0
    80001d9e:	ef5ff0ef          	jal	80001c92 <argint>
  exit(n);
    80001da2:	fec42503          	lw	a0,-20(s0)
    80001da6:	ee4ff0ef          	jal	8000148a <exit>
  return 0;  // not reached
}
    80001daa:	4501                	li	a0,0
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret

0000000080001db4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001db4:	1141                	addi	sp,sp,-16
    80001db6:	e406                	sd	ra,8(sp)
    80001db8:	e022                	sd	s0,0(sp)
    80001dba:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001dbc:	fedfe0ef          	jal	80000da8 <myproc>
}
    80001dc0:	5908                	lw	a0,48(a0)
    80001dc2:	60a2                	ld	ra,8(sp)
    80001dc4:	6402                	ld	s0,0(sp)
    80001dc6:	0141                	addi	sp,sp,16
    80001dc8:	8082                	ret

0000000080001dca <sys_fork>:

uint64
sys_fork(void)
{
    80001dca:	1141                	addi	sp,sp,-16
    80001dcc:	e406                	sd	ra,8(sp)
    80001dce:	e022                	sd	s0,0(sp)
    80001dd0:	0800                	addi	s0,sp,16
  return fork();
    80001dd2:	afcff0ef          	jal	800010ce <fork>
}
    80001dd6:	60a2                	ld	ra,8(sp)
    80001dd8:	6402                	ld	s0,0(sp)
    80001dda:	0141                	addi	sp,sp,16
    80001ddc:	8082                	ret

0000000080001dde <sys_wait>:

uint64
sys_wait(void)
{
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001de6:	fe840593          	addi	a1,s0,-24
    80001dea:	4501                	li	a0,0
    80001dec:	ec3ff0ef          	jal	80001cae <argaddr>
  return wait(p);
    80001df0:	fe843503          	ld	a0,-24(s0)
    80001df4:	fecff0ef          	jal	800015e0 <wait>
}
    80001df8:	60e2                	ld	ra,24(sp)
    80001dfa:	6442                	ld	s0,16(sp)
    80001dfc:	6105                	addi	sp,sp,32
    80001dfe:	8082                	ret

0000000080001e00 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001e00:	7179                	addi	sp,sp,-48
    80001e02:	f406                	sd	ra,40(sp)
    80001e04:	f022                	sd	s0,32(sp)
    80001e06:	ec26                	sd	s1,24(sp)
    80001e08:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001e0a:	fdc40593          	addi	a1,s0,-36
    80001e0e:	4501                	li	a0,0
    80001e10:	e83ff0ef          	jal	80001c92 <argint>
  addr = myproc()->sz;
    80001e14:	f95fe0ef          	jal	80000da8 <myproc>
    80001e18:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001e1a:	fdc42503          	lw	a0,-36(s0)
    80001e1e:	a60ff0ef          	jal	8000107e <growproc>
    80001e22:	00054863          	bltz	a0,80001e32 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001e26:	8526                	mv	a0,s1
    80001e28:	70a2                	ld	ra,40(sp)
    80001e2a:	7402                	ld	s0,32(sp)
    80001e2c:	64e2                	ld	s1,24(sp)
    80001e2e:	6145                	addi	sp,sp,48
    80001e30:	8082                	ret
    return -1;
    80001e32:	54fd                	li	s1,-1
    80001e34:	bfcd                	j	80001e26 <sys_sbrk+0x26>

0000000080001e36 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001e36:	7139                	addi	sp,sp,-64
    80001e38:	fc06                	sd	ra,56(sp)
    80001e3a:	f822                	sd	s0,48(sp)
    80001e3c:	f04a                	sd	s2,32(sp)
    80001e3e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001e40:	fcc40593          	addi	a1,s0,-52
    80001e44:	4501                	li	a0,0
    80001e46:	e4dff0ef          	jal	80001c92 <argint>
  if(n < 0)
    80001e4a:	fcc42783          	lw	a5,-52(s0)
    80001e4e:	0607c763          	bltz	a5,80001ebc <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001e52:	0000e517          	auipc	a0,0xe
    80001e56:	71e50513          	addi	a0,a0,1822 # 80010570 <tickslock>
    80001e5a:	2a7030ef          	jal	80005900 <acquire>
  ticks0 = ticks;
    80001e5e:	00008917          	auipc	s2,0x8
    80001e62:	6aa92903          	lw	s2,1706(s2) # 8000a508 <ticks>
  while(ticks - ticks0 < n){
    80001e66:	fcc42783          	lw	a5,-52(s0)
    80001e6a:	cf8d                	beqz	a5,80001ea4 <sys_sleep+0x6e>
    80001e6c:	f426                	sd	s1,40(sp)
    80001e6e:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001e70:	0000e997          	auipc	s3,0xe
    80001e74:	70098993          	addi	s3,s3,1792 # 80010570 <tickslock>
    80001e78:	00008497          	auipc	s1,0x8
    80001e7c:	69048493          	addi	s1,s1,1680 # 8000a508 <ticks>
    if(killed(myproc())){
    80001e80:	f29fe0ef          	jal	80000da8 <myproc>
    80001e84:	f32ff0ef          	jal	800015b6 <killed>
    80001e88:	ed0d                	bnez	a0,80001ec2 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001e8a:	85ce                	mv	a1,s3
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	cf0ff0ef          	jal	8000137e <sleep>
  while(ticks - ticks0 < n){
    80001e92:	409c                	lw	a5,0(s1)
    80001e94:	412787bb          	subw	a5,a5,s2
    80001e98:	fcc42703          	lw	a4,-52(s0)
    80001e9c:	fee7e2e3          	bltu	a5,a4,80001e80 <sys_sleep+0x4a>
    80001ea0:	74a2                	ld	s1,40(sp)
    80001ea2:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001ea4:	0000e517          	auipc	a0,0xe
    80001ea8:	6cc50513          	addi	a0,a0,1740 # 80010570 <tickslock>
    80001eac:	2ed030ef          	jal	80005998 <release>
  return 0;
    80001eb0:	4501                	li	a0,0
}
    80001eb2:	70e2                	ld	ra,56(sp)
    80001eb4:	7442                	ld	s0,48(sp)
    80001eb6:	7902                	ld	s2,32(sp)
    80001eb8:	6121                	addi	sp,sp,64
    80001eba:	8082                	ret
    n = 0;
    80001ebc:	fc042623          	sw	zero,-52(s0)
    80001ec0:	bf49                	j	80001e52 <sys_sleep+0x1c>
      release(&tickslock);
    80001ec2:	0000e517          	auipc	a0,0xe
    80001ec6:	6ae50513          	addi	a0,a0,1710 # 80010570 <tickslock>
    80001eca:	2cf030ef          	jal	80005998 <release>
      return -1;
    80001ece:	557d                	li	a0,-1
    80001ed0:	74a2                	ld	s1,40(sp)
    80001ed2:	69e2                	ld	s3,24(sp)
    80001ed4:	bff9                	j	80001eb2 <sys_sleep+0x7c>

0000000080001ed6 <sys_kill>:

uint64
sys_kill(void)
{
    80001ed6:	1101                	addi	sp,sp,-32
    80001ed8:	ec06                	sd	ra,24(sp)
    80001eda:	e822                	sd	s0,16(sp)
    80001edc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001ede:	fec40593          	addi	a1,s0,-20
    80001ee2:	4501                	li	a0,0
    80001ee4:	dafff0ef          	jal	80001c92 <argint>
  return kill(pid);
    80001ee8:	fec42503          	lw	a0,-20(s0)
    80001eec:	e40ff0ef          	jal	8000152c <kill>
}
    80001ef0:	60e2                	ld	ra,24(sp)
    80001ef2:	6442                	ld	s0,16(sp)
    80001ef4:	6105                	addi	sp,sp,32
    80001ef6:	8082                	ret

0000000080001ef8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001ef8:	1101                	addi	sp,sp,-32
    80001efa:	ec06                	sd	ra,24(sp)
    80001efc:	e822                	sd	s0,16(sp)
    80001efe:	e426                	sd	s1,8(sp)
    80001f00:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001f02:	0000e517          	auipc	a0,0xe
    80001f06:	66e50513          	addi	a0,a0,1646 # 80010570 <tickslock>
    80001f0a:	1f7030ef          	jal	80005900 <acquire>
  xticks = ticks;
    80001f0e:	00008497          	auipc	s1,0x8
    80001f12:	5fa4a483          	lw	s1,1530(s1) # 8000a508 <ticks>
  release(&tickslock);
    80001f16:	0000e517          	auipc	a0,0xe
    80001f1a:	65a50513          	addi	a0,a0,1626 # 80010570 <tickslock>
    80001f1e:	27b030ef          	jal	80005998 <release>
  return xticks;
}
    80001f22:	02049513          	slli	a0,s1,0x20
    80001f26:	9101                	srli	a0,a0,0x20
    80001f28:	60e2                	ld	ra,24(sp)
    80001f2a:	6442                	ld	s0,16(sp)
    80001f2c:	64a2                	ld	s1,8(sp)
    80001f2e:	6105                	addi	sp,sp,32
    80001f30:	8082                	ret

0000000080001f32 <sys_hello>:

uint64 sys_hello(void) {
    80001f32:	1141                	addi	sp,sp,-16
    80001f34:	e406                	sd	ra,8(sp)
    80001f36:	e022                	sd	s0,0(sp)
    80001f38:	0800                	addi	s0,sp,16
  printf("Hello, world!\n");
    80001f3a:	00005517          	auipc	a0,0x5
    80001f3e:	56e50513          	addi	a0,a0,1390 # 800074a8 <etext+0x4a8>
    80001f42:	3be030ef          	jal	80005300 <printf>
  return 0;
}
    80001f46:	4501                	li	a0,0
    80001f48:	60a2                	ld	ra,8(sp)
    80001f4a:	6402                	ld	s0,0(sp)
    80001f4c:	0141                	addi	sp,sp,16
    80001f4e:	8082                	ret

0000000080001f50 <sys_xv6>:

uint64 sys_xv6(void) {
    80001f50:	7179                	addi	sp,sp,-48
    80001f52:	f406                	sd	ra,40(sp)
    80001f54:	f022                	sd	s0,32(sp)
    80001f56:	1800                	addi	s0,sp,48
  int n;

  argint(0, &n);
    80001f58:	fdc40593          	addi	a1,s0,-36
    80001f5c:	4501                	li	a0,0
    80001f5e:	d35ff0ef          	jal	80001c92 <argint>

  for (int i = 0; i < n; i++){
    80001f62:	fdc42783          	lw	a5,-36(s0)
    80001f66:	02f05363          	blez	a5,80001f8c <sys_xv6+0x3c>
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	4481                	li	s1,0
    printf("Hello_xv6\n");
    80001f70:	00005917          	auipc	s2,0x5
    80001f74:	54890913          	addi	s2,s2,1352 # 800074b8 <etext+0x4b8>
    80001f78:	854a                	mv	a0,s2
    80001f7a:	386030ef          	jal	80005300 <printf>
  for (int i = 0; i < n; i++){
    80001f7e:	2485                	addiw	s1,s1,1
    80001f80:	fdc42783          	lw	a5,-36(s0)
    80001f84:	fef4cae3          	blt	s1,a5,80001f78 <sys_xv6+0x28>
    80001f88:	64e2                	ld	s1,24(sp)
    80001f8a:	6942                	ld	s2,16(sp)
  }
  return 0;
}
    80001f8c:	4501                	li	a0,0
    80001f8e:	70a2                	ld	ra,40(sp)
    80001f90:	7402                	ld	s0,32(sp)
    80001f92:	6145                	addi	sp,sp,48
    80001f94:	8082                	ret

0000000080001f96 <sys_trace>:


uint64 sys_trace(void) {
    80001f96:	1101                	addi	sp,sp,-32
    80001f98:	ec06                	sd	ra,24(sp)
    80001f9a:	e822                	sd	s0,16(sp)
    80001f9c:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80001f9e:	fec40593          	addi	a1,s0,-20
    80001fa2:	4501                	li	a0,0
    80001fa4:	cefff0ef          	jal	80001c92 <argint>
  struct proc *p = myproc();
    80001fa8:	e01fe0ef          	jal	80000da8 <myproc>
  p->trace_mask = mask;
    80001fac:	fec42783          	lw	a5,-20(s0)
    80001fb0:	16f52423          	sw	a5,360(a0)
  return 0;
}
    80001fb4:	4501                	li	a0,0
    80001fb6:	60e2                	ld	ra,24(sp)
    80001fb8:	6442                	ld	s0,16(sp)
    80001fba:	6105                	addi	sp,sp,32
    80001fbc:	8082                	ret

0000000080001fbe <sys_sysinfo>:

uint64 sys_sysinfo(void) {
    80001fbe:	7139                	addi	sp,sp,-64
    80001fc0:	fc06                	sd	ra,56(sp)
    80001fc2:	f822                	sd	s0,48(sp)
    80001fc4:	f426                	sd	s1,40(sp)
    80001fc6:	0080                	addi	s0,sp,64
  struct sysinfo info;
  struct proc *p = myproc();
    80001fc8:	de1fe0ef          	jal	80000da8 <myproc>
    80001fcc:	84aa                	mv	s1,a0
  uint64 addr;

  argaddr(0, &addr);
    80001fce:	fc040593          	addi	a1,s0,-64
    80001fd2:	4501                	li	a0,0
    80001fd4:	cdbff0ef          	jal	80001cae <argaddr>

  info.freemem = kfree_memsize();
    80001fd8:	976fe0ef          	jal	8000014e <kfree_memsize>
    80001fdc:	fca43423          	sd	a0,-56(s0)
  info.nproc = count_active_processes();
    80001fe0:	833ff0ef          	jal	80001812 <count_active_processes>
    80001fe4:	fca43823          	sd	a0,-48(s0)
  info.nopenfiles = count_open_files();
    80001fe8:	79c010ef          	jal	80003784 <count_open_files>
    80001fec:	fca43c23          	sd	a0,-40(s0)

  if (copyout(p->pagetable, addr, (char*)&info, sizeof(info)) < 0) {
    80001ff0:	46e1                	li	a3,24
    80001ff2:	fc840613          	addi	a2,s0,-56
    80001ff6:	fc043583          	ld	a1,-64(s0)
    80001ffa:	68a8                	ld	a0,80(s1)
    80001ffc:	a1ffe0ef          	jal	80000a1a <copyout>
    return -1;
  }

  return 0;
    80002000:	957d                	srai	a0,a0,0x3f
    80002002:	70e2                	ld	ra,56(sp)
    80002004:	7442                	ld	s0,48(sp)
    80002006:	74a2                	ld	s1,40(sp)
    80002008:	6121                	addi	sp,sp,64
    8000200a:	8082                	ret

000000008000200c <binit>:
} bcache;

//initialize cache 
void
binit(void)
{
    8000200c:	7179                	addi	sp,sp,-48
    8000200e:	f406                	sd	ra,40(sp)
    80002010:	f022                	sd	s0,32(sp)
    80002012:	ec26                	sd	s1,24(sp)
    80002014:	e84a                	sd	s2,16(sp)
    80002016:	e44e                	sd	s3,8(sp)
    80002018:	e052                	sd	s4,0(sp)
    8000201a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache"); //initialize lock named "bcache"
    8000201c:	00005597          	auipc	a1,0x5
    80002020:	4ac58593          	addi	a1,a1,1196 # 800074c8 <etext+0x4c8>
    80002024:	0000e517          	auipc	a0,0xe
    80002028:	56450513          	addi	a0,a0,1380 # 80010588 <bcache>
    8000202c:	055030ef          	jal	80005880 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002030:	00016797          	auipc	a5,0x16
    80002034:	55878793          	addi	a5,a5,1368 # 80018588 <bcache+0x8000>
    80002038:	00016717          	auipc	a4,0x16
    8000203c:	7b870713          	addi	a4,a4,1976 # 800187f0 <bcache+0x8268>
    80002040:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002044:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002048:	0000e497          	auipc	s1,0xe
    8000204c:	55848493          	addi	s1,s1,1368 # 800105a0 <bcache+0x18>
    b->next = bcache.head.next;
    80002050:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002052:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80002054:	00005a17          	auipc	s4,0x5
    80002058:	47ca0a13          	addi	s4,s4,1148 # 800074d0 <etext+0x4d0>
    b->next = bcache.head.next;
    8000205c:	2b893783          	ld	a5,696(s2)
    80002060:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002062:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80002066:	85d2                	mv	a1,s4
    80002068:	01048513          	addi	a0,s1,16
    8000206c:	248010ef          	jal	800032b4 <initsleeplock>
    bcache.head.next->prev = b;
    80002070:	2b893783          	ld	a5,696(s2)
    80002074:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002076:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000207a:	45848493          	addi	s1,s1,1112
    8000207e:	fd349fe3          	bne	s1,s3,8000205c <binit+0x50>
  }
}
    80002082:	70a2                	ld	ra,40(sp)
    80002084:	7402                	ld	s0,32(sp)
    80002086:	64e2                	ld	s1,24(sp)
    80002088:	6942                	ld	s2,16(sp)
    8000208a:	69a2                	ld	s3,8(sp)
    8000208c:	6a02                	ld	s4,0(sp)
    8000208e:	6145                	addi	sp,sp,48
    80002090:	8082                	ret

0000000080002092 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002092:	7179                	addi	sp,sp,-48
    80002094:	f406                	sd	ra,40(sp)
    80002096:	f022                	sd	s0,32(sp)
    80002098:	ec26                	sd	s1,24(sp)
    8000209a:	e84a                	sd	s2,16(sp)
    8000209c:	e44e                	sd	s3,8(sp)
    8000209e:	1800                	addi	s0,sp,48
    800020a0:	892a                	mv	s2,a0
    800020a2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800020a4:	0000e517          	auipc	a0,0xe
    800020a8:	4e450513          	addi	a0,a0,1252 # 80010588 <bcache>
    800020ac:	055030ef          	jal	80005900 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800020b0:	00016497          	auipc	s1,0x16
    800020b4:	7904b483          	ld	s1,1936(s1) # 80018840 <bcache+0x82b8>
    800020b8:	00016797          	auipc	a5,0x16
    800020bc:	73878793          	addi	a5,a5,1848 # 800187f0 <bcache+0x8268>
    800020c0:	02f48b63          	beq	s1,a5,800020f6 <bread+0x64>
    800020c4:	873e                	mv	a4,a5
    800020c6:	a021                	j	800020ce <bread+0x3c>
    800020c8:	68a4                	ld	s1,80(s1)
    800020ca:	02e48663          	beq	s1,a4,800020f6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800020ce:	449c                	lw	a5,8(s1)
    800020d0:	ff279ce3          	bne	a5,s2,800020c8 <bread+0x36>
    800020d4:	44dc                	lw	a5,12(s1)
    800020d6:	ff3799e3          	bne	a5,s3,800020c8 <bread+0x36>
      b->refcnt++;
    800020da:	40bc                	lw	a5,64(s1)
    800020dc:	2785                	addiw	a5,a5,1
    800020de:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800020e0:	0000e517          	auipc	a0,0xe
    800020e4:	4a850513          	addi	a0,a0,1192 # 80010588 <bcache>
    800020e8:	0b1030ef          	jal	80005998 <release>
      acquiresleep(&b->lock);
    800020ec:	01048513          	addi	a0,s1,16
    800020f0:	1fa010ef          	jal	800032ea <acquiresleep>
      return b;
    800020f4:	a889                	j	80002146 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800020f6:	00016497          	auipc	s1,0x16
    800020fa:	7424b483          	ld	s1,1858(s1) # 80018838 <bcache+0x82b0>
    800020fe:	00016797          	auipc	a5,0x16
    80002102:	6f278793          	addi	a5,a5,1778 # 800187f0 <bcache+0x8268>
    80002106:	00f48863          	beq	s1,a5,80002116 <bread+0x84>
    8000210a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000210c:	40bc                	lw	a5,64(s1)
    8000210e:	cb91                	beqz	a5,80002122 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002110:	64a4                	ld	s1,72(s1)
    80002112:	fee49de3          	bne	s1,a4,8000210c <bread+0x7a>
  panic("bget: no buffers"); //if there are no available buffer call panic.
    80002116:	00005517          	auipc	a0,0x5
    8000211a:	3c250513          	addi	a0,a0,962 # 800074d8 <etext+0x4d8>
    8000211e:	4b4030ef          	jal	800055d2 <panic>
      b->dev = dev;
    80002122:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002126:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000212a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000212e:	4785                	li	a5,1
    80002130:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002132:	0000e517          	auipc	a0,0xe
    80002136:	45650513          	addi	a0,a0,1110 # 80010588 <bcache>
    8000213a:	05f030ef          	jal	80005998 <release>
      acquiresleep(&b->lock);
    8000213e:	01048513          	addi	a0,s1,16
    80002142:	1a8010ef          	jal	800032ea <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  //check if the data is valid or not
  if(!b->valid) {
    80002146:	409c                	lw	a5,0(s1)
    80002148:	cb89                	beqz	a5,8000215a <bread+0xc8>
    virtio_disk_rw(b, 0); //write data into buffer
    b->valid = 1;
  }
  return b;
}
    8000214a:	8526                	mv	a0,s1
    8000214c:	70a2                	ld	ra,40(sp)
    8000214e:	7402                	ld	s0,32(sp)
    80002150:	64e2                	ld	s1,24(sp)
    80002152:	6942                	ld	s2,16(sp)
    80002154:	69a2                	ld	s3,8(sp)
    80002156:	6145                	addi	sp,sp,48
    80002158:	8082                	ret
    virtio_disk_rw(b, 0); //write data into buffer
    8000215a:	4581                	li	a1,0
    8000215c:	8526                	mv	a0,s1
    8000215e:	243020ef          	jal	80004ba0 <virtio_disk_rw>
    b->valid = 1;
    80002162:	4785                	li	a5,1
    80002164:	c09c                	sw	a5,0(s1)
  return b;
    80002166:	b7d5                	j	8000214a <bread+0xb8>

0000000080002168 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Synchronize the contents of buffer b with the block on disk.
void
bwrite(struct buf *b)
{
    80002168:	1101                	addi	sp,sp,-32
    8000216a:	ec06                	sd	ra,24(sp)
    8000216c:	e822                	sd	s0,16(sp)
    8000216e:	e426                	sd	s1,8(sp)
    80002170:	1000                	addi	s0,sp,32
    80002172:	84aa                	mv	s1,a0
  //check if buffer is locked by instance process
  if(!holdingsleep(&b->lock))
    80002174:	0541                	addi	a0,a0,16
    80002176:	1f2010ef          	jal	80003368 <holdingsleep>
    8000217a:	c911                	beqz	a0,8000218e <bwrite+0x26>
    panic("bwrite"); //call panic
  virtio_disk_rw(b, 1); // write data into buffer
    8000217c:	4585                	li	a1,1
    8000217e:	8526                	mv	a0,s1
    80002180:	221020ef          	jal	80004ba0 <virtio_disk_rw>
}
    80002184:	60e2                	ld	ra,24(sp)
    80002186:	6442                	ld	s0,16(sp)
    80002188:	64a2                	ld	s1,8(sp)
    8000218a:	6105                	addi	sp,sp,32
    8000218c:	8082                	ret
    panic("bwrite"); //call panic
    8000218e:	00005517          	auipc	a0,0x5
    80002192:	36250513          	addi	a0,a0,866 # 800074f0 <etext+0x4f0>
    80002196:	43c030ef          	jal	800055d2 <panic>

000000008000219a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000219a:	1101                	addi	sp,sp,-32
    8000219c:	ec06                	sd	ra,24(sp)
    8000219e:	e822                	sd	s0,16(sp)
    800021a0:	e426                	sd	s1,8(sp)
    800021a2:	e04a                	sd	s2,0(sp)
    800021a4:	1000                	addi	s0,sp,32
    800021a6:	84aa                	mv	s1,a0
  //check if buffer is lock
  if(!holdingsleep(&b->lock))
    800021a8:	01050913          	addi	s2,a0,16
    800021ac:	854a                	mv	a0,s2
    800021ae:	1ba010ef          	jal	80003368 <holdingsleep>
    800021b2:	c135                	beqz	a0,80002216 <brelse+0x7c>
    panic("brelse"); // call panic
  //release lock buffer
  releasesleep(&b->lock);
    800021b4:	854a                	mv	a0,s2
    800021b6:	17a010ef          	jal	80003330 <releasesleep>

  //reduce refcnt
  acquire(&bcache.lock);
    800021ba:	0000e517          	auipc	a0,0xe
    800021be:	3ce50513          	addi	a0,a0,974 # 80010588 <bcache>
    800021c2:	73e030ef          	jal	80005900 <acquire>
  b->refcnt--;
    800021c6:	40bc                	lw	a5,64(s1)
    800021c8:	37fd                	addiw	a5,a5,-1
    800021ca:	0007871b          	sext.w	a4,a5
    800021ce:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800021d0:	e71d                	bnez	a4,800021fe <brelse+0x64>
    // no one is waiting for it and move it to LRU
    b->next->prev = b->prev;
    800021d2:	68b8                	ld	a4,80(s1)
    800021d4:	64bc                	ld	a5,72(s1)
    800021d6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800021d8:	68b8                	ld	a4,80(s1)
    800021da:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800021dc:	00016797          	auipc	a5,0x16
    800021e0:	3ac78793          	addi	a5,a5,940 # 80018588 <bcache+0x8000>
    800021e4:	2b87b703          	ld	a4,696(a5)
    800021e8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800021ea:	00016717          	auipc	a4,0x16
    800021ee:	60670713          	addi	a4,a4,1542 # 800187f0 <bcache+0x8268>
    800021f2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800021f4:	2b87b703          	ld	a4,696(a5)
    800021f8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800021fa:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800021fe:	0000e517          	auipc	a0,0xe
    80002202:	38a50513          	addi	a0,a0,906 # 80010588 <bcache>
    80002206:	792030ef          	jal	80005998 <release>
}
    8000220a:	60e2                	ld	ra,24(sp)
    8000220c:	6442                	ld	s0,16(sp)
    8000220e:	64a2                	ld	s1,8(sp)
    80002210:	6902                	ld	s2,0(sp)
    80002212:	6105                	addi	sp,sp,32
    80002214:	8082                	ret
    panic("brelse"); // call panic
    80002216:	00005517          	auipc	a0,0x5
    8000221a:	2e250513          	addi	a0,a0,738 # 800074f8 <etext+0x4f8>
    8000221e:	3b4030ef          	jal	800055d2 <panic>

0000000080002222 <bpin>:

//pin buffer to prevent buffer from reusing
void
bpin(struct buf *b) {
    80002222:	1101                	addi	sp,sp,-32
    80002224:	ec06                	sd	ra,24(sp)
    80002226:	e822                	sd	s0,16(sp)
    80002228:	e426                	sd	s1,8(sp)
    8000222a:	1000                	addi	s0,sp,32
    8000222c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000222e:	0000e517          	auipc	a0,0xe
    80002232:	35a50513          	addi	a0,a0,858 # 80010588 <bcache>
    80002236:	6ca030ef          	jal	80005900 <acquire>
  b->refcnt++;
    8000223a:	40bc                	lw	a5,64(s1)
    8000223c:	2785                	addiw	a5,a5,1
    8000223e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002240:	0000e517          	auipc	a0,0xe
    80002244:	34850513          	addi	a0,a0,840 # 80010588 <bcache>
    80002248:	750030ef          	jal	80005998 <release>
}
    8000224c:	60e2                	ld	ra,24(sp)
    8000224e:	6442                	ld	s0,16(sp)
    80002250:	64a2                	ld	s1,8(sp)
    80002252:	6105                	addi	sp,sp,32
    80002254:	8082                	ret

0000000080002256 <bunpin>:

//unpin buffer
void
bunpin(struct buf *b) {
    80002256:	1101                	addi	sp,sp,-32
    80002258:	ec06                	sd	ra,24(sp)
    8000225a:	e822                	sd	s0,16(sp)
    8000225c:	e426                	sd	s1,8(sp)
    8000225e:	1000                	addi	s0,sp,32
    80002260:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002262:	0000e517          	auipc	a0,0xe
    80002266:	32650513          	addi	a0,a0,806 # 80010588 <bcache>
    8000226a:	696030ef          	jal	80005900 <acquire>
  b->refcnt--;
    8000226e:	40bc                	lw	a5,64(s1)
    80002270:	37fd                	addiw	a5,a5,-1
    80002272:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002274:	0000e517          	auipc	a0,0xe
    80002278:	31450513          	addi	a0,a0,788 # 80010588 <bcache>
    8000227c:	71c030ef          	jal	80005998 <release>
}
    80002280:	60e2                	ld	ra,24(sp)
    80002282:	6442                	ld	s0,16(sp)
    80002284:	64a2                	ld	s1,8(sp)
    80002286:	6105                	addi	sp,sp,32
    80002288:	8082                	ret

000000008000228a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000228a:	1101                	addi	sp,sp,-32
    8000228c:	ec06                	sd	ra,24(sp)
    8000228e:	e822                	sd	s0,16(sp)
    80002290:	e426                	sd	s1,8(sp)
    80002292:	e04a                	sd	s2,0(sp)
    80002294:	1000                	addi	s0,sp,32
    80002296:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002298:	00d5d59b          	srliw	a1,a1,0xd
    8000229c:	00017797          	auipc	a5,0x17
    800022a0:	9c87a783          	lw	a5,-1592(a5) # 80018c64 <sb+0x1c>
    800022a4:	9dbd                	addw	a1,a1,a5
    800022a6:	dedff0ef          	jal	80002092 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800022aa:	0074f713          	andi	a4,s1,7
    800022ae:	4785                	li	a5,1
    800022b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800022b4:	14ce                	slli	s1,s1,0x33
    800022b6:	90d9                	srli	s1,s1,0x36
    800022b8:	00950733          	add	a4,a0,s1
    800022bc:	05874703          	lbu	a4,88(a4)
    800022c0:	00e7f6b3          	and	a3,a5,a4
    800022c4:	c29d                	beqz	a3,800022ea <bfree+0x60>
    800022c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800022c8:	94aa                	add	s1,s1,a0
    800022ca:	fff7c793          	not	a5,a5
    800022ce:	8f7d                	and	a4,a4,a5
    800022d0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800022d4:	711000ef          	jal	800031e4 <log_write>
  brelse(bp);
    800022d8:	854a                	mv	a0,s2
    800022da:	ec1ff0ef          	jal	8000219a <brelse>
}
    800022de:	60e2                	ld	ra,24(sp)
    800022e0:	6442                	ld	s0,16(sp)
    800022e2:	64a2                	ld	s1,8(sp)
    800022e4:	6902                	ld	s2,0(sp)
    800022e6:	6105                	addi	sp,sp,32
    800022e8:	8082                	ret
    panic("freeing free block");
    800022ea:	00005517          	auipc	a0,0x5
    800022ee:	21650513          	addi	a0,a0,534 # 80007500 <etext+0x500>
    800022f2:	2e0030ef          	jal	800055d2 <panic>

00000000800022f6 <balloc>:
{
    800022f6:	711d                	addi	sp,sp,-96
    800022f8:	ec86                	sd	ra,88(sp)
    800022fa:	e8a2                	sd	s0,80(sp)
    800022fc:	e4a6                	sd	s1,72(sp)
    800022fe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002300:	00017797          	auipc	a5,0x17
    80002304:	94c7a783          	lw	a5,-1716(a5) # 80018c4c <sb+0x4>
    80002308:	0e078f63          	beqz	a5,80002406 <balloc+0x110>
    8000230c:	e0ca                	sd	s2,64(sp)
    8000230e:	fc4e                	sd	s3,56(sp)
    80002310:	f852                	sd	s4,48(sp)
    80002312:	f456                	sd	s5,40(sp)
    80002314:	f05a                	sd	s6,32(sp)
    80002316:	ec5e                	sd	s7,24(sp)
    80002318:	e862                	sd	s8,16(sp)
    8000231a:	e466                	sd	s9,8(sp)
    8000231c:	8baa                	mv	s7,a0
    8000231e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002320:	00017b17          	auipc	s6,0x17
    80002324:	928b0b13          	addi	s6,s6,-1752 # 80018c48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002328:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000232a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000232c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000232e:	6c89                	lui	s9,0x2
    80002330:	a0b5                	j	8000239c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002332:	97ca                	add	a5,a5,s2
    80002334:	8e55                	or	a2,a2,a3
    80002336:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000233a:	854a                	mv	a0,s2
    8000233c:	6a9000ef          	jal	800031e4 <log_write>
        brelse(bp);
    80002340:	854a                	mv	a0,s2
    80002342:	e59ff0ef          	jal	8000219a <brelse>
  bp = bread(dev, bno);
    80002346:	85a6                	mv	a1,s1
    80002348:	855e                	mv	a0,s7
    8000234a:	d49ff0ef          	jal	80002092 <bread>
    8000234e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002350:	40000613          	li	a2,1024
    80002354:	4581                	li	a1,0
    80002356:	05850513          	addi	a0,a0,88
    8000235a:	e37fd0ef          	jal	80000190 <memset>
  log_write(bp);
    8000235e:	854a                	mv	a0,s2
    80002360:	685000ef          	jal	800031e4 <log_write>
  brelse(bp);
    80002364:	854a                	mv	a0,s2
    80002366:	e35ff0ef          	jal	8000219a <brelse>
}
    8000236a:	6906                	ld	s2,64(sp)
    8000236c:	79e2                	ld	s3,56(sp)
    8000236e:	7a42                	ld	s4,48(sp)
    80002370:	7aa2                	ld	s5,40(sp)
    80002372:	7b02                	ld	s6,32(sp)
    80002374:	6be2                	ld	s7,24(sp)
    80002376:	6c42                	ld	s8,16(sp)
    80002378:	6ca2                	ld	s9,8(sp)
}
    8000237a:	8526                	mv	a0,s1
    8000237c:	60e6                	ld	ra,88(sp)
    8000237e:	6446                	ld	s0,80(sp)
    80002380:	64a6                	ld	s1,72(sp)
    80002382:	6125                	addi	sp,sp,96
    80002384:	8082                	ret
    brelse(bp);
    80002386:	854a                	mv	a0,s2
    80002388:	e13ff0ef          	jal	8000219a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000238c:	015c87bb          	addw	a5,s9,s5
    80002390:	00078a9b          	sext.w	s5,a5
    80002394:	004b2703          	lw	a4,4(s6)
    80002398:	04eaff63          	bgeu	s5,a4,800023f6 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000239c:	41fad79b          	sraiw	a5,s5,0x1f
    800023a0:	0137d79b          	srliw	a5,a5,0x13
    800023a4:	015787bb          	addw	a5,a5,s5
    800023a8:	40d7d79b          	sraiw	a5,a5,0xd
    800023ac:	01cb2583          	lw	a1,28(s6)
    800023b0:	9dbd                	addw	a1,a1,a5
    800023b2:	855e                	mv	a0,s7
    800023b4:	cdfff0ef          	jal	80002092 <bread>
    800023b8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800023ba:	004b2503          	lw	a0,4(s6)
    800023be:	000a849b          	sext.w	s1,s5
    800023c2:	8762                	mv	a4,s8
    800023c4:	fca4f1e3          	bgeu	s1,a0,80002386 <balloc+0x90>
      m = 1 << (bi % 8);
    800023c8:	00777693          	andi	a3,a4,7
    800023cc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800023d0:	41f7579b          	sraiw	a5,a4,0x1f
    800023d4:	01d7d79b          	srliw	a5,a5,0x1d
    800023d8:	9fb9                	addw	a5,a5,a4
    800023da:	4037d79b          	sraiw	a5,a5,0x3
    800023de:	00f90633          	add	a2,s2,a5
    800023e2:	05864603          	lbu	a2,88(a2)
    800023e6:	00c6f5b3          	and	a1,a3,a2
    800023ea:	d5a1                	beqz	a1,80002332 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800023ec:	2705                	addiw	a4,a4,1
    800023ee:	2485                	addiw	s1,s1,1
    800023f0:	fd471ae3          	bne	a4,s4,800023c4 <balloc+0xce>
    800023f4:	bf49                	j	80002386 <balloc+0x90>
    800023f6:	6906                	ld	s2,64(sp)
    800023f8:	79e2                	ld	s3,56(sp)
    800023fa:	7a42                	ld	s4,48(sp)
    800023fc:	7aa2                	ld	s5,40(sp)
    800023fe:	7b02                	ld	s6,32(sp)
    80002400:	6be2                	ld	s7,24(sp)
    80002402:	6c42                	ld	s8,16(sp)
    80002404:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002406:	00005517          	auipc	a0,0x5
    8000240a:	11250513          	addi	a0,a0,274 # 80007518 <etext+0x518>
    8000240e:	6f3020ef          	jal	80005300 <printf>
  return 0;
    80002412:	4481                	li	s1,0
    80002414:	b79d                	j	8000237a <balloc+0x84>

0000000080002416 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002416:	7179                	addi	sp,sp,-48
    80002418:	f406                	sd	ra,40(sp)
    8000241a:	f022                	sd	s0,32(sp)
    8000241c:	ec26                	sd	s1,24(sp)
    8000241e:	e84a                	sd	s2,16(sp)
    80002420:	e44e                	sd	s3,8(sp)
    80002422:	1800                	addi	s0,sp,48
    80002424:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002426:	47ad                	li	a5,11
    80002428:	02b7e663          	bltu	a5,a1,80002454 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000242c:	02059793          	slli	a5,a1,0x20
    80002430:	01e7d593          	srli	a1,a5,0x1e
    80002434:	00b504b3          	add	s1,a0,a1
    80002438:	0504a903          	lw	s2,80(s1)
    8000243c:	06091a63          	bnez	s2,800024b0 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002440:	4108                	lw	a0,0(a0)
    80002442:	eb5ff0ef          	jal	800022f6 <balloc>
    80002446:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000244a:	06090363          	beqz	s2,800024b0 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000244e:	0524a823          	sw	s2,80(s1)
    80002452:	a8b9                	j	800024b0 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002454:	ff45849b          	addiw	s1,a1,-12
    80002458:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000245c:	0ff00793          	li	a5,255
    80002460:	06e7ee63          	bltu	a5,a4,800024dc <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002464:	08052903          	lw	s2,128(a0)
    80002468:	00091d63          	bnez	s2,80002482 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000246c:	4108                	lw	a0,0(a0)
    8000246e:	e89ff0ef          	jal	800022f6 <balloc>
    80002472:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002476:	02090d63          	beqz	s2,800024b0 <bmap+0x9a>
    8000247a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000247c:	0929a023          	sw	s2,128(s3)
    80002480:	a011                	j	80002484 <bmap+0x6e>
    80002482:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002484:	85ca                	mv	a1,s2
    80002486:	0009a503          	lw	a0,0(s3)
    8000248a:	c09ff0ef          	jal	80002092 <bread>
    8000248e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002490:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002494:	02049713          	slli	a4,s1,0x20
    80002498:	01e75593          	srli	a1,a4,0x1e
    8000249c:	00b784b3          	add	s1,a5,a1
    800024a0:	0004a903          	lw	s2,0(s1)
    800024a4:	00090e63          	beqz	s2,800024c0 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800024a8:	8552                	mv	a0,s4
    800024aa:	cf1ff0ef          	jal	8000219a <brelse>
    return addr;
    800024ae:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800024b0:	854a                	mv	a0,s2
    800024b2:	70a2                	ld	ra,40(sp)
    800024b4:	7402                	ld	s0,32(sp)
    800024b6:	64e2                	ld	s1,24(sp)
    800024b8:	6942                	ld	s2,16(sp)
    800024ba:	69a2                	ld	s3,8(sp)
    800024bc:	6145                	addi	sp,sp,48
    800024be:	8082                	ret
      addr = balloc(ip->dev);
    800024c0:	0009a503          	lw	a0,0(s3)
    800024c4:	e33ff0ef          	jal	800022f6 <balloc>
    800024c8:	0005091b          	sext.w	s2,a0
      if(addr){
    800024cc:	fc090ee3          	beqz	s2,800024a8 <bmap+0x92>
        a[bn] = addr;
    800024d0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800024d4:	8552                	mv	a0,s4
    800024d6:	50f000ef          	jal	800031e4 <log_write>
    800024da:	b7f9                	j	800024a8 <bmap+0x92>
    800024dc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800024de:	00005517          	auipc	a0,0x5
    800024e2:	05250513          	addi	a0,a0,82 # 80007530 <etext+0x530>
    800024e6:	0ec030ef          	jal	800055d2 <panic>

00000000800024ea <iget>:
{
    800024ea:	7179                	addi	sp,sp,-48
    800024ec:	f406                	sd	ra,40(sp)
    800024ee:	f022                	sd	s0,32(sp)
    800024f0:	ec26                	sd	s1,24(sp)
    800024f2:	e84a                	sd	s2,16(sp)
    800024f4:	e44e                	sd	s3,8(sp)
    800024f6:	e052                	sd	s4,0(sp)
    800024f8:	1800                	addi	s0,sp,48
    800024fa:	89aa                	mv	s3,a0
    800024fc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800024fe:	00016517          	auipc	a0,0x16
    80002502:	76a50513          	addi	a0,a0,1898 # 80018c68 <itable>
    80002506:	3fa030ef          	jal	80005900 <acquire>
  empty = 0;
    8000250a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000250c:	00016497          	auipc	s1,0x16
    80002510:	77448493          	addi	s1,s1,1908 # 80018c80 <itable+0x18>
    80002514:	00018697          	auipc	a3,0x18
    80002518:	1fc68693          	addi	a3,a3,508 # 8001a710 <log>
    8000251c:	a039                	j	8000252a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000251e:	02090963          	beqz	s2,80002550 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002522:	08848493          	addi	s1,s1,136
    80002526:	02d48863          	beq	s1,a3,80002556 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000252a:	449c                	lw	a5,8(s1)
    8000252c:	fef059e3          	blez	a5,8000251e <iget+0x34>
    80002530:	4098                	lw	a4,0(s1)
    80002532:	ff3716e3          	bne	a4,s3,8000251e <iget+0x34>
    80002536:	40d8                	lw	a4,4(s1)
    80002538:	ff4713e3          	bne	a4,s4,8000251e <iget+0x34>
      ip->ref++;
    8000253c:	2785                	addiw	a5,a5,1
    8000253e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002540:	00016517          	auipc	a0,0x16
    80002544:	72850513          	addi	a0,a0,1832 # 80018c68 <itable>
    80002548:	450030ef          	jal	80005998 <release>
      return ip;
    8000254c:	8926                	mv	s2,s1
    8000254e:	a02d                	j	80002578 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002550:	fbe9                	bnez	a5,80002522 <iget+0x38>
      empty = ip;
    80002552:	8926                	mv	s2,s1
    80002554:	b7f9                	j	80002522 <iget+0x38>
  if(empty == 0)
    80002556:	02090a63          	beqz	s2,8000258a <iget+0xa0>
  ip->dev = dev;
    8000255a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000255e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002562:	4785                	li	a5,1
    80002564:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002568:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000256c:	00016517          	auipc	a0,0x16
    80002570:	6fc50513          	addi	a0,a0,1788 # 80018c68 <itable>
    80002574:	424030ef          	jal	80005998 <release>
}
    80002578:	854a                	mv	a0,s2
    8000257a:	70a2                	ld	ra,40(sp)
    8000257c:	7402                	ld	s0,32(sp)
    8000257e:	64e2                	ld	s1,24(sp)
    80002580:	6942                	ld	s2,16(sp)
    80002582:	69a2                	ld	s3,8(sp)
    80002584:	6a02                	ld	s4,0(sp)
    80002586:	6145                	addi	sp,sp,48
    80002588:	8082                	ret
    panic("iget: no inodes");
    8000258a:	00005517          	auipc	a0,0x5
    8000258e:	fbe50513          	addi	a0,a0,-66 # 80007548 <etext+0x548>
    80002592:	040030ef          	jal	800055d2 <panic>

0000000080002596 <fsinit>:
fsinit(int dev) {
    80002596:	7179                	addi	sp,sp,-48
    80002598:	f406                	sd	ra,40(sp)
    8000259a:	f022                	sd	s0,32(sp)
    8000259c:	ec26                	sd	s1,24(sp)
    8000259e:	e84a                	sd	s2,16(sp)
    800025a0:	e44e                	sd	s3,8(sp)
    800025a2:	1800                	addi	s0,sp,48
    800025a4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800025a6:	4585                	li	a1,1
    800025a8:	aebff0ef          	jal	80002092 <bread>
    800025ac:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800025ae:	00016997          	auipc	s3,0x16
    800025b2:	69a98993          	addi	s3,s3,1690 # 80018c48 <sb>
    800025b6:	02000613          	li	a2,32
    800025ba:	05850593          	addi	a1,a0,88
    800025be:	854e                	mv	a0,s3
    800025c0:	c2dfd0ef          	jal	800001ec <memmove>
  brelse(bp);
    800025c4:	8526                	mv	a0,s1
    800025c6:	bd5ff0ef          	jal	8000219a <brelse>
  if(sb.magic != FSMAGIC)
    800025ca:	0009a703          	lw	a4,0(s3)
    800025ce:	102037b7          	lui	a5,0x10203
    800025d2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800025d6:	02f71063          	bne	a4,a5,800025f6 <fsinit+0x60>
  initlog(dev, &sb);
    800025da:	00016597          	auipc	a1,0x16
    800025de:	66e58593          	addi	a1,a1,1646 # 80018c48 <sb>
    800025e2:	854a                	mv	a0,s2
    800025e4:	1f9000ef          	jal	80002fdc <initlog>
}
    800025e8:	70a2                	ld	ra,40(sp)
    800025ea:	7402                	ld	s0,32(sp)
    800025ec:	64e2                	ld	s1,24(sp)
    800025ee:	6942                	ld	s2,16(sp)
    800025f0:	69a2                	ld	s3,8(sp)
    800025f2:	6145                	addi	sp,sp,48
    800025f4:	8082                	ret
    panic("invalid file system");
    800025f6:	00005517          	auipc	a0,0x5
    800025fa:	f6250513          	addi	a0,a0,-158 # 80007558 <etext+0x558>
    800025fe:	7d5020ef          	jal	800055d2 <panic>

0000000080002602 <iinit>:
{
    80002602:	7179                	addi	sp,sp,-48
    80002604:	f406                	sd	ra,40(sp)
    80002606:	f022                	sd	s0,32(sp)
    80002608:	ec26                	sd	s1,24(sp)
    8000260a:	e84a                	sd	s2,16(sp)
    8000260c:	e44e                	sd	s3,8(sp)
    8000260e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002610:	00005597          	auipc	a1,0x5
    80002614:	f6058593          	addi	a1,a1,-160 # 80007570 <etext+0x570>
    80002618:	00016517          	auipc	a0,0x16
    8000261c:	65050513          	addi	a0,a0,1616 # 80018c68 <itable>
    80002620:	260030ef          	jal	80005880 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002624:	00016497          	auipc	s1,0x16
    80002628:	66c48493          	addi	s1,s1,1644 # 80018c90 <itable+0x28>
    8000262c:	00018997          	auipc	s3,0x18
    80002630:	0f498993          	addi	s3,s3,244 # 8001a720 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002634:	00005917          	auipc	s2,0x5
    80002638:	f4490913          	addi	s2,s2,-188 # 80007578 <etext+0x578>
    8000263c:	85ca                	mv	a1,s2
    8000263e:	8526                	mv	a0,s1
    80002640:	475000ef          	jal	800032b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002644:	08848493          	addi	s1,s1,136
    80002648:	ff349ae3          	bne	s1,s3,8000263c <iinit+0x3a>
}
    8000264c:	70a2                	ld	ra,40(sp)
    8000264e:	7402                	ld	s0,32(sp)
    80002650:	64e2                	ld	s1,24(sp)
    80002652:	6942                	ld	s2,16(sp)
    80002654:	69a2                	ld	s3,8(sp)
    80002656:	6145                	addi	sp,sp,48
    80002658:	8082                	ret

000000008000265a <ialloc>:
{
    8000265a:	7139                	addi	sp,sp,-64
    8000265c:	fc06                	sd	ra,56(sp)
    8000265e:	f822                	sd	s0,48(sp)
    80002660:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002662:	00016717          	auipc	a4,0x16
    80002666:	5f272703          	lw	a4,1522(a4) # 80018c54 <sb+0xc>
    8000266a:	4785                	li	a5,1
    8000266c:	06e7f063          	bgeu	a5,a4,800026cc <ialloc+0x72>
    80002670:	f426                	sd	s1,40(sp)
    80002672:	f04a                	sd	s2,32(sp)
    80002674:	ec4e                	sd	s3,24(sp)
    80002676:	e852                	sd	s4,16(sp)
    80002678:	e456                	sd	s5,8(sp)
    8000267a:	e05a                	sd	s6,0(sp)
    8000267c:	8aaa                	mv	s5,a0
    8000267e:	8b2e                	mv	s6,a1
    80002680:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002682:	00016a17          	auipc	s4,0x16
    80002686:	5c6a0a13          	addi	s4,s4,1478 # 80018c48 <sb>
    8000268a:	00495593          	srli	a1,s2,0x4
    8000268e:	018a2783          	lw	a5,24(s4)
    80002692:	9dbd                	addw	a1,a1,a5
    80002694:	8556                	mv	a0,s5
    80002696:	9fdff0ef          	jal	80002092 <bread>
    8000269a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000269c:	05850993          	addi	s3,a0,88
    800026a0:	00f97793          	andi	a5,s2,15
    800026a4:	079a                	slli	a5,a5,0x6
    800026a6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800026a8:	00099783          	lh	a5,0(s3)
    800026ac:	cb9d                	beqz	a5,800026e2 <ialloc+0x88>
    brelse(bp);
    800026ae:	aedff0ef          	jal	8000219a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800026b2:	0905                	addi	s2,s2,1
    800026b4:	00ca2703          	lw	a4,12(s4)
    800026b8:	0009079b          	sext.w	a5,s2
    800026bc:	fce7e7e3          	bltu	a5,a4,8000268a <ialloc+0x30>
    800026c0:	74a2                	ld	s1,40(sp)
    800026c2:	7902                	ld	s2,32(sp)
    800026c4:	69e2                	ld	s3,24(sp)
    800026c6:	6a42                	ld	s4,16(sp)
    800026c8:	6aa2                	ld	s5,8(sp)
    800026ca:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	eb450513          	addi	a0,a0,-332 # 80007580 <etext+0x580>
    800026d4:	42d020ef          	jal	80005300 <printf>
  return 0;
    800026d8:	4501                	li	a0,0
}
    800026da:	70e2                	ld	ra,56(sp)
    800026dc:	7442                	ld	s0,48(sp)
    800026de:	6121                	addi	sp,sp,64
    800026e0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800026e2:	04000613          	li	a2,64
    800026e6:	4581                	li	a1,0
    800026e8:	854e                	mv	a0,s3
    800026ea:	aa7fd0ef          	jal	80000190 <memset>
      dip->type = type;
    800026ee:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800026f2:	8526                	mv	a0,s1
    800026f4:	2f1000ef          	jal	800031e4 <log_write>
      brelse(bp);
    800026f8:	8526                	mv	a0,s1
    800026fa:	aa1ff0ef          	jal	8000219a <brelse>
      return iget(dev, inum);
    800026fe:	0009059b          	sext.w	a1,s2
    80002702:	8556                	mv	a0,s5
    80002704:	de7ff0ef          	jal	800024ea <iget>
    80002708:	74a2                	ld	s1,40(sp)
    8000270a:	7902                	ld	s2,32(sp)
    8000270c:	69e2                	ld	s3,24(sp)
    8000270e:	6a42                	ld	s4,16(sp)
    80002710:	6aa2                	ld	s5,8(sp)
    80002712:	6b02                	ld	s6,0(sp)
    80002714:	b7d9                	j	800026da <ialloc+0x80>

0000000080002716 <iupdate>:
{
    80002716:	1101                	addi	sp,sp,-32
    80002718:	ec06                	sd	ra,24(sp)
    8000271a:	e822                	sd	s0,16(sp)
    8000271c:	e426                	sd	s1,8(sp)
    8000271e:	e04a                	sd	s2,0(sp)
    80002720:	1000                	addi	s0,sp,32
    80002722:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002724:	415c                	lw	a5,4(a0)
    80002726:	0047d79b          	srliw	a5,a5,0x4
    8000272a:	00016597          	auipc	a1,0x16
    8000272e:	5365a583          	lw	a1,1334(a1) # 80018c60 <sb+0x18>
    80002732:	9dbd                	addw	a1,a1,a5
    80002734:	4108                	lw	a0,0(a0)
    80002736:	95dff0ef          	jal	80002092 <bread>
    8000273a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000273c:	05850793          	addi	a5,a0,88
    80002740:	40d8                	lw	a4,4(s1)
    80002742:	8b3d                	andi	a4,a4,15
    80002744:	071a                	slli	a4,a4,0x6
    80002746:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002748:	04449703          	lh	a4,68(s1)
    8000274c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002750:	04649703          	lh	a4,70(s1)
    80002754:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002758:	04849703          	lh	a4,72(s1)
    8000275c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002760:	04a49703          	lh	a4,74(s1)
    80002764:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002768:	44f8                	lw	a4,76(s1)
    8000276a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000276c:	03400613          	li	a2,52
    80002770:	05048593          	addi	a1,s1,80
    80002774:	00c78513          	addi	a0,a5,12
    80002778:	a75fd0ef          	jal	800001ec <memmove>
  log_write(bp);
    8000277c:	854a                	mv	a0,s2
    8000277e:	267000ef          	jal	800031e4 <log_write>
  brelse(bp);
    80002782:	854a                	mv	a0,s2
    80002784:	a17ff0ef          	jal	8000219a <brelse>
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6902                	ld	s2,0(sp)
    80002790:	6105                	addi	sp,sp,32
    80002792:	8082                	ret

0000000080002794 <idup>:
{
    80002794:	1101                	addi	sp,sp,-32
    80002796:	ec06                	sd	ra,24(sp)
    80002798:	e822                	sd	s0,16(sp)
    8000279a:	e426                	sd	s1,8(sp)
    8000279c:	1000                	addi	s0,sp,32
    8000279e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800027a0:	00016517          	auipc	a0,0x16
    800027a4:	4c850513          	addi	a0,a0,1224 # 80018c68 <itable>
    800027a8:	158030ef          	jal	80005900 <acquire>
  ip->ref++;
    800027ac:	449c                	lw	a5,8(s1)
    800027ae:	2785                	addiw	a5,a5,1
    800027b0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800027b2:	00016517          	auipc	a0,0x16
    800027b6:	4b650513          	addi	a0,a0,1206 # 80018c68 <itable>
    800027ba:	1de030ef          	jal	80005998 <release>
}
    800027be:	8526                	mv	a0,s1
    800027c0:	60e2                	ld	ra,24(sp)
    800027c2:	6442                	ld	s0,16(sp)
    800027c4:	64a2                	ld	s1,8(sp)
    800027c6:	6105                	addi	sp,sp,32
    800027c8:	8082                	ret

00000000800027ca <ilock>:
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	e426                	sd	s1,8(sp)
    800027d2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800027d4:	cd19                	beqz	a0,800027f2 <ilock+0x28>
    800027d6:	84aa                	mv	s1,a0
    800027d8:	451c                	lw	a5,8(a0)
    800027da:	00f05c63          	blez	a5,800027f2 <ilock+0x28>
  acquiresleep(&ip->lock);
    800027de:	0541                	addi	a0,a0,16
    800027e0:	30b000ef          	jal	800032ea <acquiresleep>
  if(ip->valid == 0){
    800027e4:	40bc                	lw	a5,64(s1)
    800027e6:	cf89                	beqz	a5,80002800 <ilock+0x36>
}
    800027e8:	60e2                	ld	ra,24(sp)
    800027ea:	6442                	ld	s0,16(sp)
    800027ec:	64a2                	ld	s1,8(sp)
    800027ee:	6105                	addi	sp,sp,32
    800027f0:	8082                	ret
    800027f2:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800027f4:	00005517          	auipc	a0,0x5
    800027f8:	da450513          	addi	a0,a0,-604 # 80007598 <etext+0x598>
    800027fc:	5d7020ef          	jal	800055d2 <panic>
    80002800:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002802:	40dc                	lw	a5,4(s1)
    80002804:	0047d79b          	srliw	a5,a5,0x4
    80002808:	00016597          	auipc	a1,0x16
    8000280c:	4585a583          	lw	a1,1112(a1) # 80018c60 <sb+0x18>
    80002810:	9dbd                	addw	a1,a1,a5
    80002812:	4088                	lw	a0,0(s1)
    80002814:	87fff0ef          	jal	80002092 <bread>
    80002818:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000281a:	05850593          	addi	a1,a0,88
    8000281e:	40dc                	lw	a5,4(s1)
    80002820:	8bbd                	andi	a5,a5,15
    80002822:	079a                	slli	a5,a5,0x6
    80002824:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002826:	00059783          	lh	a5,0(a1)
    8000282a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000282e:	00259783          	lh	a5,2(a1)
    80002832:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002836:	00459783          	lh	a5,4(a1)
    8000283a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000283e:	00659783          	lh	a5,6(a1)
    80002842:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002846:	459c                	lw	a5,8(a1)
    80002848:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000284a:	03400613          	li	a2,52
    8000284e:	05b1                	addi	a1,a1,12
    80002850:	05048513          	addi	a0,s1,80
    80002854:	999fd0ef          	jal	800001ec <memmove>
    brelse(bp);
    80002858:	854a                	mv	a0,s2
    8000285a:	941ff0ef          	jal	8000219a <brelse>
    ip->valid = 1;
    8000285e:	4785                	li	a5,1
    80002860:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002862:	04449783          	lh	a5,68(s1)
    80002866:	c399                	beqz	a5,8000286c <ilock+0xa2>
    80002868:	6902                	ld	s2,0(sp)
    8000286a:	bfbd                	j	800027e8 <ilock+0x1e>
      panic("ilock: no type");
    8000286c:	00005517          	auipc	a0,0x5
    80002870:	d3450513          	addi	a0,a0,-716 # 800075a0 <etext+0x5a0>
    80002874:	55f020ef          	jal	800055d2 <panic>

0000000080002878 <iunlock>:
{
    80002878:	1101                	addi	sp,sp,-32
    8000287a:	ec06                	sd	ra,24(sp)
    8000287c:	e822                	sd	s0,16(sp)
    8000287e:	e426                	sd	s1,8(sp)
    80002880:	e04a                	sd	s2,0(sp)
    80002882:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002884:	c505                	beqz	a0,800028ac <iunlock+0x34>
    80002886:	84aa                	mv	s1,a0
    80002888:	01050913          	addi	s2,a0,16
    8000288c:	854a                	mv	a0,s2
    8000288e:	2db000ef          	jal	80003368 <holdingsleep>
    80002892:	cd09                	beqz	a0,800028ac <iunlock+0x34>
    80002894:	449c                	lw	a5,8(s1)
    80002896:	00f05b63          	blez	a5,800028ac <iunlock+0x34>
  releasesleep(&ip->lock);
    8000289a:	854a                	mv	a0,s2
    8000289c:	295000ef          	jal	80003330 <releasesleep>
}
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	64a2                	ld	s1,8(sp)
    800028a6:	6902                	ld	s2,0(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret
    panic("iunlock");
    800028ac:	00005517          	auipc	a0,0x5
    800028b0:	d0450513          	addi	a0,a0,-764 # 800075b0 <etext+0x5b0>
    800028b4:	51f020ef          	jal	800055d2 <panic>

00000000800028b8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800028b8:	7179                	addi	sp,sp,-48
    800028ba:	f406                	sd	ra,40(sp)
    800028bc:	f022                	sd	s0,32(sp)
    800028be:	ec26                	sd	s1,24(sp)
    800028c0:	e84a                	sd	s2,16(sp)
    800028c2:	e44e                	sd	s3,8(sp)
    800028c4:	1800                	addi	s0,sp,48
    800028c6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800028c8:	05050493          	addi	s1,a0,80
    800028cc:	08050913          	addi	s2,a0,128
    800028d0:	a021                	j	800028d8 <itrunc+0x20>
    800028d2:	0491                	addi	s1,s1,4
    800028d4:	01248b63          	beq	s1,s2,800028ea <itrunc+0x32>
    if(ip->addrs[i]){
    800028d8:	408c                	lw	a1,0(s1)
    800028da:	dde5                	beqz	a1,800028d2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800028dc:	0009a503          	lw	a0,0(s3)
    800028e0:	9abff0ef          	jal	8000228a <bfree>
      ip->addrs[i] = 0;
    800028e4:	0004a023          	sw	zero,0(s1)
    800028e8:	b7ed                	j	800028d2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800028ea:	0809a583          	lw	a1,128(s3)
    800028ee:	ed89                	bnez	a1,80002908 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800028f0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800028f4:	854e                	mv	a0,s3
    800028f6:	e21ff0ef          	jal	80002716 <iupdate>
}
    800028fa:	70a2                	ld	ra,40(sp)
    800028fc:	7402                	ld	s0,32(sp)
    800028fe:	64e2                	ld	s1,24(sp)
    80002900:	6942                	ld	s2,16(sp)
    80002902:	69a2                	ld	s3,8(sp)
    80002904:	6145                	addi	sp,sp,48
    80002906:	8082                	ret
    80002908:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000290a:	0009a503          	lw	a0,0(s3)
    8000290e:	f84ff0ef          	jal	80002092 <bread>
    80002912:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002914:	05850493          	addi	s1,a0,88
    80002918:	45850913          	addi	s2,a0,1112
    8000291c:	a021                	j	80002924 <itrunc+0x6c>
    8000291e:	0491                	addi	s1,s1,4
    80002920:	01248963          	beq	s1,s2,80002932 <itrunc+0x7a>
      if(a[j])
    80002924:	408c                	lw	a1,0(s1)
    80002926:	dde5                	beqz	a1,8000291e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002928:	0009a503          	lw	a0,0(s3)
    8000292c:	95fff0ef          	jal	8000228a <bfree>
    80002930:	b7fd                	j	8000291e <itrunc+0x66>
    brelse(bp);
    80002932:	8552                	mv	a0,s4
    80002934:	867ff0ef          	jal	8000219a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002938:	0809a583          	lw	a1,128(s3)
    8000293c:	0009a503          	lw	a0,0(s3)
    80002940:	94bff0ef          	jal	8000228a <bfree>
    ip->addrs[NDIRECT] = 0;
    80002944:	0809a023          	sw	zero,128(s3)
    80002948:	6a02                	ld	s4,0(sp)
    8000294a:	b75d                	j	800028f0 <itrunc+0x38>

000000008000294c <iput>:
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	1000                	addi	s0,sp,32
    80002956:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002958:	00016517          	auipc	a0,0x16
    8000295c:	31050513          	addi	a0,a0,784 # 80018c68 <itable>
    80002960:	7a1020ef          	jal	80005900 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002964:	4498                	lw	a4,8(s1)
    80002966:	4785                	li	a5,1
    80002968:	02f70063          	beq	a4,a5,80002988 <iput+0x3c>
  ip->ref--;
    8000296c:	449c                	lw	a5,8(s1)
    8000296e:	37fd                	addiw	a5,a5,-1
    80002970:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002972:	00016517          	auipc	a0,0x16
    80002976:	2f650513          	addi	a0,a0,758 # 80018c68 <itable>
    8000297a:	01e030ef          	jal	80005998 <release>
}
    8000297e:	60e2                	ld	ra,24(sp)
    80002980:	6442                	ld	s0,16(sp)
    80002982:	64a2                	ld	s1,8(sp)
    80002984:	6105                	addi	sp,sp,32
    80002986:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002988:	40bc                	lw	a5,64(s1)
    8000298a:	d3ed                	beqz	a5,8000296c <iput+0x20>
    8000298c:	04a49783          	lh	a5,74(s1)
    80002990:	fff1                	bnez	a5,8000296c <iput+0x20>
    80002992:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002994:	01048913          	addi	s2,s1,16
    80002998:	854a                	mv	a0,s2
    8000299a:	151000ef          	jal	800032ea <acquiresleep>
    release(&itable.lock);
    8000299e:	00016517          	auipc	a0,0x16
    800029a2:	2ca50513          	addi	a0,a0,714 # 80018c68 <itable>
    800029a6:	7f3020ef          	jal	80005998 <release>
    itrunc(ip);
    800029aa:	8526                	mv	a0,s1
    800029ac:	f0dff0ef          	jal	800028b8 <itrunc>
    ip->type = 0;
    800029b0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800029b4:	8526                	mv	a0,s1
    800029b6:	d61ff0ef          	jal	80002716 <iupdate>
    ip->valid = 0;
    800029ba:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800029be:	854a                	mv	a0,s2
    800029c0:	171000ef          	jal	80003330 <releasesleep>
    acquire(&itable.lock);
    800029c4:	00016517          	auipc	a0,0x16
    800029c8:	2a450513          	addi	a0,a0,676 # 80018c68 <itable>
    800029cc:	735020ef          	jal	80005900 <acquire>
    800029d0:	6902                	ld	s2,0(sp)
    800029d2:	bf69                	j	8000296c <iput+0x20>

00000000800029d4 <iunlockput>:
{
    800029d4:	1101                	addi	sp,sp,-32
    800029d6:	ec06                	sd	ra,24(sp)
    800029d8:	e822                	sd	s0,16(sp)
    800029da:	e426                	sd	s1,8(sp)
    800029dc:	1000                	addi	s0,sp,32
    800029de:	84aa                	mv	s1,a0
  iunlock(ip);
    800029e0:	e99ff0ef          	jal	80002878 <iunlock>
  iput(ip);
    800029e4:	8526                	mv	a0,s1
    800029e6:	f67ff0ef          	jal	8000294c <iput>
}
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800029f4:	1141                	addi	sp,sp,-16
    800029f6:	e422                	sd	s0,8(sp)
    800029f8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800029fa:	411c                	lw	a5,0(a0)
    800029fc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800029fe:	415c                	lw	a5,4(a0)
    80002a00:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002a02:	04451783          	lh	a5,68(a0)
    80002a06:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002a0a:	04a51783          	lh	a5,74(a0)
    80002a0e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002a12:	04c56783          	lwu	a5,76(a0)
    80002a16:	e99c                	sd	a5,16(a1)
}
    80002a18:	6422                	ld	s0,8(sp)
    80002a1a:	0141                	addi	sp,sp,16
    80002a1c:	8082                	ret

0000000080002a1e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a1e:	457c                	lw	a5,76(a0)
    80002a20:	0ed7eb63          	bltu	a5,a3,80002b16 <readi+0xf8>
{
    80002a24:	7159                	addi	sp,sp,-112
    80002a26:	f486                	sd	ra,104(sp)
    80002a28:	f0a2                	sd	s0,96(sp)
    80002a2a:	eca6                	sd	s1,88(sp)
    80002a2c:	e0d2                	sd	s4,64(sp)
    80002a2e:	fc56                	sd	s5,56(sp)
    80002a30:	f85a                	sd	s6,48(sp)
    80002a32:	f45e                	sd	s7,40(sp)
    80002a34:	1880                	addi	s0,sp,112
    80002a36:	8b2a                	mv	s6,a0
    80002a38:	8bae                	mv	s7,a1
    80002a3a:	8a32                	mv	s4,a2
    80002a3c:	84b6                	mv	s1,a3
    80002a3e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002a40:	9f35                	addw	a4,a4,a3
    return 0;
    80002a42:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002a44:	0cd76063          	bltu	a4,a3,80002b04 <readi+0xe6>
    80002a48:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002a4a:	00e7f463          	bgeu	a5,a4,80002a52 <readi+0x34>
    n = ip->size - off;
    80002a4e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a52:	080a8f63          	beqz	s5,80002af0 <readi+0xd2>
    80002a56:	e8ca                	sd	s2,80(sp)
    80002a58:	f062                	sd	s8,32(sp)
    80002a5a:	ec66                	sd	s9,24(sp)
    80002a5c:	e86a                	sd	s10,16(sp)
    80002a5e:	e46e                	sd	s11,8(sp)
    80002a60:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a62:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002a66:	5c7d                	li	s8,-1
    80002a68:	a80d                	j	80002a9a <readi+0x7c>
    80002a6a:	020d1d93          	slli	s11,s10,0x20
    80002a6e:	020ddd93          	srli	s11,s11,0x20
    80002a72:	05890613          	addi	a2,s2,88
    80002a76:	86ee                	mv	a3,s11
    80002a78:	963a                	add	a2,a2,a4
    80002a7a:	85d2                	mv	a1,s4
    80002a7c:	855e                	mv	a0,s7
    80002a7e:	c5dfe0ef          	jal	800016da <either_copyout>
    80002a82:	05850763          	beq	a0,s8,80002ad0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002a86:	854a                	mv	a0,s2
    80002a88:	f12ff0ef          	jal	8000219a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a8c:	013d09bb          	addw	s3,s10,s3
    80002a90:	009d04bb          	addw	s1,s10,s1
    80002a94:	9a6e                	add	s4,s4,s11
    80002a96:	0559f763          	bgeu	s3,s5,80002ae4 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002a9a:	00a4d59b          	srliw	a1,s1,0xa
    80002a9e:	855a                	mv	a0,s6
    80002aa0:	977ff0ef          	jal	80002416 <bmap>
    80002aa4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002aa8:	c5b1                	beqz	a1,80002af4 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002aaa:	000b2503          	lw	a0,0(s6)
    80002aae:	de4ff0ef          	jal	80002092 <bread>
    80002ab2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ab4:	3ff4f713          	andi	a4,s1,1023
    80002ab8:	40ec87bb          	subw	a5,s9,a4
    80002abc:	413a86bb          	subw	a3,s5,s3
    80002ac0:	8d3e                	mv	s10,a5
    80002ac2:	2781                	sext.w	a5,a5
    80002ac4:	0006861b          	sext.w	a2,a3
    80002ac8:	faf671e3          	bgeu	a2,a5,80002a6a <readi+0x4c>
    80002acc:	8d36                	mv	s10,a3
    80002ace:	bf71                	j	80002a6a <readi+0x4c>
      brelse(bp);
    80002ad0:	854a                	mv	a0,s2
    80002ad2:	ec8ff0ef          	jal	8000219a <brelse>
      tot = -1;
    80002ad6:	59fd                	li	s3,-1
      break;
    80002ad8:	6946                	ld	s2,80(sp)
    80002ada:	7c02                	ld	s8,32(sp)
    80002adc:	6ce2                	ld	s9,24(sp)
    80002ade:	6d42                	ld	s10,16(sp)
    80002ae0:	6da2                	ld	s11,8(sp)
    80002ae2:	a831                	j	80002afe <readi+0xe0>
    80002ae4:	6946                	ld	s2,80(sp)
    80002ae6:	7c02                	ld	s8,32(sp)
    80002ae8:	6ce2                	ld	s9,24(sp)
    80002aea:	6d42                	ld	s10,16(sp)
    80002aec:	6da2                	ld	s11,8(sp)
    80002aee:	a801                	j	80002afe <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002af0:	89d6                	mv	s3,s5
    80002af2:	a031                	j	80002afe <readi+0xe0>
    80002af4:	6946                	ld	s2,80(sp)
    80002af6:	7c02                	ld	s8,32(sp)
    80002af8:	6ce2                	ld	s9,24(sp)
    80002afa:	6d42                	ld	s10,16(sp)
    80002afc:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002afe:	0009851b          	sext.w	a0,s3
    80002b02:	69a6                	ld	s3,72(sp)
}
    80002b04:	70a6                	ld	ra,104(sp)
    80002b06:	7406                	ld	s0,96(sp)
    80002b08:	64e6                	ld	s1,88(sp)
    80002b0a:	6a06                	ld	s4,64(sp)
    80002b0c:	7ae2                	ld	s5,56(sp)
    80002b0e:	7b42                	ld	s6,48(sp)
    80002b10:	7ba2                	ld	s7,40(sp)
    80002b12:	6165                	addi	sp,sp,112
    80002b14:	8082                	ret
    return 0;
    80002b16:	4501                	li	a0,0
}
    80002b18:	8082                	ret

0000000080002b1a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b1a:	457c                	lw	a5,76(a0)
    80002b1c:	10d7e063          	bltu	a5,a3,80002c1c <writei+0x102>
{
    80002b20:	7159                	addi	sp,sp,-112
    80002b22:	f486                	sd	ra,104(sp)
    80002b24:	f0a2                	sd	s0,96(sp)
    80002b26:	e8ca                	sd	s2,80(sp)
    80002b28:	e0d2                	sd	s4,64(sp)
    80002b2a:	fc56                	sd	s5,56(sp)
    80002b2c:	f85a                	sd	s6,48(sp)
    80002b2e:	f45e                	sd	s7,40(sp)
    80002b30:	1880                	addi	s0,sp,112
    80002b32:	8aaa                	mv	s5,a0
    80002b34:	8bae                	mv	s7,a1
    80002b36:	8a32                	mv	s4,a2
    80002b38:	8936                	mv	s2,a3
    80002b3a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002b3c:	00e687bb          	addw	a5,a3,a4
    80002b40:	0ed7e063          	bltu	a5,a3,80002c20 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002b44:	00043737          	lui	a4,0x43
    80002b48:	0cf76e63          	bltu	a4,a5,80002c24 <writei+0x10a>
    80002b4c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b4e:	0a0b0f63          	beqz	s6,80002c0c <writei+0xf2>
    80002b52:	eca6                	sd	s1,88(sp)
    80002b54:	f062                	sd	s8,32(sp)
    80002b56:	ec66                	sd	s9,24(sp)
    80002b58:	e86a                	sd	s10,16(sp)
    80002b5a:	e46e                	sd	s11,8(sp)
    80002b5c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b5e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002b62:	5c7d                	li	s8,-1
    80002b64:	a825                	j	80002b9c <writei+0x82>
    80002b66:	020d1d93          	slli	s11,s10,0x20
    80002b6a:	020ddd93          	srli	s11,s11,0x20
    80002b6e:	05848513          	addi	a0,s1,88
    80002b72:	86ee                	mv	a3,s11
    80002b74:	8652                	mv	a2,s4
    80002b76:	85de                	mv	a1,s7
    80002b78:	953a                	add	a0,a0,a4
    80002b7a:	babfe0ef          	jal	80001724 <either_copyin>
    80002b7e:	05850a63          	beq	a0,s8,80002bd2 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002b82:	8526                	mv	a0,s1
    80002b84:	660000ef          	jal	800031e4 <log_write>
    brelse(bp);
    80002b88:	8526                	mv	a0,s1
    80002b8a:	e10ff0ef          	jal	8000219a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b8e:	013d09bb          	addw	s3,s10,s3
    80002b92:	012d093b          	addw	s2,s10,s2
    80002b96:	9a6e                	add	s4,s4,s11
    80002b98:	0569f063          	bgeu	s3,s6,80002bd8 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002b9c:	00a9559b          	srliw	a1,s2,0xa
    80002ba0:	8556                	mv	a0,s5
    80002ba2:	875ff0ef          	jal	80002416 <bmap>
    80002ba6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002baa:	c59d                	beqz	a1,80002bd8 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002bac:	000aa503          	lw	a0,0(s5)
    80002bb0:	ce2ff0ef          	jal	80002092 <bread>
    80002bb4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002bb6:	3ff97713          	andi	a4,s2,1023
    80002bba:	40ec87bb          	subw	a5,s9,a4
    80002bbe:	413b06bb          	subw	a3,s6,s3
    80002bc2:	8d3e                	mv	s10,a5
    80002bc4:	2781                	sext.w	a5,a5
    80002bc6:	0006861b          	sext.w	a2,a3
    80002bca:	f8f67ee3          	bgeu	a2,a5,80002b66 <writei+0x4c>
    80002bce:	8d36                	mv	s10,a3
    80002bd0:	bf59                	j	80002b66 <writei+0x4c>
      brelse(bp);
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	dc6ff0ef          	jal	8000219a <brelse>
  }

  if(off > ip->size)
    80002bd8:	04caa783          	lw	a5,76(s5)
    80002bdc:	0327fa63          	bgeu	a5,s2,80002c10 <writei+0xf6>
    ip->size = off;
    80002be0:	052aa623          	sw	s2,76(s5)
    80002be4:	64e6                	ld	s1,88(sp)
    80002be6:	7c02                	ld	s8,32(sp)
    80002be8:	6ce2                	ld	s9,24(sp)
    80002bea:	6d42                	ld	s10,16(sp)
    80002bec:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002bee:	8556                	mv	a0,s5
    80002bf0:	b27ff0ef          	jal	80002716 <iupdate>

  return tot;
    80002bf4:	0009851b          	sext.w	a0,s3
    80002bf8:	69a6                	ld	s3,72(sp)
}
    80002bfa:	70a6                	ld	ra,104(sp)
    80002bfc:	7406                	ld	s0,96(sp)
    80002bfe:	6946                	ld	s2,80(sp)
    80002c00:	6a06                	ld	s4,64(sp)
    80002c02:	7ae2                	ld	s5,56(sp)
    80002c04:	7b42                	ld	s6,48(sp)
    80002c06:	7ba2                	ld	s7,40(sp)
    80002c08:	6165                	addi	sp,sp,112
    80002c0a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c0c:	89da                	mv	s3,s6
    80002c0e:	b7c5                	j	80002bee <writei+0xd4>
    80002c10:	64e6                	ld	s1,88(sp)
    80002c12:	7c02                	ld	s8,32(sp)
    80002c14:	6ce2                	ld	s9,24(sp)
    80002c16:	6d42                	ld	s10,16(sp)
    80002c18:	6da2                	ld	s11,8(sp)
    80002c1a:	bfd1                	j	80002bee <writei+0xd4>
    return -1;
    80002c1c:	557d                	li	a0,-1
}
    80002c1e:	8082                	ret
    return -1;
    80002c20:	557d                	li	a0,-1
    80002c22:	bfe1                	j	80002bfa <writei+0xe0>
    return -1;
    80002c24:	557d                	li	a0,-1
    80002c26:	bfd1                	j	80002bfa <writei+0xe0>

0000000080002c28 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002c28:	1141                	addi	sp,sp,-16
    80002c2a:	e406                	sd	ra,8(sp)
    80002c2c:	e022                	sd	s0,0(sp)
    80002c2e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002c30:	4639                	li	a2,14
    80002c32:	e2afd0ef          	jal	8000025c <strncmp>
}
    80002c36:	60a2                	ld	ra,8(sp)
    80002c38:	6402                	ld	s0,0(sp)
    80002c3a:	0141                	addi	sp,sp,16
    80002c3c:	8082                	ret

0000000080002c3e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002c3e:	7139                	addi	sp,sp,-64
    80002c40:	fc06                	sd	ra,56(sp)
    80002c42:	f822                	sd	s0,48(sp)
    80002c44:	f426                	sd	s1,40(sp)
    80002c46:	f04a                	sd	s2,32(sp)
    80002c48:	ec4e                	sd	s3,24(sp)
    80002c4a:	e852                	sd	s4,16(sp)
    80002c4c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002c4e:	04451703          	lh	a4,68(a0)
    80002c52:	4785                	li	a5,1
    80002c54:	00f71a63          	bne	a4,a5,80002c68 <dirlookup+0x2a>
    80002c58:	892a                	mv	s2,a0
    80002c5a:	89ae                	mv	s3,a1
    80002c5c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c5e:	457c                	lw	a5,76(a0)
    80002c60:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002c62:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c64:	e39d                	bnez	a5,80002c8a <dirlookup+0x4c>
    80002c66:	a095                	j	80002cca <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002c68:	00005517          	auipc	a0,0x5
    80002c6c:	95050513          	addi	a0,a0,-1712 # 800075b8 <etext+0x5b8>
    80002c70:	163020ef          	jal	800055d2 <panic>
      panic("dirlookup read");
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	95c50513          	addi	a0,a0,-1700 # 800075d0 <etext+0x5d0>
    80002c7c:	157020ef          	jal	800055d2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002c80:	24c1                	addiw	s1,s1,16
    80002c82:	04c92783          	lw	a5,76(s2)
    80002c86:	04f4f163          	bgeu	s1,a5,80002cc8 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002c8a:	4741                	li	a4,16
    80002c8c:	86a6                	mv	a3,s1
    80002c8e:	fc040613          	addi	a2,s0,-64
    80002c92:	4581                	li	a1,0
    80002c94:	854a                	mv	a0,s2
    80002c96:	d89ff0ef          	jal	80002a1e <readi>
    80002c9a:	47c1                	li	a5,16
    80002c9c:	fcf51ce3          	bne	a0,a5,80002c74 <dirlookup+0x36>
    if(de.inum == 0)
    80002ca0:	fc045783          	lhu	a5,-64(s0)
    80002ca4:	dff1                	beqz	a5,80002c80 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002ca6:	fc240593          	addi	a1,s0,-62
    80002caa:	854e                	mv	a0,s3
    80002cac:	f7dff0ef          	jal	80002c28 <namecmp>
    80002cb0:	f961                	bnez	a0,80002c80 <dirlookup+0x42>
      if(poff)
    80002cb2:	000a0463          	beqz	s4,80002cba <dirlookup+0x7c>
        *poff = off;
    80002cb6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002cba:	fc045583          	lhu	a1,-64(s0)
    80002cbe:	00092503          	lw	a0,0(s2)
    80002cc2:	829ff0ef          	jal	800024ea <iget>
    80002cc6:	a011                	j	80002cca <dirlookup+0x8c>
  return 0;
    80002cc8:	4501                	li	a0,0
}
    80002cca:	70e2                	ld	ra,56(sp)
    80002ccc:	7442                	ld	s0,48(sp)
    80002cce:	74a2                	ld	s1,40(sp)
    80002cd0:	7902                	ld	s2,32(sp)
    80002cd2:	69e2                	ld	s3,24(sp)
    80002cd4:	6a42                	ld	s4,16(sp)
    80002cd6:	6121                	addi	sp,sp,64
    80002cd8:	8082                	ret

0000000080002cda <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002cda:	711d                	addi	sp,sp,-96
    80002cdc:	ec86                	sd	ra,88(sp)
    80002cde:	e8a2                	sd	s0,80(sp)
    80002ce0:	e4a6                	sd	s1,72(sp)
    80002ce2:	e0ca                	sd	s2,64(sp)
    80002ce4:	fc4e                	sd	s3,56(sp)
    80002ce6:	f852                	sd	s4,48(sp)
    80002ce8:	f456                	sd	s5,40(sp)
    80002cea:	f05a                	sd	s6,32(sp)
    80002cec:	ec5e                	sd	s7,24(sp)
    80002cee:	e862                	sd	s8,16(sp)
    80002cf0:	e466                	sd	s9,8(sp)
    80002cf2:	1080                	addi	s0,sp,96
    80002cf4:	84aa                	mv	s1,a0
    80002cf6:	8b2e                	mv	s6,a1
    80002cf8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002cfa:	00054703          	lbu	a4,0(a0)
    80002cfe:	02f00793          	li	a5,47
    80002d02:	00f70e63          	beq	a4,a5,80002d1e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002d06:	8a2fe0ef          	jal	80000da8 <myproc>
    80002d0a:	15053503          	ld	a0,336(a0)
    80002d0e:	a87ff0ef          	jal	80002794 <idup>
    80002d12:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002d14:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002d18:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002d1a:	4b85                	li	s7,1
    80002d1c:	a871                	j	80002db8 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002d1e:	4585                	li	a1,1
    80002d20:	4505                	li	a0,1
    80002d22:	fc8ff0ef          	jal	800024ea <iget>
    80002d26:	8a2a                	mv	s4,a0
    80002d28:	b7f5                	j	80002d14 <namex+0x3a>
      iunlockput(ip);
    80002d2a:	8552                	mv	a0,s4
    80002d2c:	ca9ff0ef          	jal	800029d4 <iunlockput>
      return 0;
    80002d30:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002d32:	8552                	mv	a0,s4
    80002d34:	60e6                	ld	ra,88(sp)
    80002d36:	6446                	ld	s0,80(sp)
    80002d38:	64a6                	ld	s1,72(sp)
    80002d3a:	6906                	ld	s2,64(sp)
    80002d3c:	79e2                	ld	s3,56(sp)
    80002d3e:	7a42                	ld	s4,48(sp)
    80002d40:	7aa2                	ld	s5,40(sp)
    80002d42:	7b02                	ld	s6,32(sp)
    80002d44:	6be2                	ld	s7,24(sp)
    80002d46:	6c42                	ld	s8,16(sp)
    80002d48:	6ca2                	ld	s9,8(sp)
    80002d4a:	6125                	addi	sp,sp,96
    80002d4c:	8082                	ret
      iunlock(ip);
    80002d4e:	8552                	mv	a0,s4
    80002d50:	b29ff0ef          	jal	80002878 <iunlock>
      return ip;
    80002d54:	bff9                	j	80002d32 <namex+0x58>
      iunlockput(ip);
    80002d56:	8552                	mv	a0,s4
    80002d58:	c7dff0ef          	jal	800029d4 <iunlockput>
      return 0;
    80002d5c:	8a4e                	mv	s4,s3
    80002d5e:	bfd1                	j	80002d32 <namex+0x58>
  len = path - s;
    80002d60:	40998633          	sub	a2,s3,s1
    80002d64:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002d68:	099c5063          	bge	s8,s9,80002de8 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002d6c:	4639                	li	a2,14
    80002d6e:	85a6                	mv	a1,s1
    80002d70:	8556                	mv	a0,s5
    80002d72:	c7afd0ef          	jal	800001ec <memmove>
    80002d76:	84ce                	mv	s1,s3
  while(*path == '/')
    80002d78:	0004c783          	lbu	a5,0(s1)
    80002d7c:	01279763          	bne	a5,s2,80002d8a <namex+0xb0>
    path++;
    80002d80:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d82:	0004c783          	lbu	a5,0(s1)
    80002d86:	ff278de3          	beq	a5,s2,80002d80 <namex+0xa6>
    ilock(ip);
    80002d8a:	8552                	mv	a0,s4
    80002d8c:	a3fff0ef          	jal	800027ca <ilock>
    if(ip->type != T_DIR){
    80002d90:	044a1783          	lh	a5,68(s4)
    80002d94:	f9779be3          	bne	a5,s7,80002d2a <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002d98:	000b0563          	beqz	s6,80002da2 <namex+0xc8>
    80002d9c:	0004c783          	lbu	a5,0(s1)
    80002da0:	d7dd                	beqz	a5,80002d4e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002da2:	4601                	li	a2,0
    80002da4:	85d6                	mv	a1,s5
    80002da6:	8552                	mv	a0,s4
    80002da8:	e97ff0ef          	jal	80002c3e <dirlookup>
    80002dac:	89aa                	mv	s3,a0
    80002dae:	d545                	beqz	a0,80002d56 <namex+0x7c>
    iunlockput(ip);
    80002db0:	8552                	mv	a0,s4
    80002db2:	c23ff0ef          	jal	800029d4 <iunlockput>
    ip = next;
    80002db6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002db8:	0004c783          	lbu	a5,0(s1)
    80002dbc:	01279763          	bne	a5,s2,80002dca <namex+0xf0>
    path++;
    80002dc0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002dc2:	0004c783          	lbu	a5,0(s1)
    80002dc6:	ff278de3          	beq	a5,s2,80002dc0 <namex+0xe6>
  if(*path == 0)
    80002dca:	cb8d                	beqz	a5,80002dfc <namex+0x122>
  while(*path != '/' && *path != 0)
    80002dcc:	0004c783          	lbu	a5,0(s1)
    80002dd0:	89a6                	mv	s3,s1
  len = path - s;
    80002dd2:	4c81                	li	s9,0
    80002dd4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002dd6:	01278963          	beq	a5,s2,80002de8 <namex+0x10e>
    80002dda:	d3d9                	beqz	a5,80002d60 <namex+0x86>
    path++;
    80002ddc:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002dde:	0009c783          	lbu	a5,0(s3)
    80002de2:	ff279ce3          	bne	a5,s2,80002dda <namex+0x100>
    80002de6:	bfad                	j	80002d60 <namex+0x86>
    memmove(name, s, len);
    80002de8:	2601                	sext.w	a2,a2
    80002dea:	85a6                	mv	a1,s1
    80002dec:	8556                	mv	a0,s5
    80002dee:	bfefd0ef          	jal	800001ec <memmove>
    name[len] = 0;
    80002df2:	9cd6                	add	s9,s9,s5
    80002df4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002df8:	84ce                	mv	s1,s3
    80002dfa:	bfbd                	j	80002d78 <namex+0x9e>
  if(nameiparent){
    80002dfc:	f20b0be3          	beqz	s6,80002d32 <namex+0x58>
    iput(ip);
    80002e00:	8552                	mv	a0,s4
    80002e02:	b4bff0ef          	jal	8000294c <iput>
    return 0;
    80002e06:	4a01                	li	s4,0
    80002e08:	b72d                	j	80002d32 <namex+0x58>

0000000080002e0a <dirlink>:
{
    80002e0a:	7139                	addi	sp,sp,-64
    80002e0c:	fc06                	sd	ra,56(sp)
    80002e0e:	f822                	sd	s0,48(sp)
    80002e10:	f04a                	sd	s2,32(sp)
    80002e12:	ec4e                	sd	s3,24(sp)
    80002e14:	e852                	sd	s4,16(sp)
    80002e16:	0080                	addi	s0,sp,64
    80002e18:	892a                	mv	s2,a0
    80002e1a:	8a2e                	mv	s4,a1
    80002e1c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002e1e:	4601                	li	a2,0
    80002e20:	e1fff0ef          	jal	80002c3e <dirlookup>
    80002e24:	e535                	bnez	a0,80002e90 <dirlink+0x86>
    80002e26:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e28:	04c92483          	lw	s1,76(s2)
    80002e2c:	c48d                	beqz	s1,80002e56 <dirlink+0x4c>
    80002e2e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e30:	4741                	li	a4,16
    80002e32:	86a6                	mv	a3,s1
    80002e34:	fc040613          	addi	a2,s0,-64
    80002e38:	4581                	li	a1,0
    80002e3a:	854a                	mv	a0,s2
    80002e3c:	be3ff0ef          	jal	80002a1e <readi>
    80002e40:	47c1                	li	a5,16
    80002e42:	04f51b63          	bne	a0,a5,80002e98 <dirlink+0x8e>
    if(de.inum == 0)
    80002e46:	fc045783          	lhu	a5,-64(s0)
    80002e4a:	c791                	beqz	a5,80002e56 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e4c:	24c1                	addiw	s1,s1,16
    80002e4e:	04c92783          	lw	a5,76(s2)
    80002e52:	fcf4efe3          	bltu	s1,a5,80002e30 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002e56:	4639                	li	a2,14
    80002e58:	85d2                	mv	a1,s4
    80002e5a:	fc240513          	addi	a0,s0,-62
    80002e5e:	c34fd0ef          	jal	80000292 <strncpy>
  de.inum = inum;
    80002e62:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e66:	4741                	li	a4,16
    80002e68:	86a6                	mv	a3,s1
    80002e6a:	fc040613          	addi	a2,s0,-64
    80002e6e:	4581                	li	a1,0
    80002e70:	854a                	mv	a0,s2
    80002e72:	ca9ff0ef          	jal	80002b1a <writei>
    80002e76:	1541                	addi	a0,a0,-16
    80002e78:	00a03533          	snez	a0,a0
    80002e7c:	40a00533          	neg	a0,a0
    80002e80:	74a2                	ld	s1,40(sp)
}
    80002e82:	70e2                	ld	ra,56(sp)
    80002e84:	7442                	ld	s0,48(sp)
    80002e86:	7902                	ld	s2,32(sp)
    80002e88:	69e2                	ld	s3,24(sp)
    80002e8a:	6a42                	ld	s4,16(sp)
    80002e8c:	6121                	addi	sp,sp,64
    80002e8e:	8082                	ret
    iput(ip);
    80002e90:	abdff0ef          	jal	8000294c <iput>
    return -1;
    80002e94:	557d                	li	a0,-1
    80002e96:	b7f5                	j	80002e82 <dirlink+0x78>
      panic("dirlink read");
    80002e98:	00004517          	auipc	a0,0x4
    80002e9c:	74850513          	addi	a0,a0,1864 # 800075e0 <etext+0x5e0>
    80002ea0:	732020ef          	jal	800055d2 <panic>

0000000080002ea4 <namei>:

struct inode*
namei(char *path)
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002eac:	fe040613          	addi	a2,s0,-32
    80002eb0:	4581                	li	a1,0
    80002eb2:	e29ff0ef          	jal	80002cda <namex>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret

0000000080002ebe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002ebe:	1141                	addi	sp,sp,-16
    80002ec0:	e406                	sd	ra,8(sp)
    80002ec2:	e022                	sd	s0,0(sp)
    80002ec4:	0800                	addi	s0,sp,16
    80002ec6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002ec8:	4585                	li	a1,1
    80002eca:	e11ff0ef          	jal	80002cda <namex>
}
    80002ece:	60a2                	ld	ra,8(sp)
    80002ed0:	6402                	ld	s0,0(sp)
    80002ed2:	0141                	addi	sp,sp,16
    80002ed4:	8082                	ret

0000000080002ed6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002ed6:	1101                	addi	sp,sp,-32
    80002ed8:	ec06                	sd	ra,24(sp)
    80002eda:	e822                	sd	s0,16(sp)
    80002edc:	e426                	sd	s1,8(sp)
    80002ede:	e04a                	sd	s2,0(sp)
    80002ee0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002ee2:	00018917          	auipc	s2,0x18
    80002ee6:	82e90913          	addi	s2,s2,-2002 # 8001a710 <log>
    80002eea:	01892583          	lw	a1,24(s2)
    80002eee:	02892503          	lw	a0,40(s2)
    80002ef2:	9a0ff0ef          	jal	80002092 <bread>
    80002ef6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002ef8:	02c92603          	lw	a2,44(s2)
    80002efc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002efe:	00c05f63          	blez	a2,80002f1c <write_head+0x46>
    80002f02:	00018717          	auipc	a4,0x18
    80002f06:	83e70713          	addi	a4,a4,-1986 # 8001a740 <log+0x30>
    80002f0a:	87aa                	mv	a5,a0
    80002f0c:	060a                	slli	a2,a2,0x2
    80002f0e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002f10:	4314                	lw	a3,0(a4)
    80002f12:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002f14:	0711                	addi	a4,a4,4
    80002f16:	0791                	addi	a5,a5,4
    80002f18:	fec79ce3          	bne	a5,a2,80002f10 <write_head+0x3a>
  }
  bwrite(buf);
    80002f1c:	8526                	mv	a0,s1
    80002f1e:	a4aff0ef          	jal	80002168 <bwrite>
  brelse(buf);
    80002f22:	8526                	mv	a0,s1
    80002f24:	a76ff0ef          	jal	8000219a <brelse>
}
    80002f28:	60e2                	ld	ra,24(sp)
    80002f2a:	6442                	ld	s0,16(sp)
    80002f2c:	64a2                	ld	s1,8(sp)
    80002f2e:	6902                	ld	s2,0(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f34:	00018797          	auipc	a5,0x18
    80002f38:	8087a783          	lw	a5,-2040(a5) # 8001a73c <log+0x2c>
    80002f3c:	08f05f63          	blez	a5,80002fda <install_trans+0xa6>
{
    80002f40:	7139                	addi	sp,sp,-64
    80002f42:	fc06                	sd	ra,56(sp)
    80002f44:	f822                	sd	s0,48(sp)
    80002f46:	f426                	sd	s1,40(sp)
    80002f48:	f04a                	sd	s2,32(sp)
    80002f4a:	ec4e                	sd	s3,24(sp)
    80002f4c:	e852                	sd	s4,16(sp)
    80002f4e:	e456                	sd	s5,8(sp)
    80002f50:	e05a                	sd	s6,0(sp)
    80002f52:	0080                	addi	s0,sp,64
    80002f54:	8b2a                	mv	s6,a0
    80002f56:	00017a97          	auipc	s5,0x17
    80002f5a:	7eaa8a93          	addi	s5,s5,2026 # 8001a740 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f5e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f60:	00017997          	auipc	s3,0x17
    80002f64:	7b098993          	addi	s3,s3,1968 # 8001a710 <log>
    80002f68:	a829                	j	80002f82 <install_trans+0x4e>
    brelse(lbuf);
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	a2eff0ef          	jal	8000219a <brelse>
    brelse(dbuf);
    80002f70:	8526                	mv	a0,s1
    80002f72:	a28ff0ef          	jal	8000219a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f76:	2a05                	addiw	s4,s4,1
    80002f78:	0a91                	addi	s5,s5,4
    80002f7a:	02c9a783          	lw	a5,44(s3)
    80002f7e:	04fa5463          	bge	s4,a5,80002fc6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002f82:	0189a583          	lw	a1,24(s3)
    80002f86:	014585bb          	addw	a1,a1,s4
    80002f8a:	2585                	addiw	a1,a1,1
    80002f8c:	0289a503          	lw	a0,40(s3)
    80002f90:	902ff0ef          	jal	80002092 <bread>
    80002f94:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002f96:	000aa583          	lw	a1,0(s5)
    80002f9a:	0289a503          	lw	a0,40(s3)
    80002f9e:	8f4ff0ef          	jal	80002092 <bread>
    80002fa2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002fa4:	40000613          	li	a2,1024
    80002fa8:	05890593          	addi	a1,s2,88
    80002fac:	05850513          	addi	a0,a0,88
    80002fb0:	a3cfd0ef          	jal	800001ec <memmove>
    bwrite(dbuf);  // write dst to disk
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	9b2ff0ef          	jal	80002168 <bwrite>
    if(recovering == 0)
    80002fba:	fa0b18e3          	bnez	s6,80002f6a <install_trans+0x36>
      bunpin(dbuf);
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	a96ff0ef          	jal	80002256 <bunpin>
    80002fc4:	b75d                	j	80002f6a <install_trans+0x36>
}
    80002fc6:	70e2                	ld	ra,56(sp)
    80002fc8:	7442                	ld	s0,48(sp)
    80002fca:	74a2                	ld	s1,40(sp)
    80002fcc:	7902                	ld	s2,32(sp)
    80002fce:	69e2                	ld	s3,24(sp)
    80002fd0:	6a42                	ld	s4,16(sp)
    80002fd2:	6aa2                	ld	s5,8(sp)
    80002fd4:	6b02                	ld	s6,0(sp)
    80002fd6:	6121                	addi	sp,sp,64
    80002fd8:	8082                	ret
    80002fda:	8082                	ret

0000000080002fdc <initlog>:
{
    80002fdc:	7179                	addi	sp,sp,-48
    80002fde:	f406                	sd	ra,40(sp)
    80002fe0:	f022                	sd	s0,32(sp)
    80002fe2:	ec26                	sd	s1,24(sp)
    80002fe4:	e84a                	sd	s2,16(sp)
    80002fe6:	e44e                	sd	s3,8(sp)
    80002fe8:	1800                	addi	s0,sp,48
    80002fea:	892a                	mv	s2,a0
    80002fec:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002fee:	00017497          	auipc	s1,0x17
    80002ff2:	72248493          	addi	s1,s1,1826 # 8001a710 <log>
    80002ff6:	00004597          	auipc	a1,0x4
    80002ffa:	5fa58593          	addi	a1,a1,1530 # 800075f0 <etext+0x5f0>
    80002ffe:	8526                	mv	a0,s1
    80003000:	081020ef          	jal	80005880 <initlock>
  log.start = sb->logstart;
    80003004:	0149a583          	lw	a1,20(s3)
    80003008:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000300a:	0109a783          	lw	a5,16(s3)
    8000300e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003010:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003014:	854a                	mv	a0,s2
    80003016:	87cff0ef          	jal	80002092 <bread>
  log.lh.n = lh->n;
    8000301a:	4d30                	lw	a2,88(a0)
    8000301c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000301e:	00c05f63          	blez	a2,8000303c <initlog+0x60>
    80003022:	87aa                	mv	a5,a0
    80003024:	00017717          	auipc	a4,0x17
    80003028:	71c70713          	addi	a4,a4,1820 # 8001a740 <log+0x30>
    8000302c:	060a                	slli	a2,a2,0x2
    8000302e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003030:	4ff4                	lw	a3,92(a5)
    80003032:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003034:	0791                	addi	a5,a5,4
    80003036:	0711                	addi	a4,a4,4
    80003038:	fec79ce3          	bne	a5,a2,80003030 <initlog+0x54>
  brelse(buf);
    8000303c:	95eff0ef          	jal	8000219a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003040:	4505                	li	a0,1
    80003042:	ef3ff0ef          	jal	80002f34 <install_trans>
  log.lh.n = 0;
    80003046:	00017797          	auipc	a5,0x17
    8000304a:	6e07ab23          	sw	zero,1782(a5) # 8001a73c <log+0x2c>
  write_head(); // clear the log
    8000304e:	e89ff0ef          	jal	80002ed6 <write_head>
}
    80003052:	70a2                	ld	ra,40(sp)
    80003054:	7402                	ld	s0,32(sp)
    80003056:	64e2                	ld	s1,24(sp)
    80003058:	6942                	ld	s2,16(sp)
    8000305a:	69a2                	ld	s3,8(sp)
    8000305c:	6145                	addi	sp,sp,48
    8000305e:	8082                	ret

0000000080003060 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	e426                	sd	s1,8(sp)
    80003068:	e04a                	sd	s2,0(sp)
    8000306a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000306c:	00017517          	auipc	a0,0x17
    80003070:	6a450513          	addi	a0,a0,1700 # 8001a710 <log>
    80003074:	08d020ef          	jal	80005900 <acquire>
  while(1){
    if(log.committing){
    80003078:	00017497          	auipc	s1,0x17
    8000307c:	69848493          	addi	s1,s1,1688 # 8001a710 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003080:	4979                	li	s2,30
    80003082:	a029                	j	8000308c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003084:	85a6                	mv	a1,s1
    80003086:	8526                	mv	a0,s1
    80003088:	af6fe0ef          	jal	8000137e <sleep>
    if(log.committing){
    8000308c:	50dc                	lw	a5,36(s1)
    8000308e:	fbfd                	bnez	a5,80003084 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003090:	5098                	lw	a4,32(s1)
    80003092:	2705                	addiw	a4,a4,1
    80003094:	0027179b          	slliw	a5,a4,0x2
    80003098:	9fb9                	addw	a5,a5,a4
    8000309a:	0017979b          	slliw	a5,a5,0x1
    8000309e:	54d4                	lw	a3,44(s1)
    800030a0:	9fb5                	addw	a5,a5,a3
    800030a2:	00f95763          	bge	s2,a5,800030b0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800030a6:	85a6                	mv	a1,s1
    800030a8:	8526                	mv	a0,s1
    800030aa:	ad4fe0ef          	jal	8000137e <sleep>
    800030ae:	bff9                	j	8000308c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800030b0:	00017517          	auipc	a0,0x17
    800030b4:	66050513          	addi	a0,a0,1632 # 8001a710 <log>
    800030b8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800030ba:	0df020ef          	jal	80005998 <release>
      break;
    }
  }
}
    800030be:	60e2                	ld	ra,24(sp)
    800030c0:	6442                	ld	s0,16(sp)
    800030c2:	64a2                	ld	s1,8(sp)
    800030c4:	6902                	ld	s2,0(sp)
    800030c6:	6105                	addi	sp,sp,32
    800030c8:	8082                	ret

00000000800030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800030ca:	7139                	addi	sp,sp,-64
    800030cc:	fc06                	sd	ra,56(sp)
    800030ce:	f822                	sd	s0,48(sp)
    800030d0:	f426                	sd	s1,40(sp)
    800030d2:	f04a                	sd	s2,32(sp)
    800030d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800030d6:	00017497          	auipc	s1,0x17
    800030da:	63a48493          	addi	s1,s1,1594 # 8001a710 <log>
    800030de:	8526                	mv	a0,s1
    800030e0:	021020ef          	jal	80005900 <acquire>
  log.outstanding -= 1;
    800030e4:	509c                	lw	a5,32(s1)
    800030e6:	37fd                	addiw	a5,a5,-1
    800030e8:	0007891b          	sext.w	s2,a5
    800030ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800030ee:	50dc                	lw	a5,36(s1)
    800030f0:	ef9d                	bnez	a5,8000312e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800030f2:	04091763          	bnez	s2,80003140 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800030f6:	00017497          	auipc	s1,0x17
    800030fa:	61a48493          	addi	s1,s1,1562 # 8001a710 <log>
    800030fe:	4785                	li	a5,1
    80003100:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003102:	8526                	mv	a0,s1
    80003104:	095020ef          	jal	80005998 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003108:	54dc                	lw	a5,44(s1)
    8000310a:	04f04b63          	bgtz	a5,80003160 <end_op+0x96>
    acquire(&log.lock);
    8000310e:	00017497          	auipc	s1,0x17
    80003112:	60248493          	addi	s1,s1,1538 # 8001a710 <log>
    80003116:	8526                	mv	a0,s1
    80003118:	7e8020ef          	jal	80005900 <acquire>
    log.committing = 0;
    8000311c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003120:	8526                	mv	a0,s1
    80003122:	aa8fe0ef          	jal	800013ca <wakeup>
    release(&log.lock);
    80003126:	8526                	mv	a0,s1
    80003128:	071020ef          	jal	80005998 <release>
}
    8000312c:	a025                	j	80003154 <end_op+0x8a>
    8000312e:	ec4e                	sd	s3,24(sp)
    80003130:	e852                	sd	s4,16(sp)
    80003132:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003134:	00004517          	auipc	a0,0x4
    80003138:	4c450513          	addi	a0,a0,1220 # 800075f8 <etext+0x5f8>
    8000313c:	496020ef          	jal	800055d2 <panic>
    wakeup(&log);
    80003140:	00017497          	auipc	s1,0x17
    80003144:	5d048493          	addi	s1,s1,1488 # 8001a710 <log>
    80003148:	8526                	mv	a0,s1
    8000314a:	a80fe0ef          	jal	800013ca <wakeup>
  release(&log.lock);
    8000314e:	8526                	mv	a0,s1
    80003150:	049020ef          	jal	80005998 <release>
}
    80003154:	70e2                	ld	ra,56(sp)
    80003156:	7442                	ld	s0,48(sp)
    80003158:	74a2                	ld	s1,40(sp)
    8000315a:	7902                	ld	s2,32(sp)
    8000315c:	6121                	addi	sp,sp,64
    8000315e:	8082                	ret
    80003160:	ec4e                	sd	s3,24(sp)
    80003162:	e852                	sd	s4,16(sp)
    80003164:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003166:	00017a97          	auipc	s5,0x17
    8000316a:	5daa8a93          	addi	s5,s5,1498 # 8001a740 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000316e:	00017a17          	auipc	s4,0x17
    80003172:	5a2a0a13          	addi	s4,s4,1442 # 8001a710 <log>
    80003176:	018a2583          	lw	a1,24(s4)
    8000317a:	012585bb          	addw	a1,a1,s2
    8000317e:	2585                	addiw	a1,a1,1
    80003180:	028a2503          	lw	a0,40(s4)
    80003184:	f0ffe0ef          	jal	80002092 <bread>
    80003188:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000318a:	000aa583          	lw	a1,0(s5)
    8000318e:	028a2503          	lw	a0,40(s4)
    80003192:	f01fe0ef          	jal	80002092 <bread>
    80003196:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003198:	40000613          	li	a2,1024
    8000319c:	05850593          	addi	a1,a0,88
    800031a0:	05848513          	addi	a0,s1,88
    800031a4:	848fd0ef          	jal	800001ec <memmove>
    bwrite(to);  // write the log
    800031a8:	8526                	mv	a0,s1
    800031aa:	fbffe0ef          	jal	80002168 <bwrite>
    brelse(from);
    800031ae:	854e                	mv	a0,s3
    800031b0:	febfe0ef          	jal	8000219a <brelse>
    brelse(to);
    800031b4:	8526                	mv	a0,s1
    800031b6:	fe5fe0ef          	jal	8000219a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031ba:	2905                	addiw	s2,s2,1
    800031bc:	0a91                	addi	s5,s5,4
    800031be:	02ca2783          	lw	a5,44(s4)
    800031c2:	faf94ae3          	blt	s2,a5,80003176 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800031c6:	d11ff0ef          	jal	80002ed6 <write_head>
    install_trans(0); // Now install writes to home locations
    800031ca:	4501                	li	a0,0
    800031cc:	d69ff0ef          	jal	80002f34 <install_trans>
    log.lh.n = 0;
    800031d0:	00017797          	auipc	a5,0x17
    800031d4:	5607a623          	sw	zero,1388(a5) # 8001a73c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800031d8:	cffff0ef          	jal	80002ed6 <write_head>
    800031dc:	69e2                	ld	s3,24(sp)
    800031de:	6a42                	ld	s4,16(sp)
    800031e0:	6aa2                	ld	s5,8(sp)
    800031e2:	b735                	j	8000310e <end_op+0x44>

00000000800031e4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800031e4:	1101                	addi	sp,sp,-32
    800031e6:	ec06                	sd	ra,24(sp)
    800031e8:	e822                	sd	s0,16(sp)
    800031ea:	e426                	sd	s1,8(sp)
    800031ec:	e04a                	sd	s2,0(sp)
    800031ee:	1000                	addi	s0,sp,32
    800031f0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800031f2:	00017917          	auipc	s2,0x17
    800031f6:	51e90913          	addi	s2,s2,1310 # 8001a710 <log>
    800031fa:	854a                	mv	a0,s2
    800031fc:	704020ef          	jal	80005900 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003200:	02c92603          	lw	a2,44(s2)
    80003204:	47f5                	li	a5,29
    80003206:	06c7c363          	blt	a5,a2,8000326c <log_write+0x88>
    8000320a:	00017797          	auipc	a5,0x17
    8000320e:	5227a783          	lw	a5,1314(a5) # 8001a72c <log+0x1c>
    80003212:	37fd                	addiw	a5,a5,-1
    80003214:	04f65c63          	bge	a2,a5,8000326c <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003218:	00017797          	auipc	a5,0x17
    8000321c:	5187a783          	lw	a5,1304(a5) # 8001a730 <log+0x20>
    80003220:	04f05c63          	blez	a5,80003278 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003224:	4781                	li	a5,0
    80003226:	04c05f63          	blez	a2,80003284 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000322a:	44cc                	lw	a1,12(s1)
    8000322c:	00017717          	auipc	a4,0x17
    80003230:	51470713          	addi	a4,a4,1300 # 8001a740 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003234:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003236:	4314                	lw	a3,0(a4)
    80003238:	04b68663          	beq	a3,a1,80003284 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000323c:	2785                	addiw	a5,a5,1
    8000323e:	0711                	addi	a4,a4,4
    80003240:	fef61be3          	bne	a2,a5,80003236 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003244:	0621                	addi	a2,a2,8
    80003246:	060a                	slli	a2,a2,0x2
    80003248:	00017797          	auipc	a5,0x17
    8000324c:	4c878793          	addi	a5,a5,1224 # 8001a710 <log>
    80003250:	97b2                	add	a5,a5,a2
    80003252:	44d8                	lw	a4,12(s1)
    80003254:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003256:	8526                	mv	a0,s1
    80003258:	fcbfe0ef          	jal	80002222 <bpin>
    log.lh.n++;
    8000325c:	00017717          	auipc	a4,0x17
    80003260:	4b470713          	addi	a4,a4,1204 # 8001a710 <log>
    80003264:	575c                	lw	a5,44(a4)
    80003266:	2785                	addiw	a5,a5,1
    80003268:	d75c                	sw	a5,44(a4)
    8000326a:	a80d                	j	8000329c <log_write+0xb8>
    panic("too big a transaction");
    8000326c:	00004517          	auipc	a0,0x4
    80003270:	39c50513          	addi	a0,a0,924 # 80007608 <etext+0x608>
    80003274:	35e020ef          	jal	800055d2 <panic>
    panic("log_write outside of trans");
    80003278:	00004517          	auipc	a0,0x4
    8000327c:	3a850513          	addi	a0,a0,936 # 80007620 <etext+0x620>
    80003280:	352020ef          	jal	800055d2 <panic>
  log.lh.block[i] = b->blockno;
    80003284:	00878693          	addi	a3,a5,8
    80003288:	068a                	slli	a3,a3,0x2
    8000328a:	00017717          	auipc	a4,0x17
    8000328e:	48670713          	addi	a4,a4,1158 # 8001a710 <log>
    80003292:	9736                	add	a4,a4,a3
    80003294:	44d4                	lw	a3,12(s1)
    80003296:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003298:	faf60fe3          	beq	a2,a5,80003256 <log_write+0x72>
  }
  release(&log.lock);
    8000329c:	00017517          	auipc	a0,0x17
    800032a0:	47450513          	addi	a0,a0,1140 # 8001a710 <log>
    800032a4:	6f4020ef          	jal	80005998 <release>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6902                	ld	s2,0(sp)
    800032b0:	6105                	addi	sp,sp,32
    800032b2:	8082                	ret

00000000800032b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800032b4:	1101                	addi	sp,sp,-32
    800032b6:	ec06                	sd	ra,24(sp)
    800032b8:	e822                	sd	s0,16(sp)
    800032ba:	e426                	sd	s1,8(sp)
    800032bc:	e04a                	sd	s2,0(sp)
    800032be:	1000                	addi	s0,sp,32
    800032c0:	84aa                	mv	s1,a0
    800032c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800032c4:	00004597          	auipc	a1,0x4
    800032c8:	37c58593          	addi	a1,a1,892 # 80007640 <etext+0x640>
    800032cc:	0521                	addi	a0,a0,8
    800032ce:	5b2020ef          	jal	80005880 <initlock>
  lk->name = name;
    800032d2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800032d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800032da:	0204a423          	sw	zero,40(s1)
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6902                	ld	s2,0(sp)
    800032e6:	6105                	addi	sp,sp,32
    800032e8:	8082                	ret

00000000800032ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800032ea:	1101                	addi	sp,sp,-32
    800032ec:	ec06                	sd	ra,24(sp)
    800032ee:	e822                	sd	s0,16(sp)
    800032f0:	e426                	sd	s1,8(sp)
    800032f2:	e04a                	sd	s2,0(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800032f8:	00850913          	addi	s2,a0,8
    800032fc:	854a                	mv	a0,s2
    800032fe:	602020ef          	jal	80005900 <acquire>
  while (lk->locked) {
    80003302:	409c                	lw	a5,0(s1)
    80003304:	c799                	beqz	a5,80003312 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003306:	85ca                	mv	a1,s2
    80003308:	8526                	mv	a0,s1
    8000330a:	874fe0ef          	jal	8000137e <sleep>
  while (lk->locked) {
    8000330e:	409c                	lw	a5,0(s1)
    80003310:	fbfd                	bnez	a5,80003306 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003312:	4785                	li	a5,1
    80003314:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003316:	a93fd0ef          	jal	80000da8 <myproc>
    8000331a:	591c                	lw	a5,48(a0)
    8000331c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000331e:	854a                	mv	a0,s2
    80003320:	678020ef          	jal	80005998 <release>
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6902                	ld	s2,0(sp)
    8000332c:	6105                	addi	sp,sp,32
    8000332e:	8082                	ret

0000000080003330 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003330:	1101                	addi	sp,sp,-32
    80003332:	ec06                	sd	ra,24(sp)
    80003334:	e822                	sd	s0,16(sp)
    80003336:	e426                	sd	s1,8(sp)
    80003338:	e04a                	sd	s2,0(sp)
    8000333a:	1000                	addi	s0,sp,32
    8000333c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000333e:	00850913          	addi	s2,a0,8
    80003342:	854a                	mv	a0,s2
    80003344:	5bc020ef          	jal	80005900 <acquire>
  lk->locked = 0;
    80003348:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000334c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003350:	8526                	mv	a0,s1
    80003352:	878fe0ef          	jal	800013ca <wakeup>
  release(&lk->lk);
    80003356:	854a                	mv	a0,s2
    80003358:	640020ef          	jal	80005998 <release>
}
    8000335c:	60e2                	ld	ra,24(sp)
    8000335e:	6442                	ld	s0,16(sp)
    80003360:	64a2                	ld	s1,8(sp)
    80003362:	6902                	ld	s2,0(sp)
    80003364:	6105                	addi	sp,sp,32
    80003366:	8082                	ret

0000000080003368 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003368:	7179                	addi	sp,sp,-48
    8000336a:	f406                	sd	ra,40(sp)
    8000336c:	f022                	sd	s0,32(sp)
    8000336e:	ec26                	sd	s1,24(sp)
    80003370:	e84a                	sd	s2,16(sp)
    80003372:	1800                	addi	s0,sp,48
    80003374:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003376:	00850913          	addi	s2,a0,8
    8000337a:	854a                	mv	a0,s2
    8000337c:	584020ef          	jal	80005900 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003380:	409c                	lw	a5,0(s1)
    80003382:	ef81                	bnez	a5,8000339a <holdingsleep+0x32>
    80003384:	4481                	li	s1,0
  release(&lk->lk);
    80003386:	854a                	mv	a0,s2
    80003388:	610020ef          	jal	80005998 <release>
  return r;
}
    8000338c:	8526                	mv	a0,s1
    8000338e:	70a2                	ld	ra,40(sp)
    80003390:	7402                	ld	s0,32(sp)
    80003392:	64e2                	ld	s1,24(sp)
    80003394:	6942                	ld	s2,16(sp)
    80003396:	6145                	addi	sp,sp,48
    80003398:	8082                	ret
    8000339a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000339c:	0284a983          	lw	s3,40(s1)
    800033a0:	a09fd0ef          	jal	80000da8 <myproc>
    800033a4:	5904                	lw	s1,48(a0)
    800033a6:	413484b3          	sub	s1,s1,s3
    800033aa:	0014b493          	seqz	s1,s1
    800033ae:	69a2                	ld	s3,8(sp)
    800033b0:	bfd9                	j	80003386 <holdingsleep+0x1e>

00000000800033b2 <fileinit>:
} ftable;

// initialize file table 
void
fileinit(void)
{
    800033b2:	1141                	addi	sp,sp,-16
    800033b4:	e406                	sd	ra,8(sp)
    800033b6:	e022                	sd	s0,0(sp)
    800033b8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable"); //Initialize spinlock lock for ftable to synchronize access to file table.
    800033ba:	00004597          	auipc	a1,0x4
    800033be:	29658593          	addi	a1,a1,662 # 80007650 <etext+0x650>
    800033c2:	00017517          	auipc	a0,0x17
    800033c6:	49650513          	addi	a0,a0,1174 # 8001a858 <ftable>
    800033ca:	4b6020ef          	jal	80005880 <initlock>
}
    800033ce:	60a2                	ld	ra,8(sp)
    800033d0:	6402                	ld	s0,0(sp)
    800033d2:	0141                	addi	sp,sp,16
    800033d4:	8082                	ret

00000000800033d6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800033e0:	00017517          	auipc	a0,0x17
    800033e4:	47850513          	addi	a0,a0,1144 # 8001a858 <ftable>
    800033e8:	518020ef          	jal	80005900 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800033ec:	00017497          	auipc	s1,0x17
    800033f0:	48448493          	addi	s1,s1,1156 # 8001a870 <ftable+0x18>
    800033f4:	00018717          	auipc	a4,0x18
    800033f8:	41c70713          	addi	a4,a4,1052 # 8001b810 <disk>
    //find file structure that are not used
    if(f->ref == 0){
    800033fc:	40dc                	lw	a5,4(s1)
    800033fe:	cf89                	beqz	a5,80003418 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003400:	02848493          	addi	s1,s1,40
    80003404:	fee49ce3          	bne	s1,a4,800033fc <filealloc+0x26>
      f->ref = 1; // mark that it has been used 
      release(&ftable.lock); // unlock
      return f;
    }
  }
  release(&ftable.lock); //unlock afer finding
    80003408:	00017517          	auipc	a0,0x17
    8000340c:	45050513          	addi	a0,a0,1104 # 8001a858 <ftable>
    80003410:	588020ef          	jal	80005998 <release>
  return 0;
    80003414:	4481                	li	s1,0
    80003416:	a809                	j	80003428 <filealloc+0x52>
      f->ref = 1; // mark that it has been used 
    80003418:	4785                	li	a5,1
    8000341a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock); // unlock
    8000341c:	00017517          	auipc	a0,0x17
    80003420:	43c50513          	addi	a0,a0,1084 # 8001a858 <ftable>
    80003424:	574020ef          	jal	80005998 <release>
}
    80003428:	8526                	mv	a0,s1
    8000342a:	60e2                	ld	ra,24(sp)
    8000342c:	6442                	ld	s0,16(sp)
    8000342e:	64a2                	ld	s1,8(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret

0000000080003434 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003434:	1101                	addi	sp,sp,-32
    80003436:	ec06                	sd	ra,24(sp)
    80003438:	e822                	sd	s0,16(sp)
    8000343a:	e426                	sd	s1,8(sp)
    8000343c:	1000                	addi	s0,sp,32
    8000343e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003440:	00017517          	auipc	a0,0x17
    80003444:	41850513          	addi	a0,a0,1048 # 8001a858 <ftable>
    80003448:	4b8020ef          	jal	80005900 <acquire>
  if(f->ref < 1)
    8000344c:	40dc                	lw	a5,4(s1)
    8000344e:	02f05063          	blez	a5,8000346e <filedup+0x3a>
    panic("filedup"); // panic cannot duplicate because it isnot used
  f->ref++; //duplicate
    80003452:	2785                	addiw	a5,a5,1
    80003454:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003456:	00017517          	auipc	a0,0x17
    8000345a:	40250513          	addi	a0,a0,1026 # 8001a858 <ftable>
    8000345e:	53a020ef          	jal	80005998 <release>
  return f;
}
    80003462:	8526                	mv	a0,s1
    80003464:	60e2                	ld	ra,24(sp)
    80003466:	6442                	ld	s0,16(sp)
    80003468:	64a2                	ld	s1,8(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret
    panic("filedup"); // panic cannot duplicate because it isnot used
    8000346e:	00004517          	auipc	a0,0x4
    80003472:	1ea50513          	addi	a0,a0,490 # 80007658 <etext+0x658>
    80003476:	15c020ef          	jal	800055d2 <panic>

000000008000347a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.) and release.
void
fileclose(struct file *f)
{
    8000347a:	7139                	addi	sp,sp,-64
    8000347c:	fc06                	sd	ra,56(sp)
    8000347e:	f822                	sd	s0,48(sp)
    80003480:	f426                	sd	s1,40(sp)
    80003482:	0080                	addi	s0,sp,64
    80003484:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003486:	00017517          	auipc	a0,0x17
    8000348a:	3d250513          	addi	a0,a0,978 # 8001a858 <ftable>
    8000348e:	472020ef          	jal	80005900 <acquire>
  if(f->ref < 1)
    80003492:	40dc                	lw	a5,4(s1)
    80003494:	04f05a63          	blez	a5,800034e8 <fileclose+0x6e>
    panic("fileclose"); // panic cannot close because it is not used
  // release 1 duplicate
  if(--f->ref > 0){
    80003498:	37fd                	addiw	a5,a5,-1
    8000349a:	0007871b          	sext.w	a4,a5
    8000349e:	c0dc                	sw	a5,4(s1)
    800034a0:	04e04e63          	bgtz	a4,800034fc <fileclose+0x82>
    800034a4:	f04a                	sd	s2,32(sp)
    800034a6:	ec4e                	sd	s3,24(sp)
    800034a8:	e852                	sd	s4,16(sp)
    800034aa:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  //if ref = 0 close file.
  ff = *f;
    800034ac:	0004a903          	lw	s2,0(s1)
    800034b0:	0094ca83          	lbu	s5,9(s1)
    800034b4:	0104ba03          	ld	s4,16(s1)
    800034b8:	0184b983          	ld	s3,24(s1)
  //reset member
  f->ref = 0;
    800034bc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800034c0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800034c4:	00017517          	auipc	a0,0x17
    800034c8:	39450513          	addi	a0,a0,916 # 8001a858 <ftable>
    800034cc:	4cc020ef          	jal	80005998 <release>

  //close pipe if open pipe
  if(ff.type == FD_PIPE){
    800034d0:	4785                	li	a5,1
    800034d2:	04f90063          	beq	s2,a5,80003512 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800034d6:	3979                	addiw	s2,s2,-2
    800034d8:	4785                	li	a5,1
    800034da:	0527f563          	bgeu	a5,s2,80003524 <fileclose+0xaa>
    800034de:	7902                	ld	s2,32(sp)
    800034e0:	69e2                	ld	s3,24(sp)
    800034e2:	6a42                	ld	s4,16(sp)
    800034e4:	6aa2                	ld	s5,8(sp)
    800034e6:	a00d                	j	80003508 <fileclose+0x8e>
    800034e8:	f04a                	sd	s2,32(sp)
    800034ea:	ec4e                	sd	s3,24(sp)
    800034ec:	e852                	sd	s4,16(sp)
    800034ee:	e456                	sd	s5,8(sp)
    panic("fileclose"); // panic cannot close because it is not used
    800034f0:	00004517          	auipc	a0,0x4
    800034f4:	17050513          	addi	a0,a0,368 # 80007660 <etext+0x660>
    800034f8:	0da020ef          	jal	800055d2 <panic>
    release(&ftable.lock);
    800034fc:	00017517          	auipc	a0,0x17
    80003500:	35c50513          	addi	a0,a0,860 # 8001a858 <ftable>
    80003504:	494020ef          	jal	80005998 <release>
    begin_op();
    iput(ff.ip); //release
    end_op();
  }
}
    80003508:	70e2                	ld	ra,56(sp)
    8000350a:	7442                	ld	s0,48(sp)
    8000350c:	74a2                	ld	s1,40(sp)
    8000350e:	6121                	addi	sp,sp,64
    80003510:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003512:	85d6                	mv	a1,s5
    80003514:	8552                	mv	a0,s4
    80003516:	386000ef          	jal	8000389c <pipeclose>
    8000351a:	7902                	ld	s2,32(sp)
    8000351c:	69e2                	ld	s3,24(sp)
    8000351e:	6a42                	ld	s4,16(sp)
    80003520:	6aa2                	ld	s5,8(sp)
    80003522:	b7dd                	j	80003508 <fileclose+0x8e>
    begin_op();
    80003524:	b3dff0ef          	jal	80003060 <begin_op>
    iput(ff.ip); //release
    80003528:	854e                	mv	a0,s3
    8000352a:	c22ff0ef          	jal	8000294c <iput>
    end_op();
    8000352e:	b9dff0ef          	jal	800030ca <end_op>
    80003532:	7902                	ld	s2,32(sp)
    80003534:	69e2                	ld	s3,24(sp)
    80003536:	6a42                	ld	s4,16(sp)
    80003538:	6aa2                	ld	s5,8(sp)
    8000353a:	b7f9                	j	80003508 <fileclose+0x8e>

000000008000353c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000353c:	715d                	addi	sp,sp,-80
    8000353e:	e486                	sd	ra,72(sp)
    80003540:	e0a2                	sd	s0,64(sp)
    80003542:	fc26                	sd	s1,56(sp)
    80003544:	f44e                	sd	s3,40(sp)
    80003546:	0880                	addi	s0,sp,80
    80003548:	84aa                	mv	s1,a0
    8000354a:	89ae                	mv	s3,a1
  struct proc *p = myproc(); //process structure
    8000354c:	85dfd0ef          	jal	80000da8 <myproc>
  struct stat st; // static structure
  
  //get the metadata if the type is inode or device
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003550:	409c                	lw	a5,0(s1)
    80003552:	37f9                	addiw	a5,a5,-2
    80003554:	4705                	li	a4,1
    80003556:	04f76063          	bltu	a4,a5,80003596 <filestat+0x5a>
    8000355a:	f84a                	sd	s2,48(sp)
    8000355c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000355e:	6c88                	ld	a0,24(s1)
    80003560:	a6aff0ef          	jal	800027ca <ilock>
    stati(f->ip, &st); //get the data
    80003564:	fb840593          	addi	a1,s0,-72
    80003568:	6c88                	ld	a0,24(s1)
    8000356a:	c8aff0ef          	jal	800029f4 <stati>
    iunlock(f->ip);
    8000356e:	6c88                	ld	a0,24(s1)
    80003570:	b08ff0ef          	jal	80002878 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0) //Copy the obtained data to the user's memory space
    80003574:	46e1                	li	a3,24
    80003576:	fb840613          	addi	a2,s0,-72
    8000357a:	85ce                	mv	a1,s3
    8000357c:	05093503          	ld	a0,80(s2)
    80003580:	c9afd0ef          	jal	80000a1a <copyout>
    80003584:	41f5551b          	sraiw	a0,a0,0x1f
    80003588:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000358a:	60a6                	ld	ra,72(sp)
    8000358c:	6406                	ld	s0,64(sp)
    8000358e:	74e2                	ld	s1,56(sp)
    80003590:	79a2                	ld	s3,40(sp)
    80003592:	6161                	addi	sp,sp,80
    80003594:	8082                	ret
  return -1;
    80003596:	557d                	li	a0,-1
    80003598:	bfcd                	j	8000358a <filestat+0x4e>

000000008000359a <fileread>:

// Read from file f and copy to address.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000359a:	7179                	addi	sp,sp,-48
    8000359c:	f406                	sd	ra,40(sp)
    8000359e:	f022                	sd	s0,32(sp)
    800035a0:	e84a                	sd	s2,16(sp)
    800035a2:	1800                	addi	s0,sp,48
  int r = 0;
  // check if file can be read or not
  if(f->readable == 0)
    800035a4:	00854783          	lbu	a5,8(a0)
    800035a8:	cfd1                	beqz	a5,80003644 <fileread+0xaa>
    800035aa:	ec26                	sd	s1,24(sp)
    800035ac:	e44e                	sd	s3,8(sp)
    800035ae:	84aa                	mv	s1,a0
    800035b0:	89ae                	mv	s3,a1
    800035b2:	8932                	mv	s2,a2
    return -1;

  //read pipe
  if(f->type == FD_PIPE){
    800035b4:	411c                	lw	a5,0(a0)
    800035b6:	4705                	li	a4,1
    800035b8:	04e78363          	beq	a5,a4,800035fe <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  //read device
  } else if(f->type == FD_DEVICE){
    800035bc:	470d                	li	a4,3
    800035be:	04e78763          	beq	a5,a4,8000360c <fileread+0x72>
    //get the correct device to read from device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  //read inode  
  } else if(f->type == FD_INODE){
    800035c2:	4709                	li	a4,2
    800035c4:	06e79a63          	bne	a5,a4,80003638 <fileread+0x9e>
    ilock(f->ip);
    800035c8:	6d08                	ld	a0,24(a0)
    800035ca:	a00ff0ef          	jal	800027ca <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800035ce:	874a                	mv	a4,s2
    800035d0:	5094                	lw	a3,32(s1)
    800035d2:	864e                	mv	a2,s3
    800035d4:	4585                	li	a1,1
    800035d6:	6c88                	ld	a0,24(s1)
    800035d8:	c46ff0ef          	jal	80002a1e <readi>
    800035dc:	892a                	mv	s2,a0
    800035de:	00a05563          	blez	a0,800035e8 <fileread+0x4e>
      f->off += r;
    800035e2:	509c                	lw	a5,32(s1)
    800035e4:	9fa9                	addw	a5,a5,a0
    800035e6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800035e8:	6c88                	ld	a0,24(s1)
    800035ea:	a8eff0ef          	jal	80002878 <iunlock>
    800035ee:	64e2                	ld	s1,24(sp)
    800035f0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800035f2:	854a                	mv	a0,s2
    800035f4:	70a2                	ld	ra,40(sp)
    800035f6:	7402                	ld	s0,32(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	6145                	addi	sp,sp,48
    800035fc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800035fe:	6908                	ld	a0,16(a0)
    80003600:	3d8000ef          	jal	800039d8 <piperead>
    80003604:	892a                	mv	s2,a0
    80003606:	64e2                	ld	s1,24(sp)
    80003608:	69a2                	ld	s3,8(sp)
    8000360a:	b7e5                	j	800035f2 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000360c:	02451783          	lh	a5,36(a0)
    80003610:	03079693          	slli	a3,a5,0x30
    80003614:	92c1                	srli	a3,a3,0x30
    80003616:	4725                	li	a4,9
    80003618:	02d76863          	bltu	a4,a3,80003648 <fileread+0xae>
    8000361c:	0792                	slli	a5,a5,0x4
    8000361e:	00017717          	auipc	a4,0x17
    80003622:	19a70713          	addi	a4,a4,410 # 8001a7b8 <devsw>
    80003626:	97ba                	add	a5,a5,a4
    80003628:	639c                	ld	a5,0(a5)
    8000362a:	c39d                	beqz	a5,80003650 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000362c:	4505                	li	a0,1
    8000362e:	9782                	jalr	a5
    80003630:	892a                	mv	s2,a0
    80003632:	64e2                	ld	s1,24(sp)
    80003634:	69a2                	ld	s3,8(sp)
    80003636:	bf75                	j	800035f2 <fileread+0x58>
    panic("fileread");
    80003638:	00004517          	auipc	a0,0x4
    8000363c:	03850513          	addi	a0,a0,56 # 80007670 <etext+0x670>
    80003640:	793010ef          	jal	800055d2 <panic>
    return -1;
    80003644:	597d                	li	s2,-1
    80003646:	b775                	j	800035f2 <fileread+0x58>
      return -1;
    80003648:	597d                	li	s2,-1
    8000364a:	64e2                	ld	s1,24(sp)
    8000364c:	69a2                	ld	s3,8(sp)
    8000364e:	b755                	j	800035f2 <fileread+0x58>
    80003650:	597d                	li	s2,-1
    80003652:	64e2                	ld	s1,24(sp)
    80003654:	69a2                	ld	s3,8(sp)
    80003656:	bf71                	j	800035f2 <fileread+0x58>

0000000080003658 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;
  //check if the file can be writen or not
  if(f->writable == 0)
    80003658:	00954783          	lbu	a5,9(a0)
    8000365c:	10078b63          	beqz	a5,80003772 <filewrite+0x11a>
{
    80003660:	715d                	addi	sp,sp,-80
    80003662:	e486                	sd	ra,72(sp)
    80003664:	e0a2                	sd	s0,64(sp)
    80003666:	f84a                	sd	s2,48(sp)
    80003668:	f052                	sd	s4,32(sp)
    8000366a:	e85a                	sd	s6,16(sp)
    8000366c:	0880                	addi	s0,sp,80
    8000366e:	892a                	mv	s2,a0
    80003670:	8b2e                	mv	s6,a1
    80003672:	8a32                	mv	s4,a2
    return -1;

  //write to pipe
  if(f->type == FD_PIPE){
    80003674:	411c                	lw	a5,0(a0)
    80003676:	4705                	li	a4,1
    80003678:	02e78763          	beq	a5,a4,800036a6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000367c:	470d                	li	a4,3
    8000367e:	02e78863          	beq	a5,a4,800036ae <filewrite+0x56>
    //find the correct device from the device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003682:	4709                	li	a4,2
    80003684:	0ce79c63          	bne	a5,a4,8000375c <filewrite+0x104>
    80003688:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000368a:	0ac05863          	blez	a2,8000373a <filewrite+0xe2>
    8000368e:	fc26                	sd	s1,56(sp)
    80003690:	ec56                	sd	s5,24(sp)
    80003692:	e45e                	sd	s7,8(sp)
    80003694:	e062                	sd	s8,0(sp)
    int i = 0;
    80003696:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80003698:	6b85                	lui	s7,0x1
    8000369a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000369e:	6c05                	lui	s8,0x1
    800036a0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800036a4:	a8b5                	j	80003720 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800036a6:	6908                	ld	a0,16(a0)
    800036a8:	24c000ef          	jal	800038f4 <pipewrite>
    800036ac:	a04d                	j	8000374e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800036ae:	02451783          	lh	a5,36(a0)
    800036b2:	03079693          	slli	a3,a5,0x30
    800036b6:	92c1                	srli	a3,a3,0x30
    800036b8:	4725                	li	a4,9
    800036ba:	0ad76e63          	bltu	a4,a3,80003776 <filewrite+0x11e>
    800036be:	0792                	slli	a5,a5,0x4
    800036c0:	00017717          	auipc	a4,0x17
    800036c4:	0f870713          	addi	a4,a4,248 # 8001a7b8 <devsw>
    800036c8:	97ba                	add	a5,a5,a4
    800036ca:	679c                	ld	a5,8(a5)
    800036cc:	c7dd                	beqz	a5,8000377a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800036ce:	4505                	li	a0,1
    800036d0:	9782                	jalr	a5
    800036d2:	a8b5                	j	8000374e <filewrite+0xf6>
      if(n1 > max)
    800036d4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800036d8:	989ff0ef          	jal	80003060 <begin_op>
      ilock(f->ip);
    800036dc:	01893503          	ld	a0,24(s2)
    800036e0:	8eaff0ef          	jal	800027ca <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800036e4:	8756                	mv	a4,s5
    800036e6:	02092683          	lw	a3,32(s2)
    800036ea:	01698633          	add	a2,s3,s6
    800036ee:	4585                	li	a1,1
    800036f0:	01893503          	ld	a0,24(s2)
    800036f4:	c26ff0ef          	jal	80002b1a <writei>
    800036f8:	84aa                	mv	s1,a0
    800036fa:	00a05763          	blez	a0,80003708 <filewrite+0xb0>
        f->off += r;
    800036fe:	02092783          	lw	a5,32(s2)
    80003702:	9fa9                	addw	a5,a5,a0
    80003704:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003708:	01893503          	ld	a0,24(s2)
    8000370c:	96cff0ef          	jal	80002878 <iunlock>
      end_op();
    80003710:	9bbff0ef          	jal	800030ca <end_op>

      if(r != n1){
    80003714:	029a9563          	bne	s5,s1,8000373e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003718:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000371c:	0149da63          	bge	s3,s4,80003730 <filewrite+0xd8>
      int n1 = n - i;
    80003720:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003724:	0004879b          	sext.w	a5,s1
    80003728:	fafbd6e3          	bge	s7,a5,800036d4 <filewrite+0x7c>
    8000372c:	84e2                	mv	s1,s8
    8000372e:	b75d                	j	800036d4 <filewrite+0x7c>
    80003730:	74e2                	ld	s1,56(sp)
    80003732:	6ae2                	ld	s5,24(sp)
    80003734:	6ba2                	ld	s7,8(sp)
    80003736:	6c02                	ld	s8,0(sp)
    80003738:	a039                	j	80003746 <filewrite+0xee>
    int i = 0;
    8000373a:	4981                	li	s3,0
    8000373c:	a029                	j	80003746 <filewrite+0xee>
    8000373e:	74e2                	ld	s1,56(sp)
    80003740:	6ae2                	ld	s5,24(sp)
    80003742:	6ba2                	ld	s7,8(sp)
    80003744:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003746:	033a1c63          	bne	s4,s3,8000377e <filewrite+0x126>
    8000374a:	8552                	mv	a0,s4
    8000374c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000374e:	60a6                	ld	ra,72(sp)
    80003750:	6406                	ld	s0,64(sp)
    80003752:	7942                	ld	s2,48(sp)
    80003754:	7a02                	ld	s4,32(sp)
    80003756:	6b42                	ld	s6,16(sp)
    80003758:	6161                	addi	sp,sp,80
    8000375a:	8082                	ret
    8000375c:	fc26                	sd	s1,56(sp)
    8000375e:	f44e                	sd	s3,40(sp)
    80003760:	ec56                	sd	s5,24(sp)
    80003762:	e45e                	sd	s7,8(sp)
    80003764:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003766:	00004517          	auipc	a0,0x4
    8000376a:	f1a50513          	addi	a0,a0,-230 # 80007680 <etext+0x680>
    8000376e:	665010ef          	jal	800055d2 <panic>
    return -1;
    80003772:	557d                	li	a0,-1
}
    80003774:	8082                	ret
      return -1;
    80003776:	557d                	li	a0,-1
    80003778:	bfd9                	j	8000374e <filewrite+0xf6>
    8000377a:	557d                	li	a0,-1
    8000377c:	bfc9                	j	8000374e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000377e:	557d                	li	a0,-1
    80003780:	79a2                	ld	s3,40(sp)
    80003782:	b7f1                	j	8000374e <filewrite+0xf6>

0000000080003784 <count_open_files>:

uint64 count_open_files(void) {
    80003784:	1101                	addi	sp,sp,-32
    80003786:	ec06                	sd	ra,24(sp)
    80003788:	e822                	sd	s0,16(sp)
    8000378a:	e426                	sd	s1,8(sp)
    8000378c:	1000                	addi	s0,sp,32
  uint64 count = 0;

  acquire(&ftable.lock);
    8000378e:	00017517          	auipc	a0,0x17
    80003792:	0ca50513          	addi	a0,a0,202 # 8001a858 <ftable>
    80003796:	16a020ef          	jal	80005900 <acquire>
  for (int i = 0; i < NFILE; i++) {
    8000379a:	00017797          	auipc	a5,0x17
    8000379e:	0da78793          	addi	a5,a5,218 # 8001a874 <ftable+0x1c>
    800037a2:	00018697          	auipc	a3,0x18
    800037a6:	07268693          	addi	a3,a3,114 # 8001b814 <disk+0x4>
  uint64 count = 0;
    800037aa:	4481                	li	s1,0
    if (ftable.file[i].ref > 0){
    800037ac:	4398                	lw	a4,0(a5)
      count += 1;
    800037ae:	00e02733          	sgtz	a4,a4
    800037b2:	94ba                	add	s1,s1,a4
  for (int i = 0; i < NFILE; i++) {
    800037b4:	02878793          	addi	a5,a5,40
    800037b8:	fed79ae3          	bne	a5,a3,800037ac <count_open_files+0x28>
    }
  }
  release(&ftable.lock);
    800037bc:	00017517          	auipc	a0,0x17
    800037c0:	09c50513          	addi	a0,a0,156 # 8001a858 <ftable>
    800037c4:	1d4020ef          	jal	80005998 <release>

  return count;
    800037c8:	8526                	mv	a0,s1
    800037ca:	60e2                	ld	ra,24(sp)
    800037cc:	6442                	ld	s0,16(sp)
    800037ce:	64a2                	ld	s1,8(sp)
    800037d0:	6105                	addi	sp,sp,32
    800037d2:	8082                	ret

00000000800037d4 <pipealloc>:
};

//nitializes a pipe, and returns two file descriptors: one for read and one for write 
int
pipealloc(struct file **f0, struct file **f1)
{
    800037d4:	7179                	addi	sp,sp,-48
    800037d6:	f406                	sd	ra,40(sp)
    800037d8:	f022                	sd	s0,32(sp)
    800037da:	ec26                	sd	s1,24(sp)
    800037dc:	e052                	sd	s4,0(sp)
    800037de:	1800                	addi	s0,sp,48
    800037e0:	84aa                	mv	s1,a0
    800037e2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  //initialize file descriptors
  pi = 0;
  *f0 = *f1 = 0;
    800037e4:	0005b023          	sd	zero,0(a1)
    800037e8:	00053023          	sd	zero,0(a0)
  //allocate descriptors
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800037ec:	bebff0ef          	jal	800033d6 <filealloc>
    800037f0:	e088                	sd	a0,0(s1)
    800037f2:	c549                	beqz	a0,8000387c <pipealloc+0xa8>
    800037f4:	be3ff0ef          	jal	800033d6 <filealloc>
    800037f8:	00aa3023          	sd	a0,0(s4)
    800037fc:	cd25                	beqz	a0,80003874 <pipealloc+0xa0>
    800037fe:	e84a                	sd	s2,16(sp)
    goto bad;
  //allocate for pipe
  if((pi = (struct pipe*)kalloc()) == 0)
    80003800:	8fffc0ef          	jal	800000fe <kalloc>
    80003804:	892a                	mv	s2,a0
    80003806:	c12d                	beqz	a0,80003868 <pipealloc+0x94>
    80003808:	e44e                	sd	s3,8(sp)
    goto bad;
  //set up values
  pi->readopen = 1;
    8000380a:	4985                	li	s3,1
    8000380c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003810:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003814:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003818:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe"); // init lock
    8000381c:	00004597          	auipc	a1,0x4
    80003820:	be458593          	addi	a1,a1,-1052 # 80007400 <etext+0x400>
    80003824:	05c020ef          	jal	80005880 <initlock>
  //set up values and link file with pipe
  (*f0)->type = FD_PIPE;
    80003828:	609c                	ld	a5,0(s1)
    8000382a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000382e:	609c                	ld	a5,0(s1)
    80003830:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003834:	609c                	ld	a5,0(s1)
    80003836:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000383a:	609c                	ld	a5,0(s1)
    8000383c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003840:	000a3783          	ld	a5,0(s4)
    80003844:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003848:	000a3783          	ld	a5,0(s4)
    8000384c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003850:	000a3783          	ld	a5,0(s4)
    80003854:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003858:	000a3783          	ld	a5,0(s4)
    8000385c:	0127b823          	sd	s2,16(a5)
  return 0;
    80003860:	4501                	li	a0,0
    80003862:	6942                	ld	s2,16(sp)
    80003864:	69a2                	ld	s3,8(sp)
    80003866:	a01d                	j	8000388c <pipealloc+0xb8>

//exception
 bad:
  if(pi)
    kfree((char*)pi); //deallocate pipe
  if(*f0)
    80003868:	6088                	ld	a0,0(s1)
    8000386a:	c119                	beqz	a0,80003870 <pipealloc+0x9c>
    8000386c:	6942                	ld	s2,16(sp)
    8000386e:	a029                	j	80003878 <pipealloc+0xa4>
    80003870:	6942                	ld	s2,16(sp)
    80003872:	a029                	j	8000387c <pipealloc+0xa8>
    80003874:	6088                	ld	a0,0(s1)
    80003876:	c10d                	beqz	a0,80003898 <pipealloc+0xc4>
    fileclose(*f0); //close file and release
    80003878:	c03ff0ef          	jal	8000347a <fileclose>
  if(*f1)
    8000387c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003880:	557d                	li	a0,-1
  if(*f1)
    80003882:	c789                	beqz	a5,8000388c <pipealloc+0xb8>
    fileclose(*f1);
    80003884:	853e                	mv	a0,a5
    80003886:	bf5ff0ef          	jal	8000347a <fileclose>
  return -1;
    8000388a:	557d                	li	a0,-1
}
    8000388c:	70a2                	ld	ra,40(sp)
    8000388e:	7402                	ld	s0,32(sp)
    80003890:	64e2                	ld	s1,24(sp)
    80003892:	6a02                	ld	s4,0(sp)
    80003894:	6145                	addi	sp,sp,48
    80003896:	8082                	ret
  return -1;
    80003898:	557d                	li	a0,-1
    8000389a:	bfcd                	j	8000388c <pipealloc+0xb8>

000000008000389c <pipeclose>:
//Close one end of the pipe (read or write). If both ends are closed, release the pipe's memory.
// writable = 1 => writable = 0
// writable = 0 => readable = 0
void
pipeclose(struct pipe *pi, int writable)
{
    8000389c:	1101                	addi	sp,sp,-32
    8000389e:	ec06                	sd	ra,24(sp)
    800038a0:	e822                	sd	s0,16(sp)
    800038a2:	e426                	sd	s1,8(sp)
    800038a4:	e04a                	sd	s2,0(sp)
    800038a6:	1000                	addi	s0,sp,32
    800038a8:	84aa                	mv	s1,a0
    800038aa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800038ac:	054020ef          	jal	80005900 <acquire>
  if(writable){
    800038b0:	02090763          	beqz	s2,800038de <pipeclose+0x42>
    pi->writeopen = 0;
    800038b4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread); // wake the reader up when the writer close
    800038b8:	21848513          	addi	a0,s1,536
    800038bc:	b0ffd0ef          	jal	800013ca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite); // wake the write up when the reader close
  }
  // if all are close, release the memory
  if(pi->readopen == 0 && pi->writeopen == 0){
    800038c0:	2204b783          	ld	a5,544(s1)
    800038c4:	e785                	bnez	a5,800038ec <pipeclose+0x50>
    release(&pi->lock); // release lock
    800038c6:	8526                	mv	a0,s1
    800038c8:	0d0020ef          	jal	80005998 <release>
    kfree((char*)pi); // deallocate
    800038cc:	8526                	mv	a0,s1
    800038ce:	f4efc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6902                	ld	s2,0(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret
    pi->readopen = 0;
    800038de:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite); // wake the write up when the reader close
    800038e2:	21c48513          	addi	a0,s1,540
    800038e6:	ae5fd0ef          	jal	800013ca <wakeup>
    800038ea:	bfd9                	j	800038c0 <pipeclose+0x24>
    release(&pi->lock);
    800038ec:	8526                	mv	a0,s1
    800038ee:	0aa020ef          	jal	80005998 <release>
}
    800038f2:	b7c5                	j	800038d2 <pipeclose+0x36>

00000000800038f4 <pipewrite>:

//Writes data from the process's memory to the pipe.
int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800038f4:	711d                	addi	sp,sp,-96
    800038f6:	ec86                	sd	ra,88(sp)
    800038f8:	e8a2                	sd	s0,80(sp)
    800038fa:	e4a6                	sd	s1,72(sp)
    800038fc:	e0ca                	sd	s2,64(sp)
    800038fe:	fc4e                	sd	s3,56(sp)
    80003900:	f852                	sd	s4,48(sp)
    80003902:	f456                	sd	s5,40(sp)
    80003904:	1080                	addi	s0,sp,96
    80003906:	84aa                	mv	s1,a0
    80003908:	8aae                	mv	s5,a1
    8000390a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000390c:	c9cfd0ef          	jal	80000da8 <myproc>
    80003910:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003912:	8526                	mv	a0,s1
    80003914:	7ed010ef          	jal	80005900 <acquire>
  while(i < n){
    80003918:	0b405a63          	blez	s4,800039cc <pipewrite+0xd8>
    8000391c:	f05a                	sd	s6,32(sp)
    8000391e:	ec5e                	sd	s7,24(sp)
    80003920:	e862                	sd	s8,16(sp)
  int i = 0;
    80003922:	4901                	li	s2,0
      wakeup(&pi->nread); //wake up reader
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    } else {
      char ch;
      //read each byte from the process's memory (copyin) and write to the pipe's circular buffer
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003924:	5b7d                	li	s6,-1
      wakeup(&pi->nread); //wake up reader
    80003926:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    8000392a:	21c48b93          	addi	s7,s1,540
    8000392e:	a81d                	j	80003964 <pipewrite+0x70>
      release(&pi->lock);
    80003930:	8526                	mv	a0,s1
    80003932:	066020ef          	jal	80005998 <release>
      return -1;
    80003936:	597d                	li	s2,-1
    80003938:	7b02                	ld	s6,32(sp)
    8000393a:	6be2                	ld	s7,24(sp)
    8000393c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000393e:	854a                	mv	a0,s2
    80003940:	60e6                	ld	ra,88(sp)
    80003942:	6446                	ld	s0,80(sp)
    80003944:	64a6                	ld	s1,72(sp)
    80003946:	6906                	ld	s2,64(sp)
    80003948:	79e2                	ld	s3,56(sp)
    8000394a:	7a42                	ld	s4,48(sp)
    8000394c:	7aa2                	ld	s5,40(sp)
    8000394e:	6125                	addi	sp,sp,96
    80003950:	8082                	ret
      wakeup(&pi->nread); //wake up reader
    80003952:	8562                	mv	a0,s8
    80003954:	a77fd0ef          	jal	800013ca <wakeup>
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    80003958:	85a6                	mv	a1,s1
    8000395a:	855e                	mv	a0,s7
    8000395c:	a23fd0ef          	jal	8000137e <sleep>
  while(i < n){
    80003960:	05495b63          	bge	s2,s4,800039b6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003964:	2204a783          	lw	a5,544(s1)
    80003968:	d7e1                	beqz	a5,80003930 <pipewrite+0x3c>
    8000396a:	854e                	mv	a0,s3
    8000396c:	c4bfd0ef          	jal	800015b6 <killed>
    80003970:	f161                	bnez	a0,80003930 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full cannot write more
    80003972:	2184a783          	lw	a5,536(s1)
    80003976:	21c4a703          	lw	a4,540(s1)
    8000397a:	2007879b          	addiw	a5,a5,512
    8000397e:	fcf70ae3          	beq	a4,a5,80003952 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003982:	4685                	li	a3,1
    80003984:	01590633          	add	a2,s2,s5
    80003988:	faf40593          	addi	a1,s0,-81
    8000398c:	0509b503          	ld	a0,80(s3)
    80003990:	960fd0ef          	jal	80000af0 <copyin>
    80003994:	03650e63          	beq	a0,s6,800039d0 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003998:	21c4a783          	lw	a5,540(s1)
    8000399c:	0017871b          	addiw	a4,a5,1
    800039a0:	20e4ae23          	sw	a4,540(s1)
    800039a4:	1ff7f793          	andi	a5,a5,511
    800039a8:	97a6                	add	a5,a5,s1
    800039aa:	faf44703          	lbu	a4,-81(s0)
    800039ae:	00e78c23          	sb	a4,24(a5)
      i++;
    800039b2:	2905                	addiw	s2,s2,1
    800039b4:	b775                	j	80003960 <pipewrite+0x6c>
    800039b6:	7b02                	ld	s6,32(sp)
    800039b8:	6be2                	ld	s7,24(sp)
    800039ba:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800039bc:	21848513          	addi	a0,s1,536
    800039c0:	a0bfd0ef          	jal	800013ca <wakeup>
  release(&pi->lock);
    800039c4:	8526                	mv	a0,s1
    800039c6:	7d3010ef          	jal	80005998 <release>
  return i;
    800039ca:	bf95                	j	8000393e <pipewrite+0x4a>
  int i = 0;
    800039cc:	4901                	li	s2,0
    800039ce:	b7fd                	j	800039bc <pipewrite+0xc8>
    800039d0:	7b02                	ld	s6,32(sp)
    800039d2:	6be2                	ld	s7,24(sp)
    800039d4:	6c42                	ld	s8,16(sp)
    800039d6:	b7dd                	j	800039bc <pipewrite+0xc8>

00000000800039d8 <piperead>:

//Read data from the pipe into the process's memory.
int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800039d8:	715d                	addi	sp,sp,-80
    800039da:	e486                	sd	ra,72(sp)
    800039dc:	e0a2                	sd	s0,64(sp)
    800039de:	fc26                	sd	s1,56(sp)
    800039e0:	f84a                	sd	s2,48(sp)
    800039e2:	f44e                	sd	s3,40(sp)
    800039e4:	f052                	sd	s4,32(sp)
    800039e6:	ec56                	sd	s5,24(sp)
    800039e8:	0880                	addi	s0,sp,80
    800039ea:	84aa                	mv	s1,a0
    800039ec:	892e                	mv	s2,a1
    800039ee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800039f0:	bb8fd0ef          	jal	80000da8 <myproc>
    800039f4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800039f6:	8526                	mv	a0,s1
    800039f8:	709010ef          	jal	80005900 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800039fc:	2184a703          	lw	a4,536(s1)
    80003a00:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    //waiting
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a04:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003a08:	02f71563          	bne	a4,a5,80003a32 <piperead+0x5a>
    80003a0c:	2244a783          	lw	a5,548(s1)
    80003a10:	cb85                	beqz	a5,80003a40 <piperead+0x68>
    if(killed(pr)){
    80003a12:	8552                	mv	a0,s4
    80003a14:	ba3fd0ef          	jal	800015b6 <killed>
    80003a18:	ed19                	bnez	a0,80003a36 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a1a:	85a6                	mv	a1,s1
    80003a1c:	854e                	mv	a0,s3
    80003a1e:	961fd0ef          	jal	8000137e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003a22:	2184a703          	lw	a4,536(s1)
    80003a26:	21c4a783          	lw	a5,540(s1)
    80003a2a:	fef701e3          	beq	a4,a5,80003a0c <piperead+0x34>
    80003a2e:	e85a                	sd	s6,16(sp)
    80003a30:	a809                	j	80003a42 <piperead+0x6a>
    80003a32:	e85a                	sd	s6,16(sp)
    80003a34:	a039                	j	80003a42 <piperead+0x6a>
      release(&pi->lock);
    80003a36:	8526                	mv	a0,s1
    80003a38:	761010ef          	jal	80005998 <release>
      return -1;
    80003a3c:	59fd                	li	s3,-1
    80003a3e:	a8b1                	j	80003a9a <piperead+0xc2>
    80003a40:	e85a                	sd	s6,16(sp)
  }
  //Read each byte from the pipe's circular buffer and write it to the process's memory (copyout).
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a42:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    //increasing nread after reading
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a44:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a46:	05505263          	blez	s5,80003a8a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003a4a:	2184a783          	lw	a5,536(s1)
    80003a4e:	21c4a703          	lw	a4,540(s1)
    80003a52:	02f70c63          	beq	a4,a5,80003a8a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003a56:	0017871b          	addiw	a4,a5,1
    80003a5a:	20e4ac23          	sw	a4,536(s1)
    80003a5e:	1ff7f793          	andi	a5,a5,511
    80003a62:	97a6                	add	a5,a5,s1
    80003a64:	0187c783          	lbu	a5,24(a5)
    80003a68:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a6c:	4685                	li	a3,1
    80003a6e:	fbf40613          	addi	a2,s0,-65
    80003a72:	85ca                	mv	a1,s2
    80003a74:	050a3503          	ld	a0,80(s4)
    80003a78:	fa3fc0ef          	jal	80000a1a <copyout>
    80003a7c:	01650763          	beq	a0,s6,80003a8a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a80:	2985                	addiw	s3,s3,1
    80003a82:	0905                	addi	s2,s2,1
    80003a84:	fd3a93e3          	bne	s5,s3,80003a4a <piperead+0x72>
    80003a88:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003a8a:	21c48513          	addi	a0,s1,540
    80003a8e:	93dfd0ef          	jal	800013ca <wakeup>
  release(&pi->lock);
    80003a92:	8526                	mv	a0,s1
    80003a94:	705010ef          	jal	80005998 <release>
    80003a98:	6b42                	ld	s6,16(sp)
  return i;
}
    80003a9a:	854e                	mv	a0,s3
    80003a9c:	60a6                	ld	ra,72(sp)
    80003a9e:	6406                	ld	s0,64(sp)
    80003aa0:	74e2                	ld	s1,56(sp)
    80003aa2:	7942                	ld	s2,48(sp)
    80003aa4:	79a2                	ld	s3,40(sp)
    80003aa6:	7a02                	ld	s4,32(sp)
    80003aa8:	6ae2                	ld	s5,24(sp)
    80003aaa:	6161                	addi	sp,sp,80
    80003aac:	8082                	ret

0000000080003aae <flags2perm>:
//Load file contents into memory
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

//convert ELF flag into type of access  
int flags2perm(int flags)
{
    80003aae:	1141                	addi	sp,sp,-16
    80003ab0:	e422                	sd	s0,8(sp)
    80003ab2:	0800                	addi	s0,sp,16
    80003ab4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003ab6:	8905                	andi	a0,a0,1
    80003ab8:	050e                	slli	a0,a0,0x3
      perm = PTE_X; //execute access
    if(flags & 0x2)
    80003aba:	8b89                	andi	a5,a5,2
    80003abc:	c399                	beqz	a5,80003ac2 <flags2perm+0x14>
      perm |= PTE_W; //write access
    80003abe:	00456513          	ori	a0,a0,4
    return perm;
}
    80003ac2:	6422                	ld	s0,8(sp)
    80003ac4:	0141                	addi	sp,sp,16
    80003ac6:	8082                	ret

0000000080003ac8 <exec>:

//execute file
int
exec(char *path, char **argv)
{
    80003ac8:	df010113          	addi	sp,sp,-528
    80003acc:	20113423          	sd	ra,520(sp)
    80003ad0:	20813023          	sd	s0,512(sp)
    80003ad4:	ffa6                	sd	s1,504(sp)
    80003ad6:	fbca                	sd	s2,496(sp)
    80003ad8:	0c00                	addi	s0,sp,528
    80003ada:	892a                	mv	s2,a0
    80003adc:	dea43c23          	sd	a0,-520(s0)
    80003ae0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003ae4:	ac4fd0ef          	jal	80000da8 <myproc>
    80003ae8:	84aa                	mv	s1,a0

// open execute file
  begin_op(); //begin a transaction of file system
    80003aea:	d76ff0ef          	jal	80003060 <begin_op>

  if((ip = namei(path)) == 0){ //find inode 
    80003aee:	854a                	mv	a0,s2
    80003af0:	bb4ff0ef          	jal	80002ea4 <namei>
    80003af4:	c931                	beqz	a0,80003b48 <exec+0x80>
    80003af6:	f3d2                	sd	s4,480(sp)
    80003af8:	8a2a                	mv	s4,a0
    end_op(); // end transaction
    return -1;
  }
  ilock(ip); //lock inode to make sure that inode can not be modified during executing
    80003afa:	cd1fe0ef          	jal	800027ca <ilock>

  //read and check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) //read
    80003afe:	04000713          	li	a4,64
    80003b02:	4681                	li	a3,0
    80003b04:	e5040613          	addi	a2,s0,-432
    80003b08:	4581                	li	a1,0
    80003b0a:	8552                	mv	a0,s4
    80003b0c:	f13fe0ef          	jal	80002a1e <readi>
    80003b10:	04000793          	li	a5,64
    80003b14:	00f51a63          	bne	a0,a5,80003b28 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC) //check
    80003b18:	e5042703          	lw	a4,-432(s0)
    80003b1c:	464c47b7          	lui	a5,0x464c4
    80003b20:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003b24:	02f70663          	beq	a4,a5,80003b50 <exec+0x88>
//handle the unvalid
 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003b28:	8552                	mv	a0,s4
    80003b2a:	eabfe0ef          	jal	800029d4 <iunlockput>
    end_op();
    80003b2e:	d9cff0ef          	jal	800030ca <end_op>
  }
  return -1;
    80003b32:	557d                	li	a0,-1
    80003b34:	7a1e                	ld	s4,480(sp)
}
    80003b36:	20813083          	ld	ra,520(sp)
    80003b3a:	20013403          	ld	s0,512(sp)
    80003b3e:	74fe                	ld	s1,504(sp)
    80003b40:	795e                	ld	s2,496(sp)
    80003b42:	21010113          	addi	sp,sp,528
    80003b46:	8082                	ret
    end_op(); // end transaction
    80003b48:	d82ff0ef          	jal	800030ca <end_op>
    return -1;
    80003b4c:	557d                	li	a0,-1
    80003b4e:	b7e5                	j	80003b36 <exec+0x6e>
    80003b50:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0) //create new pagetable for executing
    80003b52:	8526                	mv	a0,s1
    80003b54:	afcfd0ef          	jal	80000e50 <proc_pagetable>
    80003b58:	8b2a                	mv	s6,a0
    80003b5a:	2c050b63          	beqz	a0,80003e30 <exec+0x368>
    80003b5e:	f7ce                	sd	s3,488(sp)
    80003b60:	efd6                	sd	s5,472(sp)
    80003b62:	e7de                	sd	s7,456(sp)
    80003b64:	e3e2                	sd	s8,448(sp)
    80003b66:	ff66                	sd	s9,440(sp)
    80003b68:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b6a:	e7042d03          	lw	s10,-400(s0)
    80003b6e:	e8845783          	lhu	a5,-376(s0)
    80003b72:	12078963          	beqz	a5,80003ca4 <exec+0x1dc>
    80003b76:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b78:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b7a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003b7c:	6c85                	lui	s9,0x1
    80003b7e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003b82:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003b86:	6a85                	lui	s5,0x1
    80003b88:	a085                	j	80003be8 <exec+0x120>
      panic("loadseg: address should exist");
    80003b8a:	00004517          	auipc	a0,0x4
    80003b8e:	b0650513          	addi	a0,a0,-1274 # 80007690 <etext+0x690>
    80003b92:	241010ef          	jal	800055d2 <panic>
    if(sz - i < PGSIZE)
    80003b96:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003b98:	8726                	mv	a4,s1
    80003b9a:	012c06bb          	addw	a3,s8,s2
    80003b9e:	4581                	li	a1,0
    80003ba0:	8552                	mv	a0,s4
    80003ba2:	e7dfe0ef          	jal	80002a1e <readi>
    80003ba6:	2501                	sext.w	a0,a0
    80003ba8:	24a49a63          	bne	s1,a0,80003dfc <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003bac:	012a893b          	addw	s2,s5,s2
    80003bb0:	03397363          	bgeu	s2,s3,80003bd6 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003bb4:	02091593          	slli	a1,s2,0x20
    80003bb8:	9181                	srli	a1,a1,0x20
    80003bba:	95de                	add	a1,a1,s7
    80003bbc:	855a                	mv	a0,s6
    80003bbe:	8e1fc0ef          	jal	8000049e <walkaddr>
    80003bc2:	862a                	mv	a2,a0
    if(pa == 0)
    80003bc4:	d179                	beqz	a0,80003b8a <exec+0xc2>
    if(sz - i < PGSIZE)
    80003bc6:	412984bb          	subw	s1,s3,s2
    80003bca:	0004879b          	sext.w	a5,s1
    80003bce:	fcfcf4e3          	bgeu	s9,a5,80003b96 <exec+0xce>
    80003bd2:	84d6                	mv	s1,s5
    80003bd4:	b7c9                	j	80003b96 <exec+0xce>
    sz = sz1;
    80003bd6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003bda:	2d85                	addiw	s11,s11,1
    80003bdc:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003be0:	e8845783          	lhu	a5,-376(s0)
    80003be4:	08fdd063          	bge	s11,a5,80003c64 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003be8:	2d01                	sext.w	s10,s10
    80003bea:	03800713          	li	a4,56
    80003bee:	86ea                	mv	a3,s10
    80003bf0:	e1840613          	addi	a2,s0,-488
    80003bf4:	4581                	li	a1,0
    80003bf6:	8552                	mv	a0,s4
    80003bf8:	e27fe0ef          	jal	80002a1e <readi>
    80003bfc:	03800793          	li	a5,56
    80003c00:	1cf51663          	bne	a0,a5,80003dcc <exec+0x304>
    if(ph.type != ELF_PROG_LOAD) //checks if a segment is the type to load into memory 
    80003c04:	e1842783          	lw	a5,-488(s0)
    80003c08:	4705                	li	a4,1
    80003c0a:	fce798e3          	bne	a5,a4,80003bda <exec+0x112>
    if(ph.memsz < ph.filesz) //memory size >= file size
    80003c0e:	e4043483          	ld	s1,-448(s0)
    80003c12:	e3843783          	ld	a5,-456(s0)
    80003c16:	1af4ef63          	bltu	s1,a5,80003dd4 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr) //address must align to the page size
    80003c1a:	e2843783          	ld	a5,-472(s0)
    80003c1e:	94be                	add	s1,s1,a5
    80003c20:	1af4ee63          	bltu	s1,a5,80003ddc <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003c24:	df043703          	ld	a4,-528(s0)
    80003c28:	8ff9                	and	a5,a5,a4
    80003c2a:	1a079d63          	bnez	a5,80003de4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)//allocate memory for segment
    80003c2e:	e1c42503          	lw	a0,-484(s0)
    80003c32:	e7dff0ef          	jal	80003aae <flags2perm>
    80003c36:	86aa                	mv	a3,a0
    80003c38:	8626                	mv	a2,s1
    80003c3a:	85ca                	mv	a1,s2
    80003c3c:	855a                	mv	a0,s6
    80003c3e:	bc9fc0ef          	jal	80000806 <uvmalloc>
    80003c42:	e0a43423          	sd	a0,-504(s0)
    80003c46:	1a050363          	beqz	a0,80003dec <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0) //Load file contents into memory
    80003c4a:	e2843b83          	ld	s7,-472(s0)
    80003c4e:	e2042c03          	lw	s8,-480(s0)
    80003c52:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003c56:	00098463          	beqz	s3,80003c5e <exec+0x196>
    80003c5a:	4901                	li	s2,0
    80003c5c:	bfa1                	j	80003bb4 <exec+0xec>
    sz = sz1;
    80003c5e:	e0843903          	ld	s2,-504(s0)
    80003c62:	bfa5                	j	80003bda <exec+0x112>
    80003c64:	7dba                	ld	s11,424(sp)
  iunlockput(ip); //unlock ip
    80003c66:	8552                	mv	a0,s4
    80003c68:	d6dfe0ef          	jal	800029d4 <iunlockput>
  end_op(); // end transaction
    80003c6c:	c5eff0ef          	jal	800030ca <end_op>
  p = myproc();
    80003c70:	938fd0ef          	jal	80000da8 <myproc>
    80003c74:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003c76:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz); //round the value
    80003c7a:	6985                	lui	s3,0x1
    80003c7c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003c7e:	99ca                	add	s3,s3,s2
    80003c80:	77fd                	lui	a5,0xfffff
    80003c82:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0) //allocate stack space in memory.
    80003c86:	4691                	li	a3,4
    80003c88:	660d                	lui	a2,0x3
    80003c8a:	964e                	add	a2,a2,s3
    80003c8c:	85ce                	mv	a1,s3
    80003c8e:	855a                	mv	a0,s6
    80003c90:	b77fc0ef          	jal	80000806 <uvmalloc>
    80003c94:	892a                	mv	s2,a0
    80003c96:	e0a43423          	sd	a0,-504(s0)
    80003c9a:	e519                	bnez	a0,80003ca8 <exec+0x1e0>
  if(pagetable)
    80003c9c:	e1343423          	sd	s3,-504(s0)
    80003ca0:	4a01                	li	s4,0
    80003ca2:	aab1                	j	80003dfe <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ca4:	4901                	li	s2,0
    80003ca6:	b7c1                	j	80003c66 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE); //makes the first page inaccessible, acting as a "stack guard".
    80003ca8:	75f5                	lui	a1,0xffffd
    80003caa:	95aa                	add	a1,a1,a0
    80003cac:	855a                	mv	a0,s6
    80003cae:	d43fc0ef          	jal	800009f0 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003cb2:	7bf9                	lui	s7,0xffffe
    80003cb4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003cb6:	e0043783          	ld	a5,-512(s0)
    80003cba:	6388                	ld	a0,0(a5)
    80003cbc:	cd39                	beqz	a0,80003d1a <exec+0x252>
    80003cbe:	e9040993          	addi	s3,s0,-368
    80003cc2:	f9040c13          	addi	s8,s0,-112
    80003cc6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003cc8:	e38fc0ef          	jal	80000300 <strlen>
    80003ccc:	0015079b          	addiw	a5,a0,1
    80003cd0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003cd4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003cd8:	11796e63          	bltu	s2,s7,80003df4 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003cdc:	e0043d03          	ld	s10,-512(s0)
    80003ce0:	000d3a03          	ld	s4,0(s10)
    80003ce4:	8552                	mv	a0,s4
    80003ce6:	e1afc0ef          	jal	80000300 <strlen>
    80003cea:	0015069b          	addiw	a3,a0,1
    80003cee:	8652                	mv	a2,s4
    80003cf0:	85ca                	mv	a1,s2
    80003cf2:	855a                	mv	a0,s6
    80003cf4:	d27fc0ef          	jal	80000a1a <copyout>
    80003cf8:	10054063          	bltz	a0,80003df8 <exec+0x330>
    ustack[argc] = sp;
    80003cfc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003d00:	0485                	addi	s1,s1,1
    80003d02:	008d0793          	addi	a5,s10,8
    80003d06:	e0f43023          	sd	a5,-512(s0)
    80003d0a:	008d3503          	ld	a0,8(s10)
    80003d0e:	c909                	beqz	a0,80003d20 <exec+0x258>
    if(argc >= MAXARG)
    80003d10:	09a1                	addi	s3,s3,8
    80003d12:	fb899be3          	bne	s3,s8,80003cc8 <exec+0x200>
  ip = 0;
    80003d16:	4a01                	li	s4,0
    80003d18:	a0dd                	j	80003dfe <exec+0x336>
  sp = sz;
    80003d1a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003d1e:	4481                	li	s1,0
  ustack[argc] = 0;
    80003d20:	00349793          	slli	a5,s1,0x3
    80003d24:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb540>
    80003d28:	97a2                	add	a5,a5,s0
    80003d2a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003d2e:	00148693          	addi	a3,s1,1
    80003d32:	068e                	slli	a3,a3,0x3
    80003d34:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003d38:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003d3c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003d40:	f5796ee3          	bltu	s2,s7,80003c9c <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003d44:	e9040613          	addi	a2,s0,-368
    80003d48:	85ca                	mv	a1,s2
    80003d4a:	855a                	mv	a0,s6
    80003d4c:	ccffc0ef          	jal	80000a1a <copyout>
    80003d50:	0e054263          	bltz	a0,80003e34 <exec+0x36c>
  p->trapframe->a1 = sp;
    80003d54:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003d58:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003d5c:	df843783          	ld	a5,-520(s0)
    80003d60:	0007c703          	lbu	a4,0(a5)
    80003d64:	cf11                	beqz	a4,80003d80 <exec+0x2b8>
    80003d66:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003d68:	02f00693          	li	a3,47
    80003d6c:	a039                	j	80003d7a <exec+0x2b2>
      last = s+1;
    80003d6e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003d72:	0785                	addi	a5,a5,1
    80003d74:	fff7c703          	lbu	a4,-1(a5)
    80003d78:	c701                	beqz	a4,80003d80 <exec+0x2b8>
    if(*s == '/')
    80003d7a:	fed71ce3          	bne	a4,a3,80003d72 <exec+0x2aa>
    80003d7e:	bfc5                	j	80003d6e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003d80:	4641                	li	a2,16
    80003d82:	df843583          	ld	a1,-520(s0)
    80003d86:	158a8513          	addi	a0,s5,344
    80003d8a:	d44fc0ef          	jal	800002ce <safestrcpy>
  oldpagetable = p->pagetable;
    80003d8e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003d92:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003d96:	e0843783          	ld	a5,-504(s0)
    80003d9a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003d9e:	058ab783          	ld	a5,88(s5)
    80003da2:	e6843703          	ld	a4,-408(s0)
    80003da6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003da8:	058ab783          	ld	a5,88(s5)
    80003dac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); //deallocate the old page table
    80003db0:	85e6                	mv	a1,s9
    80003db2:	922fd0ef          	jal	80000ed4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003db6:	0004851b          	sext.w	a0,s1
    80003dba:	79be                	ld	s3,488(sp)
    80003dbc:	7a1e                	ld	s4,480(sp)
    80003dbe:	6afe                	ld	s5,472(sp)
    80003dc0:	6b5e                	ld	s6,464(sp)
    80003dc2:	6bbe                	ld	s7,456(sp)
    80003dc4:	6c1e                	ld	s8,448(sp)
    80003dc6:	7cfa                	ld	s9,440(sp)
    80003dc8:	7d5a                	ld	s10,432(sp)
    80003dca:	b3b5                	j	80003b36 <exec+0x6e>
    80003dcc:	e1243423          	sd	s2,-504(s0)
    80003dd0:	7dba                	ld	s11,424(sp)
    80003dd2:	a035                	j	80003dfe <exec+0x336>
    80003dd4:	e1243423          	sd	s2,-504(s0)
    80003dd8:	7dba                	ld	s11,424(sp)
    80003dda:	a015                	j	80003dfe <exec+0x336>
    80003ddc:	e1243423          	sd	s2,-504(s0)
    80003de0:	7dba                	ld	s11,424(sp)
    80003de2:	a831                	j	80003dfe <exec+0x336>
    80003de4:	e1243423          	sd	s2,-504(s0)
    80003de8:	7dba                	ld	s11,424(sp)
    80003dea:	a811                	j	80003dfe <exec+0x336>
    80003dec:	e1243423          	sd	s2,-504(s0)
    80003df0:	7dba                	ld	s11,424(sp)
    80003df2:	a031                	j	80003dfe <exec+0x336>
  ip = 0;
    80003df4:	4a01                	li	s4,0
    80003df6:	a021                	j	80003dfe <exec+0x336>
    80003df8:	4a01                	li	s4,0
  if(pagetable)
    80003dfa:	a011                	j	80003dfe <exec+0x336>
    80003dfc:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003dfe:	e0843583          	ld	a1,-504(s0)
    80003e02:	855a                	mv	a0,s6
    80003e04:	8d0fd0ef          	jal	80000ed4 <proc_freepagetable>
  return -1;
    80003e08:	557d                	li	a0,-1
  if(ip){
    80003e0a:	000a1b63          	bnez	s4,80003e20 <exec+0x358>
    80003e0e:	79be                	ld	s3,488(sp)
    80003e10:	7a1e                	ld	s4,480(sp)
    80003e12:	6afe                	ld	s5,472(sp)
    80003e14:	6b5e                	ld	s6,464(sp)
    80003e16:	6bbe                	ld	s7,456(sp)
    80003e18:	6c1e                	ld	s8,448(sp)
    80003e1a:	7cfa                	ld	s9,440(sp)
    80003e1c:	7d5a                	ld	s10,432(sp)
    80003e1e:	bb21                	j	80003b36 <exec+0x6e>
    80003e20:	79be                	ld	s3,488(sp)
    80003e22:	6afe                	ld	s5,472(sp)
    80003e24:	6b5e                	ld	s6,464(sp)
    80003e26:	6bbe                	ld	s7,456(sp)
    80003e28:	6c1e                	ld	s8,448(sp)
    80003e2a:	7cfa                	ld	s9,440(sp)
    80003e2c:	7d5a                	ld	s10,432(sp)
    80003e2e:	b9ed                	j	80003b28 <exec+0x60>
    80003e30:	6b5e                	ld	s6,464(sp)
    80003e32:	b9dd                	j	80003b28 <exec+0x60>
  sz = sz1;
    80003e34:	e0843983          	ld	s3,-504(s0)
    80003e38:	b595                	j	80003c9c <exec+0x1d4>

0000000080003e3a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003e3a:	7179                	addi	sp,sp,-48
    80003e3c:	f406                	sd	ra,40(sp)
    80003e3e:	f022                	sd	s0,32(sp)
    80003e40:	ec26                	sd	s1,24(sp)
    80003e42:	e84a                	sd	s2,16(sp)
    80003e44:	1800                	addi	s0,sp,48
    80003e46:	892e                	mv	s2,a1
    80003e48:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003e4a:	fdc40593          	addi	a1,s0,-36
    80003e4e:	e45fd0ef          	jal	80001c92 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003e52:	fdc42703          	lw	a4,-36(s0)
    80003e56:	47bd                	li	a5,15
    80003e58:	02e7e963          	bltu	a5,a4,80003e8a <argfd+0x50>
    80003e5c:	f4dfc0ef          	jal	80000da8 <myproc>
    80003e60:	fdc42703          	lw	a4,-36(s0)
    80003e64:	01a70793          	addi	a5,a4,26
    80003e68:	078e                	slli	a5,a5,0x3
    80003e6a:	953e                	add	a0,a0,a5
    80003e6c:	611c                	ld	a5,0(a0)
    80003e6e:	c385                	beqz	a5,80003e8e <argfd+0x54>
    return -1;
  if(pfd)
    80003e70:	00090463          	beqz	s2,80003e78 <argfd+0x3e>
    *pfd = fd;
    80003e74:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003e78:	4501                	li	a0,0
  if(pf)
    80003e7a:	c091                	beqz	s1,80003e7e <argfd+0x44>
    *pf = f;
    80003e7c:	e09c                	sd	a5,0(s1)
}
    80003e7e:	70a2                	ld	ra,40(sp)
    80003e80:	7402                	ld	s0,32(sp)
    80003e82:	64e2                	ld	s1,24(sp)
    80003e84:	6942                	ld	s2,16(sp)
    80003e86:	6145                	addi	sp,sp,48
    80003e88:	8082                	ret
    return -1;
    80003e8a:	557d                	li	a0,-1
    80003e8c:	bfcd                	j	80003e7e <argfd+0x44>
    80003e8e:	557d                	li	a0,-1
    80003e90:	b7fd                	j	80003e7e <argfd+0x44>

0000000080003e92 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003e92:	1101                	addi	sp,sp,-32
    80003e94:	ec06                	sd	ra,24(sp)
    80003e96:	e822                	sd	s0,16(sp)
    80003e98:	e426                	sd	s1,8(sp)
    80003e9a:	1000                	addi	s0,sp,32
    80003e9c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003e9e:	f0bfc0ef          	jal	80000da8 <myproc>
    80003ea2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003ea4:	0d050793          	addi	a5,a0,208
    80003ea8:	4501                	li	a0,0
    80003eaa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003eac:	6398                	ld	a4,0(a5)
    80003eae:	cb19                	beqz	a4,80003ec4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003eb0:	2505                	addiw	a0,a0,1
    80003eb2:	07a1                	addi	a5,a5,8
    80003eb4:	fed51ce3          	bne	a0,a3,80003eac <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003eb8:	557d                	li	a0,-1
}
    80003eba:	60e2                	ld	ra,24(sp)
    80003ebc:	6442                	ld	s0,16(sp)
    80003ebe:	64a2                	ld	s1,8(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret
      p->ofile[fd] = f;
    80003ec4:	01a50793          	addi	a5,a0,26
    80003ec8:	078e                	slli	a5,a5,0x3
    80003eca:	963e                	add	a2,a2,a5
    80003ecc:	e204                	sd	s1,0(a2)
      return fd;
    80003ece:	b7f5                	j	80003eba <fdalloc+0x28>

0000000080003ed0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003ed0:	715d                	addi	sp,sp,-80
    80003ed2:	e486                	sd	ra,72(sp)
    80003ed4:	e0a2                	sd	s0,64(sp)
    80003ed6:	fc26                	sd	s1,56(sp)
    80003ed8:	f84a                	sd	s2,48(sp)
    80003eda:	f44e                	sd	s3,40(sp)
    80003edc:	ec56                	sd	s5,24(sp)
    80003ede:	e85a                	sd	s6,16(sp)
    80003ee0:	0880                	addi	s0,sp,80
    80003ee2:	8b2e                	mv	s6,a1
    80003ee4:	89b2                	mv	s3,a2
    80003ee6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003ee8:	fb040593          	addi	a1,s0,-80
    80003eec:	fd3fe0ef          	jal	80002ebe <nameiparent>
    80003ef0:	84aa                	mv	s1,a0
    80003ef2:	10050a63          	beqz	a0,80004006 <create+0x136>
    return 0;

  ilock(dp);
    80003ef6:	8d5fe0ef          	jal	800027ca <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003efa:	4601                	li	a2,0
    80003efc:	fb040593          	addi	a1,s0,-80
    80003f00:	8526                	mv	a0,s1
    80003f02:	d3dfe0ef          	jal	80002c3e <dirlookup>
    80003f06:	8aaa                	mv	s5,a0
    80003f08:	c129                	beqz	a0,80003f4a <create+0x7a>
    iunlockput(dp);
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	ac9fe0ef          	jal	800029d4 <iunlockput>
    ilock(ip);
    80003f10:	8556                	mv	a0,s5
    80003f12:	8b9fe0ef          	jal	800027ca <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003f16:	4789                	li	a5,2
    80003f18:	02fb1463          	bne	s6,a5,80003f40 <create+0x70>
    80003f1c:	044ad783          	lhu	a5,68(s5)
    80003f20:	37f9                	addiw	a5,a5,-2
    80003f22:	17c2                	slli	a5,a5,0x30
    80003f24:	93c1                	srli	a5,a5,0x30
    80003f26:	4705                	li	a4,1
    80003f28:	00f76c63          	bltu	a4,a5,80003f40 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	60a6                	ld	ra,72(sp)
    80003f30:	6406                	ld	s0,64(sp)
    80003f32:	74e2                	ld	s1,56(sp)
    80003f34:	7942                	ld	s2,48(sp)
    80003f36:	79a2                	ld	s3,40(sp)
    80003f38:	6ae2                	ld	s5,24(sp)
    80003f3a:	6b42                	ld	s6,16(sp)
    80003f3c:	6161                	addi	sp,sp,80
    80003f3e:	8082                	ret
    iunlockput(ip);
    80003f40:	8556                	mv	a0,s5
    80003f42:	a93fe0ef          	jal	800029d4 <iunlockput>
    return 0;
    80003f46:	4a81                	li	s5,0
    80003f48:	b7d5                	j	80003f2c <create+0x5c>
    80003f4a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003f4c:	85da                	mv	a1,s6
    80003f4e:	4088                	lw	a0,0(s1)
    80003f50:	f0afe0ef          	jal	8000265a <ialloc>
    80003f54:	8a2a                	mv	s4,a0
    80003f56:	cd15                	beqz	a0,80003f92 <create+0xc2>
  ilock(ip);
    80003f58:	873fe0ef          	jal	800027ca <ilock>
  ip->major = major;
    80003f5c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003f60:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003f64:	4905                	li	s2,1
    80003f66:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	faafe0ef          	jal	80002716 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003f70:	032b0763          	beq	s6,s2,80003f9e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f74:	004a2603          	lw	a2,4(s4)
    80003f78:	fb040593          	addi	a1,s0,-80
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	e8dfe0ef          	jal	80002e0a <dirlink>
    80003f82:	06054563          	bltz	a0,80003fec <create+0x11c>
  iunlockput(dp);
    80003f86:	8526                	mv	a0,s1
    80003f88:	a4dfe0ef          	jal	800029d4 <iunlockput>
  return ip;
    80003f8c:	8ad2                	mv	s5,s4
    80003f8e:	7a02                	ld	s4,32(sp)
    80003f90:	bf71                	j	80003f2c <create+0x5c>
    iunlockput(dp);
    80003f92:	8526                	mv	a0,s1
    80003f94:	a41fe0ef          	jal	800029d4 <iunlockput>
    return 0;
    80003f98:	8ad2                	mv	s5,s4
    80003f9a:	7a02                	ld	s4,32(sp)
    80003f9c:	bf41                	j	80003f2c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003f9e:	004a2603          	lw	a2,4(s4)
    80003fa2:	00003597          	auipc	a1,0x3
    80003fa6:	70e58593          	addi	a1,a1,1806 # 800076b0 <etext+0x6b0>
    80003faa:	8552                	mv	a0,s4
    80003fac:	e5ffe0ef          	jal	80002e0a <dirlink>
    80003fb0:	02054e63          	bltz	a0,80003fec <create+0x11c>
    80003fb4:	40d0                	lw	a2,4(s1)
    80003fb6:	00003597          	auipc	a1,0x3
    80003fba:	70258593          	addi	a1,a1,1794 # 800076b8 <etext+0x6b8>
    80003fbe:	8552                	mv	a0,s4
    80003fc0:	e4bfe0ef          	jal	80002e0a <dirlink>
    80003fc4:	02054463          	bltz	a0,80003fec <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003fc8:	004a2603          	lw	a2,4(s4)
    80003fcc:	fb040593          	addi	a1,s0,-80
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	e39fe0ef          	jal	80002e0a <dirlink>
    80003fd6:	00054b63          	bltz	a0,80003fec <create+0x11c>
    dp->nlink++;  // for ".."
    80003fda:	04a4d783          	lhu	a5,74(s1)
    80003fde:	2785                	addiw	a5,a5,1
    80003fe0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	f30fe0ef          	jal	80002716 <iupdate>
    80003fea:	bf71                	j	80003f86 <create+0xb6>
  ip->nlink = 0;
    80003fec:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003ff0:	8552                	mv	a0,s4
    80003ff2:	f24fe0ef          	jal	80002716 <iupdate>
  iunlockput(ip);
    80003ff6:	8552                	mv	a0,s4
    80003ff8:	9ddfe0ef          	jal	800029d4 <iunlockput>
  iunlockput(dp);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	9d7fe0ef          	jal	800029d4 <iunlockput>
  return 0;
    80004002:	7a02                	ld	s4,32(sp)
    80004004:	b725                	j	80003f2c <create+0x5c>
    return 0;
    80004006:	8aaa                	mv	s5,a0
    80004008:	b715                	j	80003f2c <create+0x5c>

000000008000400a <sys_dup>:
{
    8000400a:	7179                	addi	sp,sp,-48
    8000400c:	f406                	sd	ra,40(sp)
    8000400e:	f022                	sd	s0,32(sp)
    80004010:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004012:	fd840613          	addi	a2,s0,-40
    80004016:	4581                	li	a1,0
    80004018:	4501                	li	a0,0
    8000401a:	e21ff0ef          	jal	80003e3a <argfd>
    return -1;
    8000401e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004020:	02054363          	bltz	a0,80004046 <sys_dup+0x3c>
    80004024:	ec26                	sd	s1,24(sp)
    80004026:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004028:	fd843903          	ld	s2,-40(s0)
    8000402c:	854a                	mv	a0,s2
    8000402e:	e65ff0ef          	jal	80003e92 <fdalloc>
    80004032:	84aa                	mv	s1,a0
    return -1;
    80004034:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004036:	00054d63          	bltz	a0,80004050 <sys_dup+0x46>
  filedup(f);
    8000403a:	854a                	mv	a0,s2
    8000403c:	bf8ff0ef          	jal	80003434 <filedup>
  return fd;
    80004040:	87a6                	mv	a5,s1
    80004042:	64e2                	ld	s1,24(sp)
    80004044:	6942                	ld	s2,16(sp)
}
    80004046:	853e                	mv	a0,a5
    80004048:	70a2                	ld	ra,40(sp)
    8000404a:	7402                	ld	s0,32(sp)
    8000404c:	6145                	addi	sp,sp,48
    8000404e:	8082                	ret
    80004050:	64e2                	ld	s1,24(sp)
    80004052:	6942                	ld	s2,16(sp)
    80004054:	bfcd                	j	80004046 <sys_dup+0x3c>

0000000080004056 <sys_read>:
{
    80004056:	7179                	addi	sp,sp,-48
    80004058:	f406                	sd	ra,40(sp)
    8000405a:	f022                	sd	s0,32(sp)
    8000405c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000405e:	fd840593          	addi	a1,s0,-40
    80004062:	4505                	li	a0,1
    80004064:	c4bfd0ef          	jal	80001cae <argaddr>
  argint(2, &n);
    80004068:	fe440593          	addi	a1,s0,-28
    8000406c:	4509                	li	a0,2
    8000406e:	c25fd0ef          	jal	80001c92 <argint>
  if(argfd(0, 0, &f) < 0)
    80004072:	fe840613          	addi	a2,s0,-24
    80004076:	4581                	li	a1,0
    80004078:	4501                	li	a0,0
    8000407a:	dc1ff0ef          	jal	80003e3a <argfd>
    8000407e:	87aa                	mv	a5,a0
    return -1;
    80004080:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004082:	0007ca63          	bltz	a5,80004096 <sys_read+0x40>
  return fileread(f, p, n);
    80004086:	fe442603          	lw	a2,-28(s0)
    8000408a:	fd843583          	ld	a1,-40(s0)
    8000408e:	fe843503          	ld	a0,-24(s0)
    80004092:	d08ff0ef          	jal	8000359a <fileread>
}
    80004096:	70a2                	ld	ra,40(sp)
    80004098:	7402                	ld	s0,32(sp)
    8000409a:	6145                	addi	sp,sp,48
    8000409c:	8082                	ret

000000008000409e <sys_write>:
{
    8000409e:	7179                	addi	sp,sp,-48
    800040a0:	f406                	sd	ra,40(sp)
    800040a2:	f022                	sd	s0,32(sp)
    800040a4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800040a6:	fd840593          	addi	a1,s0,-40
    800040aa:	4505                	li	a0,1
    800040ac:	c03fd0ef          	jal	80001cae <argaddr>
  argint(2, &n);
    800040b0:	fe440593          	addi	a1,s0,-28
    800040b4:	4509                	li	a0,2
    800040b6:	bddfd0ef          	jal	80001c92 <argint>
  if(argfd(0, 0, &f) < 0)
    800040ba:	fe840613          	addi	a2,s0,-24
    800040be:	4581                	li	a1,0
    800040c0:	4501                	li	a0,0
    800040c2:	d79ff0ef          	jal	80003e3a <argfd>
    800040c6:	87aa                	mv	a5,a0
    return -1;
    800040c8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800040ca:	0007ca63          	bltz	a5,800040de <sys_write+0x40>
  return filewrite(f, p, n);
    800040ce:	fe442603          	lw	a2,-28(s0)
    800040d2:	fd843583          	ld	a1,-40(s0)
    800040d6:	fe843503          	ld	a0,-24(s0)
    800040da:	d7eff0ef          	jal	80003658 <filewrite>
}
    800040de:	70a2                	ld	ra,40(sp)
    800040e0:	7402                	ld	s0,32(sp)
    800040e2:	6145                	addi	sp,sp,48
    800040e4:	8082                	ret

00000000800040e6 <sys_close>:
{
    800040e6:	1101                	addi	sp,sp,-32
    800040e8:	ec06                	sd	ra,24(sp)
    800040ea:	e822                	sd	s0,16(sp)
    800040ec:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800040ee:	fe040613          	addi	a2,s0,-32
    800040f2:	fec40593          	addi	a1,s0,-20
    800040f6:	4501                	li	a0,0
    800040f8:	d43ff0ef          	jal	80003e3a <argfd>
    return -1;
    800040fc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800040fe:	02054063          	bltz	a0,8000411e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004102:	ca7fc0ef          	jal	80000da8 <myproc>
    80004106:	fec42783          	lw	a5,-20(s0)
    8000410a:	07e9                	addi	a5,a5,26
    8000410c:	078e                	slli	a5,a5,0x3
    8000410e:	953e                	add	a0,a0,a5
    80004110:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004114:	fe043503          	ld	a0,-32(s0)
    80004118:	b62ff0ef          	jal	8000347a <fileclose>
  return 0;
    8000411c:	4781                	li	a5,0
}
    8000411e:	853e                	mv	a0,a5
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	6105                	addi	sp,sp,32
    80004126:	8082                	ret

0000000080004128 <sys_fstat>:
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004130:	fe040593          	addi	a1,s0,-32
    80004134:	4505                	li	a0,1
    80004136:	b79fd0ef          	jal	80001cae <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000413a:	fe840613          	addi	a2,s0,-24
    8000413e:	4581                	li	a1,0
    80004140:	4501                	li	a0,0
    80004142:	cf9ff0ef          	jal	80003e3a <argfd>
    80004146:	87aa                	mv	a5,a0
    return -1;
    80004148:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000414a:	0007c863          	bltz	a5,8000415a <sys_fstat+0x32>
  return filestat(f, st);
    8000414e:	fe043583          	ld	a1,-32(s0)
    80004152:	fe843503          	ld	a0,-24(s0)
    80004156:	be6ff0ef          	jal	8000353c <filestat>
}
    8000415a:	60e2                	ld	ra,24(sp)
    8000415c:	6442                	ld	s0,16(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret

0000000080004162 <sys_link>:
{
    80004162:	7169                	addi	sp,sp,-304
    80004164:	f606                	sd	ra,296(sp)
    80004166:	f222                	sd	s0,288(sp)
    80004168:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000416a:	08000613          	li	a2,128
    8000416e:	ed040593          	addi	a1,s0,-304
    80004172:	4501                	li	a0,0
    80004174:	b57fd0ef          	jal	80001cca <argstr>
    return -1;
    80004178:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000417a:	0c054e63          	bltz	a0,80004256 <sys_link+0xf4>
    8000417e:	08000613          	li	a2,128
    80004182:	f5040593          	addi	a1,s0,-176
    80004186:	4505                	li	a0,1
    80004188:	b43fd0ef          	jal	80001cca <argstr>
    return -1;
    8000418c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000418e:	0c054463          	bltz	a0,80004256 <sys_link+0xf4>
    80004192:	ee26                	sd	s1,280(sp)
  begin_op();
    80004194:	ecdfe0ef          	jal	80003060 <begin_op>
  if((ip = namei(old)) == 0){
    80004198:	ed040513          	addi	a0,s0,-304
    8000419c:	d09fe0ef          	jal	80002ea4 <namei>
    800041a0:	84aa                	mv	s1,a0
    800041a2:	c53d                	beqz	a0,80004210 <sys_link+0xae>
  ilock(ip);
    800041a4:	e26fe0ef          	jal	800027ca <ilock>
  if(ip->type == T_DIR){
    800041a8:	04449703          	lh	a4,68(s1)
    800041ac:	4785                	li	a5,1
    800041ae:	06f70663          	beq	a4,a5,8000421a <sys_link+0xb8>
    800041b2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800041b4:	04a4d783          	lhu	a5,74(s1)
    800041b8:	2785                	addiw	a5,a5,1
    800041ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800041be:	8526                	mv	a0,s1
    800041c0:	d56fe0ef          	jal	80002716 <iupdate>
  iunlock(ip);
    800041c4:	8526                	mv	a0,s1
    800041c6:	eb2fe0ef          	jal	80002878 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800041ca:	fd040593          	addi	a1,s0,-48
    800041ce:	f5040513          	addi	a0,s0,-176
    800041d2:	cedfe0ef          	jal	80002ebe <nameiparent>
    800041d6:	892a                	mv	s2,a0
    800041d8:	cd21                	beqz	a0,80004230 <sys_link+0xce>
  ilock(dp);
    800041da:	df0fe0ef          	jal	800027ca <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800041de:	00092703          	lw	a4,0(s2)
    800041e2:	409c                	lw	a5,0(s1)
    800041e4:	04f71363          	bne	a4,a5,8000422a <sys_link+0xc8>
    800041e8:	40d0                	lw	a2,4(s1)
    800041ea:	fd040593          	addi	a1,s0,-48
    800041ee:	854a                	mv	a0,s2
    800041f0:	c1bfe0ef          	jal	80002e0a <dirlink>
    800041f4:	02054b63          	bltz	a0,8000422a <sys_link+0xc8>
  iunlockput(dp);
    800041f8:	854a                	mv	a0,s2
    800041fa:	fdafe0ef          	jal	800029d4 <iunlockput>
  iput(ip);
    800041fe:	8526                	mv	a0,s1
    80004200:	f4cfe0ef          	jal	8000294c <iput>
  end_op();
    80004204:	ec7fe0ef          	jal	800030ca <end_op>
  return 0;
    80004208:	4781                	li	a5,0
    8000420a:	64f2                	ld	s1,280(sp)
    8000420c:	6952                	ld	s2,272(sp)
    8000420e:	a0a1                	j	80004256 <sys_link+0xf4>
    end_op();
    80004210:	ebbfe0ef          	jal	800030ca <end_op>
    return -1;
    80004214:	57fd                	li	a5,-1
    80004216:	64f2                	ld	s1,280(sp)
    80004218:	a83d                	j	80004256 <sys_link+0xf4>
    iunlockput(ip);
    8000421a:	8526                	mv	a0,s1
    8000421c:	fb8fe0ef          	jal	800029d4 <iunlockput>
    end_op();
    80004220:	eabfe0ef          	jal	800030ca <end_op>
    return -1;
    80004224:	57fd                	li	a5,-1
    80004226:	64f2                	ld	s1,280(sp)
    80004228:	a03d                	j	80004256 <sys_link+0xf4>
    iunlockput(dp);
    8000422a:	854a                	mv	a0,s2
    8000422c:	fa8fe0ef          	jal	800029d4 <iunlockput>
  ilock(ip);
    80004230:	8526                	mv	a0,s1
    80004232:	d98fe0ef          	jal	800027ca <ilock>
  ip->nlink--;
    80004236:	04a4d783          	lhu	a5,74(s1)
    8000423a:	37fd                	addiw	a5,a5,-1
    8000423c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004240:	8526                	mv	a0,s1
    80004242:	cd4fe0ef          	jal	80002716 <iupdate>
  iunlockput(ip);
    80004246:	8526                	mv	a0,s1
    80004248:	f8cfe0ef          	jal	800029d4 <iunlockput>
  end_op();
    8000424c:	e7ffe0ef          	jal	800030ca <end_op>
  return -1;
    80004250:	57fd                	li	a5,-1
    80004252:	64f2                	ld	s1,280(sp)
    80004254:	6952                	ld	s2,272(sp)
}
    80004256:	853e                	mv	a0,a5
    80004258:	70b2                	ld	ra,296(sp)
    8000425a:	7412                	ld	s0,288(sp)
    8000425c:	6155                	addi	sp,sp,304
    8000425e:	8082                	ret

0000000080004260 <sys_unlink>:
{
    80004260:	7151                	addi	sp,sp,-240
    80004262:	f586                	sd	ra,232(sp)
    80004264:	f1a2                	sd	s0,224(sp)
    80004266:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004268:	08000613          	li	a2,128
    8000426c:	f3040593          	addi	a1,s0,-208
    80004270:	4501                	li	a0,0
    80004272:	a59fd0ef          	jal	80001cca <argstr>
    80004276:	16054063          	bltz	a0,800043d6 <sys_unlink+0x176>
    8000427a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000427c:	de5fe0ef          	jal	80003060 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004280:	fb040593          	addi	a1,s0,-80
    80004284:	f3040513          	addi	a0,s0,-208
    80004288:	c37fe0ef          	jal	80002ebe <nameiparent>
    8000428c:	84aa                	mv	s1,a0
    8000428e:	c945                	beqz	a0,8000433e <sys_unlink+0xde>
  ilock(dp);
    80004290:	d3afe0ef          	jal	800027ca <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004294:	00003597          	auipc	a1,0x3
    80004298:	41c58593          	addi	a1,a1,1052 # 800076b0 <etext+0x6b0>
    8000429c:	fb040513          	addi	a0,s0,-80
    800042a0:	989fe0ef          	jal	80002c28 <namecmp>
    800042a4:	10050e63          	beqz	a0,800043c0 <sys_unlink+0x160>
    800042a8:	00003597          	auipc	a1,0x3
    800042ac:	41058593          	addi	a1,a1,1040 # 800076b8 <etext+0x6b8>
    800042b0:	fb040513          	addi	a0,s0,-80
    800042b4:	975fe0ef          	jal	80002c28 <namecmp>
    800042b8:	10050463          	beqz	a0,800043c0 <sys_unlink+0x160>
    800042bc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800042be:	f2c40613          	addi	a2,s0,-212
    800042c2:	fb040593          	addi	a1,s0,-80
    800042c6:	8526                	mv	a0,s1
    800042c8:	977fe0ef          	jal	80002c3e <dirlookup>
    800042cc:	892a                	mv	s2,a0
    800042ce:	0e050863          	beqz	a0,800043be <sys_unlink+0x15e>
  ilock(ip);
    800042d2:	cf8fe0ef          	jal	800027ca <ilock>
  if(ip->nlink < 1)
    800042d6:	04a91783          	lh	a5,74(s2)
    800042da:	06f05763          	blez	a5,80004348 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800042de:	04491703          	lh	a4,68(s2)
    800042e2:	4785                	li	a5,1
    800042e4:	06f70963          	beq	a4,a5,80004356 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800042e8:	4641                	li	a2,16
    800042ea:	4581                	li	a1,0
    800042ec:	fc040513          	addi	a0,s0,-64
    800042f0:	ea1fb0ef          	jal	80000190 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042f4:	4741                	li	a4,16
    800042f6:	f2c42683          	lw	a3,-212(s0)
    800042fa:	fc040613          	addi	a2,s0,-64
    800042fe:	4581                	li	a1,0
    80004300:	8526                	mv	a0,s1
    80004302:	819fe0ef          	jal	80002b1a <writei>
    80004306:	47c1                	li	a5,16
    80004308:	08f51b63          	bne	a0,a5,8000439e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000430c:	04491703          	lh	a4,68(s2)
    80004310:	4785                	li	a5,1
    80004312:	08f70d63          	beq	a4,a5,800043ac <sys_unlink+0x14c>
  iunlockput(dp);
    80004316:	8526                	mv	a0,s1
    80004318:	ebcfe0ef          	jal	800029d4 <iunlockput>
  ip->nlink--;
    8000431c:	04a95783          	lhu	a5,74(s2)
    80004320:	37fd                	addiw	a5,a5,-1
    80004322:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004326:	854a                	mv	a0,s2
    80004328:	beefe0ef          	jal	80002716 <iupdate>
  iunlockput(ip);
    8000432c:	854a                	mv	a0,s2
    8000432e:	ea6fe0ef          	jal	800029d4 <iunlockput>
  end_op();
    80004332:	d99fe0ef          	jal	800030ca <end_op>
  return 0;
    80004336:	4501                	li	a0,0
    80004338:	64ee                	ld	s1,216(sp)
    8000433a:	694e                	ld	s2,208(sp)
    8000433c:	a849                	j	800043ce <sys_unlink+0x16e>
    end_op();
    8000433e:	d8dfe0ef          	jal	800030ca <end_op>
    return -1;
    80004342:	557d                	li	a0,-1
    80004344:	64ee                	ld	s1,216(sp)
    80004346:	a061                	j	800043ce <sys_unlink+0x16e>
    80004348:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000434a:	00003517          	auipc	a0,0x3
    8000434e:	37650513          	addi	a0,a0,886 # 800076c0 <etext+0x6c0>
    80004352:	280010ef          	jal	800055d2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004356:	04c92703          	lw	a4,76(s2)
    8000435a:	02000793          	li	a5,32
    8000435e:	f8e7f5e3          	bgeu	a5,a4,800042e8 <sys_unlink+0x88>
    80004362:	e5ce                	sd	s3,200(sp)
    80004364:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004368:	4741                	li	a4,16
    8000436a:	86ce                	mv	a3,s3
    8000436c:	f1840613          	addi	a2,s0,-232
    80004370:	4581                	li	a1,0
    80004372:	854a                	mv	a0,s2
    80004374:	eaafe0ef          	jal	80002a1e <readi>
    80004378:	47c1                	li	a5,16
    8000437a:	00f51c63          	bne	a0,a5,80004392 <sys_unlink+0x132>
    if(de.inum != 0)
    8000437e:	f1845783          	lhu	a5,-232(s0)
    80004382:	efa1                	bnez	a5,800043da <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004384:	29c1                	addiw	s3,s3,16
    80004386:	04c92783          	lw	a5,76(s2)
    8000438a:	fcf9efe3          	bltu	s3,a5,80004368 <sys_unlink+0x108>
    8000438e:	69ae                	ld	s3,200(sp)
    80004390:	bfa1                	j	800042e8 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004392:	00003517          	auipc	a0,0x3
    80004396:	34650513          	addi	a0,a0,838 # 800076d8 <etext+0x6d8>
    8000439a:	238010ef          	jal	800055d2 <panic>
    8000439e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800043a0:	00003517          	auipc	a0,0x3
    800043a4:	35050513          	addi	a0,a0,848 # 800076f0 <etext+0x6f0>
    800043a8:	22a010ef          	jal	800055d2 <panic>
    dp->nlink--;
    800043ac:	04a4d783          	lhu	a5,74(s1)
    800043b0:	37fd                	addiw	a5,a5,-1
    800043b2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800043b6:	8526                	mv	a0,s1
    800043b8:	b5efe0ef          	jal	80002716 <iupdate>
    800043bc:	bfa9                	j	80004316 <sys_unlink+0xb6>
    800043be:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800043c0:	8526                	mv	a0,s1
    800043c2:	e12fe0ef          	jal	800029d4 <iunlockput>
  end_op();
    800043c6:	d05fe0ef          	jal	800030ca <end_op>
  return -1;
    800043ca:	557d                	li	a0,-1
    800043cc:	64ee                	ld	s1,216(sp)
}
    800043ce:	70ae                	ld	ra,232(sp)
    800043d0:	740e                	ld	s0,224(sp)
    800043d2:	616d                	addi	sp,sp,240
    800043d4:	8082                	ret
    return -1;
    800043d6:	557d                	li	a0,-1
    800043d8:	bfdd                	j	800043ce <sys_unlink+0x16e>
    iunlockput(ip);
    800043da:	854a                	mv	a0,s2
    800043dc:	df8fe0ef          	jal	800029d4 <iunlockput>
    goto bad;
    800043e0:	694e                	ld	s2,208(sp)
    800043e2:	69ae                	ld	s3,200(sp)
    800043e4:	bff1                	j	800043c0 <sys_unlink+0x160>

00000000800043e6 <sys_open>:

uint64
sys_open(void)
{
    800043e6:	7131                	addi	sp,sp,-192
    800043e8:	fd06                	sd	ra,184(sp)
    800043ea:	f922                	sd	s0,176(sp)
    800043ec:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800043ee:	f4c40593          	addi	a1,s0,-180
    800043f2:	4505                	li	a0,1
    800043f4:	89ffd0ef          	jal	80001c92 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043f8:	08000613          	li	a2,128
    800043fc:	f5040593          	addi	a1,s0,-176
    80004400:	4501                	li	a0,0
    80004402:	8c9fd0ef          	jal	80001cca <argstr>
    80004406:	87aa                	mv	a5,a0
    return -1;
    80004408:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000440a:	0a07c263          	bltz	a5,800044ae <sys_open+0xc8>
    8000440e:	f526                	sd	s1,168(sp)

  begin_op();
    80004410:	c51fe0ef          	jal	80003060 <begin_op>

  if(omode & O_CREATE){
    80004414:	f4c42783          	lw	a5,-180(s0)
    80004418:	2007f793          	andi	a5,a5,512
    8000441c:	c3d5                	beqz	a5,800044c0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000441e:	4681                	li	a3,0
    80004420:	4601                	li	a2,0
    80004422:	4589                	li	a1,2
    80004424:	f5040513          	addi	a0,s0,-176
    80004428:	aa9ff0ef          	jal	80003ed0 <create>
    8000442c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000442e:	c541                	beqz	a0,800044b6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004430:	04449703          	lh	a4,68(s1)
    80004434:	478d                	li	a5,3
    80004436:	00f71763          	bne	a4,a5,80004444 <sys_open+0x5e>
    8000443a:	0464d703          	lhu	a4,70(s1)
    8000443e:	47a5                	li	a5,9
    80004440:	0ae7ed63          	bltu	a5,a4,800044fa <sys_open+0x114>
    80004444:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004446:	f91fe0ef          	jal	800033d6 <filealloc>
    8000444a:	892a                	mv	s2,a0
    8000444c:	c179                	beqz	a0,80004512 <sys_open+0x12c>
    8000444e:	ed4e                	sd	s3,152(sp)
    80004450:	a43ff0ef          	jal	80003e92 <fdalloc>
    80004454:	89aa                	mv	s3,a0
    80004456:	0a054a63          	bltz	a0,8000450a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000445a:	04449703          	lh	a4,68(s1)
    8000445e:	478d                	li	a5,3
    80004460:	0cf70263          	beq	a4,a5,80004524 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004464:	4789                	li	a5,2
    80004466:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000446a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000446e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004472:	f4c42783          	lw	a5,-180(s0)
    80004476:	0017c713          	xori	a4,a5,1
    8000447a:	8b05                	andi	a4,a4,1
    8000447c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004480:	0037f713          	andi	a4,a5,3
    80004484:	00e03733          	snez	a4,a4
    80004488:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000448c:	4007f793          	andi	a5,a5,1024
    80004490:	c791                	beqz	a5,8000449c <sys_open+0xb6>
    80004492:	04449703          	lh	a4,68(s1)
    80004496:	4789                	li	a5,2
    80004498:	08f70d63          	beq	a4,a5,80004532 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000449c:	8526                	mv	a0,s1
    8000449e:	bdafe0ef          	jal	80002878 <iunlock>
  end_op();
    800044a2:	c29fe0ef          	jal	800030ca <end_op>

  return fd;
    800044a6:	854e                	mv	a0,s3
    800044a8:	74aa                	ld	s1,168(sp)
    800044aa:	790a                	ld	s2,160(sp)
    800044ac:	69ea                	ld	s3,152(sp)
}
    800044ae:	70ea                	ld	ra,184(sp)
    800044b0:	744a                	ld	s0,176(sp)
    800044b2:	6129                	addi	sp,sp,192
    800044b4:	8082                	ret
      end_op();
    800044b6:	c15fe0ef          	jal	800030ca <end_op>
      return -1;
    800044ba:	557d                	li	a0,-1
    800044bc:	74aa                	ld	s1,168(sp)
    800044be:	bfc5                	j	800044ae <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800044c0:	f5040513          	addi	a0,s0,-176
    800044c4:	9e1fe0ef          	jal	80002ea4 <namei>
    800044c8:	84aa                	mv	s1,a0
    800044ca:	c11d                	beqz	a0,800044f0 <sys_open+0x10a>
    ilock(ip);
    800044cc:	afefe0ef          	jal	800027ca <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800044d0:	04449703          	lh	a4,68(s1)
    800044d4:	4785                	li	a5,1
    800044d6:	f4f71de3          	bne	a4,a5,80004430 <sys_open+0x4a>
    800044da:	f4c42783          	lw	a5,-180(s0)
    800044de:	d3bd                	beqz	a5,80004444 <sys_open+0x5e>
      iunlockput(ip);
    800044e0:	8526                	mv	a0,s1
    800044e2:	cf2fe0ef          	jal	800029d4 <iunlockput>
      end_op();
    800044e6:	be5fe0ef          	jal	800030ca <end_op>
      return -1;
    800044ea:	557d                	li	a0,-1
    800044ec:	74aa                	ld	s1,168(sp)
    800044ee:	b7c1                	j	800044ae <sys_open+0xc8>
      end_op();
    800044f0:	bdbfe0ef          	jal	800030ca <end_op>
      return -1;
    800044f4:	557d                	li	a0,-1
    800044f6:	74aa                	ld	s1,168(sp)
    800044f8:	bf5d                	j	800044ae <sys_open+0xc8>
    iunlockput(ip);
    800044fa:	8526                	mv	a0,s1
    800044fc:	cd8fe0ef          	jal	800029d4 <iunlockput>
    end_op();
    80004500:	bcbfe0ef          	jal	800030ca <end_op>
    return -1;
    80004504:	557d                	li	a0,-1
    80004506:	74aa                	ld	s1,168(sp)
    80004508:	b75d                	j	800044ae <sys_open+0xc8>
      fileclose(f);
    8000450a:	854a                	mv	a0,s2
    8000450c:	f6ffe0ef          	jal	8000347a <fileclose>
    80004510:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004512:	8526                	mv	a0,s1
    80004514:	cc0fe0ef          	jal	800029d4 <iunlockput>
    end_op();
    80004518:	bb3fe0ef          	jal	800030ca <end_op>
    return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	74aa                	ld	s1,168(sp)
    80004520:	790a                	ld	s2,160(sp)
    80004522:	b771                	j	800044ae <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004524:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004528:	04649783          	lh	a5,70(s1)
    8000452c:	02f91223          	sh	a5,36(s2)
    80004530:	bf3d                	j	8000446e <sys_open+0x88>
    itrunc(ip);
    80004532:	8526                	mv	a0,s1
    80004534:	b84fe0ef          	jal	800028b8 <itrunc>
    80004538:	b795                	j	8000449c <sys_open+0xb6>

000000008000453a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000453a:	7175                	addi	sp,sp,-144
    8000453c:	e506                	sd	ra,136(sp)
    8000453e:	e122                	sd	s0,128(sp)
    80004540:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004542:	b1ffe0ef          	jal	80003060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004546:	08000613          	li	a2,128
    8000454a:	f7040593          	addi	a1,s0,-144
    8000454e:	4501                	li	a0,0
    80004550:	f7afd0ef          	jal	80001cca <argstr>
    80004554:	02054363          	bltz	a0,8000457a <sys_mkdir+0x40>
    80004558:	4681                	li	a3,0
    8000455a:	4601                	li	a2,0
    8000455c:	4585                	li	a1,1
    8000455e:	f7040513          	addi	a0,s0,-144
    80004562:	96fff0ef          	jal	80003ed0 <create>
    80004566:	c911                	beqz	a0,8000457a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004568:	c6cfe0ef          	jal	800029d4 <iunlockput>
  end_op();
    8000456c:	b5ffe0ef          	jal	800030ca <end_op>
  return 0;
    80004570:	4501                	li	a0,0
}
    80004572:	60aa                	ld	ra,136(sp)
    80004574:	640a                	ld	s0,128(sp)
    80004576:	6149                	addi	sp,sp,144
    80004578:	8082                	ret
    end_op();
    8000457a:	b51fe0ef          	jal	800030ca <end_op>
    return -1;
    8000457e:	557d                	li	a0,-1
    80004580:	bfcd                	j	80004572 <sys_mkdir+0x38>

0000000080004582 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004582:	7135                	addi	sp,sp,-160
    80004584:	ed06                	sd	ra,152(sp)
    80004586:	e922                	sd	s0,144(sp)
    80004588:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000458a:	ad7fe0ef          	jal	80003060 <begin_op>
  argint(1, &major);
    8000458e:	f6c40593          	addi	a1,s0,-148
    80004592:	4505                	li	a0,1
    80004594:	efefd0ef          	jal	80001c92 <argint>
  argint(2, &minor);
    80004598:	f6840593          	addi	a1,s0,-152
    8000459c:	4509                	li	a0,2
    8000459e:	ef4fd0ef          	jal	80001c92 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045a2:	08000613          	li	a2,128
    800045a6:	f7040593          	addi	a1,s0,-144
    800045aa:	4501                	li	a0,0
    800045ac:	f1efd0ef          	jal	80001cca <argstr>
    800045b0:	02054563          	bltz	a0,800045da <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800045b4:	f6841683          	lh	a3,-152(s0)
    800045b8:	f6c41603          	lh	a2,-148(s0)
    800045bc:	458d                	li	a1,3
    800045be:	f7040513          	addi	a0,s0,-144
    800045c2:	90fff0ef          	jal	80003ed0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045c6:	c911                	beqz	a0,800045da <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800045c8:	c0cfe0ef          	jal	800029d4 <iunlockput>
  end_op();
    800045cc:	afffe0ef          	jal	800030ca <end_op>
  return 0;
    800045d0:	4501                	li	a0,0
}
    800045d2:	60ea                	ld	ra,152(sp)
    800045d4:	644a                	ld	s0,144(sp)
    800045d6:	610d                	addi	sp,sp,160
    800045d8:	8082                	ret
    end_op();
    800045da:	af1fe0ef          	jal	800030ca <end_op>
    return -1;
    800045de:	557d                	li	a0,-1
    800045e0:	bfcd                	j	800045d2 <sys_mknod+0x50>

00000000800045e2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800045e2:	7135                	addi	sp,sp,-160
    800045e4:	ed06                	sd	ra,152(sp)
    800045e6:	e922                	sd	s0,144(sp)
    800045e8:	e14a                	sd	s2,128(sp)
    800045ea:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800045ec:	fbcfc0ef          	jal	80000da8 <myproc>
    800045f0:	892a                	mv	s2,a0
  
  begin_op();
    800045f2:	a6ffe0ef          	jal	80003060 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800045f6:	08000613          	li	a2,128
    800045fa:	f6040593          	addi	a1,s0,-160
    800045fe:	4501                	li	a0,0
    80004600:	ecafd0ef          	jal	80001cca <argstr>
    80004604:	04054363          	bltz	a0,8000464a <sys_chdir+0x68>
    80004608:	e526                	sd	s1,136(sp)
    8000460a:	f6040513          	addi	a0,s0,-160
    8000460e:	897fe0ef          	jal	80002ea4 <namei>
    80004612:	84aa                	mv	s1,a0
    80004614:	c915                	beqz	a0,80004648 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004616:	9b4fe0ef          	jal	800027ca <ilock>
  if(ip->type != T_DIR){
    8000461a:	04449703          	lh	a4,68(s1)
    8000461e:	4785                	li	a5,1
    80004620:	02f71963          	bne	a4,a5,80004652 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004624:	8526                	mv	a0,s1
    80004626:	a52fe0ef          	jal	80002878 <iunlock>
  iput(p->cwd);
    8000462a:	15093503          	ld	a0,336(s2)
    8000462e:	b1efe0ef          	jal	8000294c <iput>
  end_op();
    80004632:	a99fe0ef          	jal	800030ca <end_op>
  p->cwd = ip;
    80004636:	14993823          	sd	s1,336(s2)
  return 0;
    8000463a:	4501                	li	a0,0
    8000463c:	64aa                	ld	s1,136(sp)
}
    8000463e:	60ea                	ld	ra,152(sp)
    80004640:	644a                	ld	s0,144(sp)
    80004642:	690a                	ld	s2,128(sp)
    80004644:	610d                	addi	sp,sp,160
    80004646:	8082                	ret
    80004648:	64aa                	ld	s1,136(sp)
    end_op();
    8000464a:	a81fe0ef          	jal	800030ca <end_op>
    return -1;
    8000464e:	557d                	li	a0,-1
    80004650:	b7fd                	j	8000463e <sys_chdir+0x5c>
    iunlockput(ip);
    80004652:	8526                	mv	a0,s1
    80004654:	b80fe0ef          	jal	800029d4 <iunlockput>
    end_op();
    80004658:	a73fe0ef          	jal	800030ca <end_op>
    return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	64aa                	ld	s1,136(sp)
    80004660:	bff9                	j	8000463e <sys_chdir+0x5c>

0000000080004662 <sys_exec>:

uint64
sys_exec(void)
{
    80004662:	7121                	addi	sp,sp,-448
    80004664:	ff06                	sd	ra,440(sp)
    80004666:	fb22                	sd	s0,432(sp)
    80004668:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000466a:	e4840593          	addi	a1,s0,-440
    8000466e:	4505                	li	a0,1
    80004670:	e3efd0ef          	jal	80001cae <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004674:	08000613          	li	a2,128
    80004678:	f5040593          	addi	a1,s0,-176
    8000467c:	4501                	li	a0,0
    8000467e:	e4cfd0ef          	jal	80001cca <argstr>
    80004682:	87aa                	mv	a5,a0
    return -1;
    80004684:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004686:	0c07c463          	bltz	a5,8000474e <sys_exec+0xec>
    8000468a:	f726                	sd	s1,424(sp)
    8000468c:	f34a                	sd	s2,416(sp)
    8000468e:	ef4e                	sd	s3,408(sp)
    80004690:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004692:	10000613          	li	a2,256
    80004696:	4581                	li	a1,0
    80004698:	e5040513          	addi	a0,s0,-432
    8000469c:	af5fb0ef          	jal	80000190 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800046a0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800046a4:	89a6                	mv	s3,s1
    800046a6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800046a8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800046ac:	00391513          	slli	a0,s2,0x3
    800046b0:	e4040593          	addi	a1,s0,-448
    800046b4:	e4843783          	ld	a5,-440(s0)
    800046b8:	953e                	add	a0,a0,a5
    800046ba:	d4efd0ef          	jal	80001c08 <fetchaddr>
    800046be:	02054663          	bltz	a0,800046ea <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800046c2:	e4043783          	ld	a5,-448(s0)
    800046c6:	c3a9                	beqz	a5,80004708 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800046c8:	a37fb0ef          	jal	800000fe <kalloc>
    800046cc:	85aa                	mv	a1,a0
    800046ce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800046d2:	cd01                	beqz	a0,800046ea <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800046d4:	6605                	lui	a2,0x1
    800046d6:	e4043503          	ld	a0,-448(s0)
    800046da:	d78fd0ef          	jal	80001c52 <fetchstr>
    800046de:	00054663          	bltz	a0,800046ea <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800046e2:	0905                	addi	s2,s2,1
    800046e4:	09a1                	addi	s3,s3,8
    800046e6:	fd4913e3          	bne	s2,s4,800046ac <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046ea:	f5040913          	addi	s2,s0,-176
    800046ee:	6088                	ld	a0,0(s1)
    800046f0:	c931                	beqz	a0,80004744 <sys_exec+0xe2>
    kfree(argv[i]);
    800046f2:	92bfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046f6:	04a1                	addi	s1,s1,8
    800046f8:	ff249be3          	bne	s1,s2,800046ee <sys_exec+0x8c>
  return -1;
    800046fc:	557d                	li	a0,-1
    800046fe:	74ba                	ld	s1,424(sp)
    80004700:	791a                	ld	s2,416(sp)
    80004702:	69fa                	ld	s3,408(sp)
    80004704:	6a5a                	ld	s4,400(sp)
    80004706:	a0a1                	j	8000474e <sys_exec+0xec>
      argv[i] = 0;
    80004708:	0009079b          	sext.w	a5,s2
    8000470c:	078e                	slli	a5,a5,0x3
    8000470e:	fd078793          	addi	a5,a5,-48
    80004712:	97a2                	add	a5,a5,s0
    80004714:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80004718:	e5040593          	addi	a1,s0,-432
    8000471c:	f5040513          	addi	a0,s0,-176
    80004720:	ba8ff0ef          	jal	80003ac8 <exec>
    80004724:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004726:	f5040993          	addi	s3,s0,-176
    8000472a:	6088                	ld	a0,0(s1)
    8000472c:	c511                	beqz	a0,80004738 <sys_exec+0xd6>
    kfree(argv[i]);
    8000472e:	8effb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004732:	04a1                	addi	s1,s1,8
    80004734:	ff349be3          	bne	s1,s3,8000472a <sys_exec+0xc8>
  return ret;
    80004738:	854a                	mv	a0,s2
    8000473a:	74ba                	ld	s1,424(sp)
    8000473c:	791a                	ld	s2,416(sp)
    8000473e:	69fa                	ld	s3,408(sp)
    80004740:	6a5a                	ld	s4,400(sp)
    80004742:	a031                	j	8000474e <sys_exec+0xec>
  return -1;
    80004744:	557d                	li	a0,-1
    80004746:	74ba                	ld	s1,424(sp)
    80004748:	791a                	ld	s2,416(sp)
    8000474a:	69fa                	ld	s3,408(sp)
    8000474c:	6a5a                	ld	s4,400(sp)
}
    8000474e:	70fa                	ld	ra,440(sp)
    80004750:	745a                	ld	s0,432(sp)
    80004752:	6139                	addi	sp,sp,448
    80004754:	8082                	ret

0000000080004756 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004756:	7139                	addi	sp,sp,-64
    80004758:	fc06                	sd	ra,56(sp)
    8000475a:	f822                	sd	s0,48(sp)
    8000475c:	f426                	sd	s1,40(sp)
    8000475e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004760:	e48fc0ef          	jal	80000da8 <myproc>
    80004764:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004766:	fd840593          	addi	a1,s0,-40
    8000476a:	4501                	li	a0,0
    8000476c:	d42fd0ef          	jal	80001cae <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004770:	fc840593          	addi	a1,s0,-56
    80004774:	fd040513          	addi	a0,s0,-48
    80004778:	85cff0ef          	jal	800037d4 <pipealloc>
    return -1;
    8000477c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000477e:	0a054463          	bltz	a0,80004826 <sys_pipe+0xd0>
  fd0 = -1;
    80004782:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004786:	fd043503          	ld	a0,-48(s0)
    8000478a:	f08ff0ef          	jal	80003e92 <fdalloc>
    8000478e:	fca42223          	sw	a0,-60(s0)
    80004792:	08054163          	bltz	a0,80004814 <sys_pipe+0xbe>
    80004796:	fc843503          	ld	a0,-56(s0)
    8000479a:	ef8ff0ef          	jal	80003e92 <fdalloc>
    8000479e:	fca42023          	sw	a0,-64(s0)
    800047a2:	06054063          	bltz	a0,80004802 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047a6:	4691                	li	a3,4
    800047a8:	fc440613          	addi	a2,s0,-60
    800047ac:	fd843583          	ld	a1,-40(s0)
    800047b0:	68a8                	ld	a0,80(s1)
    800047b2:	a68fc0ef          	jal	80000a1a <copyout>
    800047b6:	00054e63          	bltz	a0,800047d2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800047ba:	4691                	li	a3,4
    800047bc:	fc040613          	addi	a2,s0,-64
    800047c0:	fd843583          	ld	a1,-40(s0)
    800047c4:	0591                	addi	a1,a1,4
    800047c6:	68a8                	ld	a0,80(s1)
    800047c8:	a52fc0ef          	jal	80000a1a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800047cc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047ce:	04055c63          	bgez	a0,80004826 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800047d2:	fc442783          	lw	a5,-60(s0)
    800047d6:	07e9                	addi	a5,a5,26
    800047d8:	078e                	slli	a5,a5,0x3
    800047da:	97a6                	add	a5,a5,s1
    800047dc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800047e0:	fc042783          	lw	a5,-64(s0)
    800047e4:	07e9                	addi	a5,a5,26
    800047e6:	078e                	slli	a5,a5,0x3
    800047e8:	94be                	add	s1,s1,a5
    800047ea:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800047ee:	fd043503          	ld	a0,-48(s0)
    800047f2:	c89fe0ef          	jal	8000347a <fileclose>
    fileclose(wf);
    800047f6:	fc843503          	ld	a0,-56(s0)
    800047fa:	c81fe0ef          	jal	8000347a <fileclose>
    return -1;
    800047fe:	57fd                	li	a5,-1
    80004800:	a01d                	j	80004826 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004802:	fc442783          	lw	a5,-60(s0)
    80004806:	0007c763          	bltz	a5,80004814 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000480a:	07e9                	addi	a5,a5,26
    8000480c:	078e                	slli	a5,a5,0x3
    8000480e:	97a6                	add	a5,a5,s1
    80004810:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004814:	fd043503          	ld	a0,-48(s0)
    80004818:	c63fe0ef          	jal	8000347a <fileclose>
    fileclose(wf);
    8000481c:	fc843503          	ld	a0,-56(s0)
    80004820:	c5bfe0ef          	jal	8000347a <fileclose>
    return -1;
    80004824:	57fd                	li	a5,-1
}
    80004826:	853e                	mv	a0,a5
    80004828:	70e2                	ld	ra,56(sp)
    8000482a:	7442                	ld	s0,48(sp)
    8000482c:	74a2                	ld	s1,40(sp)
    8000482e:	6121                	addi	sp,sp,64
    80004830:	8082                	ret
	...

0000000080004840 <kernelvec>:
    80004840:	7111                	addi	sp,sp,-256
    80004842:	e006                	sd	ra,0(sp)
    80004844:	e40a                	sd	sp,8(sp)
    80004846:	e80e                	sd	gp,16(sp)
    80004848:	ec12                	sd	tp,24(sp)
    8000484a:	f016                	sd	t0,32(sp)
    8000484c:	f41a                	sd	t1,40(sp)
    8000484e:	f81e                	sd	t2,48(sp)
    80004850:	e4aa                	sd	a0,72(sp)
    80004852:	e8ae                	sd	a1,80(sp)
    80004854:	ecb2                	sd	a2,88(sp)
    80004856:	f0b6                	sd	a3,96(sp)
    80004858:	f4ba                	sd	a4,104(sp)
    8000485a:	f8be                	sd	a5,112(sp)
    8000485c:	fcc2                	sd	a6,120(sp)
    8000485e:	e146                	sd	a7,128(sp)
    80004860:	edf2                	sd	t3,216(sp)
    80004862:	f1f6                	sd	t4,224(sp)
    80004864:	f5fa                	sd	t5,232(sp)
    80004866:	f9fe                	sd	t6,240(sp)
    80004868:	ab0fd0ef          	jal	80001b18 <kerneltrap>
    8000486c:	6082                	ld	ra,0(sp)
    8000486e:	6122                	ld	sp,8(sp)
    80004870:	61c2                	ld	gp,16(sp)
    80004872:	7282                	ld	t0,32(sp)
    80004874:	7322                	ld	t1,40(sp)
    80004876:	73c2                	ld	t2,48(sp)
    80004878:	6526                	ld	a0,72(sp)
    8000487a:	65c6                	ld	a1,80(sp)
    8000487c:	6666                	ld	a2,88(sp)
    8000487e:	7686                	ld	a3,96(sp)
    80004880:	7726                	ld	a4,104(sp)
    80004882:	77c6                	ld	a5,112(sp)
    80004884:	7866                	ld	a6,120(sp)
    80004886:	688a                	ld	a7,128(sp)
    80004888:	6e6e                	ld	t3,216(sp)
    8000488a:	7e8e                	ld	t4,224(sp)
    8000488c:	7f2e                	ld	t5,232(sp)
    8000488e:	7fce                	ld	t6,240(sp)
    80004890:	6111                	addi	sp,sp,256
    80004892:	10200073          	sret
	...

000000008000489e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000489e:	1141                	addi	sp,sp,-16
    800048a0:	e422                	sd	s0,8(sp)
    800048a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800048a4:	0c0007b7          	lui	a5,0xc000
    800048a8:	4705                	li	a4,1
    800048aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800048ac:	0c0007b7          	lui	a5,0xc000
    800048b0:	c3d8                	sw	a4,4(a5)
}
    800048b2:	6422                	ld	s0,8(sp)
    800048b4:	0141                	addi	sp,sp,16
    800048b6:	8082                	ret

00000000800048b8 <plicinithart>:

void
plicinithart(void)
{
    800048b8:	1141                	addi	sp,sp,-16
    800048ba:	e406                	sd	ra,8(sp)
    800048bc:	e022                	sd	s0,0(sp)
    800048be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048c0:	cbcfc0ef          	jal	80000d7c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800048c4:	0085171b          	slliw	a4,a0,0x8
    800048c8:	0c0027b7          	lui	a5,0xc002
    800048cc:	97ba                	add	a5,a5,a4
    800048ce:	40200713          	li	a4,1026
    800048d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800048d6:	00d5151b          	slliw	a0,a0,0xd
    800048da:	0c2017b7          	lui	a5,0xc201
    800048de:	97aa                	add	a5,a5,a0
    800048e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800048e4:	60a2                	ld	ra,8(sp)
    800048e6:	6402                	ld	s0,0(sp)
    800048e8:	0141                	addi	sp,sp,16
    800048ea:	8082                	ret

00000000800048ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800048ec:	1141                	addi	sp,sp,-16
    800048ee:	e406                	sd	ra,8(sp)
    800048f0:	e022                	sd	s0,0(sp)
    800048f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048f4:	c88fc0ef          	jal	80000d7c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800048f8:	00d5151b          	slliw	a0,a0,0xd
    800048fc:	0c2017b7          	lui	a5,0xc201
    80004900:	97aa                	add	a5,a5,a0
  return irq;
}
    80004902:	43c8                	lw	a0,4(a5)
    80004904:	60a2                	ld	ra,8(sp)
    80004906:	6402                	ld	s0,0(sp)
    80004908:	0141                	addi	sp,sp,16
    8000490a:	8082                	ret

000000008000490c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000490c:	1101                	addi	sp,sp,-32
    8000490e:	ec06                	sd	ra,24(sp)
    80004910:	e822                	sd	s0,16(sp)
    80004912:	e426                	sd	s1,8(sp)
    80004914:	1000                	addi	s0,sp,32
    80004916:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004918:	c64fc0ef          	jal	80000d7c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000491c:	00d5151b          	slliw	a0,a0,0xd
    80004920:	0c2017b7          	lui	a5,0xc201
    80004924:	97aa                	add	a5,a5,a0
    80004926:	c3c4                	sw	s1,4(a5)
}
    80004928:	60e2                	ld	ra,24(sp)
    8000492a:	6442                	ld	s0,16(sp)
    8000492c:	64a2                	ld	s1,8(sp)
    8000492e:	6105                	addi	sp,sp,32
    80004930:	8082                	ret

0000000080004932 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004932:	1141                	addi	sp,sp,-16
    80004934:	e406                	sd	ra,8(sp)
    80004936:	e022                	sd	s0,0(sp)
    80004938:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000493a:	479d                	li	a5,7
    8000493c:	04a7ca63          	blt	a5,a0,80004990 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004940:	00017797          	auipc	a5,0x17
    80004944:	ed078793          	addi	a5,a5,-304 # 8001b810 <disk>
    80004948:	97aa                	add	a5,a5,a0
    8000494a:	0187c783          	lbu	a5,24(a5)
    8000494e:	e7b9                	bnez	a5,8000499c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004950:	00451693          	slli	a3,a0,0x4
    80004954:	00017797          	auipc	a5,0x17
    80004958:	ebc78793          	addi	a5,a5,-324 # 8001b810 <disk>
    8000495c:	6398                	ld	a4,0(a5)
    8000495e:	9736                	add	a4,a4,a3
    80004960:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004964:	6398                	ld	a4,0(a5)
    80004966:	9736                	add	a4,a4,a3
    80004968:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000496c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004970:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004974:	97aa                	add	a5,a5,a0
    80004976:	4705                	li	a4,1
    80004978:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000497c:	00017517          	auipc	a0,0x17
    80004980:	eac50513          	addi	a0,a0,-340 # 8001b828 <disk+0x18>
    80004984:	a47fc0ef          	jal	800013ca <wakeup>
}
    80004988:	60a2                	ld	ra,8(sp)
    8000498a:	6402                	ld	s0,0(sp)
    8000498c:	0141                	addi	sp,sp,16
    8000498e:	8082                	ret
    panic("free_desc 1");
    80004990:	00003517          	auipc	a0,0x3
    80004994:	d7050513          	addi	a0,a0,-656 # 80007700 <etext+0x700>
    80004998:	43b000ef          	jal	800055d2 <panic>
    panic("free_desc 2");
    8000499c:	00003517          	auipc	a0,0x3
    800049a0:	d7450513          	addi	a0,a0,-652 # 80007710 <etext+0x710>
    800049a4:	42f000ef          	jal	800055d2 <panic>

00000000800049a8 <virtio_disk_init>:
{
    800049a8:	1101                	addi	sp,sp,-32
    800049aa:	ec06                	sd	ra,24(sp)
    800049ac:	e822                	sd	s0,16(sp)
    800049ae:	e426                	sd	s1,8(sp)
    800049b0:	e04a                	sd	s2,0(sp)
    800049b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800049b4:	00003597          	auipc	a1,0x3
    800049b8:	d6c58593          	addi	a1,a1,-660 # 80007720 <etext+0x720>
    800049bc:	00017517          	auipc	a0,0x17
    800049c0:	f7c50513          	addi	a0,a0,-132 # 8001b938 <disk+0x128>
    800049c4:	6bd000ef          	jal	80005880 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049c8:	100017b7          	lui	a5,0x10001
    800049cc:	4398                	lw	a4,0(a5)
    800049ce:	2701                	sext.w	a4,a4
    800049d0:	747277b7          	lui	a5,0x74727
    800049d4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800049d8:	18f71063          	bne	a4,a5,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049dc:	100017b7          	lui	a5,0x10001
    800049e0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800049e2:	439c                	lw	a5,0(a5)
    800049e4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049e6:	4709                	li	a4,2
    800049e8:	16e79863          	bne	a5,a4,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049ec:	100017b7          	lui	a5,0x10001
    800049f0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800049f2:	439c                	lw	a5,0(a5)
    800049f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049f6:	16e79163          	bne	a5,a4,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800049fa:	100017b7          	lui	a5,0x10001
    800049fe:	47d8                	lw	a4,12(a5)
    80004a00:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004a02:	554d47b7          	lui	a5,0x554d4
    80004a06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004a0a:	14f71763          	bne	a4,a5,80004b58 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a0e:	100017b7          	lui	a5,0x10001
    80004a12:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a16:	4705                	li	a4,1
    80004a18:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a1a:	470d                	li	a4,3
    80004a1c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004a1e:	10001737          	lui	a4,0x10001
    80004a22:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004a24:	c7ffe737          	lui	a4,0xc7ffe
    80004a28:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004a2c:	8ef9                	and	a3,a3,a4
    80004a2e:	10001737          	lui	a4,0x10001
    80004a32:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a34:	472d                	li	a4,11
    80004a36:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a38:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004a3c:	439c                	lw	a5,0(a5)
    80004a3e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004a42:	8ba1                	andi	a5,a5,8
    80004a44:	12078063          	beqz	a5,80004b64 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004a48:	100017b7          	lui	a5,0x10001
    80004a4c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004a50:	100017b7          	lui	a5,0x10001
    80004a54:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004a58:	439c                	lw	a5,0(a5)
    80004a5a:	2781                	sext.w	a5,a5
    80004a5c:	10079a63          	bnez	a5,80004b70 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004a60:	100017b7          	lui	a5,0x10001
    80004a64:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004a68:	439c                	lw	a5,0(a5)
    80004a6a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004a6c:	10078863          	beqz	a5,80004b7c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004a70:	471d                	li	a4,7
    80004a72:	10f77b63          	bgeu	a4,a5,80004b88 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004a76:	e88fb0ef          	jal	800000fe <kalloc>
    80004a7a:	00017497          	auipc	s1,0x17
    80004a7e:	d9648493          	addi	s1,s1,-618 # 8001b810 <disk>
    80004a82:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004a84:	e7afb0ef          	jal	800000fe <kalloc>
    80004a88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004a8a:	e74fb0ef          	jal	800000fe <kalloc>
    80004a8e:	87aa                	mv	a5,a0
    80004a90:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004a92:	6088                	ld	a0,0(s1)
    80004a94:	10050063          	beqz	a0,80004b94 <virtio_disk_init+0x1ec>
    80004a98:	00017717          	auipc	a4,0x17
    80004a9c:	d8073703          	ld	a4,-640(a4) # 8001b818 <disk+0x8>
    80004aa0:	0e070a63          	beqz	a4,80004b94 <virtio_disk_init+0x1ec>
    80004aa4:	0e078863          	beqz	a5,80004b94 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004aa8:	6605                	lui	a2,0x1
    80004aaa:	4581                	li	a1,0
    80004aac:	ee4fb0ef          	jal	80000190 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004ab0:	00017497          	auipc	s1,0x17
    80004ab4:	d6048493          	addi	s1,s1,-672 # 8001b810 <disk>
    80004ab8:	6605                	lui	a2,0x1
    80004aba:	4581                	li	a1,0
    80004abc:	6488                	ld	a0,8(s1)
    80004abe:	ed2fb0ef          	jal	80000190 <memset>
  memset(disk.used, 0, PGSIZE);
    80004ac2:	6605                	lui	a2,0x1
    80004ac4:	4581                	li	a1,0
    80004ac6:	6888                	ld	a0,16(s1)
    80004ac8:	ec8fb0ef          	jal	80000190 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004acc:	100017b7          	lui	a5,0x10001
    80004ad0:	4721                	li	a4,8
    80004ad2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004ad4:	4098                	lw	a4,0(s1)
    80004ad6:	100017b7          	lui	a5,0x10001
    80004ada:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004ade:	40d8                	lw	a4,4(s1)
    80004ae0:	100017b7          	lui	a5,0x10001
    80004ae4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004ae8:	649c                	ld	a5,8(s1)
    80004aea:	0007869b          	sext.w	a3,a5
    80004aee:	10001737          	lui	a4,0x10001
    80004af2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004af6:	9781                	srai	a5,a5,0x20
    80004af8:	10001737          	lui	a4,0x10001
    80004afc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004b00:	689c                	ld	a5,16(s1)
    80004b02:	0007869b          	sext.w	a3,a5
    80004b06:	10001737          	lui	a4,0x10001
    80004b0a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004b0e:	9781                	srai	a5,a5,0x20
    80004b10:	10001737          	lui	a4,0x10001
    80004b14:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004b18:	10001737          	lui	a4,0x10001
    80004b1c:	4785                	li	a5,1
    80004b1e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004b20:	00f48c23          	sb	a5,24(s1)
    80004b24:	00f48ca3          	sb	a5,25(s1)
    80004b28:	00f48d23          	sb	a5,26(s1)
    80004b2c:	00f48da3          	sb	a5,27(s1)
    80004b30:	00f48e23          	sb	a5,28(s1)
    80004b34:	00f48ea3          	sb	a5,29(s1)
    80004b38:	00f48f23          	sb	a5,30(s1)
    80004b3c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004b40:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b44:	100017b7          	lui	a5,0x10001
    80004b48:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004b4c:	60e2                	ld	ra,24(sp)
    80004b4e:	6442                	ld	s0,16(sp)
    80004b50:	64a2                	ld	s1,8(sp)
    80004b52:	6902                	ld	s2,0(sp)
    80004b54:	6105                	addi	sp,sp,32
    80004b56:	8082                	ret
    panic("could not find virtio disk");
    80004b58:	00003517          	auipc	a0,0x3
    80004b5c:	bd850513          	addi	a0,a0,-1064 # 80007730 <etext+0x730>
    80004b60:	273000ef          	jal	800055d2 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004b64:	00003517          	auipc	a0,0x3
    80004b68:	bec50513          	addi	a0,a0,-1044 # 80007750 <etext+0x750>
    80004b6c:	267000ef          	jal	800055d2 <panic>
    panic("virtio disk should not be ready");
    80004b70:	00003517          	auipc	a0,0x3
    80004b74:	c0050513          	addi	a0,a0,-1024 # 80007770 <etext+0x770>
    80004b78:	25b000ef          	jal	800055d2 <panic>
    panic("virtio disk has no queue 0");
    80004b7c:	00003517          	auipc	a0,0x3
    80004b80:	c1450513          	addi	a0,a0,-1004 # 80007790 <etext+0x790>
    80004b84:	24f000ef          	jal	800055d2 <panic>
    panic("virtio disk max queue too short");
    80004b88:	00003517          	auipc	a0,0x3
    80004b8c:	c2850513          	addi	a0,a0,-984 # 800077b0 <etext+0x7b0>
    80004b90:	243000ef          	jal	800055d2 <panic>
    panic("virtio disk kalloc");
    80004b94:	00003517          	auipc	a0,0x3
    80004b98:	c3c50513          	addi	a0,a0,-964 # 800077d0 <etext+0x7d0>
    80004b9c:	237000ef          	jal	800055d2 <panic>

0000000080004ba0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004ba0:	7159                	addi	sp,sp,-112
    80004ba2:	f486                	sd	ra,104(sp)
    80004ba4:	f0a2                	sd	s0,96(sp)
    80004ba6:	eca6                	sd	s1,88(sp)
    80004ba8:	e8ca                	sd	s2,80(sp)
    80004baa:	e4ce                	sd	s3,72(sp)
    80004bac:	e0d2                	sd	s4,64(sp)
    80004bae:	fc56                	sd	s5,56(sp)
    80004bb0:	f85a                	sd	s6,48(sp)
    80004bb2:	f45e                	sd	s7,40(sp)
    80004bb4:	f062                	sd	s8,32(sp)
    80004bb6:	ec66                	sd	s9,24(sp)
    80004bb8:	1880                	addi	s0,sp,112
    80004bba:	8a2a                	mv	s4,a0
    80004bbc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004bbe:	00c52c83          	lw	s9,12(a0)
    80004bc2:	001c9c9b          	slliw	s9,s9,0x1
    80004bc6:	1c82                	slli	s9,s9,0x20
    80004bc8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004bcc:	00017517          	auipc	a0,0x17
    80004bd0:	d6c50513          	addi	a0,a0,-660 # 8001b938 <disk+0x128>
    80004bd4:	52d000ef          	jal	80005900 <acquire>
  for(int i = 0; i < 3; i++){
    80004bd8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004bda:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004bdc:	00017b17          	auipc	s6,0x17
    80004be0:	c34b0b13          	addi	s6,s6,-972 # 8001b810 <disk>
  for(int i = 0; i < 3; i++){
    80004be4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004be6:	00017c17          	auipc	s8,0x17
    80004bea:	d52c0c13          	addi	s8,s8,-686 # 8001b938 <disk+0x128>
    80004bee:	a8b9                	j	80004c4c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004bf0:	00fb0733          	add	a4,s6,a5
    80004bf4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004bf8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004bfa:	0207c563          	bltz	a5,80004c24 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004bfe:	2905                	addiw	s2,s2,1
    80004c00:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004c02:	05590963          	beq	s2,s5,80004c54 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004c06:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004c08:	00017717          	auipc	a4,0x17
    80004c0c:	c0870713          	addi	a4,a4,-1016 # 8001b810 <disk>
    80004c10:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004c12:	01874683          	lbu	a3,24(a4)
    80004c16:	fee9                	bnez	a3,80004bf0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004c18:	2785                	addiw	a5,a5,1
    80004c1a:	0705                	addi	a4,a4,1
    80004c1c:	fe979be3          	bne	a5,s1,80004c12 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004c20:	57fd                	li	a5,-1
    80004c22:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004c24:	01205d63          	blez	s2,80004c3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c28:	f9042503          	lw	a0,-112(s0)
    80004c2c:	d07ff0ef          	jal	80004932 <free_desc>
      for(int j = 0; j < i; j++)
    80004c30:	4785                	li	a5,1
    80004c32:	0127d663          	bge	a5,s2,80004c3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c36:	f9442503          	lw	a0,-108(s0)
    80004c3a:	cf9ff0ef          	jal	80004932 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c3e:	85e2                	mv	a1,s8
    80004c40:	00017517          	auipc	a0,0x17
    80004c44:	be850513          	addi	a0,a0,-1048 # 8001b828 <disk+0x18>
    80004c48:	f36fc0ef          	jal	8000137e <sleep>
  for(int i = 0; i < 3; i++){
    80004c4c:	f9040613          	addi	a2,s0,-112
    80004c50:	894e                	mv	s2,s3
    80004c52:	bf55                	j	80004c06 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c54:	f9042503          	lw	a0,-112(s0)
    80004c58:	00451693          	slli	a3,a0,0x4

  if(write)
    80004c5c:	00017797          	auipc	a5,0x17
    80004c60:	bb478793          	addi	a5,a5,-1100 # 8001b810 <disk>
    80004c64:	00a50713          	addi	a4,a0,10
    80004c68:	0712                	slli	a4,a4,0x4
    80004c6a:	973e                	add	a4,a4,a5
    80004c6c:	01703633          	snez	a2,s7
    80004c70:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004c72:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004c76:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c7a:	6398                	ld	a4,0(a5)
    80004c7c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c7e:	0a868613          	addi	a2,a3,168
    80004c82:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c84:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004c86:	6390                	ld	a2,0(a5)
    80004c88:	00d605b3          	add	a1,a2,a3
    80004c8c:	4741                	li	a4,16
    80004c8e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004c90:	4805                	li	a6,1
    80004c92:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004c96:	f9442703          	lw	a4,-108(s0)
    80004c9a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004c9e:	0712                	slli	a4,a4,0x4
    80004ca0:	963a                	add	a2,a2,a4
    80004ca2:	058a0593          	addi	a1,s4,88
    80004ca6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004ca8:	0007b883          	ld	a7,0(a5)
    80004cac:	9746                	add	a4,a4,a7
    80004cae:	40000613          	li	a2,1024
    80004cb2:	c710                	sw	a2,8(a4)
  if(write)
    80004cb4:	001bb613          	seqz	a2,s7
    80004cb8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004cbc:	00166613          	ori	a2,a2,1
    80004cc0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004cc4:	f9842583          	lw	a1,-104(s0)
    80004cc8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004ccc:	00250613          	addi	a2,a0,2
    80004cd0:	0612                	slli	a2,a2,0x4
    80004cd2:	963e                	add	a2,a2,a5
    80004cd4:	577d                	li	a4,-1
    80004cd6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004cda:	0592                	slli	a1,a1,0x4
    80004cdc:	98ae                	add	a7,a7,a1
    80004cde:	03068713          	addi	a4,a3,48
    80004ce2:	973e                	add	a4,a4,a5
    80004ce4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004ce8:	6398                	ld	a4,0(a5)
    80004cea:	972e                	add	a4,a4,a1
    80004cec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004cf0:	4689                	li	a3,2
    80004cf2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004cf6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004cfa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004cfe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004d02:	6794                	ld	a3,8(a5)
    80004d04:	0026d703          	lhu	a4,2(a3)
    80004d08:	8b1d                	andi	a4,a4,7
    80004d0a:	0706                	slli	a4,a4,0x1
    80004d0c:	96ba                	add	a3,a3,a4
    80004d0e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004d12:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004d16:	6798                	ld	a4,8(a5)
    80004d18:	00275783          	lhu	a5,2(a4)
    80004d1c:	2785                	addiw	a5,a5,1
    80004d1e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004d22:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004d26:	100017b7          	lui	a5,0x10001
    80004d2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004d2e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004d32:	00017917          	auipc	s2,0x17
    80004d36:	c0690913          	addi	s2,s2,-1018 # 8001b938 <disk+0x128>
  while(b->disk == 1) {
    80004d3a:	4485                	li	s1,1
    80004d3c:	01079a63          	bne	a5,a6,80004d50 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004d40:	85ca                	mv	a1,s2
    80004d42:	8552                	mv	a0,s4
    80004d44:	e3afc0ef          	jal	8000137e <sleep>
  while(b->disk == 1) {
    80004d48:	004a2783          	lw	a5,4(s4)
    80004d4c:	fe978ae3          	beq	a5,s1,80004d40 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004d50:	f9042903          	lw	s2,-112(s0)
    80004d54:	00290713          	addi	a4,s2,2
    80004d58:	0712                	slli	a4,a4,0x4
    80004d5a:	00017797          	auipc	a5,0x17
    80004d5e:	ab678793          	addi	a5,a5,-1354 # 8001b810 <disk>
    80004d62:	97ba                	add	a5,a5,a4
    80004d64:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004d68:	00017997          	auipc	s3,0x17
    80004d6c:	aa898993          	addi	s3,s3,-1368 # 8001b810 <disk>
    80004d70:	00491713          	slli	a4,s2,0x4
    80004d74:	0009b783          	ld	a5,0(s3)
    80004d78:	97ba                	add	a5,a5,a4
    80004d7a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004d7e:	854a                	mv	a0,s2
    80004d80:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004d84:	bafff0ef          	jal	80004932 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004d88:	8885                	andi	s1,s1,1
    80004d8a:	f0fd                	bnez	s1,80004d70 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004d8c:	00017517          	auipc	a0,0x17
    80004d90:	bac50513          	addi	a0,a0,-1108 # 8001b938 <disk+0x128>
    80004d94:	405000ef          	jal	80005998 <release>
}
    80004d98:	70a6                	ld	ra,104(sp)
    80004d9a:	7406                	ld	s0,96(sp)
    80004d9c:	64e6                	ld	s1,88(sp)
    80004d9e:	6946                	ld	s2,80(sp)
    80004da0:	69a6                	ld	s3,72(sp)
    80004da2:	6a06                	ld	s4,64(sp)
    80004da4:	7ae2                	ld	s5,56(sp)
    80004da6:	7b42                	ld	s6,48(sp)
    80004da8:	7ba2                	ld	s7,40(sp)
    80004daa:	7c02                	ld	s8,32(sp)
    80004dac:	6ce2                	ld	s9,24(sp)
    80004dae:	6165                	addi	sp,sp,112
    80004db0:	8082                	ret

0000000080004db2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004db2:	1101                	addi	sp,sp,-32
    80004db4:	ec06                	sd	ra,24(sp)
    80004db6:	e822                	sd	s0,16(sp)
    80004db8:	e426                	sd	s1,8(sp)
    80004dba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004dbc:	00017497          	auipc	s1,0x17
    80004dc0:	a5448493          	addi	s1,s1,-1452 # 8001b810 <disk>
    80004dc4:	00017517          	auipc	a0,0x17
    80004dc8:	b7450513          	addi	a0,a0,-1164 # 8001b938 <disk+0x128>
    80004dcc:	335000ef          	jal	80005900 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004dd0:	100017b7          	lui	a5,0x10001
    80004dd4:	53b8                	lw	a4,96(a5)
    80004dd6:	8b0d                	andi	a4,a4,3
    80004dd8:	100017b7          	lui	a5,0x10001
    80004ddc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004dde:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004de2:	689c                	ld	a5,16(s1)
    80004de4:	0204d703          	lhu	a4,32(s1)
    80004de8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004dec:	04f70663          	beq	a4,a5,80004e38 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004df0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004df4:	6898                	ld	a4,16(s1)
    80004df6:	0204d783          	lhu	a5,32(s1)
    80004dfa:	8b9d                	andi	a5,a5,7
    80004dfc:	078e                	slli	a5,a5,0x3
    80004dfe:	97ba                	add	a5,a5,a4
    80004e00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004e02:	00278713          	addi	a4,a5,2
    80004e06:	0712                	slli	a4,a4,0x4
    80004e08:	9726                	add	a4,a4,s1
    80004e0a:	01074703          	lbu	a4,16(a4)
    80004e0e:	e321                	bnez	a4,80004e4e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004e10:	0789                	addi	a5,a5,2
    80004e12:	0792                	slli	a5,a5,0x4
    80004e14:	97a6                	add	a5,a5,s1
    80004e16:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004e18:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004e1c:	daefc0ef          	jal	800013ca <wakeup>

    disk.used_idx += 1;
    80004e20:	0204d783          	lhu	a5,32(s1)
    80004e24:	2785                	addiw	a5,a5,1
    80004e26:	17c2                	slli	a5,a5,0x30
    80004e28:	93c1                	srli	a5,a5,0x30
    80004e2a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004e2e:	6898                	ld	a4,16(s1)
    80004e30:	00275703          	lhu	a4,2(a4)
    80004e34:	faf71ee3          	bne	a4,a5,80004df0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004e38:	00017517          	auipc	a0,0x17
    80004e3c:	b0050513          	addi	a0,a0,-1280 # 8001b938 <disk+0x128>
    80004e40:	359000ef          	jal	80005998 <release>
}
    80004e44:	60e2                	ld	ra,24(sp)
    80004e46:	6442                	ld	s0,16(sp)
    80004e48:	64a2                	ld	s1,8(sp)
    80004e4a:	6105                	addi	sp,sp,32
    80004e4c:	8082                	ret
      panic("virtio_disk_intr status");
    80004e4e:	00003517          	auipc	a0,0x3
    80004e52:	99a50513          	addi	a0,a0,-1638 # 800077e8 <etext+0x7e8>
    80004e56:	77c000ef          	jal	800055d2 <panic>

0000000080004e5a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004e5a:	1141                	addi	sp,sp,-16
    80004e5c:	e422                	sd	s0,8(sp)
    80004e5e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004e60:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004e64:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004e68:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004e6c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004e70:	577d                	li	a4,-1
    80004e72:	177e                	slli	a4,a4,0x3f
    80004e74:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004e76:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004e7a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004e7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004e82:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004e86:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004e8a:	000f4737          	lui	a4,0xf4
    80004e8e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004e92:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004e94:	14d79073          	csrw	stimecmp,a5
}
    80004e98:	6422                	ld	s0,8(sp)
    80004e9a:	0141                	addi	sp,sp,16
    80004e9c:	8082                	ret

0000000080004e9e <start>:
{
    80004e9e:	1141                	addi	sp,sp,-16
    80004ea0:	e406                	sd	ra,8(sp)
    80004ea2:	e022                	sd	s0,0(sp)
    80004ea4:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004ea6:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004eaa:	7779                	lui	a4,0xffffe
    80004eac:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdadaf>
    80004eb0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004eb2:	6705                	lui	a4,0x1
    80004eb4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004eb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004eba:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004ebe:	ffffb797          	auipc	a5,0xffffb
    80004ec2:	46c78793          	addi	a5,a5,1132 # 8000032a <main>
    80004ec6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004eca:	4781                	li	a5,0
    80004ecc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004ed0:	67c1                	lui	a5,0x10
    80004ed2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004ed4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004ed8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004edc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004ee0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004ee4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004ee8:	57fd                	li	a5,-1
    80004eea:	83a9                	srli	a5,a5,0xa
    80004eec:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004ef0:	47bd                	li	a5,15
    80004ef2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004ef6:	f65ff0ef          	jal	80004e5a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004efa:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004efe:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004f00:	823e                	mv	tp,a5
  asm volatile("mret");
    80004f02:	30200073          	mret
}
    80004f06:	60a2                	ld	ra,8(sp)
    80004f08:	6402                	ld	s0,0(sp)
    80004f0a:	0141                	addi	sp,sp,16
    80004f0c:	8082                	ret

0000000080004f0e <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004f0e:	715d                	addi	sp,sp,-80
    80004f10:	e486                	sd	ra,72(sp)
    80004f12:	e0a2                	sd	s0,64(sp)
    80004f14:	f84a                	sd	s2,48(sp)
    80004f16:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004f18:	04c05263          	blez	a2,80004f5c <consolewrite+0x4e>
    80004f1c:	fc26                	sd	s1,56(sp)
    80004f1e:	f44e                	sd	s3,40(sp)
    80004f20:	f052                	sd	s4,32(sp)
    80004f22:	ec56                	sd	s5,24(sp)
    80004f24:	8a2a                	mv	s4,a0
    80004f26:	84ae                	mv	s1,a1
    80004f28:	89b2                	mv	s3,a2
    80004f2a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004f2c:	5afd                	li	s5,-1
    80004f2e:	4685                	li	a3,1
    80004f30:	8626                	mv	a2,s1
    80004f32:	85d2                	mv	a1,s4
    80004f34:	fbf40513          	addi	a0,s0,-65
    80004f38:	fecfc0ef          	jal	80001724 <either_copyin>
    80004f3c:	03550263          	beq	a0,s5,80004f60 <consolewrite+0x52>
      break;
    uartputc(c);
    80004f40:	fbf44503          	lbu	a0,-65(s0)
    80004f44:	035000ef          	jal	80005778 <uartputc>
  for(i = 0; i < n; i++){
    80004f48:	2905                	addiw	s2,s2,1
    80004f4a:	0485                	addi	s1,s1,1
    80004f4c:	ff2991e3          	bne	s3,s2,80004f2e <consolewrite+0x20>
    80004f50:	894e                	mv	s2,s3
    80004f52:	74e2                	ld	s1,56(sp)
    80004f54:	79a2                	ld	s3,40(sp)
    80004f56:	7a02                	ld	s4,32(sp)
    80004f58:	6ae2                	ld	s5,24(sp)
    80004f5a:	a039                	j	80004f68 <consolewrite+0x5a>
    80004f5c:	4901                	li	s2,0
    80004f5e:	a029                	j	80004f68 <consolewrite+0x5a>
    80004f60:	74e2                	ld	s1,56(sp)
    80004f62:	79a2                	ld	s3,40(sp)
    80004f64:	7a02                	ld	s4,32(sp)
    80004f66:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80004f68:	854a                	mv	a0,s2
    80004f6a:	60a6                	ld	ra,72(sp)
    80004f6c:	6406                	ld	s0,64(sp)
    80004f6e:	7942                	ld	s2,48(sp)
    80004f70:	6161                	addi	sp,sp,80
    80004f72:	8082                	ret

0000000080004f74 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004f74:	711d                	addi	sp,sp,-96
    80004f76:	ec86                	sd	ra,88(sp)
    80004f78:	e8a2                	sd	s0,80(sp)
    80004f7a:	e4a6                	sd	s1,72(sp)
    80004f7c:	e0ca                	sd	s2,64(sp)
    80004f7e:	fc4e                	sd	s3,56(sp)
    80004f80:	f852                	sd	s4,48(sp)
    80004f82:	f456                	sd	s5,40(sp)
    80004f84:	f05a                	sd	s6,32(sp)
    80004f86:	1080                	addi	s0,sp,96
    80004f88:	8aaa                	mv	s5,a0
    80004f8a:	8a2e                	mv	s4,a1
    80004f8c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004f8e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004f92:	0001f517          	auipc	a0,0x1f
    80004f96:	9be50513          	addi	a0,a0,-1602 # 80023950 <cons>
    80004f9a:	167000ef          	jal	80005900 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004f9e:	0001f497          	auipc	s1,0x1f
    80004fa2:	9b248493          	addi	s1,s1,-1614 # 80023950 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004fa6:	0001f917          	auipc	s2,0x1f
    80004faa:	a4290913          	addi	s2,s2,-1470 # 800239e8 <cons+0x98>
  while(n > 0){
    80004fae:	0b305d63          	blez	s3,80005068 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004fb2:	0984a783          	lw	a5,152(s1)
    80004fb6:	09c4a703          	lw	a4,156(s1)
    80004fba:	0af71263          	bne	a4,a5,8000505e <consoleread+0xea>
      if(killed(myproc())){
    80004fbe:	debfb0ef          	jal	80000da8 <myproc>
    80004fc2:	df4fc0ef          	jal	800015b6 <killed>
    80004fc6:	e12d                	bnez	a0,80005028 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004fc8:	85a6                	mv	a1,s1
    80004fca:	854a                	mv	a0,s2
    80004fcc:	bb2fc0ef          	jal	8000137e <sleep>
    while(cons.r == cons.w){
    80004fd0:	0984a783          	lw	a5,152(s1)
    80004fd4:	09c4a703          	lw	a4,156(s1)
    80004fd8:	fef703e3          	beq	a4,a5,80004fbe <consoleread+0x4a>
    80004fdc:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004fde:	0001f717          	auipc	a4,0x1f
    80004fe2:	97270713          	addi	a4,a4,-1678 # 80023950 <cons>
    80004fe6:	0017869b          	addiw	a3,a5,1
    80004fea:	08d72c23          	sw	a3,152(a4)
    80004fee:	07f7f693          	andi	a3,a5,127
    80004ff2:	9736                	add	a4,a4,a3
    80004ff4:	01874703          	lbu	a4,24(a4)
    80004ff8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004ffc:	4691                	li	a3,4
    80004ffe:	04db8663          	beq	s7,a3,8000504a <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80005002:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005006:	4685                	li	a3,1
    80005008:	faf40613          	addi	a2,s0,-81
    8000500c:	85d2                	mv	a1,s4
    8000500e:	8556                	mv	a0,s5
    80005010:	ecafc0ef          	jal	800016da <either_copyout>
    80005014:	57fd                	li	a5,-1
    80005016:	04f50863          	beq	a0,a5,80005066 <consoleread+0xf2>
      break;

    dst++;
    8000501a:	0a05                	addi	s4,s4,1
    --n;
    8000501c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000501e:	47a9                	li	a5,10
    80005020:	04fb8d63          	beq	s7,a5,8000507a <consoleread+0x106>
    80005024:	6be2                	ld	s7,24(sp)
    80005026:	b761                	j	80004fae <consoleread+0x3a>
        release(&cons.lock);
    80005028:	0001f517          	auipc	a0,0x1f
    8000502c:	92850513          	addi	a0,a0,-1752 # 80023950 <cons>
    80005030:	169000ef          	jal	80005998 <release>
        return -1;
    80005034:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80005036:	60e6                	ld	ra,88(sp)
    80005038:	6446                	ld	s0,80(sp)
    8000503a:	64a6                	ld	s1,72(sp)
    8000503c:	6906                	ld	s2,64(sp)
    8000503e:	79e2                	ld	s3,56(sp)
    80005040:	7a42                	ld	s4,48(sp)
    80005042:	7aa2                	ld	s5,40(sp)
    80005044:	7b02                	ld	s6,32(sp)
    80005046:	6125                	addi	sp,sp,96
    80005048:	8082                	ret
      if(n < target){
    8000504a:	0009871b          	sext.w	a4,s3
    8000504e:	01677a63          	bgeu	a4,s6,80005062 <consoleread+0xee>
        cons.r--;
    80005052:	0001f717          	auipc	a4,0x1f
    80005056:	98f72b23          	sw	a5,-1642(a4) # 800239e8 <cons+0x98>
    8000505a:	6be2                	ld	s7,24(sp)
    8000505c:	a031                	j	80005068 <consoleread+0xf4>
    8000505e:	ec5e                	sd	s7,24(sp)
    80005060:	bfbd                	j	80004fde <consoleread+0x6a>
    80005062:	6be2                	ld	s7,24(sp)
    80005064:	a011                	j	80005068 <consoleread+0xf4>
    80005066:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005068:	0001f517          	auipc	a0,0x1f
    8000506c:	8e850513          	addi	a0,a0,-1816 # 80023950 <cons>
    80005070:	129000ef          	jal	80005998 <release>
  return target - n;
    80005074:	413b053b          	subw	a0,s6,s3
    80005078:	bf7d                	j	80005036 <consoleread+0xc2>
    8000507a:	6be2                	ld	s7,24(sp)
    8000507c:	b7f5                	j	80005068 <consoleread+0xf4>

000000008000507e <consputc>:
{
    8000507e:	1141                	addi	sp,sp,-16
    80005080:	e406                	sd	ra,8(sp)
    80005082:	e022                	sd	s0,0(sp)
    80005084:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005086:	10000793          	li	a5,256
    8000508a:	00f50863          	beq	a0,a5,8000509a <consputc+0x1c>
    uartputc_sync(c);
    8000508e:	604000ef          	jal	80005692 <uartputc_sync>
}
    80005092:	60a2                	ld	ra,8(sp)
    80005094:	6402                	ld	s0,0(sp)
    80005096:	0141                	addi	sp,sp,16
    80005098:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000509a:	4521                	li	a0,8
    8000509c:	5f6000ef          	jal	80005692 <uartputc_sync>
    800050a0:	02000513          	li	a0,32
    800050a4:	5ee000ef          	jal	80005692 <uartputc_sync>
    800050a8:	4521                	li	a0,8
    800050aa:	5e8000ef          	jal	80005692 <uartputc_sync>
    800050ae:	b7d5                	j	80005092 <consputc+0x14>

00000000800050b0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800050b0:	1101                	addi	sp,sp,-32
    800050b2:	ec06                	sd	ra,24(sp)
    800050b4:	e822                	sd	s0,16(sp)
    800050b6:	e426                	sd	s1,8(sp)
    800050b8:	1000                	addi	s0,sp,32
    800050ba:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800050bc:	0001f517          	auipc	a0,0x1f
    800050c0:	89450513          	addi	a0,a0,-1900 # 80023950 <cons>
    800050c4:	03d000ef          	jal	80005900 <acquire>

  switch(c){
    800050c8:	47d5                	li	a5,21
    800050ca:	08f48f63          	beq	s1,a5,80005168 <consoleintr+0xb8>
    800050ce:	0297c563          	blt	a5,s1,800050f8 <consoleintr+0x48>
    800050d2:	47a1                	li	a5,8
    800050d4:	0ef48463          	beq	s1,a5,800051bc <consoleintr+0x10c>
    800050d8:	47c1                	li	a5,16
    800050da:	10f49563          	bne	s1,a5,800051e4 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800050de:	e90fc0ef          	jal	8000176e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800050e2:	0001f517          	auipc	a0,0x1f
    800050e6:	86e50513          	addi	a0,a0,-1938 # 80023950 <cons>
    800050ea:	0af000ef          	jal	80005998 <release>
}
    800050ee:	60e2                	ld	ra,24(sp)
    800050f0:	6442                	ld	s0,16(sp)
    800050f2:	64a2                	ld	s1,8(sp)
    800050f4:	6105                	addi	sp,sp,32
    800050f6:	8082                	ret
  switch(c){
    800050f8:	07f00793          	li	a5,127
    800050fc:	0cf48063          	beq	s1,a5,800051bc <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005100:	0001f717          	auipc	a4,0x1f
    80005104:	85070713          	addi	a4,a4,-1968 # 80023950 <cons>
    80005108:	0a072783          	lw	a5,160(a4)
    8000510c:	09872703          	lw	a4,152(a4)
    80005110:	9f99                	subw	a5,a5,a4
    80005112:	07f00713          	li	a4,127
    80005116:	fcf766e3          	bltu	a4,a5,800050e2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    8000511a:	47b5                	li	a5,13
    8000511c:	0cf48763          	beq	s1,a5,800051ea <consoleintr+0x13a>
      consputc(c);
    80005120:	8526                	mv	a0,s1
    80005122:	f5dff0ef          	jal	8000507e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005126:	0001f797          	auipc	a5,0x1f
    8000512a:	82a78793          	addi	a5,a5,-2006 # 80023950 <cons>
    8000512e:	0a07a683          	lw	a3,160(a5)
    80005132:	0016871b          	addiw	a4,a3,1
    80005136:	0007061b          	sext.w	a2,a4
    8000513a:	0ae7a023          	sw	a4,160(a5)
    8000513e:	07f6f693          	andi	a3,a3,127
    80005142:	97b6                	add	a5,a5,a3
    80005144:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005148:	47a9                	li	a5,10
    8000514a:	0cf48563          	beq	s1,a5,80005214 <consoleintr+0x164>
    8000514e:	4791                	li	a5,4
    80005150:	0cf48263          	beq	s1,a5,80005214 <consoleintr+0x164>
    80005154:	0001f797          	auipc	a5,0x1f
    80005158:	8947a783          	lw	a5,-1900(a5) # 800239e8 <cons+0x98>
    8000515c:	9f1d                	subw	a4,a4,a5
    8000515e:	08000793          	li	a5,128
    80005162:	f8f710e3          	bne	a4,a5,800050e2 <consoleintr+0x32>
    80005166:	a07d                	j	80005214 <consoleintr+0x164>
    80005168:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000516a:	0001e717          	auipc	a4,0x1e
    8000516e:	7e670713          	addi	a4,a4,2022 # 80023950 <cons>
    80005172:	0a072783          	lw	a5,160(a4)
    80005176:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000517a:	0001e497          	auipc	s1,0x1e
    8000517e:	7d648493          	addi	s1,s1,2006 # 80023950 <cons>
    while(cons.e != cons.w &&
    80005182:	4929                	li	s2,10
    80005184:	02f70863          	beq	a4,a5,800051b4 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005188:	37fd                	addiw	a5,a5,-1
    8000518a:	07f7f713          	andi	a4,a5,127
    8000518e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005190:	01874703          	lbu	a4,24(a4)
    80005194:	03270263          	beq	a4,s2,800051b8 <consoleintr+0x108>
      cons.e--;
    80005198:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000519c:	10000513          	li	a0,256
    800051a0:	edfff0ef          	jal	8000507e <consputc>
    while(cons.e != cons.w &&
    800051a4:	0a04a783          	lw	a5,160(s1)
    800051a8:	09c4a703          	lw	a4,156(s1)
    800051ac:	fcf71ee3          	bne	a4,a5,80005188 <consoleintr+0xd8>
    800051b0:	6902                	ld	s2,0(sp)
    800051b2:	bf05                	j	800050e2 <consoleintr+0x32>
    800051b4:	6902                	ld	s2,0(sp)
    800051b6:	b735                	j	800050e2 <consoleintr+0x32>
    800051b8:	6902                	ld	s2,0(sp)
    800051ba:	b725                	j	800050e2 <consoleintr+0x32>
    if(cons.e != cons.w){
    800051bc:	0001e717          	auipc	a4,0x1e
    800051c0:	79470713          	addi	a4,a4,1940 # 80023950 <cons>
    800051c4:	0a072783          	lw	a5,160(a4)
    800051c8:	09c72703          	lw	a4,156(a4)
    800051cc:	f0f70be3          	beq	a4,a5,800050e2 <consoleintr+0x32>
      cons.e--;
    800051d0:	37fd                	addiw	a5,a5,-1
    800051d2:	0001f717          	auipc	a4,0x1f
    800051d6:	80f72f23          	sw	a5,-2018(a4) # 800239f0 <cons+0xa0>
      consputc(BACKSPACE);
    800051da:	10000513          	li	a0,256
    800051de:	ea1ff0ef          	jal	8000507e <consputc>
    800051e2:	b701                	j	800050e2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051e4:	ee048fe3          	beqz	s1,800050e2 <consoleintr+0x32>
    800051e8:	bf21                	j	80005100 <consoleintr+0x50>
      consputc(c);
    800051ea:	4529                	li	a0,10
    800051ec:	e93ff0ef          	jal	8000507e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051f0:	0001e797          	auipc	a5,0x1e
    800051f4:	76078793          	addi	a5,a5,1888 # 80023950 <cons>
    800051f8:	0a07a703          	lw	a4,160(a5)
    800051fc:	0017069b          	addiw	a3,a4,1
    80005200:	0006861b          	sext.w	a2,a3
    80005204:	0ad7a023          	sw	a3,160(a5)
    80005208:	07f77713          	andi	a4,a4,127
    8000520c:	97ba                	add	a5,a5,a4
    8000520e:	4729                	li	a4,10
    80005210:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005214:	0001e797          	auipc	a5,0x1e
    80005218:	7cc7ac23          	sw	a2,2008(a5) # 800239ec <cons+0x9c>
        wakeup(&cons.r);
    8000521c:	0001e517          	auipc	a0,0x1e
    80005220:	7cc50513          	addi	a0,a0,1996 # 800239e8 <cons+0x98>
    80005224:	9a6fc0ef          	jal	800013ca <wakeup>
    80005228:	bd6d                	j	800050e2 <consoleintr+0x32>

000000008000522a <consoleinit>:

void
consoleinit(void)
{
    8000522a:	1141                	addi	sp,sp,-16
    8000522c:	e406                	sd	ra,8(sp)
    8000522e:	e022                	sd	s0,0(sp)
    80005230:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005232:	00002597          	auipc	a1,0x2
    80005236:	5ce58593          	addi	a1,a1,1486 # 80007800 <etext+0x800>
    8000523a:	0001e517          	auipc	a0,0x1e
    8000523e:	71650513          	addi	a0,a0,1814 # 80023950 <cons>
    80005242:	63e000ef          	jal	80005880 <initlock>

  uartinit();
    80005246:	3f4000ef          	jal	8000563a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000524a:	00015797          	auipc	a5,0x15
    8000524e:	56e78793          	addi	a5,a5,1390 # 8001a7b8 <devsw>
    80005252:	00000717          	auipc	a4,0x0
    80005256:	d2270713          	addi	a4,a4,-734 # 80004f74 <consoleread>
    8000525a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000525c:	00000717          	auipc	a4,0x0
    80005260:	cb270713          	addi	a4,a4,-846 # 80004f0e <consolewrite>
    80005264:	ef98                	sd	a4,24(a5)
}
    80005266:	60a2                	ld	ra,8(sp)
    80005268:	6402                	ld	s0,0(sp)
    8000526a:	0141                	addi	sp,sp,16
    8000526c:	8082                	ret

000000008000526e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000526e:	7179                	addi	sp,sp,-48
    80005270:	f406                	sd	ra,40(sp)
    80005272:	f022                	sd	s0,32(sp)
    80005274:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005276:	c219                	beqz	a2,8000527c <printint+0xe>
    80005278:	08054063          	bltz	a0,800052f8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000527c:	4881                	li	a7,0
    8000527e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005282:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005284:	00002617          	auipc	a2,0x2
    80005288:	7c460613          	addi	a2,a2,1988 # 80007a48 <digits>
    8000528c:	883e                	mv	a6,a5
    8000528e:	2785                	addiw	a5,a5,1
    80005290:	02b57733          	remu	a4,a0,a1
    80005294:	9732                	add	a4,a4,a2
    80005296:	00074703          	lbu	a4,0(a4)
    8000529a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000529e:	872a                	mv	a4,a0
    800052a0:	02b55533          	divu	a0,a0,a1
    800052a4:	0685                	addi	a3,a3,1
    800052a6:	feb773e3          	bgeu	a4,a1,8000528c <printint+0x1e>

  if(sign)
    800052aa:	00088a63          	beqz	a7,800052be <printint+0x50>
    buf[i++] = '-';
    800052ae:	1781                	addi	a5,a5,-32
    800052b0:	97a2                	add	a5,a5,s0
    800052b2:	02d00713          	li	a4,45
    800052b6:	fee78823          	sb	a4,-16(a5)
    800052ba:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800052be:	02f05963          	blez	a5,800052f0 <printint+0x82>
    800052c2:	ec26                	sd	s1,24(sp)
    800052c4:	e84a                	sd	s2,16(sp)
    800052c6:	fd040713          	addi	a4,s0,-48
    800052ca:	00f704b3          	add	s1,a4,a5
    800052ce:	fff70913          	addi	s2,a4,-1
    800052d2:	993e                	add	s2,s2,a5
    800052d4:	37fd                	addiw	a5,a5,-1
    800052d6:	1782                	slli	a5,a5,0x20
    800052d8:	9381                	srli	a5,a5,0x20
    800052da:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800052de:	fff4c503          	lbu	a0,-1(s1)
    800052e2:	d9dff0ef          	jal	8000507e <consputc>
  while(--i >= 0)
    800052e6:	14fd                	addi	s1,s1,-1
    800052e8:	ff249be3          	bne	s1,s2,800052de <printint+0x70>
    800052ec:	64e2                	ld	s1,24(sp)
    800052ee:	6942                	ld	s2,16(sp)
}
    800052f0:	70a2                	ld	ra,40(sp)
    800052f2:	7402                	ld	s0,32(sp)
    800052f4:	6145                	addi	sp,sp,48
    800052f6:	8082                	ret
    x = -xx;
    800052f8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800052fc:	4885                	li	a7,1
    x = -xx;
    800052fe:	b741                	j	8000527e <printint+0x10>

0000000080005300 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005300:	7155                	addi	sp,sp,-208
    80005302:	e506                	sd	ra,136(sp)
    80005304:	e122                	sd	s0,128(sp)
    80005306:	f0d2                	sd	s4,96(sp)
    80005308:	0900                	addi	s0,sp,144
    8000530a:	8a2a                	mv	s4,a0
    8000530c:	e40c                	sd	a1,8(s0)
    8000530e:	e810                	sd	a2,16(s0)
    80005310:	ec14                	sd	a3,24(s0)
    80005312:	f018                	sd	a4,32(s0)
    80005314:	f41c                	sd	a5,40(s0)
    80005316:	03043823          	sd	a6,48(s0)
    8000531a:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    8000531e:	0001e797          	auipc	a5,0x1e
    80005322:	6f27a783          	lw	a5,1778(a5) # 80023a10 <pr+0x18>
    80005326:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000532a:	e3a1                	bnez	a5,8000536a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000532c:	00840793          	addi	a5,s0,8
    80005330:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005334:	00054503          	lbu	a0,0(a0)
    80005338:	26050763          	beqz	a0,800055a6 <printf+0x2a6>
    8000533c:	fca6                	sd	s1,120(sp)
    8000533e:	f8ca                	sd	s2,112(sp)
    80005340:	f4ce                	sd	s3,104(sp)
    80005342:	ecd6                	sd	s5,88(sp)
    80005344:	e8da                	sd	s6,80(sp)
    80005346:	e0e2                	sd	s8,64(sp)
    80005348:	fc66                	sd	s9,56(sp)
    8000534a:	f86a                	sd	s10,48(sp)
    8000534c:	f46e                	sd	s11,40(sp)
    8000534e:	4981                	li	s3,0
    if(cx != '%'){
    80005350:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005354:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005358:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000535c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005360:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005364:	07000d93          	li	s11,112
    80005368:	a815                	j	8000539c <printf+0x9c>
    acquire(&pr.lock);
    8000536a:	0001e517          	auipc	a0,0x1e
    8000536e:	68e50513          	addi	a0,a0,1678 # 800239f8 <pr>
    80005372:	58e000ef          	jal	80005900 <acquire>
  va_start(ap, fmt);
    80005376:	00840793          	addi	a5,s0,8
    8000537a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000537e:	000a4503          	lbu	a0,0(s4)
    80005382:	fd4d                	bnez	a0,8000533c <printf+0x3c>
    80005384:	a481                	j	800055c4 <printf+0x2c4>
      consputc(cx);
    80005386:	cf9ff0ef          	jal	8000507e <consputc>
      continue;
    8000538a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000538c:	0014899b          	addiw	s3,s1,1
    80005390:	013a07b3          	add	a5,s4,s3
    80005394:	0007c503          	lbu	a0,0(a5)
    80005398:	1e050b63          	beqz	a0,8000558e <printf+0x28e>
    if(cx != '%'){
    8000539c:	ff5515e3          	bne	a0,s5,80005386 <printf+0x86>
    i++;
    800053a0:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800053a4:	009a07b3          	add	a5,s4,s1
    800053a8:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800053ac:	1e090163          	beqz	s2,8000558e <printf+0x28e>
    800053b0:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800053b4:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800053b6:	c789                	beqz	a5,800053c0 <printf+0xc0>
    800053b8:	009a0733          	add	a4,s4,s1
    800053bc:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800053c0:	03690763          	beq	s2,s6,800053ee <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    800053c4:	05890163          	beq	s2,s8,80005406 <printf+0x106>
    } else if(c0 == 'u'){
    800053c8:	0d990b63          	beq	s2,s9,8000549e <printf+0x19e>
    } else if(c0 == 'x'){
    800053cc:	13a90163          	beq	s2,s10,800054ee <printf+0x1ee>
    } else if(c0 == 'p'){
    800053d0:	13b90b63          	beq	s2,s11,80005506 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800053d4:	07300793          	li	a5,115
    800053d8:	16f90a63          	beq	s2,a5,8000554c <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800053dc:	1b590463          	beq	s2,s5,80005584 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800053e0:	8556                	mv	a0,s5
    800053e2:	c9dff0ef          	jal	8000507e <consputc>
      consputc(c0);
    800053e6:	854a                	mv	a0,s2
    800053e8:	c97ff0ef          	jal	8000507e <consputc>
    800053ec:	b745                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800053ee:	f8843783          	ld	a5,-120(s0)
    800053f2:	00878713          	addi	a4,a5,8
    800053f6:	f8e43423          	sd	a4,-120(s0)
    800053fa:	4605                	li	a2,1
    800053fc:	45a9                	li	a1,10
    800053fe:	4388                	lw	a0,0(a5)
    80005400:	e6fff0ef          	jal	8000526e <printint>
    80005404:	b761                	j	8000538c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    80005406:	03678663          	beq	a5,s6,80005432 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000540a:	05878263          	beq	a5,s8,8000544e <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    8000540e:	0b978463          	beq	a5,s9,800054b6 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    80005412:	fda797e3          	bne	a5,s10,800053e0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005416:	f8843783          	ld	a5,-120(s0)
    8000541a:	00878713          	addi	a4,a5,8
    8000541e:	f8e43423          	sd	a4,-120(s0)
    80005422:	4601                	li	a2,0
    80005424:	45c1                	li	a1,16
    80005426:	6388                	ld	a0,0(a5)
    80005428:	e47ff0ef          	jal	8000526e <printint>
      i += 1;
    8000542c:	0029849b          	addiw	s1,s3,2
    80005430:	bfb1                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005432:	f8843783          	ld	a5,-120(s0)
    80005436:	00878713          	addi	a4,a5,8
    8000543a:	f8e43423          	sd	a4,-120(s0)
    8000543e:	4605                	li	a2,1
    80005440:	45a9                	li	a1,10
    80005442:	6388                	ld	a0,0(a5)
    80005444:	e2bff0ef          	jal	8000526e <printint>
      i += 1;
    80005448:	0029849b          	addiw	s1,s3,2
    8000544c:	b781                	j	8000538c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000544e:	06400793          	li	a5,100
    80005452:	02f68863          	beq	a3,a5,80005482 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005456:	07500793          	li	a5,117
    8000545a:	06f68c63          	beq	a3,a5,800054d2 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000545e:	07800793          	li	a5,120
    80005462:	f6f69fe3          	bne	a3,a5,800053e0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005466:	f8843783          	ld	a5,-120(s0)
    8000546a:	00878713          	addi	a4,a5,8
    8000546e:	f8e43423          	sd	a4,-120(s0)
    80005472:	4601                	li	a2,0
    80005474:	45c1                	li	a1,16
    80005476:	6388                	ld	a0,0(a5)
    80005478:	df7ff0ef          	jal	8000526e <printint>
      i += 2;
    8000547c:	0039849b          	addiw	s1,s3,3
    80005480:	b731                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005482:	f8843783          	ld	a5,-120(s0)
    80005486:	00878713          	addi	a4,a5,8
    8000548a:	f8e43423          	sd	a4,-120(s0)
    8000548e:	4605                	li	a2,1
    80005490:	45a9                	li	a1,10
    80005492:	6388                	ld	a0,0(a5)
    80005494:	ddbff0ef          	jal	8000526e <printint>
      i += 2;
    80005498:	0039849b          	addiw	s1,s3,3
    8000549c:	bdc5                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000549e:	f8843783          	ld	a5,-120(s0)
    800054a2:	00878713          	addi	a4,a5,8
    800054a6:	f8e43423          	sd	a4,-120(s0)
    800054aa:	4601                	li	a2,0
    800054ac:	45a9                	li	a1,10
    800054ae:	4388                	lw	a0,0(a5)
    800054b0:	dbfff0ef          	jal	8000526e <printint>
    800054b4:	bde1                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800054b6:	f8843783          	ld	a5,-120(s0)
    800054ba:	00878713          	addi	a4,a5,8
    800054be:	f8e43423          	sd	a4,-120(s0)
    800054c2:	4601                	li	a2,0
    800054c4:	45a9                	li	a1,10
    800054c6:	6388                	ld	a0,0(a5)
    800054c8:	da7ff0ef          	jal	8000526e <printint>
      i += 1;
    800054cc:	0029849b          	addiw	s1,s3,2
    800054d0:	bd75                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800054d2:	f8843783          	ld	a5,-120(s0)
    800054d6:	00878713          	addi	a4,a5,8
    800054da:	f8e43423          	sd	a4,-120(s0)
    800054de:	4601                	li	a2,0
    800054e0:	45a9                	li	a1,10
    800054e2:	6388                	ld	a0,0(a5)
    800054e4:	d8bff0ef          	jal	8000526e <printint>
      i += 2;
    800054e8:	0039849b          	addiw	s1,s3,3
    800054ec:	b545                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800054ee:	f8843783          	ld	a5,-120(s0)
    800054f2:	00878713          	addi	a4,a5,8
    800054f6:	f8e43423          	sd	a4,-120(s0)
    800054fa:	4601                	li	a2,0
    800054fc:	45c1                	li	a1,16
    800054fe:	4388                	lw	a0,0(a5)
    80005500:	d6fff0ef          	jal	8000526e <printint>
    80005504:	b561                	j	8000538c <printf+0x8c>
    80005506:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    80005508:	f8843783          	ld	a5,-120(s0)
    8000550c:	00878713          	addi	a4,a5,8
    80005510:	f8e43423          	sd	a4,-120(s0)
    80005514:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005518:	03000513          	li	a0,48
    8000551c:	b63ff0ef          	jal	8000507e <consputc>
  consputc('x');
    80005520:	07800513          	li	a0,120
    80005524:	b5bff0ef          	jal	8000507e <consputc>
    80005528:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000552a:	00002b97          	auipc	s7,0x2
    8000552e:	51eb8b93          	addi	s7,s7,1310 # 80007a48 <digits>
    80005532:	03c9d793          	srli	a5,s3,0x3c
    80005536:	97de                	add	a5,a5,s7
    80005538:	0007c503          	lbu	a0,0(a5)
    8000553c:	b43ff0ef          	jal	8000507e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005540:	0992                	slli	s3,s3,0x4
    80005542:	397d                	addiw	s2,s2,-1
    80005544:	fe0917e3          	bnez	s2,80005532 <printf+0x232>
    80005548:	6ba6                	ld	s7,72(sp)
    8000554a:	b589                	j	8000538c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000554c:	f8843783          	ld	a5,-120(s0)
    80005550:	00878713          	addi	a4,a5,8
    80005554:	f8e43423          	sd	a4,-120(s0)
    80005558:	0007b903          	ld	s2,0(a5)
    8000555c:	00090d63          	beqz	s2,80005576 <printf+0x276>
      for(; *s; s++)
    80005560:	00094503          	lbu	a0,0(s2)
    80005564:	e20504e3          	beqz	a0,8000538c <printf+0x8c>
        consputc(*s);
    80005568:	b17ff0ef          	jal	8000507e <consputc>
      for(; *s; s++)
    8000556c:	0905                	addi	s2,s2,1
    8000556e:	00094503          	lbu	a0,0(s2)
    80005572:	f97d                	bnez	a0,80005568 <printf+0x268>
    80005574:	bd21                	j	8000538c <printf+0x8c>
        s = "(null)";
    80005576:	00002917          	auipc	s2,0x2
    8000557a:	29290913          	addi	s2,s2,658 # 80007808 <etext+0x808>
      for(; *s; s++)
    8000557e:	02800513          	li	a0,40
    80005582:	b7dd                	j	80005568 <printf+0x268>
      consputc('%');
    80005584:	02500513          	li	a0,37
    80005588:	af7ff0ef          	jal	8000507e <consputc>
    8000558c:	b501                	j	8000538c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000558e:	f7843783          	ld	a5,-136(s0)
    80005592:	e385                	bnez	a5,800055b2 <printf+0x2b2>
    80005594:	74e6                	ld	s1,120(sp)
    80005596:	7946                	ld	s2,112(sp)
    80005598:	79a6                	ld	s3,104(sp)
    8000559a:	6ae6                	ld	s5,88(sp)
    8000559c:	6b46                	ld	s6,80(sp)
    8000559e:	6c06                	ld	s8,64(sp)
    800055a0:	7ce2                	ld	s9,56(sp)
    800055a2:	7d42                	ld	s10,48(sp)
    800055a4:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    800055a6:	4501                	li	a0,0
    800055a8:	60aa                	ld	ra,136(sp)
    800055aa:	640a                	ld	s0,128(sp)
    800055ac:	7a06                	ld	s4,96(sp)
    800055ae:	6169                	addi	sp,sp,208
    800055b0:	8082                	ret
    800055b2:	74e6                	ld	s1,120(sp)
    800055b4:	7946                	ld	s2,112(sp)
    800055b6:	79a6                	ld	s3,104(sp)
    800055b8:	6ae6                	ld	s5,88(sp)
    800055ba:	6b46                	ld	s6,80(sp)
    800055bc:	6c06                	ld	s8,64(sp)
    800055be:	7ce2                	ld	s9,56(sp)
    800055c0:	7d42                	ld	s10,48(sp)
    800055c2:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    800055c4:	0001e517          	auipc	a0,0x1e
    800055c8:	43450513          	addi	a0,a0,1076 # 800239f8 <pr>
    800055cc:	3cc000ef          	jal	80005998 <release>
    800055d0:	bfd9                	j	800055a6 <printf+0x2a6>

00000000800055d2 <panic>:

void
panic(char *s)
{
    800055d2:	1101                	addi	sp,sp,-32
    800055d4:	ec06                	sd	ra,24(sp)
    800055d6:	e822                	sd	s0,16(sp)
    800055d8:	e426                	sd	s1,8(sp)
    800055da:	1000                	addi	s0,sp,32
    800055dc:	84aa                	mv	s1,a0
  pr.locking = 0;
    800055de:	0001e797          	auipc	a5,0x1e
    800055e2:	4207a923          	sw	zero,1074(a5) # 80023a10 <pr+0x18>
  printf("panic: ");
    800055e6:	00002517          	auipc	a0,0x2
    800055ea:	22a50513          	addi	a0,a0,554 # 80007810 <etext+0x810>
    800055ee:	d13ff0ef          	jal	80005300 <printf>
  printf("%s\n", s);
    800055f2:	85a6                	mv	a1,s1
    800055f4:	00002517          	auipc	a0,0x2
    800055f8:	22450513          	addi	a0,a0,548 # 80007818 <etext+0x818>
    800055fc:	d05ff0ef          	jal	80005300 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005600:	4785                	li	a5,1
    80005602:	00005717          	auipc	a4,0x5
    80005606:	f0f72523          	sw	a5,-246(a4) # 8000a50c <panicked>
  for(;;)
    8000560a:	a001                	j	8000560a <panic+0x38>

000000008000560c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000560c:	1101                	addi	sp,sp,-32
    8000560e:	ec06                	sd	ra,24(sp)
    80005610:	e822                	sd	s0,16(sp)
    80005612:	e426                	sd	s1,8(sp)
    80005614:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005616:	0001e497          	auipc	s1,0x1e
    8000561a:	3e248493          	addi	s1,s1,994 # 800239f8 <pr>
    8000561e:	00002597          	auipc	a1,0x2
    80005622:	20258593          	addi	a1,a1,514 # 80007820 <etext+0x820>
    80005626:	8526                	mv	a0,s1
    80005628:	258000ef          	jal	80005880 <initlock>
  pr.locking = 1;
    8000562c:	4785                	li	a5,1
    8000562e:	cc9c                	sw	a5,24(s1)
}
    80005630:	60e2                	ld	ra,24(sp)
    80005632:	6442                	ld	s0,16(sp)
    80005634:	64a2                	ld	s1,8(sp)
    80005636:	6105                	addi	sp,sp,32
    80005638:	8082                	ret

000000008000563a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000563a:	1141                	addi	sp,sp,-16
    8000563c:	e406                	sd	ra,8(sp)
    8000563e:	e022                	sd	s0,0(sp)
    80005640:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005642:	100007b7          	lui	a5,0x10000
    80005646:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000564a:	10000737          	lui	a4,0x10000
    8000564e:	f8000693          	li	a3,-128
    80005652:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005656:	468d                	li	a3,3
    80005658:	10000637          	lui	a2,0x10000
    8000565c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005660:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005664:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005668:	10000737          	lui	a4,0x10000
    8000566c:	461d                	li	a2,7
    8000566e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005672:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005676:	00002597          	auipc	a1,0x2
    8000567a:	1b258593          	addi	a1,a1,434 # 80007828 <etext+0x828>
    8000567e:	0001e517          	auipc	a0,0x1e
    80005682:	39a50513          	addi	a0,a0,922 # 80023a18 <uart_tx_lock>
    80005686:	1fa000ef          	jal	80005880 <initlock>
}
    8000568a:	60a2                	ld	ra,8(sp)
    8000568c:	6402                	ld	s0,0(sp)
    8000568e:	0141                	addi	sp,sp,16
    80005690:	8082                	ret

0000000080005692 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005692:	1101                	addi	sp,sp,-32
    80005694:	ec06                	sd	ra,24(sp)
    80005696:	e822                	sd	s0,16(sp)
    80005698:	e426                	sd	s1,8(sp)
    8000569a:	1000                	addi	s0,sp,32
    8000569c:	84aa                	mv	s1,a0
  push_off();
    8000569e:	222000ef          	jal	800058c0 <push_off>

  if(panicked){
    800056a2:	00005797          	auipc	a5,0x5
    800056a6:	e6a7a783          	lw	a5,-406(a5) # 8000a50c <panicked>
    800056aa:	e795                	bnez	a5,800056d6 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800056ac:	10000737          	lui	a4,0x10000
    800056b0:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800056b2:	00074783          	lbu	a5,0(a4)
    800056b6:	0207f793          	andi	a5,a5,32
    800056ba:	dfe5                	beqz	a5,800056b2 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800056bc:	0ff4f513          	zext.b	a0,s1
    800056c0:	100007b7          	lui	a5,0x10000
    800056c4:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800056c8:	27c000ef          	jal	80005944 <pop_off>
}
    800056cc:	60e2                	ld	ra,24(sp)
    800056ce:	6442                	ld	s0,16(sp)
    800056d0:	64a2                	ld	s1,8(sp)
    800056d2:	6105                	addi	sp,sp,32
    800056d4:	8082                	ret
    for(;;)
    800056d6:	a001                	j	800056d6 <uartputc_sync+0x44>

00000000800056d8 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800056d8:	00005797          	auipc	a5,0x5
    800056dc:	e387b783          	ld	a5,-456(a5) # 8000a510 <uart_tx_r>
    800056e0:	00005717          	auipc	a4,0x5
    800056e4:	e3873703          	ld	a4,-456(a4) # 8000a518 <uart_tx_w>
    800056e8:	08f70263          	beq	a4,a5,8000576c <uartstart+0x94>
{
    800056ec:	7139                	addi	sp,sp,-64
    800056ee:	fc06                	sd	ra,56(sp)
    800056f0:	f822                	sd	s0,48(sp)
    800056f2:	f426                	sd	s1,40(sp)
    800056f4:	f04a                	sd	s2,32(sp)
    800056f6:	ec4e                	sd	s3,24(sp)
    800056f8:	e852                	sd	s4,16(sp)
    800056fa:	e456                	sd	s5,8(sp)
    800056fc:	e05a                	sd	s6,0(sp)
    800056fe:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005700:	10000937          	lui	s2,0x10000
    80005704:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005706:	0001ea97          	auipc	s5,0x1e
    8000570a:	312a8a93          	addi	s5,s5,786 # 80023a18 <uart_tx_lock>
    uart_tx_r += 1;
    8000570e:	00005497          	auipc	s1,0x5
    80005712:	e0248493          	addi	s1,s1,-510 # 8000a510 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    80005716:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    8000571a:	00005997          	auipc	s3,0x5
    8000571e:	dfe98993          	addi	s3,s3,-514 # 8000a518 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005722:	00094703          	lbu	a4,0(s2)
    80005726:	02077713          	andi	a4,a4,32
    8000572a:	c71d                	beqz	a4,80005758 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000572c:	01f7f713          	andi	a4,a5,31
    80005730:	9756                	add	a4,a4,s5
    80005732:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80005736:	0785                	addi	a5,a5,1
    80005738:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    8000573a:	8526                	mv	a0,s1
    8000573c:	c8ffb0ef          	jal	800013ca <wakeup>
    WriteReg(THR, c);
    80005740:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80005744:	609c                	ld	a5,0(s1)
    80005746:	0009b703          	ld	a4,0(s3)
    8000574a:	fcf71ce3          	bne	a4,a5,80005722 <uartstart+0x4a>
      ReadReg(ISR);
    8000574e:	100007b7          	lui	a5,0x10000
    80005752:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005754:	0007c783          	lbu	a5,0(a5)
  }
}
    80005758:	70e2                	ld	ra,56(sp)
    8000575a:	7442                	ld	s0,48(sp)
    8000575c:	74a2                	ld	s1,40(sp)
    8000575e:	7902                	ld	s2,32(sp)
    80005760:	69e2                	ld	s3,24(sp)
    80005762:	6a42                	ld	s4,16(sp)
    80005764:	6aa2                	ld	s5,8(sp)
    80005766:	6b02                	ld	s6,0(sp)
    80005768:	6121                	addi	sp,sp,64
    8000576a:	8082                	ret
      ReadReg(ISR);
    8000576c:	100007b7          	lui	a5,0x10000
    80005770:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005772:	0007c783          	lbu	a5,0(a5)
      return;
    80005776:	8082                	ret

0000000080005778 <uartputc>:
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	e84a                	sd	s2,16(sp)
    80005782:	e44e                	sd	s3,8(sp)
    80005784:	e052                	sd	s4,0(sp)
    80005786:	1800                	addi	s0,sp,48
    80005788:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000578a:	0001e517          	auipc	a0,0x1e
    8000578e:	28e50513          	addi	a0,a0,654 # 80023a18 <uart_tx_lock>
    80005792:	16e000ef          	jal	80005900 <acquire>
  if(panicked){
    80005796:	00005797          	auipc	a5,0x5
    8000579a:	d767a783          	lw	a5,-650(a5) # 8000a50c <panicked>
    8000579e:	efbd                	bnez	a5,8000581c <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057a0:	00005717          	auipc	a4,0x5
    800057a4:	d7873703          	ld	a4,-648(a4) # 8000a518 <uart_tx_w>
    800057a8:	00005797          	auipc	a5,0x5
    800057ac:	d687b783          	ld	a5,-664(a5) # 8000a510 <uart_tx_r>
    800057b0:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800057b4:	0001e997          	auipc	s3,0x1e
    800057b8:	26498993          	addi	s3,s3,612 # 80023a18 <uart_tx_lock>
    800057bc:	00005497          	auipc	s1,0x5
    800057c0:	d5448493          	addi	s1,s1,-684 # 8000a510 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057c4:	00005917          	auipc	s2,0x5
    800057c8:	d5490913          	addi	s2,s2,-684 # 8000a518 <uart_tx_w>
    800057cc:	00e79d63          	bne	a5,a4,800057e6 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800057d0:	85ce                	mv	a1,s3
    800057d2:	8526                	mv	a0,s1
    800057d4:	babfb0ef          	jal	8000137e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057d8:	00093703          	ld	a4,0(s2)
    800057dc:	609c                	ld	a5,0(s1)
    800057de:	02078793          	addi	a5,a5,32
    800057e2:	fee787e3          	beq	a5,a4,800057d0 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800057e6:	0001e497          	auipc	s1,0x1e
    800057ea:	23248493          	addi	s1,s1,562 # 80023a18 <uart_tx_lock>
    800057ee:	01f77793          	andi	a5,a4,31
    800057f2:	97a6                	add	a5,a5,s1
    800057f4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800057f8:	0705                	addi	a4,a4,1
    800057fa:	00005797          	auipc	a5,0x5
    800057fe:	d0e7bf23          	sd	a4,-738(a5) # 8000a518 <uart_tx_w>
  uartstart();
    80005802:	ed7ff0ef          	jal	800056d8 <uartstart>
  release(&uart_tx_lock);
    80005806:	8526                	mv	a0,s1
    80005808:	190000ef          	jal	80005998 <release>
}
    8000580c:	70a2                	ld	ra,40(sp)
    8000580e:	7402                	ld	s0,32(sp)
    80005810:	64e2                	ld	s1,24(sp)
    80005812:	6942                	ld	s2,16(sp)
    80005814:	69a2                	ld	s3,8(sp)
    80005816:	6a02                	ld	s4,0(sp)
    80005818:	6145                	addi	sp,sp,48
    8000581a:	8082                	ret
    for(;;)
    8000581c:	a001                	j	8000581c <uartputc+0xa4>

000000008000581e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000581e:	1141                	addi	sp,sp,-16
    80005820:	e422                	sd	s0,8(sp)
    80005822:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005824:	100007b7          	lui	a5,0x10000
    80005828:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    8000582a:	0007c783          	lbu	a5,0(a5)
    8000582e:	8b85                	andi	a5,a5,1
    80005830:	cb81                	beqz	a5,80005840 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005832:	100007b7          	lui	a5,0x10000
    80005836:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000583a:	6422                	ld	s0,8(sp)
    8000583c:	0141                	addi	sp,sp,16
    8000583e:	8082                	ret
    return -1;
    80005840:	557d                	li	a0,-1
    80005842:	bfe5                	j	8000583a <uartgetc+0x1c>

0000000080005844 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005844:	1101                	addi	sp,sp,-32
    80005846:	ec06                	sd	ra,24(sp)
    80005848:	e822                	sd	s0,16(sp)
    8000584a:	e426                	sd	s1,8(sp)
    8000584c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000584e:	54fd                	li	s1,-1
    80005850:	a019                	j	80005856 <uartintr+0x12>
      break;
    consoleintr(c);
    80005852:	85fff0ef          	jal	800050b0 <consoleintr>
    int c = uartgetc();
    80005856:	fc9ff0ef          	jal	8000581e <uartgetc>
    if(c == -1)
    8000585a:	fe951ce3          	bne	a0,s1,80005852 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000585e:	0001e497          	auipc	s1,0x1e
    80005862:	1ba48493          	addi	s1,s1,442 # 80023a18 <uart_tx_lock>
    80005866:	8526                	mv	a0,s1
    80005868:	098000ef          	jal	80005900 <acquire>
  uartstart();
    8000586c:	e6dff0ef          	jal	800056d8 <uartstart>
  release(&uart_tx_lock);
    80005870:	8526                	mv	a0,s1
    80005872:	126000ef          	jal	80005998 <release>
}
    80005876:	60e2                	ld	ra,24(sp)
    80005878:	6442                	ld	s0,16(sp)
    8000587a:	64a2                	ld	s1,8(sp)
    8000587c:	6105                	addi	sp,sp,32
    8000587e:	8082                	ret

0000000080005880 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005880:	1141                	addi	sp,sp,-16
    80005882:	e422                	sd	s0,8(sp)
    80005884:	0800                	addi	s0,sp,16
  lk->name = name;
    80005886:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005888:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000588c:	00053823          	sd	zero,16(a0)
}
    80005890:	6422                	ld	s0,8(sp)
    80005892:	0141                	addi	sp,sp,16
    80005894:	8082                	ret

0000000080005896 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005896:	411c                	lw	a5,0(a0)
    80005898:	e399                	bnez	a5,8000589e <holding+0x8>
    8000589a:	4501                	li	a0,0
  return r;
}
    8000589c:	8082                	ret
{
    8000589e:	1101                	addi	sp,sp,-32
    800058a0:	ec06                	sd	ra,24(sp)
    800058a2:	e822                	sd	s0,16(sp)
    800058a4:	e426                	sd	s1,8(sp)
    800058a6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800058a8:	6904                	ld	s1,16(a0)
    800058aa:	ce2fb0ef          	jal	80000d8c <mycpu>
    800058ae:	40a48533          	sub	a0,s1,a0
    800058b2:	00153513          	seqz	a0,a0
}
    800058b6:	60e2                	ld	ra,24(sp)
    800058b8:	6442                	ld	s0,16(sp)
    800058ba:	64a2                	ld	s1,8(sp)
    800058bc:	6105                	addi	sp,sp,32
    800058be:	8082                	ret

00000000800058c0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800058c0:	1101                	addi	sp,sp,-32
    800058c2:	ec06                	sd	ra,24(sp)
    800058c4:	e822                	sd	s0,16(sp)
    800058c6:	e426                	sd	s1,8(sp)
    800058c8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800058ca:	100024f3          	csrr	s1,sstatus
    800058ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800058d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800058d4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800058d8:	cb4fb0ef          	jal	80000d8c <mycpu>
    800058dc:	5d3c                	lw	a5,120(a0)
    800058de:	cb99                	beqz	a5,800058f4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800058e0:	cacfb0ef          	jal	80000d8c <mycpu>
    800058e4:	5d3c                	lw	a5,120(a0)
    800058e6:	2785                	addiw	a5,a5,1
    800058e8:	dd3c                	sw	a5,120(a0)
}
    800058ea:	60e2                	ld	ra,24(sp)
    800058ec:	6442                	ld	s0,16(sp)
    800058ee:	64a2                	ld	s1,8(sp)
    800058f0:	6105                	addi	sp,sp,32
    800058f2:	8082                	ret
    mycpu()->intena = old;
    800058f4:	c98fb0ef          	jal	80000d8c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800058f8:	8085                	srli	s1,s1,0x1
    800058fa:	8885                	andi	s1,s1,1
    800058fc:	dd64                	sw	s1,124(a0)
    800058fe:	b7cd                	j	800058e0 <push_off+0x20>

0000000080005900 <acquire>:
{
    80005900:	1101                	addi	sp,sp,-32
    80005902:	ec06                	sd	ra,24(sp)
    80005904:	e822                	sd	s0,16(sp)
    80005906:	e426                	sd	s1,8(sp)
    80005908:	1000                	addi	s0,sp,32
    8000590a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000590c:	fb5ff0ef          	jal	800058c0 <push_off>
  if(holding(lk))
    80005910:	8526                	mv	a0,s1
    80005912:	f85ff0ef          	jal	80005896 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005916:	4705                	li	a4,1
  if(holding(lk))
    80005918:	e105                	bnez	a0,80005938 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000591a:	87ba                	mv	a5,a4
    8000591c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005920:	2781                	sext.w	a5,a5
    80005922:	ffe5                	bnez	a5,8000591a <acquire+0x1a>
  __sync_synchronize();
    80005924:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80005928:	c64fb0ef          	jal	80000d8c <mycpu>
    8000592c:	e888                	sd	a0,16(s1)
}
    8000592e:	60e2                	ld	ra,24(sp)
    80005930:	6442                	ld	s0,16(sp)
    80005932:	64a2                	ld	s1,8(sp)
    80005934:	6105                	addi	sp,sp,32
    80005936:	8082                	ret
    panic("acquire");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	ef850513          	addi	a0,a0,-264 # 80007830 <etext+0x830>
    80005940:	c93ff0ef          	jal	800055d2 <panic>

0000000080005944 <pop_off>:

void
pop_off(void)
{
    80005944:	1141                	addi	sp,sp,-16
    80005946:	e406                	sd	ra,8(sp)
    80005948:	e022                	sd	s0,0(sp)
    8000594a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000594c:	c40fb0ef          	jal	80000d8c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005950:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005954:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005956:	e78d                	bnez	a5,80005980 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005958:	5d3c                	lw	a5,120(a0)
    8000595a:	02f05963          	blez	a5,8000598c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    8000595e:	37fd                	addiw	a5,a5,-1
    80005960:	0007871b          	sext.w	a4,a5
    80005964:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005966:	eb09                	bnez	a4,80005978 <pop_off+0x34>
    80005968:	5d7c                	lw	a5,124(a0)
    8000596a:	c799                	beqz	a5,80005978 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000596c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005970:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005974:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005978:	60a2                	ld	ra,8(sp)
    8000597a:	6402                	ld	s0,0(sp)
    8000597c:	0141                	addi	sp,sp,16
    8000597e:	8082                	ret
    panic("pop_off - interruptible");
    80005980:	00002517          	auipc	a0,0x2
    80005984:	eb850513          	addi	a0,a0,-328 # 80007838 <etext+0x838>
    80005988:	c4bff0ef          	jal	800055d2 <panic>
    panic("pop_off");
    8000598c:	00002517          	auipc	a0,0x2
    80005990:	ec450513          	addi	a0,a0,-316 # 80007850 <etext+0x850>
    80005994:	c3fff0ef          	jal	800055d2 <panic>

0000000080005998 <release>:
{
    80005998:	1101                	addi	sp,sp,-32
    8000599a:	ec06                	sd	ra,24(sp)
    8000599c:	e822                	sd	s0,16(sp)
    8000599e:	e426                	sd	s1,8(sp)
    800059a0:	1000                	addi	s0,sp,32
    800059a2:	84aa                	mv	s1,a0
  if(!holding(lk))
    800059a4:	ef3ff0ef          	jal	80005896 <holding>
    800059a8:	c105                	beqz	a0,800059c8 <release+0x30>
  lk->cpu = 0;
    800059aa:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800059ae:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    800059b2:	0310000f          	fence	rw,w
    800059b6:	0004a023          	sw	zero,0(s1)
  pop_off();
    800059ba:	f8bff0ef          	jal	80005944 <pop_off>
}
    800059be:	60e2                	ld	ra,24(sp)
    800059c0:	6442                	ld	s0,16(sp)
    800059c2:	64a2                	ld	s1,8(sp)
    800059c4:	6105                	addi	sp,sp,32
    800059c6:	8082                	ret
    panic("release");
    800059c8:	00002517          	auipc	a0,0x2
    800059cc:	e9050513          	addi	a0,a0,-368 # 80007858 <etext+0x858>
    800059d0:	c03ff0ef          	jal	800055d2 <panic>
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
