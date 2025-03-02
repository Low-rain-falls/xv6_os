
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	41013103          	ld	sp,1040(sp) # 8000a410 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	579040ef          	jal	80004d8e <start>

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
    80000034:	96078793          	addi	a5,a5,-1696 # 80023990 <end>
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
    80000050:	41490913          	addi	s2,s2,1044 # 8000a460 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	79a050ef          	jal	800057f0 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	023050ef          	jal	80005888 <release>
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
    8000007e:	444050ef          	jal	800054c2 <panic>

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
    800000de:	38650513          	addi	a0,a0,902 # 8000a460 <kmem>
    800000e2:	68e050ef          	jal	80005770 <initlock>
  freerange(end, (void*)PHYSTOP); //release a range of page from "end" to phystop = put a range to free list pf page
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00024517          	auipc	a0,0x24
    800000ee:	8a650513          	addi	a0,a0,-1882 # 80023990 <end>
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
    8000010c:	35848493          	addi	s1,s1,856 # 8000a460 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	6de050ef          	jal	800057f0 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	34450513          	addi	a0,a0,836 # 8000a460 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	762050ef          	jal	80005888 <release>

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
    80000144:	32050513          	addi	a0,a0,800 # 8000a460 <kmem>
    80000148:	740050ef          	jal	80005888 <release>
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
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb671>
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
    800002f8:	13c70713          	addi	a4,a4,316 # 8000a430 <started>
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
    80000316:	6db040ef          	jal	800051f0 <printf>
    kvminithart();    // turn on paging
    8000031a:	080000ef          	jal	8000039a <kvminithart>
    trapinithart();   // install kernel trap vector
    8000031e:	540010ef          	jal	8000185e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000322:	486040ef          	jal	800047a8 <plicinithart>
  }

  scheduler();        
    80000326:	67d000ef          	jal	800011a2 <scheduler>
    consoleinit();
    8000032a:	5f1040ef          	jal	8000511a <consoleinit>
    printfinit();
    8000032e:	1ce050ef          	jal	800054fc <printfinit>
    printf("\n");
    80000332:	00007517          	auipc	a0,0x7
    80000336:	ce650513          	addi	a0,a0,-794 # 80007018 <etext+0x18>
    8000033a:	6b7040ef          	jal	800051f0 <printf>
    printf("xv6 kernel is booting\n");
    8000033e:	00007517          	auipc	a0,0x7
    80000342:	ce250513          	addi	a0,a0,-798 # 80007020 <etext+0x20>
    80000346:	6ab040ef          	jal	800051f0 <printf>
    printf("\n");
    8000034a:	00007517          	auipc	a0,0x7
    8000034e:	cce50513          	addi	a0,a0,-818 # 80007018 <etext+0x18>
    80000352:	69f040ef          	jal	800051f0 <printf>
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
    8000036e:	420040ef          	jal	8000478e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000372:	436040ef          	jal	800047a8 <plicinithart>
    binit();         // buffer cache
    80000376:	3d9010ef          	jal	80001f4e <binit>
    iinit();         // inode table
    8000037a:	1ca020ef          	jal	80002544 <iinit>
    fileinit();      // file table
    8000037e:	777020ef          	jal	800032f4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000382:	516040ef          	jal	80004898 <virtio_disk_init>
    userinit();      // first user process
    80000386:	449000ef          	jal	80000fce <userinit>
    __sync_synchronize();
    8000038a:	0330000f          	fence	rw,rw
    started = 1;
    8000038e:	4785                	li	a5,1
    80000390:	0000a717          	auipc	a4,0xa
    80000394:	0af72023          	sw	a5,160(a4) # 8000a430 <started>
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
    800003a8:	0947b783          	ld	a5,148(a5) # 8000a438 <kernel_pagetable>
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
    800003f0:	0d2050ef          	jal	800054c2 <panic>
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
    80000416:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb667>
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
    80000506:	7bd040ef          	jal	800054c2 <panic>
    panic("mappages: size not aligned");
    8000050a:	00007517          	auipc	a0,0x7
    8000050e:	b6e50513          	addi	a0,a0,-1170 # 80007078 <etext+0x78>
    80000512:	7b1040ef          	jal	800054c2 <panic>
    panic("mappages: size");
    80000516:	00007517          	auipc	a0,0x7
    8000051a:	b8250513          	addi	a0,a0,-1150 # 80007098 <etext+0x98>
    8000051e:	7a5040ef          	jal	800054c2 <panic>
      panic("mappages: remap");
    80000522:	00007517          	auipc	a0,0x7
    80000526:	b8650513          	addi	a0,a0,-1146 # 800070a8 <etext+0xa8>
    8000052a:	799040ef          	jal	800054c2 <panic>
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
    8000056e:	755040ef          	jal	800054c2 <panic>

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
    80000634:	e0a7b423          	sd	a0,-504(a5) # 8000a438 <kernel_pagetable>
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
    80000688:	63b040ef          	jal	800054c2 <panic>
      panic("uvmunmap: walk");
    8000068c:	00007517          	auipc	a0,0x7
    80000690:	a4c50513          	addi	a0,a0,-1460 # 800070d8 <etext+0xd8>
    80000694:	62f040ef          	jal	800054c2 <panic>
      panic("uvmunmap: not mapped");
    80000698:	00007517          	auipc	a0,0x7
    8000069c:	a5050513          	addi	a0,a0,-1456 # 800070e8 <etext+0xe8>
    800006a0:	623040ef          	jal	800054c2 <panic>
      panic("uvmunmap: not a leaf");
    800006a4:	00007517          	auipc	a0,0x7
    800006a8:	a5c50513          	addi	a0,a0,-1444 # 80007100 <etext+0x100>
    800006ac:	617040ef          	jal	800054c2 <panic>
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
    8000077c:	547040ef          	jal	800054c2 <panic>

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
    800008b0:	413040ef          	jal	800054c2 <panic>
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
    8000096e:	355040ef          	jal	800054c2 <panic>
      panic("uvmcopy: page not present");
    80000972:	00006517          	auipc	a0,0x6
    80000976:	7f650513          	addi	a0,a0,2038 # 80007168 <etext+0x168>
    8000097a:	349040ef          	jal	800054c2 <panic>
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
    800009d4:	2ef040ef          	jal	800054c2 <panic>

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
    80000c06:	cae48493          	addi	s1,s1,-850 # 8000a8b0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c0a:	8b26                	mv	s6,s1
    80000c0c:	ff4df937          	lui	s2,0xff4df
    80000c10:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb02d>
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
    80000c2e:	00010a97          	auipc	s5,0x10
    80000c32:	882a8a93          	addi	s5,s5,-1918 # 800104b0 <tickslock>
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
    80000c80:	043040ef          	jal	800054c2 <panic>

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
    80000ca4:	7e050513          	addi	a0,a0,2016 # 8000a480 <pid_lock>
    80000ca8:	2c9040ef          	jal	80005770 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cac:	00006597          	auipc	a1,0x6
    80000cb0:	4fc58593          	addi	a1,a1,1276 # 800071a8 <etext+0x1a8>
    80000cb4:	00009517          	auipc	a0,0x9
    80000cb8:	7e450513          	addi	a0,a0,2020 # 8000a498 <wait_lock>
    80000cbc:	2b5040ef          	jal	80005770 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cc0:	0000a497          	auipc	s1,0xa
    80000cc4:	bf048493          	addi	s1,s1,-1040 # 8000a8b0 <proc>
      initlock(&p->lock, "proc");
    80000cc8:	00006b17          	auipc	s6,0x6
    80000ccc:	4f0b0b13          	addi	s6,s6,1264 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000cd0:	8aa6                	mv	s5,s1
    80000cd2:	ff4df937          	lui	s2,0xff4df
    80000cd6:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb02d>
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
    80000cf8:	7bca0a13          	addi	s4,s4,1980 # 800104b0 <tickslock>
      initlock(&p->lock, "proc");
    80000cfc:	85da                	mv	a1,s6
    80000cfe:	8526                	mv	a0,s1
    80000d00:	271040ef          	jal	80005770 <initlock>
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
    80000d5a:	75a50513          	addi	a0,a0,1882 # 8000a4b0 <cpus>
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
    80000d70:	241040ef          	jal	800057b0 <push_off>
    80000d74:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d76:	2781                	sext.w	a5,a5
    80000d78:	079e                	slli	a5,a5,0x7
    80000d7a:	00009717          	auipc	a4,0x9
    80000d7e:	70670713          	addi	a4,a4,1798 # 8000a480 <pid_lock>
    80000d82:	97ba                	add	a5,a5,a4
    80000d84:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d86:	2af040ef          	jal	80005834 <pop_off>
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
    80000da2:	2e7040ef          	jal	80005888 <release>

  if (first) {
    80000da6:	00009797          	auipc	a5,0x9
    80000daa:	61a7a783          	lw	a5,1562(a5) # 8000a3c0 <first.1>
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
    80000dbe:	71a010ef          	jal	800024d8 <fsinit>
    first = 0;
    80000dc2:	00009797          	auipc	a5,0x9
    80000dc6:	5e07af23          	sw	zero,1534(a5) # 8000a3c0 <first.1>
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
    80000de0:	6a490913          	addi	s2,s2,1700 # 8000a480 <pid_lock>
    80000de4:	854a                	mv	a0,s2
    80000de6:	20b040ef          	jal	800057f0 <acquire>
  pid = nextpid;
    80000dea:	00009797          	auipc	a5,0x9
    80000dee:	5da78793          	addi	a5,a5,1498 # 8000a3c4 <nextpid>
    80000df2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000df4:	0014871b          	addiw	a4,s1,1
    80000df8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000dfa:	854a                	mv	a0,s2
    80000dfc:	28d040ef          	jal	80005888 <release>
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
    80000f34:	0000a497          	auipc	s1,0xa
    80000f38:	97c48493          	addi	s1,s1,-1668 # 8000a8b0 <proc>
    80000f3c:	0000f917          	auipc	s2,0xf
    80000f40:	57490913          	addi	s2,s2,1396 # 800104b0 <tickslock>
    acquire(&p->lock);
    80000f44:	8526                	mv	a0,s1
    80000f46:	0ab040ef          	jal	800057f0 <acquire>
    if(p->state == UNUSED) {
    80000f4a:	4c9c                	lw	a5,24(s1)
    80000f4c:	cb91                	beqz	a5,80000f60 <allocproc+0x38>
      release(&p->lock);
    80000f4e:	8526                	mv	a0,s1
    80000f50:	139040ef          	jal	80005888 <release>
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
    80000fb6:	0d3040ef          	jal	80005888 <release>
    return 0;
    80000fba:	84ca                	mv	s1,s2
    80000fbc:	b7d5                	j	80000fa0 <allocproc+0x78>
    freeproc(p);
    80000fbe:	8526                	mv	a0,s1
    80000fc0:	f19ff0ef          	jal	80000ed8 <freeproc>
    release(&p->lock);
    80000fc4:	8526                	mv	a0,s1
    80000fc6:	0c3040ef          	jal	80005888 <release>
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
    80000fe2:	46a7b123          	sd	a0,1122(a5) # 8000a440 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80000fe6:	03400613          	li	a2,52
    80000fea:	00009597          	auipc	a1,0x9
    80000fee:	3e658593          	addi	a1,a1,998 # 8000a3d0 <initcode>
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
    80001020:	5c7010ef          	jal	80002de6 <namei>
    80001024:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001028:	478d                	li	a5,3
    8000102a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000102c:	8526                	mv	a0,s1
    8000102e:	05b040ef          	jal	80005888 <release>
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
    8000111c:	76c040ef          	jal	80005888 <release>
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
    80001132:	244020ef          	jal	80003376 <filedup>
    80001136:	00a93023          	sd	a0,0(s2)
    8000113a:	b7f5                	j	80001126 <fork+0x9a>
  np->cwd = idup(p->cwd);
    8000113c:	150ab503          	ld	a0,336(s5)
    80001140:	596010ef          	jal	800026d6 <idup>
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
    8000115c:	72c040ef          	jal	80005888 <release>
  acquire(&wait_lock);
    80001160:	00009497          	auipc	s1,0x9
    80001164:	33848493          	addi	s1,s1,824 # 8000a498 <wait_lock>
    80001168:	8526                	mv	a0,s1
    8000116a:	686040ef          	jal	800057f0 <acquire>
  np->parent = p;
    8000116e:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001172:	8526                	mv	a0,s1
    80001174:	714040ef          	jal	80005888 <release>
  acquire(&np->lock);
    80001178:	854e                	mv	a0,s3
    8000117a:	676040ef          	jal	800057f0 <acquire>
  np->state = RUNNABLE;
    8000117e:	478d                	li	a5,3
    80001180:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001184:	854e                	mv	a0,s3
    80001186:	702040ef          	jal	80005888 <release>
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
    800011c6:	2be70713          	addi	a4,a4,702 # 8000a480 <pid_lock>
    800011ca:	975a                	add	a4,a4,s6
    800011cc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800011d0:	00009717          	auipc	a4,0x9
    800011d4:	2e870713          	addi	a4,a4,744 # 8000a4b8 <cpus+0x8>
    800011d8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800011da:	4c11                	li	s8,4
        c->proc = p;
    800011dc:	079e                	slli	a5,a5,0x7
    800011de:	00009a17          	auipc	s4,0x9
    800011e2:	2a2a0a13          	addi	s4,s4,674 # 8000a480 <pid_lock>
    800011e6:	9a3e                	add	s4,s4,a5
        found = 1;
    800011e8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800011ea:	0000f997          	auipc	s3,0xf
    800011ee:	2c698993          	addi	s3,s3,710 # 800104b0 <tickslock>
    800011f2:	a0a9                	j	8000123c <scheduler+0x9a>
      release(&p->lock);
    800011f4:	8526                	mv	a0,s1
    800011f6:	692040ef          	jal	80005888 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800011fa:	17048493          	addi	s1,s1,368
    800011fe:	03348563          	beq	s1,s3,80001228 <scheduler+0x86>
      acquire(&p->lock);
    80001202:	8526                	mv	a0,s1
    80001204:	5ec040ef          	jal	800057f0 <acquire>
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
    8000124e:	66648493          	addi	s1,s1,1638 # 8000a8b0 <proc>
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
    8000126a:	51c040ef          	jal	80005786 <holding>
    8000126e:	c92d                	beqz	a0,800012e0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001270:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001272:	2781                	sext.w	a5,a5
    80001274:	079e                	slli	a5,a5,0x7
    80001276:	00009717          	auipc	a4,0x9
    8000127a:	20a70713          	addi	a4,a4,522 # 8000a480 <pid_lock>
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
    800012a0:	1e490913          	addi	s2,s2,484 # 8000a480 <pid_lock>
    800012a4:	2781                	sext.w	a5,a5
    800012a6:	079e                	slli	a5,a5,0x7
    800012a8:	97ca                	add	a5,a5,s2
    800012aa:	0ac7a983          	lw	s3,172(a5)
    800012ae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012b0:	2781                	sext.w	a5,a5
    800012b2:	079e                	slli	a5,a5,0x7
    800012b4:	00009597          	auipc	a1,0x9
    800012b8:	20458593          	addi	a1,a1,516 # 8000a4b8 <cpus+0x8>
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
    800012e8:	1da040ef          	jal	800054c2 <panic>
    panic("sched locks");
    800012ec:	00006517          	auipc	a0,0x6
    800012f0:	efc50513          	addi	a0,a0,-260 # 800071e8 <etext+0x1e8>
    800012f4:	1ce040ef          	jal	800054c2 <panic>
    panic("sched running");
    800012f8:	00006517          	auipc	a0,0x6
    800012fc:	f0050513          	addi	a0,a0,-256 # 800071f8 <etext+0x1f8>
    80001300:	1c2040ef          	jal	800054c2 <panic>
    panic("sched interruptible");
    80001304:	00006517          	auipc	a0,0x6
    80001308:	f0450513          	addi	a0,a0,-252 # 80007208 <etext+0x208>
    8000130c:	1b6040ef          	jal	800054c2 <panic>

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
    80001320:	4d0040ef          	jal	800057f0 <acquire>
  p->state = RUNNABLE;
    80001324:	478d                	li	a5,3
    80001326:	cc9c                	sw	a5,24(s1)
  sched();
    80001328:	f2fff0ef          	jal	80001256 <sched>
  release(&p->lock);
    8000132c:	8526                	mv	a0,s1
    8000132e:	55a040ef          	jal	80005888 <release>
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
    80001354:	49c040ef          	jal	800057f0 <acquire>
  release(lk);
    80001358:	854a                	mv	a0,s2
    8000135a:	52e040ef          	jal	80005888 <release>

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
    80001370:	518040ef          	jal	80005888 <release>
  acquire(lk);
    80001374:	854a                	mv	a0,s2
    80001376:	47a040ef          	jal	800057f0 <acquire>
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
    800013a0:	51448493          	addi	s1,s1,1300 # 8000a8b0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800013a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800013a6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013a8:	0000f917          	auipc	s2,0xf
    800013ac:	10890913          	addi	s2,s2,264 # 800104b0 <tickslock>
    800013b0:	a801                	j	800013c0 <wakeup+0x38>
      }
      release(&p->lock);
    800013b2:	8526                	mv	a0,s1
    800013b4:	4d4040ef          	jal	80005888 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013b8:	17048493          	addi	s1,s1,368
    800013bc:	03248263          	beq	s1,s2,800013e0 <wakeup+0x58>
    if(p != myproc()){
    800013c0:	9a7ff0ef          	jal	80000d66 <myproc>
    800013c4:	fea48ae3          	beq	s1,a0,800013b8 <wakeup+0x30>
      acquire(&p->lock);
    800013c8:	8526                	mv	a0,s1
    800013ca:	426040ef          	jal	800057f0 <acquire>
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
    80001408:	4ac48493          	addi	s1,s1,1196 # 8000a8b0 <proc>
      pp->parent = initproc;
    8000140c:	00009a17          	auipc	s4,0x9
    80001410:	034a0a13          	addi	s4,s4,52 # 8000a440 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001414:	0000f997          	auipc	s3,0xf
    80001418:	09c98993          	addi	s3,s3,156 # 800104b0 <tickslock>
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
    80001464:	fe07b783          	ld	a5,-32(a5) # 8000a440 <initproc>
    80001468:	0d050493          	addi	s1,a0,208
    8000146c:	15050913          	addi	s2,a0,336
    80001470:	00a79f63          	bne	a5,a0,8000148e <exit+0x46>
    panic("init exiting");
    80001474:	00006517          	auipc	a0,0x6
    80001478:	dac50513          	addi	a0,a0,-596 # 80007220 <etext+0x220>
    8000147c:	046040ef          	jal	800054c2 <panic>
      fileclose(f);
    80001480:	73d010ef          	jal	800033bc <fileclose>
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
    80001494:	30f010ef          	jal	80002fa2 <begin_op>
  iput(p->cwd);
    80001498:	1509b503          	ld	a0,336(s3)
    8000149c:	3f2010ef          	jal	8000288e <iput>
  end_op();
    800014a0:	36d010ef          	jal	8000300c <end_op>
  p->cwd = 0;
    800014a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014a8:	00009497          	auipc	s1,0x9
    800014ac:	ff048493          	addi	s1,s1,-16 # 8000a498 <wait_lock>
    800014b0:	8526                	mv	a0,s1
    800014b2:	33e040ef          	jal	800057f0 <acquire>
  reparent(p);
    800014b6:	854e                	mv	a0,s3
    800014b8:	f3bff0ef          	jal	800013f2 <reparent>
  wakeup(p->parent);
    800014bc:	0389b503          	ld	a0,56(s3)
    800014c0:	ec9ff0ef          	jal	80001388 <wakeup>
  acquire(&p->lock);
    800014c4:	854e                	mv	a0,s3
    800014c6:	32a040ef          	jal	800057f0 <acquire>
  p->xstate = status;
    800014ca:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800014ce:	4795                	li	a5,5
    800014d0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800014d4:	8526                	mv	a0,s1
    800014d6:	3b2040ef          	jal	80005888 <release>
  sched();
    800014da:	d7dff0ef          	jal	80001256 <sched>
  panic("zombie exit");
    800014de:	00006517          	auipc	a0,0x6
    800014e2:	d5250513          	addi	a0,a0,-686 # 80007230 <etext+0x230>
    800014e6:	7dd030ef          	jal	800054c2 <panic>

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
    800014fe:	3b648493          	addi	s1,s1,950 # 8000a8b0 <proc>
    80001502:	0000f997          	auipc	s3,0xf
    80001506:	fae98993          	addi	s3,s3,-82 # 800104b0 <tickslock>
    acquire(&p->lock);
    8000150a:	8526                	mv	a0,s1
    8000150c:	2e4040ef          	jal	800057f0 <acquire>
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
    80001518:	370040ef          	jal	80005888 <release>
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
    80001536:	352040ef          	jal	80005888 <release>
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
    8000155c:	294040ef          	jal	800057f0 <acquire>
  p->killed = 1;
    80001560:	4785                	li	a5,1
    80001562:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001564:	8526                	mv	a0,s1
    80001566:	322040ef          	jal	80005888 <release>
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
    80001582:	26e040ef          	jal	800057f0 <acquire>
  k = p->killed;
    80001586:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000158a:	8526                	mv	a0,s1
    8000158c:	2fc040ef          	jal	80005888 <release>
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
    800015c2:	eda50513          	addi	a0,a0,-294 # 8000a498 <wait_lock>
    800015c6:	22a040ef          	jal	800057f0 <acquire>
    havekids = 0;
    800015ca:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800015cc:	4a15                	li	s4,5
        havekids = 1;
    800015ce:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800015d0:	0000f997          	auipc	s3,0xf
    800015d4:	ee098993          	addi	s3,s3,-288 # 800104b0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800015d8:	00009c17          	auipc	s8,0x9
    800015dc:	ec0c0c13          	addi	s8,s8,-320 # 8000a498 <wait_lock>
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
    80001606:	282040ef          	jal	80005888 <release>
          release(&wait_lock);
    8000160a:	00009517          	auipc	a0,0x9
    8000160e:	e8e50513          	addi	a0,a0,-370 # 8000a498 <wait_lock>
    80001612:	276040ef          	jal	80005888 <release>
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
    80001632:	256040ef          	jal	80005888 <release>
            release(&wait_lock);
    80001636:	00009517          	auipc	a0,0x9
    8000163a:	e6250513          	addi	a0,a0,-414 # 8000a498 <wait_lock>
    8000163e:	24a040ef          	jal	80005888 <release>
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
    80001656:	19a040ef          	jal	800057f0 <acquire>
        if(pp->state == ZOMBIE){
    8000165a:	4c9c                	lw	a5,24(s1)
    8000165c:	f94783e3          	beq	a5,s4,800015e2 <wait+0x44>
        release(&pp->lock);
    80001660:	8526                	mv	a0,s1
    80001662:	226040ef          	jal	80005888 <release>
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
    80001682:	23248493          	addi	s1,s1,562 # 8000a8b0 <proc>
    80001686:	b7e1                	j	8000164e <wait+0xb0>
      release(&wait_lock);
    80001688:	00009517          	auipc	a0,0x9
    8000168c:	e1050513          	addi	a0,a0,-496 # 8000a498 <wait_lock>
    80001690:	1f8040ef          	jal	80005888 <release>
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
    8000174a:	2a7030ef          	jal	800051f0 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000174e:	00009497          	auipc	s1,0x9
    80001752:	2ba48493          	addi	s1,s1,698 # 8000aa08 <proc+0x158>
    80001756:	0000f917          	auipc	s2,0xf
    8000175a:	eb290913          	addi	s2,s2,-334 # 80010608 <bcache+0x140>
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
    8000177c:	0e0b8b93          	addi	s7,s7,224 # 80007858 <states.0>
    80001780:	a829                	j	8000179a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001782:	ed86a583          	lw	a1,-296(a3)
    80001786:	8556                	mv	a0,s5
    80001788:	269030ef          	jal	800051f0 <printf>
    printf("\n");
    8000178c:	8552                	mv	a0,s4
    8000178e:	263030ef          	jal	800051f0 <printf>
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
    8000184e:	c6650513          	addi	a0,a0,-922 # 800104b0 <tickslock>
    80001852:	71f030ef          	jal	80005770 <initlock>
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
    80001868:	ecc78793          	addi	a5,a5,-308 # 80004730 <kernelvec>
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
    80001936:	b7e48493          	addi	s1,s1,-1154 # 800104b0 <tickslock>
    8000193a:	8526                	mv	a0,s1
    8000193c:	6b5030ef          	jal	800057f0 <acquire>
    ticks++;
    80001940:	00009517          	auipc	a0,0x9
    80001944:	b0850513          	addi	a0,a0,-1272 # 8000a448 <ticks>
    80001948:	411c                	lw	a5,0(a0)
    8000194a:	2785                	addiw	a5,a5,1
    8000194c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000194e:	a3bff0ef          	jal	80001388 <wakeup>
    release(&tickslock);
    80001952:	8526                	mv	a0,s1
    80001954:	735030ef          	jal	80005888 <release>
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
    80001988:	655020ef          	jal	800047dc <plic_claim>
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
    800019a2:	593030ef          	jal	80005734 <uartintr>
    if(irq)
    800019a6:	a819                	j	800019bc <devintr+0x60>
      virtio_disk_intr();
    800019a8:	2fa030ef          	jal	80004ca2 <virtio_disk_intr>
    if(irq)
    800019ac:	a801                	j	800019bc <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800019ae:	85a6                	mv	a1,s1
    800019b0:	00006517          	auipc	a0,0x6
    800019b4:	8e050513          	addi	a0,a0,-1824 # 80007290 <etext+0x290>
    800019b8:	039030ef          	jal	800051f0 <printf>
      plic_complete(irq);
    800019bc:	8526                	mv	a0,s1
    800019be:	63f020ef          	jal	800047fc <plic_complete>
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
    800019ea:	d4a78793          	addi	a5,a5,-694 # 80004730 <kernelvec>
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
    80001a24:	29f030ef          	jal	800054c2 <panic>
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
    80001a82:	76e030ef          	jal	800051f0 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001a8a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001a8e:	00006517          	auipc	a0,0x6
    80001a92:	87250513          	addi	a0,a0,-1934 # 80007300 <etext+0x300>
    80001a96:	75a030ef          	jal	800051f0 <printf>
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
    80001afa:	1c9030ef          	jal	800054c2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001afe:	00006517          	auipc	a0,0x6
    80001b02:	85250513          	addi	a0,a0,-1966 # 80007350 <etext+0x350>
    80001b06:	1bd030ef          	jal	800054c2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b0a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b0e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001b12:	85ce                	mv	a1,s3
    80001b14:	00006517          	auipc	a0,0x6
    80001b18:	85c50513          	addi	a0,a0,-1956 # 80007370 <etext+0x370>
    80001b1c:	6d4030ef          	jal	800051f0 <printf>
    panic("kerneltrap");
    80001b20:	00006517          	auipc	a0,0x6
    80001b24:	87850513          	addi	a0,a0,-1928 # 80007398 <etext+0x398>
    80001b28:	19b030ef          	jal	800054c2 <panic>
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
    80001b54:	d3870713          	addi	a4,a4,-712 # 80007888 <states.0+0x30>
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
    80001b94:	12f030ef          	jal	800054c2 <panic>

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
  [SYS_trace]   "trace",
};

void
syscall(void)
{
    80001c8a:	7179                	addi	sp,sp,-48
    80001c8c:	f406                	sd	ra,40(sp)
    80001c8e:	f022                	sd	s0,32(sp)
    80001c90:	ec26                	sd	s1,24(sp)
    80001c92:	e84a                	sd	s2,16(sp)
    80001c94:	e44e                	sd	s3,8(sp)
    80001c96:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80001c98:	8ceff0ef          	jal	80000d66 <myproc>
    80001c9c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001c9e:	05853903          	ld	s2,88(a0)
    80001ca2:	0a893783          	ld	a5,168(s2)
    80001ca6:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001caa:	37fd                	addiw	a5,a5,-1
    80001cac:	475d                	li	a4,23
    80001cae:	04f76563          	bltu	a4,a5,80001cf8 <syscall+0x6e>
    80001cb2:	00399713          	slli	a4,s3,0x3
    80001cb6:	00006797          	auipc	a5,0x6
    80001cba:	bea78793          	addi	a5,a5,-1046 # 800078a0 <syscalls>
    80001cbe:	97ba                	add	a5,a5,a4
    80001cc0:	639c                	ld	a5,0(a5)
    80001cc2:	cb9d                	beqz	a5,80001cf8 <syscall+0x6e>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001cc4:	9782                	jalr	a5
    80001cc6:	06a93823          	sd	a0,112(s2)

    if (p->trace_mask & (1 << num)) {
    80001cca:	1684a783          	lw	a5,360(s1)
    80001cce:	4137d7bb          	sraw	a5,a5,s3
    80001cd2:	8b85                	andi	a5,a5,1
    80001cd4:	cf9d                	beqz	a5,80001d12 <syscall+0x88>
      printf("%d: syscall %s -> %ld\n", p->pid, syscall_names[num], p->trapframe->a0);
    80001cd6:	6cb8                	ld	a4,88(s1)
    80001cd8:	098e                	slli	s3,s3,0x3
    80001cda:	00006797          	auipc	a5,0x6
    80001cde:	bc678793          	addi	a5,a5,-1082 # 800078a0 <syscalls>
    80001ce2:	97ce                	add	a5,a5,s3
    80001ce4:	7b34                	ld	a3,112(a4)
    80001ce6:	67f0                	ld	a2,200(a5)
    80001ce8:	588c                	lw	a1,48(s1)
    80001cea:	00005517          	auipc	a0,0x5
    80001cee:	6c650513          	addi	a0,a0,1734 # 800073b0 <etext+0x3b0>
    80001cf2:	4fe030ef          	jal	800051f0 <printf>
    80001cf6:	a831                	j	80001d12 <syscall+0x88>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001cf8:	86ce                	mv	a3,s3
    80001cfa:	15848613          	addi	a2,s1,344
    80001cfe:	588c                	lw	a1,48(s1)
    80001d00:	00005517          	auipc	a0,0x5
    80001d04:	6c850513          	addi	a0,a0,1736 # 800073c8 <etext+0x3c8>
    80001d08:	4e8030ef          	jal	800051f0 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001d0c:	6cbc                	ld	a5,88(s1)
    80001d0e:	577d                	li	a4,-1
    80001d10:	fbb8                	sd	a4,112(a5)
  }
}
    80001d12:	70a2                	ld	ra,40(sp)
    80001d14:	7402                	ld	s0,32(sp)
    80001d16:	64e2                	ld	s1,24(sp)
    80001d18:	6942                	ld	s2,16(sp)
    80001d1a:	69a2                	ld	s3,8(sp)
    80001d1c:	6145                	addi	sp,sp,48
    80001d1e:	8082                	ret

0000000080001d20 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001d28:	fec40593          	addi	a1,s0,-20
    80001d2c:	4501                	li	a0,0
    80001d2e:	ef5ff0ef          	jal	80001c22 <argint>
  exit(n);
    80001d32:	fec42503          	lw	a0,-20(s0)
    80001d36:	f12ff0ef          	jal	80001448 <exit>
  return 0;  // not reached
}
    80001d3a:	4501                	li	a0,0
    80001d3c:	60e2                	ld	ra,24(sp)
    80001d3e:	6442                	ld	s0,16(sp)
    80001d40:	6105                	addi	sp,sp,32
    80001d42:	8082                	ret

0000000080001d44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001d44:	1141                	addi	sp,sp,-16
    80001d46:	e406                	sd	ra,8(sp)
    80001d48:	e022                	sd	s0,0(sp)
    80001d4a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001d4c:	81aff0ef          	jal	80000d66 <myproc>
}
    80001d50:	5908                	lw	a0,48(a0)
    80001d52:	60a2                	ld	ra,8(sp)
    80001d54:	6402                	ld	s0,0(sp)
    80001d56:	0141                	addi	sp,sp,16
    80001d58:	8082                	ret

0000000080001d5a <sys_fork>:

uint64
sys_fork(void)
{
    80001d5a:	1141                	addi	sp,sp,-16
    80001d5c:	e406                	sd	ra,8(sp)
    80001d5e:	e022                	sd	s0,0(sp)
    80001d60:	0800                	addi	s0,sp,16
  return fork();
    80001d62:	b2aff0ef          	jal	8000108c <fork>
}
    80001d66:	60a2                	ld	ra,8(sp)
    80001d68:	6402                	ld	s0,0(sp)
    80001d6a:	0141                	addi	sp,sp,16
    80001d6c:	8082                	ret

0000000080001d6e <sys_wait>:

uint64
sys_wait(void)
{
    80001d6e:	1101                	addi	sp,sp,-32
    80001d70:	ec06                	sd	ra,24(sp)
    80001d72:	e822                	sd	s0,16(sp)
    80001d74:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001d76:	fe840593          	addi	a1,s0,-24
    80001d7a:	4501                	li	a0,0
    80001d7c:	ec3ff0ef          	jal	80001c3e <argaddr>
  return wait(p);
    80001d80:	fe843503          	ld	a0,-24(s0)
    80001d84:	81bff0ef          	jal	8000159e <wait>
}
    80001d88:	60e2                	ld	ra,24(sp)
    80001d8a:	6442                	ld	s0,16(sp)
    80001d8c:	6105                	addi	sp,sp,32
    80001d8e:	8082                	ret

0000000080001d90 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001d90:	7179                	addi	sp,sp,-48
    80001d92:	f406                	sd	ra,40(sp)
    80001d94:	f022                	sd	s0,32(sp)
    80001d96:	ec26                	sd	s1,24(sp)
    80001d98:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001d9a:	fdc40593          	addi	a1,s0,-36
    80001d9e:	4501                	li	a0,0
    80001da0:	e83ff0ef          	jal	80001c22 <argint>
  addr = myproc()->sz;
    80001da4:	fc3fe0ef          	jal	80000d66 <myproc>
    80001da8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001daa:	fdc42503          	lw	a0,-36(s0)
    80001dae:	a8eff0ef          	jal	8000103c <growproc>
    80001db2:	00054863          	bltz	a0,80001dc2 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001db6:	8526                	mv	a0,s1
    80001db8:	70a2                	ld	ra,40(sp)
    80001dba:	7402                	ld	s0,32(sp)
    80001dbc:	64e2                	ld	s1,24(sp)
    80001dbe:	6145                	addi	sp,sp,48
    80001dc0:	8082                	ret
    return -1;
    80001dc2:	54fd                	li	s1,-1
    80001dc4:	bfcd                	j	80001db6 <sys_sbrk+0x26>

0000000080001dc6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001dc6:	7139                	addi	sp,sp,-64
    80001dc8:	fc06                	sd	ra,56(sp)
    80001dca:	f822                	sd	s0,48(sp)
    80001dcc:	f04a                	sd	s2,32(sp)
    80001dce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001dd0:	fcc40593          	addi	a1,s0,-52
    80001dd4:	4501                	li	a0,0
    80001dd6:	e4dff0ef          	jal	80001c22 <argint>
  if(n < 0)
    80001dda:	fcc42783          	lw	a5,-52(s0)
    80001dde:	0607c763          	bltz	a5,80001e4c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001de2:	0000e517          	auipc	a0,0xe
    80001de6:	6ce50513          	addi	a0,a0,1742 # 800104b0 <tickslock>
    80001dea:	207030ef          	jal	800057f0 <acquire>
  ticks0 = ticks;
    80001dee:	00008917          	auipc	s2,0x8
    80001df2:	65a92903          	lw	s2,1626(s2) # 8000a448 <ticks>
  while(ticks - ticks0 < n){
    80001df6:	fcc42783          	lw	a5,-52(s0)
    80001dfa:	cf8d                	beqz	a5,80001e34 <sys_sleep+0x6e>
    80001dfc:	f426                	sd	s1,40(sp)
    80001dfe:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001e00:	0000e997          	auipc	s3,0xe
    80001e04:	6b098993          	addi	s3,s3,1712 # 800104b0 <tickslock>
    80001e08:	00008497          	auipc	s1,0x8
    80001e0c:	64048493          	addi	s1,s1,1600 # 8000a448 <ticks>
    if(killed(myproc())){
    80001e10:	f57fe0ef          	jal	80000d66 <myproc>
    80001e14:	f60ff0ef          	jal	80001574 <killed>
    80001e18:	ed0d                	bnez	a0,80001e52 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001e1a:	85ce                	mv	a1,s3
    80001e1c:	8526                	mv	a0,s1
    80001e1e:	d1eff0ef          	jal	8000133c <sleep>
  while(ticks - ticks0 < n){
    80001e22:	409c                	lw	a5,0(s1)
    80001e24:	412787bb          	subw	a5,a5,s2
    80001e28:	fcc42703          	lw	a4,-52(s0)
    80001e2c:	fee7e2e3          	bltu	a5,a4,80001e10 <sys_sleep+0x4a>
    80001e30:	74a2                	ld	s1,40(sp)
    80001e32:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001e34:	0000e517          	auipc	a0,0xe
    80001e38:	67c50513          	addi	a0,a0,1660 # 800104b0 <tickslock>
    80001e3c:	24d030ef          	jal	80005888 <release>
  return 0;
    80001e40:	4501                	li	a0,0
}
    80001e42:	70e2                	ld	ra,56(sp)
    80001e44:	7442                	ld	s0,48(sp)
    80001e46:	7902                	ld	s2,32(sp)
    80001e48:	6121                	addi	sp,sp,64
    80001e4a:	8082                	ret
    n = 0;
    80001e4c:	fc042623          	sw	zero,-52(s0)
    80001e50:	bf49                	j	80001de2 <sys_sleep+0x1c>
      release(&tickslock);
    80001e52:	0000e517          	auipc	a0,0xe
    80001e56:	65e50513          	addi	a0,a0,1630 # 800104b0 <tickslock>
    80001e5a:	22f030ef          	jal	80005888 <release>
      return -1;
    80001e5e:	557d                	li	a0,-1
    80001e60:	74a2                	ld	s1,40(sp)
    80001e62:	69e2                	ld	s3,24(sp)
    80001e64:	bff9                	j	80001e42 <sys_sleep+0x7c>

0000000080001e66 <sys_kill>:

uint64
sys_kill(void)
{
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001e6e:	fec40593          	addi	a1,s0,-20
    80001e72:	4501                	li	a0,0
    80001e74:	dafff0ef          	jal	80001c22 <argint>
  return kill(pid);
    80001e78:	fec42503          	lw	a0,-20(s0)
    80001e7c:	e6eff0ef          	jal	800014ea <kill>
}
    80001e80:	60e2                	ld	ra,24(sp)
    80001e82:	6442                	ld	s0,16(sp)
    80001e84:	6105                	addi	sp,sp,32
    80001e86:	8082                	ret

0000000080001e88 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001e88:	1101                	addi	sp,sp,-32
    80001e8a:	ec06                	sd	ra,24(sp)
    80001e8c:	e822                	sd	s0,16(sp)
    80001e8e:	e426                	sd	s1,8(sp)
    80001e90:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001e92:	0000e517          	auipc	a0,0xe
    80001e96:	61e50513          	addi	a0,a0,1566 # 800104b0 <tickslock>
    80001e9a:	157030ef          	jal	800057f0 <acquire>
  xticks = ticks;
    80001e9e:	00008497          	auipc	s1,0x8
    80001ea2:	5aa4a483          	lw	s1,1450(s1) # 8000a448 <ticks>
  release(&tickslock);
    80001ea6:	0000e517          	auipc	a0,0xe
    80001eaa:	60a50513          	addi	a0,a0,1546 # 800104b0 <tickslock>
    80001eae:	1db030ef          	jal	80005888 <release>
  return xticks;
}
    80001eb2:	02049513          	slli	a0,s1,0x20
    80001eb6:	9101                	srli	a0,a0,0x20
    80001eb8:	60e2                	ld	ra,24(sp)
    80001eba:	6442                	ld	s0,16(sp)
    80001ebc:	64a2                	ld	s1,8(sp)
    80001ebe:	6105                	addi	sp,sp,32
    80001ec0:	8082                	ret

0000000080001ec2 <sys_hello>:

uint64 sys_hello(void) {
    80001ec2:	1141                	addi	sp,sp,-16
    80001ec4:	e406                	sd	ra,8(sp)
    80001ec6:	e022                	sd	s0,0(sp)
    80001ec8:	0800                	addi	s0,sp,16
  printf("Hello, world!\n");
    80001eca:	00005517          	auipc	a0,0x5
    80001ece:	5d650513          	addi	a0,a0,1494 # 800074a0 <etext+0x4a0>
    80001ed2:	31e030ef          	jal	800051f0 <printf>
  return 0;
}
    80001ed6:	4501                	li	a0,0
    80001ed8:	60a2                	ld	ra,8(sp)
    80001eda:	6402                	ld	s0,0(sp)
    80001edc:	0141                	addi	sp,sp,16
    80001ede:	8082                	ret

0000000080001ee0 <sys_xv6>:

uint64 sys_xv6(void) {
    80001ee0:	7179                	addi	sp,sp,-48
    80001ee2:	f406                	sd	ra,40(sp)
    80001ee4:	f022                	sd	s0,32(sp)
    80001ee6:	1800                	addi	s0,sp,48
  int n;

  argint(0, &n);
    80001ee8:	fdc40593          	addi	a1,s0,-36
    80001eec:	4501                	li	a0,0
    80001eee:	d35ff0ef          	jal	80001c22 <argint>

  for (int i = 0; i < n; i++){
    80001ef2:	fdc42783          	lw	a5,-36(s0)
    80001ef6:	02f05363          	blez	a5,80001f1c <sys_xv6+0x3c>
    80001efa:	ec26                	sd	s1,24(sp)
    80001efc:	e84a                	sd	s2,16(sp)
    80001efe:	4481                	li	s1,0
    printf("Hello_xv6\n");
    80001f00:	00005917          	auipc	s2,0x5
    80001f04:	5b090913          	addi	s2,s2,1456 # 800074b0 <etext+0x4b0>
    80001f08:	854a                	mv	a0,s2
    80001f0a:	2e6030ef          	jal	800051f0 <printf>
  for (int i = 0; i < n; i++){
    80001f0e:	2485                	addiw	s1,s1,1
    80001f10:	fdc42783          	lw	a5,-36(s0)
    80001f14:	fef4cae3          	blt	s1,a5,80001f08 <sys_xv6+0x28>
    80001f18:	64e2                	ld	s1,24(sp)
    80001f1a:	6942                	ld	s2,16(sp)
  }
  return 0;
}
    80001f1c:	4501                	li	a0,0
    80001f1e:	70a2                	ld	ra,40(sp)
    80001f20:	7402                	ld	s0,32(sp)
    80001f22:	6145                	addi	sp,sp,48
    80001f24:	8082                	ret

0000000080001f26 <sys_trace>:


uint64 sys_trace(void) {
    80001f26:	1101                	addi	sp,sp,-32
    80001f28:	ec06                	sd	ra,24(sp)
    80001f2a:	e822                	sd	s0,16(sp)
    80001f2c:	1000                	addi	s0,sp,32
  int mask;

  argint(0, &mask);
    80001f2e:	fec40593          	addi	a1,s0,-20
    80001f32:	4501                	li	a0,0
    80001f34:	cefff0ef          	jal	80001c22 <argint>
  struct proc *p = myproc();
    80001f38:	e2ffe0ef          	jal	80000d66 <myproc>
  p->trace_mask = mask;
    80001f3c:	fec42783          	lw	a5,-20(s0)
    80001f40:	16f52423          	sw	a5,360(a0)
  return 0;
    80001f44:	4501                	li	a0,0
    80001f46:	60e2                	ld	ra,24(sp)
    80001f48:	6442                	ld	s0,16(sp)
    80001f4a:	6105                	addi	sp,sp,32
    80001f4c:	8082                	ret

0000000080001f4e <binit>:
} bcache;

//initialize cache 
void
binit(void)
{
    80001f4e:	7179                	addi	sp,sp,-48
    80001f50:	f406                	sd	ra,40(sp)
    80001f52:	f022                	sd	s0,32(sp)
    80001f54:	ec26                	sd	s1,24(sp)
    80001f56:	e84a                	sd	s2,16(sp)
    80001f58:	e44e                	sd	s3,8(sp)
    80001f5a:	e052                	sd	s4,0(sp)
    80001f5c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache"); //initialize lock named "bcache"
    80001f5e:	00005597          	auipc	a1,0x5
    80001f62:	56258593          	addi	a1,a1,1378 # 800074c0 <etext+0x4c0>
    80001f66:	0000e517          	auipc	a0,0xe
    80001f6a:	56250513          	addi	a0,a0,1378 # 800104c8 <bcache>
    80001f6e:	003030ef          	jal	80005770 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001f72:	00016797          	auipc	a5,0x16
    80001f76:	55678793          	addi	a5,a5,1366 # 800184c8 <bcache+0x8000>
    80001f7a:	00016717          	auipc	a4,0x16
    80001f7e:	7b670713          	addi	a4,a4,1974 # 80018730 <bcache+0x8268>
    80001f82:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001f86:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f8a:	0000e497          	auipc	s1,0xe
    80001f8e:	55648493          	addi	s1,s1,1366 # 800104e0 <bcache+0x18>
    b->next = bcache.head.next;
    80001f92:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001f94:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001f96:	00005a17          	auipc	s4,0x5
    80001f9a:	532a0a13          	addi	s4,s4,1330 # 800074c8 <etext+0x4c8>
    b->next = bcache.head.next;
    80001f9e:	2b893783          	ld	a5,696(s2)
    80001fa2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001fa4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer"); // init sleeplock to synchronize access individually
    80001fa8:	85d2                	mv	a1,s4
    80001faa:	01048513          	addi	a0,s1,16
    80001fae:	248010ef          	jal	800031f6 <initsleeplock>
    bcache.head.next->prev = b;
    80001fb2:	2b893783          	ld	a5,696(s2)
    80001fb6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001fb8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001fbc:	45848493          	addi	s1,s1,1112
    80001fc0:	fd349fe3          	bne	s1,s3,80001f9e <binit+0x50>
  }
}
    80001fc4:	70a2                	ld	ra,40(sp)
    80001fc6:	7402                	ld	s0,32(sp)
    80001fc8:	64e2                	ld	s1,24(sp)
    80001fca:	6942                	ld	s2,16(sp)
    80001fcc:	69a2                	ld	s3,8(sp)
    80001fce:	6a02                	ld	s4,0(sp)
    80001fd0:	6145                	addi	sp,sp,48
    80001fd2:	8082                	ret

0000000080001fd4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001fd4:	7179                	addi	sp,sp,-48
    80001fd6:	f406                	sd	ra,40(sp)
    80001fd8:	f022                	sd	s0,32(sp)
    80001fda:	ec26                	sd	s1,24(sp)
    80001fdc:	e84a                	sd	s2,16(sp)
    80001fde:	e44e                	sd	s3,8(sp)
    80001fe0:	1800                	addi	s0,sp,48
    80001fe2:	892a                	mv	s2,a0
    80001fe4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80001fe6:	0000e517          	auipc	a0,0xe
    80001fea:	4e250513          	addi	a0,a0,1250 # 800104c8 <bcache>
    80001fee:	003030ef          	jal	800057f0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80001ff2:	00016497          	auipc	s1,0x16
    80001ff6:	78e4b483          	ld	s1,1934(s1) # 80018780 <bcache+0x82b8>
    80001ffa:	00016797          	auipc	a5,0x16
    80001ffe:	73678793          	addi	a5,a5,1846 # 80018730 <bcache+0x8268>
    80002002:	02f48b63          	beq	s1,a5,80002038 <bread+0x64>
    80002006:	873e                	mv	a4,a5
    80002008:	a021                	j	80002010 <bread+0x3c>
    8000200a:	68a4                	ld	s1,80(s1)
    8000200c:	02e48663          	beq	s1,a4,80002038 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002010:	449c                	lw	a5,8(s1)
    80002012:	ff279ce3          	bne	a5,s2,8000200a <bread+0x36>
    80002016:	44dc                	lw	a5,12(s1)
    80002018:	ff3799e3          	bne	a5,s3,8000200a <bread+0x36>
      b->refcnt++;
    8000201c:	40bc                	lw	a5,64(s1)
    8000201e:	2785                	addiw	a5,a5,1
    80002020:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002022:	0000e517          	auipc	a0,0xe
    80002026:	4a650513          	addi	a0,a0,1190 # 800104c8 <bcache>
    8000202a:	05f030ef          	jal	80005888 <release>
      acquiresleep(&b->lock);
    8000202e:	01048513          	addi	a0,s1,16
    80002032:	1fa010ef          	jal	8000322c <acquiresleep>
      return b;
    80002036:	a889                	j	80002088 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002038:	00016497          	auipc	s1,0x16
    8000203c:	7404b483          	ld	s1,1856(s1) # 80018778 <bcache+0x82b0>
    80002040:	00016797          	auipc	a5,0x16
    80002044:	6f078793          	addi	a5,a5,1776 # 80018730 <bcache+0x8268>
    80002048:	00f48863          	beq	s1,a5,80002058 <bread+0x84>
    8000204c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000204e:	40bc                	lw	a5,64(s1)
    80002050:	cb91                	beqz	a5,80002064 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002052:	64a4                	ld	s1,72(s1)
    80002054:	fee49de3          	bne	s1,a4,8000204e <bread+0x7a>
  panic("bget: no buffers"); //if there are no available buffer call panic.
    80002058:	00005517          	auipc	a0,0x5
    8000205c:	47850513          	addi	a0,a0,1144 # 800074d0 <etext+0x4d0>
    80002060:	462030ef          	jal	800054c2 <panic>
      b->dev = dev;
    80002064:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002068:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000206c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002070:	4785                	li	a5,1
    80002072:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002074:	0000e517          	auipc	a0,0xe
    80002078:	45450513          	addi	a0,a0,1108 # 800104c8 <bcache>
    8000207c:	00d030ef          	jal	80005888 <release>
      acquiresleep(&b->lock);
    80002080:	01048513          	addi	a0,s1,16
    80002084:	1a8010ef          	jal	8000322c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  //check if the data is valid or not
  if(!b->valid) {
    80002088:	409c                	lw	a5,0(s1)
    8000208a:	cb89                	beqz	a5,8000209c <bread+0xc8>
    virtio_disk_rw(b, 0); //write data into buffer
    b->valid = 1;
  }
  return b;
}
    8000208c:	8526                	mv	a0,s1
    8000208e:	70a2                	ld	ra,40(sp)
    80002090:	7402                	ld	s0,32(sp)
    80002092:	64e2                	ld	s1,24(sp)
    80002094:	6942                	ld	s2,16(sp)
    80002096:	69a2                	ld	s3,8(sp)
    80002098:	6145                	addi	sp,sp,48
    8000209a:	8082                	ret
    virtio_disk_rw(b, 0); //write data into buffer
    8000209c:	4581                	li	a1,0
    8000209e:	8526                	mv	a0,s1
    800020a0:	1f1020ef          	jal	80004a90 <virtio_disk_rw>
    b->valid = 1;
    800020a4:	4785                	li	a5,1
    800020a6:	c09c                	sw	a5,0(s1)
  return b;
    800020a8:	b7d5                	j	8000208c <bread+0xb8>

00000000800020aa <bwrite>:

// Write b's contents to disk.  Must be locked.
// Synchronize the contents of buffer b with the block on disk.
void
bwrite(struct buf *b)
{
    800020aa:	1101                	addi	sp,sp,-32
    800020ac:	ec06                	sd	ra,24(sp)
    800020ae:	e822                	sd	s0,16(sp)
    800020b0:	e426                	sd	s1,8(sp)
    800020b2:	1000                	addi	s0,sp,32
    800020b4:	84aa                	mv	s1,a0
  //check if buffer is locked by instance process
  if(!holdingsleep(&b->lock))
    800020b6:	0541                	addi	a0,a0,16
    800020b8:	1f2010ef          	jal	800032aa <holdingsleep>
    800020bc:	c911                	beqz	a0,800020d0 <bwrite+0x26>
    panic("bwrite"); //call panic
  virtio_disk_rw(b, 1); // write data into buffer
    800020be:	4585                	li	a1,1
    800020c0:	8526                	mv	a0,s1
    800020c2:	1cf020ef          	jal	80004a90 <virtio_disk_rw>
}
    800020c6:	60e2                	ld	ra,24(sp)
    800020c8:	6442                	ld	s0,16(sp)
    800020ca:	64a2                	ld	s1,8(sp)
    800020cc:	6105                	addi	sp,sp,32
    800020ce:	8082                	ret
    panic("bwrite"); //call panic
    800020d0:	00005517          	auipc	a0,0x5
    800020d4:	41850513          	addi	a0,a0,1048 # 800074e8 <etext+0x4e8>
    800020d8:	3ea030ef          	jal	800054c2 <panic>

00000000800020dc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800020dc:	1101                	addi	sp,sp,-32
    800020de:	ec06                	sd	ra,24(sp)
    800020e0:	e822                	sd	s0,16(sp)
    800020e2:	e426                	sd	s1,8(sp)
    800020e4:	e04a                	sd	s2,0(sp)
    800020e6:	1000                	addi	s0,sp,32
    800020e8:	84aa                	mv	s1,a0
  //check if buffer is lock
  if(!holdingsleep(&b->lock))
    800020ea:	01050913          	addi	s2,a0,16
    800020ee:	854a                	mv	a0,s2
    800020f0:	1ba010ef          	jal	800032aa <holdingsleep>
    800020f4:	c135                	beqz	a0,80002158 <brelse+0x7c>
    panic("brelse"); // call panic
  //release lock buffer
  releasesleep(&b->lock);
    800020f6:	854a                	mv	a0,s2
    800020f8:	17a010ef          	jal	80003272 <releasesleep>

  //reduce refcnt
  acquire(&bcache.lock);
    800020fc:	0000e517          	auipc	a0,0xe
    80002100:	3cc50513          	addi	a0,a0,972 # 800104c8 <bcache>
    80002104:	6ec030ef          	jal	800057f0 <acquire>
  b->refcnt--;
    80002108:	40bc                	lw	a5,64(s1)
    8000210a:	37fd                	addiw	a5,a5,-1
    8000210c:	0007871b          	sext.w	a4,a5
    80002110:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002112:	e71d                	bnez	a4,80002140 <brelse+0x64>
    // no one is waiting for it and move it to LRU
    b->next->prev = b->prev;
    80002114:	68b8                	ld	a4,80(s1)
    80002116:	64bc                	ld	a5,72(s1)
    80002118:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000211a:	68b8                	ld	a4,80(s1)
    8000211c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000211e:	00016797          	auipc	a5,0x16
    80002122:	3aa78793          	addi	a5,a5,938 # 800184c8 <bcache+0x8000>
    80002126:	2b87b703          	ld	a4,696(a5)
    8000212a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000212c:	00016717          	auipc	a4,0x16
    80002130:	60470713          	addi	a4,a4,1540 # 80018730 <bcache+0x8268>
    80002134:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002136:	2b87b703          	ld	a4,696(a5)
    8000213a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000213c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002140:	0000e517          	auipc	a0,0xe
    80002144:	38850513          	addi	a0,a0,904 # 800104c8 <bcache>
    80002148:	740030ef          	jal	80005888 <release>
}
    8000214c:	60e2                	ld	ra,24(sp)
    8000214e:	6442                	ld	s0,16(sp)
    80002150:	64a2                	ld	s1,8(sp)
    80002152:	6902                	ld	s2,0(sp)
    80002154:	6105                	addi	sp,sp,32
    80002156:	8082                	ret
    panic("brelse"); // call panic
    80002158:	00005517          	auipc	a0,0x5
    8000215c:	39850513          	addi	a0,a0,920 # 800074f0 <etext+0x4f0>
    80002160:	362030ef          	jal	800054c2 <panic>

0000000080002164 <bpin>:

//pin buffer to prevent buffer from reusing
void
bpin(struct buf *b) {
    80002164:	1101                	addi	sp,sp,-32
    80002166:	ec06                	sd	ra,24(sp)
    80002168:	e822                	sd	s0,16(sp)
    8000216a:	e426                	sd	s1,8(sp)
    8000216c:	1000                	addi	s0,sp,32
    8000216e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002170:	0000e517          	auipc	a0,0xe
    80002174:	35850513          	addi	a0,a0,856 # 800104c8 <bcache>
    80002178:	678030ef          	jal	800057f0 <acquire>
  b->refcnt++;
    8000217c:	40bc                	lw	a5,64(s1)
    8000217e:	2785                	addiw	a5,a5,1
    80002180:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002182:	0000e517          	auipc	a0,0xe
    80002186:	34650513          	addi	a0,a0,838 # 800104c8 <bcache>
    8000218a:	6fe030ef          	jal	80005888 <release>
}
    8000218e:	60e2                	ld	ra,24(sp)
    80002190:	6442                	ld	s0,16(sp)
    80002192:	64a2                	ld	s1,8(sp)
    80002194:	6105                	addi	sp,sp,32
    80002196:	8082                	ret

0000000080002198 <bunpin>:

//unpin buffer
void
bunpin(struct buf *b) {
    80002198:	1101                	addi	sp,sp,-32
    8000219a:	ec06                	sd	ra,24(sp)
    8000219c:	e822                	sd	s0,16(sp)
    8000219e:	e426                	sd	s1,8(sp)
    800021a0:	1000                	addi	s0,sp,32
    800021a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800021a4:	0000e517          	auipc	a0,0xe
    800021a8:	32450513          	addi	a0,a0,804 # 800104c8 <bcache>
    800021ac:	644030ef          	jal	800057f0 <acquire>
  b->refcnt--;
    800021b0:	40bc                	lw	a5,64(s1)
    800021b2:	37fd                	addiw	a5,a5,-1
    800021b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800021b6:	0000e517          	auipc	a0,0xe
    800021ba:	31250513          	addi	a0,a0,786 # 800104c8 <bcache>
    800021be:	6ca030ef          	jal	80005888 <release>
}
    800021c2:	60e2                	ld	ra,24(sp)
    800021c4:	6442                	ld	s0,16(sp)
    800021c6:	64a2                	ld	s1,8(sp)
    800021c8:	6105                	addi	sp,sp,32
    800021ca:	8082                	ret

00000000800021cc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800021cc:	1101                	addi	sp,sp,-32
    800021ce:	ec06                	sd	ra,24(sp)
    800021d0:	e822                	sd	s0,16(sp)
    800021d2:	e426                	sd	s1,8(sp)
    800021d4:	e04a                	sd	s2,0(sp)
    800021d6:	1000                	addi	s0,sp,32
    800021d8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800021da:	00d5d59b          	srliw	a1,a1,0xd
    800021de:	00017797          	auipc	a5,0x17
    800021e2:	9c67a783          	lw	a5,-1594(a5) # 80018ba4 <sb+0x1c>
    800021e6:	9dbd                	addw	a1,a1,a5
    800021e8:	dedff0ef          	jal	80001fd4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800021ec:	0074f713          	andi	a4,s1,7
    800021f0:	4785                	li	a5,1
    800021f2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800021f6:	14ce                	slli	s1,s1,0x33
    800021f8:	90d9                	srli	s1,s1,0x36
    800021fa:	00950733          	add	a4,a0,s1
    800021fe:	05874703          	lbu	a4,88(a4)
    80002202:	00e7f6b3          	and	a3,a5,a4
    80002206:	c29d                	beqz	a3,8000222c <bfree+0x60>
    80002208:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000220a:	94aa                	add	s1,s1,a0
    8000220c:	fff7c793          	not	a5,a5
    80002210:	8f7d                	and	a4,a4,a5
    80002212:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002216:	711000ef          	jal	80003126 <log_write>
  brelse(bp);
    8000221a:	854a                	mv	a0,s2
    8000221c:	ec1ff0ef          	jal	800020dc <brelse>
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	64a2                	ld	s1,8(sp)
    80002226:	6902                	ld	s2,0(sp)
    80002228:	6105                	addi	sp,sp,32
    8000222a:	8082                	ret
    panic("freeing free block");
    8000222c:	00005517          	auipc	a0,0x5
    80002230:	2cc50513          	addi	a0,a0,716 # 800074f8 <etext+0x4f8>
    80002234:	28e030ef          	jal	800054c2 <panic>

0000000080002238 <balloc>:
{
    80002238:	711d                	addi	sp,sp,-96
    8000223a:	ec86                	sd	ra,88(sp)
    8000223c:	e8a2                	sd	s0,80(sp)
    8000223e:	e4a6                	sd	s1,72(sp)
    80002240:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002242:	00017797          	auipc	a5,0x17
    80002246:	94a7a783          	lw	a5,-1718(a5) # 80018b8c <sb+0x4>
    8000224a:	0e078f63          	beqz	a5,80002348 <balloc+0x110>
    8000224e:	e0ca                	sd	s2,64(sp)
    80002250:	fc4e                	sd	s3,56(sp)
    80002252:	f852                	sd	s4,48(sp)
    80002254:	f456                	sd	s5,40(sp)
    80002256:	f05a                	sd	s6,32(sp)
    80002258:	ec5e                	sd	s7,24(sp)
    8000225a:	e862                	sd	s8,16(sp)
    8000225c:	e466                	sd	s9,8(sp)
    8000225e:	8baa                	mv	s7,a0
    80002260:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002262:	00017b17          	auipc	s6,0x17
    80002266:	926b0b13          	addi	s6,s6,-1754 # 80018b88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000226a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000226c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000226e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002270:	6c89                	lui	s9,0x2
    80002272:	a0b5                	j	800022de <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002274:	97ca                	add	a5,a5,s2
    80002276:	8e55                	or	a2,a2,a3
    80002278:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000227c:	854a                	mv	a0,s2
    8000227e:	6a9000ef          	jal	80003126 <log_write>
        brelse(bp);
    80002282:	854a                	mv	a0,s2
    80002284:	e59ff0ef          	jal	800020dc <brelse>
  bp = bread(dev, bno);
    80002288:	85a6                	mv	a1,s1
    8000228a:	855e                	mv	a0,s7
    8000228c:	d49ff0ef          	jal	80001fd4 <bread>
    80002290:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002292:	40000613          	li	a2,1024
    80002296:	4581                	li	a1,0
    80002298:	05850513          	addi	a0,a0,88
    8000229c:	eb3fd0ef          	jal	8000014e <memset>
  log_write(bp);
    800022a0:	854a                	mv	a0,s2
    800022a2:	685000ef          	jal	80003126 <log_write>
  brelse(bp);
    800022a6:	854a                	mv	a0,s2
    800022a8:	e35ff0ef          	jal	800020dc <brelse>
}
    800022ac:	6906                	ld	s2,64(sp)
    800022ae:	79e2                	ld	s3,56(sp)
    800022b0:	7a42                	ld	s4,48(sp)
    800022b2:	7aa2                	ld	s5,40(sp)
    800022b4:	7b02                	ld	s6,32(sp)
    800022b6:	6be2                	ld	s7,24(sp)
    800022b8:	6c42                	ld	s8,16(sp)
    800022ba:	6ca2                	ld	s9,8(sp)
}
    800022bc:	8526                	mv	a0,s1
    800022be:	60e6                	ld	ra,88(sp)
    800022c0:	6446                	ld	s0,80(sp)
    800022c2:	64a6                	ld	s1,72(sp)
    800022c4:	6125                	addi	sp,sp,96
    800022c6:	8082                	ret
    brelse(bp);
    800022c8:	854a                	mv	a0,s2
    800022ca:	e13ff0ef          	jal	800020dc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800022ce:	015c87bb          	addw	a5,s9,s5
    800022d2:	00078a9b          	sext.w	s5,a5
    800022d6:	004b2703          	lw	a4,4(s6)
    800022da:	04eaff63          	bgeu	s5,a4,80002338 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800022de:	41fad79b          	sraiw	a5,s5,0x1f
    800022e2:	0137d79b          	srliw	a5,a5,0x13
    800022e6:	015787bb          	addw	a5,a5,s5
    800022ea:	40d7d79b          	sraiw	a5,a5,0xd
    800022ee:	01cb2583          	lw	a1,28(s6)
    800022f2:	9dbd                	addw	a1,a1,a5
    800022f4:	855e                	mv	a0,s7
    800022f6:	cdfff0ef          	jal	80001fd4 <bread>
    800022fa:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022fc:	004b2503          	lw	a0,4(s6)
    80002300:	000a849b          	sext.w	s1,s5
    80002304:	8762                	mv	a4,s8
    80002306:	fca4f1e3          	bgeu	s1,a0,800022c8 <balloc+0x90>
      m = 1 << (bi % 8);
    8000230a:	00777693          	andi	a3,a4,7
    8000230e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002312:	41f7579b          	sraiw	a5,a4,0x1f
    80002316:	01d7d79b          	srliw	a5,a5,0x1d
    8000231a:	9fb9                	addw	a5,a5,a4
    8000231c:	4037d79b          	sraiw	a5,a5,0x3
    80002320:	00f90633          	add	a2,s2,a5
    80002324:	05864603          	lbu	a2,88(a2)
    80002328:	00c6f5b3          	and	a1,a3,a2
    8000232c:	d5a1                	beqz	a1,80002274 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000232e:	2705                	addiw	a4,a4,1
    80002330:	2485                	addiw	s1,s1,1
    80002332:	fd471ae3          	bne	a4,s4,80002306 <balloc+0xce>
    80002336:	bf49                	j	800022c8 <balloc+0x90>
    80002338:	6906                	ld	s2,64(sp)
    8000233a:	79e2                	ld	s3,56(sp)
    8000233c:	7a42                	ld	s4,48(sp)
    8000233e:	7aa2                	ld	s5,40(sp)
    80002340:	7b02                	ld	s6,32(sp)
    80002342:	6be2                	ld	s7,24(sp)
    80002344:	6c42                	ld	s8,16(sp)
    80002346:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002348:	00005517          	auipc	a0,0x5
    8000234c:	1c850513          	addi	a0,a0,456 # 80007510 <etext+0x510>
    80002350:	6a1020ef          	jal	800051f0 <printf>
  return 0;
    80002354:	4481                	li	s1,0
    80002356:	b79d                	j	800022bc <balloc+0x84>

0000000080002358 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002358:	7179                	addi	sp,sp,-48
    8000235a:	f406                	sd	ra,40(sp)
    8000235c:	f022                	sd	s0,32(sp)
    8000235e:	ec26                	sd	s1,24(sp)
    80002360:	e84a                	sd	s2,16(sp)
    80002362:	e44e                	sd	s3,8(sp)
    80002364:	1800                	addi	s0,sp,48
    80002366:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002368:	47ad                	li	a5,11
    8000236a:	02b7e663          	bltu	a5,a1,80002396 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000236e:	02059793          	slli	a5,a1,0x20
    80002372:	01e7d593          	srli	a1,a5,0x1e
    80002376:	00b504b3          	add	s1,a0,a1
    8000237a:	0504a903          	lw	s2,80(s1)
    8000237e:	06091a63          	bnez	s2,800023f2 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002382:	4108                	lw	a0,0(a0)
    80002384:	eb5ff0ef          	jal	80002238 <balloc>
    80002388:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000238c:	06090363          	beqz	s2,800023f2 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002390:	0524a823          	sw	s2,80(s1)
    80002394:	a8b9                	j	800023f2 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002396:	ff45849b          	addiw	s1,a1,-12
    8000239a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000239e:	0ff00793          	li	a5,255
    800023a2:	06e7ee63          	bltu	a5,a4,8000241e <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800023a6:	08052903          	lw	s2,128(a0)
    800023aa:	00091d63          	bnez	s2,800023c4 <bmap+0x6c>
      addr = balloc(ip->dev);
    800023ae:	4108                	lw	a0,0(a0)
    800023b0:	e89ff0ef          	jal	80002238 <balloc>
    800023b4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800023b8:	02090d63          	beqz	s2,800023f2 <bmap+0x9a>
    800023bc:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800023be:	0929a023          	sw	s2,128(s3)
    800023c2:	a011                	j	800023c6 <bmap+0x6e>
    800023c4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800023c6:	85ca                	mv	a1,s2
    800023c8:	0009a503          	lw	a0,0(s3)
    800023cc:	c09ff0ef          	jal	80001fd4 <bread>
    800023d0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800023d2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800023d6:	02049713          	slli	a4,s1,0x20
    800023da:	01e75593          	srli	a1,a4,0x1e
    800023de:	00b784b3          	add	s1,a5,a1
    800023e2:	0004a903          	lw	s2,0(s1)
    800023e6:	00090e63          	beqz	s2,80002402 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800023ea:	8552                	mv	a0,s4
    800023ec:	cf1ff0ef          	jal	800020dc <brelse>
    return addr;
    800023f0:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800023f2:	854a                	mv	a0,s2
    800023f4:	70a2                	ld	ra,40(sp)
    800023f6:	7402                	ld	s0,32(sp)
    800023f8:	64e2                	ld	s1,24(sp)
    800023fa:	6942                	ld	s2,16(sp)
    800023fc:	69a2                	ld	s3,8(sp)
    800023fe:	6145                	addi	sp,sp,48
    80002400:	8082                	ret
      addr = balloc(ip->dev);
    80002402:	0009a503          	lw	a0,0(s3)
    80002406:	e33ff0ef          	jal	80002238 <balloc>
    8000240a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000240e:	fc090ee3          	beqz	s2,800023ea <bmap+0x92>
        a[bn] = addr;
    80002412:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002416:	8552                	mv	a0,s4
    80002418:	50f000ef          	jal	80003126 <log_write>
    8000241c:	b7f9                	j	800023ea <bmap+0x92>
    8000241e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002420:	00005517          	auipc	a0,0x5
    80002424:	10850513          	addi	a0,a0,264 # 80007528 <etext+0x528>
    80002428:	09a030ef          	jal	800054c2 <panic>

000000008000242c <iget>:
{
    8000242c:	7179                	addi	sp,sp,-48
    8000242e:	f406                	sd	ra,40(sp)
    80002430:	f022                	sd	s0,32(sp)
    80002432:	ec26                	sd	s1,24(sp)
    80002434:	e84a                	sd	s2,16(sp)
    80002436:	e44e                	sd	s3,8(sp)
    80002438:	e052                	sd	s4,0(sp)
    8000243a:	1800                	addi	s0,sp,48
    8000243c:	89aa                	mv	s3,a0
    8000243e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002440:	00016517          	auipc	a0,0x16
    80002444:	76850513          	addi	a0,a0,1896 # 80018ba8 <itable>
    80002448:	3a8030ef          	jal	800057f0 <acquire>
  empty = 0;
    8000244c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000244e:	00016497          	auipc	s1,0x16
    80002452:	77248493          	addi	s1,s1,1906 # 80018bc0 <itable+0x18>
    80002456:	00018697          	auipc	a3,0x18
    8000245a:	1fa68693          	addi	a3,a3,506 # 8001a650 <log>
    8000245e:	a039                	j	8000246c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002460:	02090963          	beqz	s2,80002492 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002464:	08848493          	addi	s1,s1,136
    80002468:	02d48863          	beq	s1,a3,80002498 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000246c:	449c                	lw	a5,8(s1)
    8000246e:	fef059e3          	blez	a5,80002460 <iget+0x34>
    80002472:	4098                	lw	a4,0(s1)
    80002474:	ff3716e3          	bne	a4,s3,80002460 <iget+0x34>
    80002478:	40d8                	lw	a4,4(s1)
    8000247a:	ff4713e3          	bne	a4,s4,80002460 <iget+0x34>
      ip->ref++;
    8000247e:	2785                	addiw	a5,a5,1
    80002480:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002482:	00016517          	auipc	a0,0x16
    80002486:	72650513          	addi	a0,a0,1830 # 80018ba8 <itable>
    8000248a:	3fe030ef          	jal	80005888 <release>
      return ip;
    8000248e:	8926                	mv	s2,s1
    80002490:	a02d                	j	800024ba <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002492:	fbe9                	bnez	a5,80002464 <iget+0x38>
      empty = ip;
    80002494:	8926                	mv	s2,s1
    80002496:	b7f9                	j	80002464 <iget+0x38>
  if(empty == 0)
    80002498:	02090a63          	beqz	s2,800024cc <iget+0xa0>
  ip->dev = dev;
    8000249c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800024a0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800024a4:	4785                	li	a5,1
    800024a6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800024aa:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800024ae:	00016517          	auipc	a0,0x16
    800024b2:	6fa50513          	addi	a0,a0,1786 # 80018ba8 <itable>
    800024b6:	3d2030ef          	jal	80005888 <release>
}
    800024ba:	854a                	mv	a0,s2
    800024bc:	70a2                	ld	ra,40(sp)
    800024be:	7402                	ld	s0,32(sp)
    800024c0:	64e2                	ld	s1,24(sp)
    800024c2:	6942                	ld	s2,16(sp)
    800024c4:	69a2                	ld	s3,8(sp)
    800024c6:	6a02                	ld	s4,0(sp)
    800024c8:	6145                	addi	sp,sp,48
    800024ca:	8082                	ret
    panic("iget: no inodes");
    800024cc:	00005517          	auipc	a0,0x5
    800024d0:	07450513          	addi	a0,a0,116 # 80007540 <etext+0x540>
    800024d4:	7ef020ef          	jal	800054c2 <panic>

00000000800024d8 <fsinit>:
fsinit(int dev) {
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	1800                	addi	s0,sp,48
    800024e6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800024e8:	4585                	li	a1,1
    800024ea:	aebff0ef          	jal	80001fd4 <bread>
    800024ee:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800024f0:	00016997          	auipc	s3,0x16
    800024f4:	69898993          	addi	s3,s3,1688 # 80018b88 <sb>
    800024f8:	02000613          	li	a2,32
    800024fc:	05850593          	addi	a1,a0,88
    80002500:	854e                	mv	a0,s3
    80002502:	ca9fd0ef          	jal	800001aa <memmove>
  brelse(bp);
    80002506:	8526                	mv	a0,s1
    80002508:	bd5ff0ef          	jal	800020dc <brelse>
  if(sb.magic != FSMAGIC)
    8000250c:	0009a703          	lw	a4,0(s3)
    80002510:	102037b7          	lui	a5,0x10203
    80002514:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002518:	02f71063          	bne	a4,a5,80002538 <fsinit+0x60>
  initlog(dev, &sb);
    8000251c:	00016597          	auipc	a1,0x16
    80002520:	66c58593          	addi	a1,a1,1644 # 80018b88 <sb>
    80002524:	854a                	mv	a0,s2
    80002526:	1f9000ef          	jal	80002f1e <initlog>
}
    8000252a:	70a2                	ld	ra,40(sp)
    8000252c:	7402                	ld	s0,32(sp)
    8000252e:	64e2                	ld	s1,24(sp)
    80002530:	6942                	ld	s2,16(sp)
    80002532:	69a2                	ld	s3,8(sp)
    80002534:	6145                	addi	sp,sp,48
    80002536:	8082                	ret
    panic("invalid file system");
    80002538:	00005517          	auipc	a0,0x5
    8000253c:	01850513          	addi	a0,a0,24 # 80007550 <etext+0x550>
    80002540:	783020ef          	jal	800054c2 <panic>

0000000080002544 <iinit>:
{
    80002544:	7179                	addi	sp,sp,-48
    80002546:	f406                	sd	ra,40(sp)
    80002548:	f022                	sd	s0,32(sp)
    8000254a:	ec26                	sd	s1,24(sp)
    8000254c:	e84a                	sd	s2,16(sp)
    8000254e:	e44e                	sd	s3,8(sp)
    80002550:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002552:	00005597          	auipc	a1,0x5
    80002556:	01658593          	addi	a1,a1,22 # 80007568 <etext+0x568>
    8000255a:	00016517          	auipc	a0,0x16
    8000255e:	64e50513          	addi	a0,a0,1614 # 80018ba8 <itable>
    80002562:	20e030ef          	jal	80005770 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002566:	00016497          	auipc	s1,0x16
    8000256a:	66a48493          	addi	s1,s1,1642 # 80018bd0 <itable+0x28>
    8000256e:	00018997          	auipc	s3,0x18
    80002572:	0f298993          	addi	s3,s3,242 # 8001a660 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002576:	00005917          	auipc	s2,0x5
    8000257a:	ffa90913          	addi	s2,s2,-6 # 80007570 <etext+0x570>
    8000257e:	85ca                	mv	a1,s2
    80002580:	8526                	mv	a0,s1
    80002582:	475000ef          	jal	800031f6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002586:	08848493          	addi	s1,s1,136
    8000258a:	ff349ae3          	bne	s1,s3,8000257e <iinit+0x3a>
}
    8000258e:	70a2                	ld	ra,40(sp)
    80002590:	7402                	ld	s0,32(sp)
    80002592:	64e2                	ld	s1,24(sp)
    80002594:	6942                	ld	s2,16(sp)
    80002596:	69a2                	ld	s3,8(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret

000000008000259c <ialloc>:
{
    8000259c:	7139                	addi	sp,sp,-64
    8000259e:	fc06                	sd	ra,56(sp)
    800025a0:	f822                	sd	s0,48(sp)
    800025a2:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800025a4:	00016717          	auipc	a4,0x16
    800025a8:	5f072703          	lw	a4,1520(a4) # 80018b94 <sb+0xc>
    800025ac:	4785                	li	a5,1
    800025ae:	06e7f063          	bgeu	a5,a4,8000260e <ialloc+0x72>
    800025b2:	f426                	sd	s1,40(sp)
    800025b4:	f04a                	sd	s2,32(sp)
    800025b6:	ec4e                	sd	s3,24(sp)
    800025b8:	e852                	sd	s4,16(sp)
    800025ba:	e456                	sd	s5,8(sp)
    800025bc:	e05a                	sd	s6,0(sp)
    800025be:	8aaa                	mv	s5,a0
    800025c0:	8b2e                	mv	s6,a1
    800025c2:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800025c4:	00016a17          	auipc	s4,0x16
    800025c8:	5c4a0a13          	addi	s4,s4,1476 # 80018b88 <sb>
    800025cc:	00495593          	srli	a1,s2,0x4
    800025d0:	018a2783          	lw	a5,24(s4)
    800025d4:	9dbd                	addw	a1,a1,a5
    800025d6:	8556                	mv	a0,s5
    800025d8:	9fdff0ef          	jal	80001fd4 <bread>
    800025dc:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800025de:	05850993          	addi	s3,a0,88
    800025e2:	00f97793          	andi	a5,s2,15
    800025e6:	079a                	slli	a5,a5,0x6
    800025e8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800025ea:	00099783          	lh	a5,0(s3)
    800025ee:	cb9d                	beqz	a5,80002624 <ialloc+0x88>
    brelse(bp);
    800025f0:	aedff0ef          	jal	800020dc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800025f4:	0905                	addi	s2,s2,1
    800025f6:	00ca2703          	lw	a4,12(s4)
    800025fa:	0009079b          	sext.w	a5,s2
    800025fe:	fce7e7e3          	bltu	a5,a4,800025cc <ialloc+0x30>
    80002602:	74a2                	ld	s1,40(sp)
    80002604:	7902                	ld	s2,32(sp)
    80002606:	69e2                	ld	s3,24(sp)
    80002608:	6a42                	ld	s4,16(sp)
    8000260a:	6aa2                	ld	s5,8(sp)
    8000260c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000260e:	00005517          	auipc	a0,0x5
    80002612:	f6a50513          	addi	a0,a0,-150 # 80007578 <etext+0x578>
    80002616:	3db020ef          	jal	800051f0 <printf>
  return 0;
    8000261a:	4501                	li	a0,0
}
    8000261c:	70e2                	ld	ra,56(sp)
    8000261e:	7442                	ld	s0,48(sp)
    80002620:	6121                	addi	sp,sp,64
    80002622:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002624:	04000613          	li	a2,64
    80002628:	4581                	li	a1,0
    8000262a:	854e                	mv	a0,s3
    8000262c:	b23fd0ef          	jal	8000014e <memset>
      dip->type = type;
    80002630:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002634:	8526                	mv	a0,s1
    80002636:	2f1000ef          	jal	80003126 <log_write>
      brelse(bp);
    8000263a:	8526                	mv	a0,s1
    8000263c:	aa1ff0ef          	jal	800020dc <brelse>
      return iget(dev, inum);
    80002640:	0009059b          	sext.w	a1,s2
    80002644:	8556                	mv	a0,s5
    80002646:	de7ff0ef          	jal	8000242c <iget>
    8000264a:	74a2                	ld	s1,40(sp)
    8000264c:	7902                	ld	s2,32(sp)
    8000264e:	69e2                	ld	s3,24(sp)
    80002650:	6a42                	ld	s4,16(sp)
    80002652:	6aa2                	ld	s5,8(sp)
    80002654:	6b02                	ld	s6,0(sp)
    80002656:	b7d9                	j	8000261c <ialloc+0x80>

0000000080002658 <iupdate>:
{
    80002658:	1101                	addi	sp,sp,-32
    8000265a:	ec06                	sd	ra,24(sp)
    8000265c:	e822                	sd	s0,16(sp)
    8000265e:	e426                	sd	s1,8(sp)
    80002660:	e04a                	sd	s2,0(sp)
    80002662:	1000                	addi	s0,sp,32
    80002664:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002666:	415c                	lw	a5,4(a0)
    80002668:	0047d79b          	srliw	a5,a5,0x4
    8000266c:	00016597          	auipc	a1,0x16
    80002670:	5345a583          	lw	a1,1332(a1) # 80018ba0 <sb+0x18>
    80002674:	9dbd                	addw	a1,a1,a5
    80002676:	4108                	lw	a0,0(a0)
    80002678:	95dff0ef          	jal	80001fd4 <bread>
    8000267c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000267e:	05850793          	addi	a5,a0,88
    80002682:	40d8                	lw	a4,4(s1)
    80002684:	8b3d                	andi	a4,a4,15
    80002686:	071a                	slli	a4,a4,0x6
    80002688:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000268a:	04449703          	lh	a4,68(s1)
    8000268e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002692:	04649703          	lh	a4,70(s1)
    80002696:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000269a:	04849703          	lh	a4,72(s1)
    8000269e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800026a2:	04a49703          	lh	a4,74(s1)
    800026a6:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800026aa:	44f8                	lw	a4,76(s1)
    800026ac:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800026ae:	03400613          	li	a2,52
    800026b2:	05048593          	addi	a1,s1,80
    800026b6:	00c78513          	addi	a0,a5,12
    800026ba:	af1fd0ef          	jal	800001aa <memmove>
  log_write(bp);
    800026be:	854a                	mv	a0,s2
    800026c0:	267000ef          	jal	80003126 <log_write>
  brelse(bp);
    800026c4:	854a                	mv	a0,s2
    800026c6:	a17ff0ef          	jal	800020dc <brelse>
}
    800026ca:	60e2                	ld	ra,24(sp)
    800026cc:	6442                	ld	s0,16(sp)
    800026ce:	64a2                	ld	s1,8(sp)
    800026d0:	6902                	ld	s2,0(sp)
    800026d2:	6105                	addi	sp,sp,32
    800026d4:	8082                	ret

00000000800026d6 <idup>:
{
    800026d6:	1101                	addi	sp,sp,-32
    800026d8:	ec06                	sd	ra,24(sp)
    800026da:	e822                	sd	s0,16(sp)
    800026dc:	e426                	sd	s1,8(sp)
    800026de:	1000                	addi	s0,sp,32
    800026e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800026e2:	00016517          	auipc	a0,0x16
    800026e6:	4c650513          	addi	a0,a0,1222 # 80018ba8 <itable>
    800026ea:	106030ef          	jal	800057f0 <acquire>
  ip->ref++;
    800026ee:	449c                	lw	a5,8(s1)
    800026f0:	2785                	addiw	a5,a5,1
    800026f2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800026f4:	00016517          	auipc	a0,0x16
    800026f8:	4b450513          	addi	a0,a0,1204 # 80018ba8 <itable>
    800026fc:	18c030ef          	jal	80005888 <release>
}
    80002700:	8526                	mv	a0,s1
    80002702:	60e2                	ld	ra,24(sp)
    80002704:	6442                	ld	s0,16(sp)
    80002706:	64a2                	ld	s1,8(sp)
    80002708:	6105                	addi	sp,sp,32
    8000270a:	8082                	ret

000000008000270c <ilock>:
{
    8000270c:	1101                	addi	sp,sp,-32
    8000270e:	ec06                	sd	ra,24(sp)
    80002710:	e822                	sd	s0,16(sp)
    80002712:	e426                	sd	s1,8(sp)
    80002714:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002716:	cd19                	beqz	a0,80002734 <ilock+0x28>
    80002718:	84aa                	mv	s1,a0
    8000271a:	451c                	lw	a5,8(a0)
    8000271c:	00f05c63          	blez	a5,80002734 <ilock+0x28>
  acquiresleep(&ip->lock);
    80002720:	0541                	addi	a0,a0,16
    80002722:	30b000ef          	jal	8000322c <acquiresleep>
  if(ip->valid == 0){
    80002726:	40bc                	lw	a5,64(s1)
    80002728:	cf89                	beqz	a5,80002742 <ilock+0x36>
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	64a2                	ld	s1,8(sp)
    80002730:	6105                	addi	sp,sp,32
    80002732:	8082                	ret
    80002734:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80002736:	00005517          	auipc	a0,0x5
    8000273a:	e5a50513          	addi	a0,a0,-422 # 80007590 <etext+0x590>
    8000273e:	585020ef          	jal	800054c2 <panic>
    80002742:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002744:	40dc                	lw	a5,4(s1)
    80002746:	0047d79b          	srliw	a5,a5,0x4
    8000274a:	00016597          	auipc	a1,0x16
    8000274e:	4565a583          	lw	a1,1110(a1) # 80018ba0 <sb+0x18>
    80002752:	9dbd                	addw	a1,a1,a5
    80002754:	4088                	lw	a0,0(s1)
    80002756:	87fff0ef          	jal	80001fd4 <bread>
    8000275a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000275c:	05850593          	addi	a1,a0,88
    80002760:	40dc                	lw	a5,4(s1)
    80002762:	8bbd                	andi	a5,a5,15
    80002764:	079a                	slli	a5,a5,0x6
    80002766:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002768:	00059783          	lh	a5,0(a1)
    8000276c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002770:	00259783          	lh	a5,2(a1)
    80002774:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002778:	00459783          	lh	a5,4(a1)
    8000277c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002780:	00659783          	lh	a5,6(a1)
    80002784:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002788:	459c                	lw	a5,8(a1)
    8000278a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000278c:	03400613          	li	a2,52
    80002790:	05b1                	addi	a1,a1,12
    80002792:	05048513          	addi	a0,s1,80
    80002796:	a15fd0ef          	jal	800001aa <memmove>
    brelse(bp);
    8000279a:	854a                	mv	a0,s2
    8000279c:	941ff0ef          	jal	800020dc <brelse>
    ip->valid = 1;
    800027a0:	4785                	li	a5,1
    800027a2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800027a4:	04449783          	lh	a5,68(s1)
    800027a8:	c399                	beqz	a5,800027ae <ilock+0xa2>
    800027aa:	6902                	ld	s2,0(sp)
    800027ac:	bfbd                	j	8000272a <ilock+0x1e>
      panic("ilock: no type");
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	dea50513          	addi	a0,a0,-534 # 80007598 <etext+0x598>
    800027b6:	50d020ef          	jal	800054c2 <panic>

00000000800027ba <iunlock>:
{
    800027ba:	1101                	addi	sp,sp,-32
    800027bc:	ec06                	sd	ra,24(sp)
    800027be:	e822                	sd	s0,16(sp)
    800027c0:	e426                	sd	s1,8(sp)
    800027c2:	e04a                	sd	s2,0(sp)
    800027c4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800027c6:	c505                	beqz	a0,800027ee <iunlock+0x34>
    800027c8:	84aa                	mv	s1,a0
    800027ca:	01050913          	addi	s2,a0,16
    800027ce:	854a                	mv	a0,s2
    800027d0:	2db000ef          	jal	800032aa <holdingsleep>
    800027d4:	cd09                	beqz	a0,800027ee <iunlock+0x34>
    800027d6:	449c                	lw	a5,8(s1)
    800027d8:	00f05b63          	blez	a5,800027ee <iunlock+0x34>
  releasesleep(&ip->lock);
    800027dc:	854a                	mv	a0,s2
    800027de:	295000ef          	jal	80003272 <releasesleep>
}
    800027e2:	60e2                	ld	ra,24(sp)
    800027e4:	6442                	ld	s0,16(sp)
    800027e6:	64a2                	ld	s1,8(sp)
    800027e8:	6902                	ld	s2,0(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret
    panic("iunlock");
    800027ee:	00005517          	auipc	a0,0x5
    800027f2:	dba50513          	addi	a0,a0,-582 # 800075a8 <etext+0x5a8>
    800027f6:	4cd020ef          	jal	800054c2 <panic>

00000000800027fa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800027fa:	7179                	addi	sp,sp,-48
    800027fc:	f406                	sd	ra,40(sp)
    800027fe:	f022                	sd	s0,32(sp)
    80002800:	ec26                	sd	s1,24(sp)
    80002802:	e84a                	sd	s2,16(sp)
    80002804:	e44e                	sd	s3,8(sp)
    80002806:	1800                	addi	s0,sp,48
    80002808:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000280a:	05050493          	addi	s1,a0,80
    8000280e:	08050913          	addi	s2,a0,128
    80002812:	a021                	j	8000281a <itrunc+0x20>
    80002814:	0491                	addi	s1,s1,4
    80002816:	01248b63          	beq	s1,s2,8000282c <itrunc+0x32>
    if(ip->addrs[i]){
    8000281a:	408c                	lw	a1,0(s1)
    8000281c:	dde5                	beqz	a1,80002814 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000281e:	0009a503          	lw	a0,0(s3)
    80002822:	9abff0ef          	jal	800021cc <bfree>
      ip->addrs[i] = 0;
    80002826:	0004a023          	sw	zero,0(s1)
    8000282a:	b7ed                	j	80002814 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000282c:	0809a583          	lw	a1,128(s3)
    80002830:	ed89                	bnez	a1,8000284a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002832:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002836:	854e                	mv	a0,s3
    80002838:	e21ff0ef          	jal	80002658 <iupdate>
}
    8000283c:	70a2                	ld	ra,40(sp)
    8000283e:	7402                	ld	s0,32(sp)
    80002840:	64e2                	ld	s1,24(sp)
    80002842:	6942                	ld	s2,16(sp)
    80002844:	69a2                	ld	s3,8(sp)
    80002846:	6145                	addi	sp,sp,48
    80002848:	8082                	ret
    8000284a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000284c:	0009a503          	lw	a0,0(s3)
    80002850:	f84ff0ef          	jal	80001fd4 <bread>
    80002854:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002856:	05850493          	addi	s1,a0,88
    8000285a:	45850913          	addi	s2,a0,1112
    8000285e:	a021                	j	80002866 <itrunc+0x6c>
    80002860:	0491                	addi	s1,s1,4
    80002862:	01248963          	beq	s1,s2,80002874 <itrunc+0x7a>
      if(a[j])
    80002866:	408c                	lw	a1,0(s1)
    80002868:	dde5                	beqz	a1,80002860 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000286a:	0009a503          	lw	a0,0(s3)
    8000286e:	95fff0ef          	jal	800021cc <bfree>
    80002872:	b7fd                	j	80002860 <itrunc+0x66>
    brelse(bp);
    80002874:	8552                	mv	a0,s4
    80002876:	867ff0ef          	jal	800020dc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000287a:	0809a583          	lw	a1,128(s3)
    8000287e:	0009a503          	lw	a0,0(s3)
    80002882:	94bff0ef          	jal	800021cc <bfree>
    ip->addrs[NDIRECT] = 0;
    80002886:	0809a023          	sw	zero,128(s3)
    8000288a:	6a02                	ld	s4,0(sp)
    8000288c:	b75d                	j	80002832 <itrunc+0x38>

000000008000288e <iput>:
{
    8000288e:	1101                	addi	sp,sp,-32
    80002890:	ec06                	sd	ra,24(sp)
    80002892:	e822                	sd	s0,16(sp)
    80002894:	e426                	sd	s1,8(sp)
    80002896:	1000                	addi	s0,sp,32
    80002898:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000289a:	00016517          	auipc	a0,0x16
    8000289e:	30e50513          	addi	a0,a0,782 # 80018ba8 <itable>
    800028a2:	74f020ef          	jal	800057f0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800028a6:	4498                	lw	a4,8(s1)
    800028a8:	4785                	li	a5,1
    800028aa:	02f70063          	beq	a4,a5,800028ca <iput+0x3c>
  ip->ref--;
    800028ae:	449c                	lw	a5,8(s1)
    800028b0:	37fd                	addiw	a5,a5,-1
    800028b2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028b4:	00016517          	auipc	a0,0x16
    800028b8:	2f450513          	addi	a0,a0,756 # 80018ba8 <itable>
    800028bc:	7cd020ef          	jal	80005888 <release>
}
    800028c0:	60e2                	ld	ra,24(sp)
    800028c2:	6442                	ld	s0,16(sp)
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800028ca:	40bc                	lw	a5,64(s1)
    800028cc:	d3ed                	beqz	a5,800028ae <iput+0x20>
    800028ce:	04a49783          	lh	a5,74(s1)
    800028d2:	fff1                	bnez	a5,800028ae <iput+0x20>
    800028d4:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800028d6:	01048913          	addi	s2,s1,16
    800028da:	854a                	mv	a0,s2
    800028dc:	151000ef          	jal	8000322c <acquiresleep>
    release(&itable.lock);
    800028e0:	00016517          	auipc	a0,0x16
    800028e4:	2c850513          	addi	a0,a0,712 # 80018ba8 <itable>
    800028e8:	7a1020ef          	jal	80005888 <release>
    itrunc(ip);
    800028ec:	8526                	mv	a0,s1
    800028ee:	f0dff0ef          	jal	800027fa <itrunc>
    ip->type = 0;
    800028f2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800028f6:	8526                	mv	a0,s1
    800028f8:	d61ff0ef          	jal	80002658 <iupdate>
    ip->valid = 0;
    800028fc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002900:	854a                	mv	a0,s2
    80002902:	171000ef          	jal	80003272 <releasesleep>
    acquire(&itable.lock);
    80002906:	00016517          	auipc	a0,0x16
    8000290a:	2a250513          	addi	a0,a0,674 # 80018ba8 <itable>
    8000290e:	6e3020ef          	jal	800057f0 <acquire>
    80002912:	6902                	ld	s2,0(sp)
    80002914:	bf69                	j	800028ae <iput+0x20>

0000000080002916 <iunlockput>:
{
    80002916:	1101                	addi	sp,sp,-32
    80002918:	ec06                	sd	ra,24(sp)
    8000291a:	e822                	sd	s0,16(sp)
    8000291c:	e426                	sd	s1,8(sp)
    8000291e:	1000                	addi	s0,sp,32
    80002920:	84aa                	mv	s1,a0
  iunlock(ip);
    80002922:	e99ff0ef          	jal	800027ba <iunlock>
  iput(ip);
    80002926:	8526                	mv	a0,s1
    80002928:	f67ff0ef          	jal	8000288e <iput>
}
    8000292c:	60e2                	ld	ra,24(sp)
    8000292e:	6442                	ld	s0,16(sp)
    80002930:	64a2                	ld	s1,8(sp)
    80002932:	6105                	addi	sp,sp,32
    80002934:	8082                	ret

0000000080002936 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002936:	1141                	addi	sp,sp,-16
    80002938:	e422                	sd	s0,8(sp)
    8000293a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000293c:	411c                	lw	a5,0(a0)
    8000293e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002940:	415c                	lw	a5,4(a0)
    80002942:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002944:	04451783          	lh	a5,68(a0)
    80002948:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000294c:	04a51783          	lh	a5,74(a0)
    80002950:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002954:	04c56783          	lwu	a5,76(a0)
    80002958:	e99c                	sd	a5,16(a1)
}
    8000295a:	6422                	ld	s0,8(sp)
    8000295c:	0141                	addi	sp,sp,16
    8000295e:	8082                	ret

0000000080002960 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002960:	457c                	lw	a5,76(a0)
    80002962:	0ed7eb63          	bltu	a5,a3,80002a58 <readi+0xf8>
{
    80002966:	7159                	addi	sp,sp,-112
    80002968:	f486                	sd	ra,104(sp)
    8000296a:	f0a2                	sd	s0,96(sp)
    8000296c:	eca6                	sd	s1,88(sp)
    8000296e:	e0d2                	sd	s4,64(sp)
    80002970:	fc56                	sd	s5,56(sp)
    80002972:	f85a                	sd	s6,48(sp)
    80002974:	f45e                	sd	s7,40(sp)
    80002976:	1880                	addi	s0,sp,112
    80002978:	8b2a                	mv	s6,a0
    8000297a:	8bae                	mv	s7,a1
    8000297c:	8a32                	mv	s4,a2
    8000297e:	84b6                	mv	s1,a3
    80002980:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002982:	9f35                	addw	a4,a4,a3
    return 0;
    80002984:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002986:	0cd76063          	bltu	a4,a3,80002a46 <readi+0xe6>
    8000298a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000298c:	00e7f463          	bgeu	a5,a4,80002994 <readi+0x34>
    n = ip->size - off;
    80002990:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002994:	080a8f63          	beqz	s5,80002a32 <readi+0xd2>
    80002998:	e8ca                	sd	s2,80(sp)
    8000299a:	f062                	sd	s8,32(sp)
    8000299c:	ec66                	sd	s9,24(sp)
    8000299e:	e86a                	sd	s10,16(sp)
    800029a0:	e46e                	sd	s11,8(sp)
    800029a2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800029a4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800029a8:	5c7d                	li	s8,-1
    800029aa:	a80d                	j	800029dc <readi+0x7c>
    800029ac:	020d1d93          	slli	s11,s10,0x20
    800029b0:	020ddd93          	srli	s11,s11,0x20
    800029b4:	05890613          	addi	a2,s2,88
    800029b8:	86ee                	mv	a3,s11
    800029ba:	963a                	add	a2,a2,a4
    800029bc:	85d2                	mv	a1,s4
    800029be:	855e                	mv	a0,s7
    800029c0:	cd9fe0ef          	jal	80001698 <either_copyout>
    800029c4:	05850763          	beq	a0,s8,80002a12 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800029c8:	854a                	mv	a0,s2
    800029ca:	f12ff0ef          	jal	800020dc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800029ce:	013d09bb          	addw	s3,s10,s3
    800029d2:	009d04bb          	addw	s1,s10,s1
    800029d6:	9a6e                	add	s4,s4,s11
    800029d8:	0559f763          	bgeu	s3,s5,80002a26 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800029dc:	00a4d59b          	srliw	a1,s1,0xa
    800029e0:	855a                	mv	a0,s6
    800029e2:	977ff0ef          	jal	80002358 <bmap>
    800029e6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800029ea:	c5b1                	beqz	a1,80002a36 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800029ec:	000b2503          	lw	a0,0(s6)
    800029f0:	de4ff0ef          	jal	80001fd4 <bread>
    800029f4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800029f6:	3ff4f713          	andi	a4,s1,1023
    800029fa:	40ec87bb          	subw	a5,s9,a4
    800029fe:	413a86bb          	subw	a3,s5,s3
    80002a02:	8d3e                	mv	s10,a5
    80002a04:	2781                	sext.w	a5,a5
    80002a06:	0006861b          	sext.w	a2,a3
    80002a0a:	faf671e3          	bgeu	a2,a5,800029ac <readi+0x4c>
    80002a0e:	8d36                	mv	s10,a3
    80002a10:	bf71                	j	800029ac <readi+0x4c>
      brelse(bp);
    80002a12:	854a                	mv	a0,s2
    80002a14:	ec8ff0ef          	jal	800020dc <brelse>
      tot = -1;
    80002a18:	59fd                	li	s3,-1
      break;
    80002a1a:	6946                	ld	s2,80(sp)
    80002a1c:	7c02                	ld	s8,32(sp)
    80002a1e:	6ce2                	ld	s9,24(sp)
    80002a20:	6d42                	ld	s10,16(sp)
    80002a22:	6da2                	ld	s11,8(sp)
    80002a24:	a831                	j	80002a40 <readi+0xe0>
    80002a26:	6946                	ld	s2,80(sp)
    80002a28:	7c02                	ld	s8,32(sp)
    80002a2a:	6ce2                	ld	s9,24(sp)
    80002a2c:	6d42                	ld	s10,16(sp)
    80002a2e:	6da2                	ld	s11,8(sp)
    80002a30:	a801                	j	80002a40 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002a32:	89d6                	mv	s3,s5
    80002a34:	a031                	j	80002a40 <readi+0xe0>
    80002a36:	6946                	ld	s2,80(sp)
    80002a38:	7c02                	ld	s8,32(sp)
    80002a3a:	6ce2                	ld	s9,24(sp)
    80002a3c:	6d42                	ld	s10,16(sp)
    80002a3e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002a40:	0009851b          	sext.w	a0,s3
    80002a44:	69a6                	ld	s3,72(sp)
}
    80002a46:	70a6                	ld	ra,104(sp)
    80002a48:	7406                	ld	s0,96(sp)
    80002a4a:	64e6                	ld	s1,88(sp)
    80002a4c:	6a06                	ld	s4,64(sp)
    80002a4e:	7ae2                	ld	s5,56(sp)
    80002a50:	7b42                	ld	s6,48(sp)
    80002a52:	7ba2                	ld	s7,40(sp)
    80002a54:	6165                	addi	sp,sp,112
    80002a56:	8082                	ret
    return 0;
    80002a58:	4501                	li	a0,0
}
    80002a5a:	8082                	ret

0000000080002a5c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a5c:	457c                	lw	a5,76(a0)
    80002a5e:	10d7e063          	bltu	a5,a3,80002b5e <writei+0x102>
{
    80002a62:	7159                	addi	sp,sp,-112
    80002a64:	f486                	sd	ra,104(sp)
    80002a66:	f0a2                	sd	s0,96(sp)
    80002a68:	e8ca                	sd	s2,80(sp)
    80002a6a:	e0d2                	sd	s4,64(sp)
    80002a6c:	fc56                	sd	s5,56(sp)
    80002a6e:	f85a                	sd	s6,48(sp)
    80002a70:	f45e                	sd	s7,40(sp)
    80002a72:	1880                	addi	s0,sp,112
    80002a74:	8aaa                	mv	s5,a0
    80002a76:	8bae                	mv	s7,a1
    80002a78:	8a32                	mv	s4,a2
    80002a7a:	8936                	mv	s2,a3
    80002a7c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002a7e:	00e687bb          	addw	a5,a3,a4
    80002a82:	0ed7e063          	bltu	a5,a3,80002b62 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002a86:	00043737          	lui	a4,0x43
    80002a8a:	0cf76e63          	bltu	a4,a5,80002b66 <writei+0x10a>
    80002a8e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a90:	0a0b0f63          	beqz	s6,80002b4e <writei+0xf2>
    80002a94:	eca6                	sd	s1,88(sp)
    80002a96:	f062                	sd	s8,32(sp)
    80002a98:	ec66                	sd	s9,24(sp)
    80002a9a:	e86a                	sd	s10,16(sp)
    80002a9c:	e46e                	sd	s11,8(sp)
    80002a9e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002aa0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002aa4:	5c7d                	li	s8,-1
    80002aa6:	a825                	j	80002ade <writei+0x82>
    80002aa8:	020d1d93          	slli	s11,s10,0x20
    80002aac:	020ddd93          	srli	s11,s11,0x20
    80002ab0:	05848513          	addi	a0,s1,88
    80002ab4:	86ee                	mv	a3,s11
    80002ab6:	8652                	mv	a2,s4
    80002ab8:	85de                	mv	a1,s7
    80002aba:	953a                	add	a0,a0,a4
    80002abc:	c27fe0ef          	jal	800016e2 <either_copyin>
    80002ac0:	05850a63          	beq	a0,s8,80002b14 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	660000ef          	jal	80003126 <log_write>
    brelse(bp);
    80002aca:	8526                	mv	a0,s1
    80002acc:	e10ff0ef          	jal	800020dc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ad0:	013d09bb          	addw	s3,s10,s3
    80002ad4:	012d093b          	addw	s2,s10,s2
    80002ad8:	9a6e                	add	s4,s4,s11
    80002ada:	0569f063          	bgeu	s3,s6,80002b1a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002ade:	00a9559b          	srliw	a1,s2,0xa
    80002ae2:	8556                	mv	a0,s5
    80002ae4:	875ff0ef          	jal	80002358 <bmap>
    80002ae8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002aec:	c59d                	beqz	a1,80002b1a <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002aee:	000aa503          	lw	a0,0(s5)
    80002af2:	ce2ff0ef          	jal	80001fd4 <bread>
    80002af6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002af8:	3ff97713          	andi	a4,s2,1023
    80002afc:	40ec87bb          	subw	a5,s9,a4
    80002b00:	413b06bb          	subw	a3,s6,s3
    80002b04:	8d3e                	mv	s10,a5
    80002b06:	2781                	sext.w	a5,a5
    80002b08:	0006861b          	sext.w	a2,a3
    80002b0c:	f8f67ee3          	bgeu	a2,a5,80002aa8 <writei+0x4c>
    80002b10:	8d36                	mv	s10,a3
    80002b12:	bf59                	j	80002aa8 <writei+0x4c>
      brelse(bp);
    80002b14:	8526                	mv	a0,s1
    80002b16:	dc6ff0ef          	jal	800020dc <brelse>
  }

  if(off > ip->size)
    80002b1a:	04caa783          	lw	a5,76(s5)
    80002b1e:	0327fa63          	bgeu	a5,s2,80002b52 <writei+0xf6>
    ip->size = off;
    80002b22:	052aa623          	sw	s2,76(s5)
    80002b26:	64e6                	ld	s1,88(sp)
    80002b28:	7c02                	ld	s8,32(sp)
    80002b2a:	6ce2                	ld	s9,24(sp)
    80002b2c:	6d42                	ld	s10,16(sp)
    80002b2e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002b30:	8556                	mv	a0,s5
    80002b32:	b27ff0ef          	jal	80002658 <iupdate>

  return tot;
    80002b36:	0009851b          	sext.w	a0,s3
    80002b3a:	69a6                	ld	s3,72(sp)
}
    80002b3c:	70a6                	ld	ra,104(sp)
    80002b3e:	7406                	ld	s0,96(sp)
    80002b40:	6946                	ld	s2,80(sp)
    80002b42:	6a06                	ld	s4,64(sp)
    80002b44:	7ae2                	ld	s5,56(sp)
    80002b46:	7b42                	ld	s6,48(sp)
    80002b48:	7ba2                	ld	s7,40(sp)
    80002b4a:	6165                	addi	sp,sp,112
    80002b4c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b4e:	89da                	mv	s3,s6
    80002b50:	b7c5                	j	80002b30 <writei+0xd4>
    80002b52:	64e6                	ld	s1,88(sp)
    80002b54:	7c02                	ld	s8,32(sp)
    80002b56:	6ce2                	ld	s9,24(sp)
    80002b58:	6d42                	ld	s10,16(sp)
    80002b5a:	6da2                	ld	s11,8(sp)
    80002b5c:	bfd1                	j	80002b30 <writei+0xd4>
    return -1;
    80002b5e:	557d                	li	a0,-1
}
    80002b60:	8082                	ret
    return -1;
    80002b62:	557d                	li	a0,-1
    80002b64:	bfe1                	j	80002b3c <writei+0xe0>
    return -1;
    80002b66:	557d                	li	a0,-1
    80002b68:	bfd1                	j	80002b3c <writei+0xe0>

0000000080002b6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002b6a:	1141                	addi	sp,sp,-16
    80002b6c:	e406                	sd	ra,8(sp)
    80002b6e:	e022                	sd	s0,0(sp)
    80002b70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002b72:	4639                	li	a2,14
    80002b74:	ea6fd0ef          	jal	8000021a <strncmp>
}
    80002b78:	60a2                	ld	ra,8(sp)
    80002b7a:	6402                	ld	s0,0(sp)
    80002b7c:	0141                	addi	sp,sp,16
    80002b7e:	8082                	ret

0000000080002b80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002b80:	7139                	addi	sp,sp,-64
    80002b82:	fc06                	sd	ra,56(sp)
    80002b84:	f822                	sd	s0,48(sp)
    80002b86:	f426                	sd	s1,40(sp)
    80002b88:	f04a                	sd	s2,32(sp)
    80002b8a:	ec4e                	sd	s3,24(sp)
    80002b8c:	e852                	sd	s4,16(sp)
    80002b8e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002b90:	04451703          	lh	a4,68(a0)
    80002b94:	4785                	li	a5,1
    80002b96:	00f71a63          	bne	a4,a5,80002baa <dirlookup+0x2a>
    80002b9a:	892a                	mv	s2,a0
    80002b9c:	89ae                	mv	s3,a1
    80002b9e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ba0:	457c                	lw	a5,76(a0)
    80002ba2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002ba4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ba6:	e39d                	bnez	a5,80002bcc <dirlookup+0x4c>
    80002ba8:	a095                	j	80002c0c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002baa:	00005517          	auipc	a0,0x5
    80002bae:	a0650513          	addi	a0,a0,-1530 # 800075b0 <etext+0x5b0>
    80002bb2:	111020ef          	jal	800054c2 <panic>
      panic("dirlookup read");
    80002bb6:	00005517          	auipc	a0,0x5
    80002bba:	a1250513          	addi	a0,a0,-1518 # 800075c8 <etext+0x5c8>
    80002bbe:	105020ef          	jal	800054c2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002bc2:	24c1                	addiw	s1,s1,16
    80002bc4:	04c92783          	lw	a5,76(s2)
    80002bc8:	04f4f163          	bgeu	s1,a5,80002c0a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002bcc:	4741                	li	a4,16
    80002bce:	86a6                	mv	a3,s1
    80002bd0:	fc040613          	addi	a2,s0,-64
    80002bd4:	4581                	li	a1,0
    80002bd6:	854a                	mv	a0,s2
    80002bd8:	d89ff0ef          	jal	80002960 <readi>
    80002bdc:	47c1                	li	a5,16
    80002bde:	fcf51ce3          	bne	a0,a5,80002bb6 <dirlookup+0x36>
    if(de.inum == 0)
    80002be2:	fc045783          	lhu	a5,-64(s0)
    80002be6:	dff1                	beqz	a5,80002bc2 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002be8:	fc240593          	addi	a1,s0,-62
    80002bec:	854e                	mv	a0,s3
    80002bee:	f7dff0ef          	jal	80002b6a <namecmp>
    80002bf2:	f961                	bnez	a0,80002bc2 <dirlookup+0x42>
      if(poff)
    80002bf4:	000a0463          	beqz	s4,80002bfc <dirlookup+0x7c>
        *poff = off;
    80002bf8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002bfc:	fc045583          	lhu	a1,-64(s0)
    80002c00:	00092503          	lw	a0,0(s2)
    80002c04:	829ff0ef          	jal	8000242c <iget>
    80002c08:	a011                	j	80002c0c <dirlookup+0x8c>
  return 0;
    80002c0a:	4501                	li	a0,0
}
    80002c0c:	70e2                	ld	ra,56(sp)
    80002c0e:	7442                	ld	s0,48(sp)
    80002c10:	74a2                	ld	s1,40(sp)
    80002c12:	7902                	ld	s2,32(sp)
    80002c14:	69e2                	ld	s3,24(sp)
    80002c16:	6a42                	ld	s4,16(sp)
    80002c18:	6121                	addi	sp,sp,64
    80002c1a:	8082                	ret

0000000080002c1c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002c1c:	711d                	addi	sp,sp,-96
    80002c1e:	ec86                	sd	ra,88(sp)
    80002c20:	e8a2                	sd	s0,80(sp)
    80002c22:	e4a6                	sd	s1,72(sp)
    80002c24:	e0ca                	sd	s2,64(sp)
    80002c26:	fc4e                	sd	s3,56(sp)
    80002c28:	f852                	sd	s4,48(sp)
    80002c2a:	f456                	sd	s5,40(sp)
    80002c2c:	f05a                	sd	s6,32(sp)
    80002c2e:	ec5e                	sd	s7,24(sp)
    80002c30:	e862                	sd	s8,16(sp)
    80002c32:	e466                	sd	s9,8(sp)
    80002c34:	1080                	addi	s0,sp,96
    80002c36:	84aa                	mv	s1,a0
    80002c38:	8b2e                	mv	s6,a1
    80002c3a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002c3c:	00054703          	lbu	a4,0(a0)
    80002c40:	02f00793          	li	a5,47
    80002c44:	00f70e63          	beq	a4,a5,80002c60 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002c48:	91efe0ef          	jal	80000d66 <myproc>
    80002c4c:	15053503          	ld	a0,336(a0)
    80002c50:	a87ff0ef          	jal	800026d6 <idup>
    80002c54:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002c56:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002c5a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002c5c:	4b85                	li	s7,1
    80002c5e:	a871                	j	80002cfa <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002c60:	4585                	li	a1,1
    80002c62:	4505                	li	a0,1
    80002c64:	fc8ff0ef          	jal	8000242c <iget>
    80002c68:	8a2a                	mv	s4,a0
    80002c6a:	b7f5                	j	80002c56 <namex+0x3a>
      iunlockput(ip);
    80002c6c:	8552                	mv	a0,s4
    80002c6e:	ca9ff0ef          	jal	80002916 <iunlockput>
      return 0;
    80002c72:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002c74:	8552                	mv	a0,s4
    80002c76:	60e6                	ld	ra,88(sp)
    80002c78:	6446                	ld	s0,80(sp)
    80002c7a:	64a6                	ld	s1,72(sp)
    80002c7c:	6906                	ld	s2,64(sp)
    80002c7e:	79e2                	ld	s3,56(sp)
    80002c80:	7a42                	ld	s4,48(sp)
    80002c82:	7aa2                	ld	s5,40(sp)
    80002c84:	7b02                	ld	s6,32(sp)
    80002c86:	6be2                	ld	s7,24(sp)
    80002c88:	6c42                	ld	s8,16(sp)
    80002c8a:	6ca2                	ld	s9,8(sp)
    80002c8c:	6125                	addi	sp,sp,96
    80002c8e:	8082                	ret
      iunlock(ip);
    80002c90:	8552                	mv	a0,s4
    80002c92:	b29ff0ef          	jal	800027ba <iunlock>
      return ip;
    80002c96:	bff9                	j	80002c74 <namex+0x58>
      iunlockput(ip);
    80002c98:	8552                	mv	a0,s4
    80002c9a:	c7dff0ef          	jal	80002916 <iunlockput>
      return 0;
    80002c9e:	8a4e                	mv	s4,s3
    80002ca0:	bfd1                	j	80002c74 <namex+0x58>
  len = path - s;
    80002ca2:	40998633          	sub	a2,s3,s1
    80002ca6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002caa:	099c5063          	bge	s8,s9,80002d2a <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002cae:	4639                	li	a2,14
    80002cb0:	85a6                	mv	a1,s1
    80002cb2:	8556                	mv	a0,s5
    80002cb4:	cf6fd0ef          	jal	800001aa <memmove>
    80002cb8:	84ce                	mv	s1,s3
  while(*path == '/')
    80002cba:	0004c783          	lbu	a5,0(s1)
    80002cbe:	01279763          	bne	a5,s2,80002ccc <namex+0xb0>
    path++;
    80002cc2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002cc4:	0004c783          	lbu	a5,0(s1)
    80002cc8:	ff278de3          	beq	a5,s2,80002cc2 <namex+0xa6>
    ilock(ip);
    80002ccc:	8552                	mv	a0,s4
    80002cce:	a3fff0ef          	jal	8000270c <ilock>
    if(ip->type != T_DIR){
    80002cd2:	044a1783          	lh	a5,68(s4)
    80002cd6:	f9779be3          	bne	a5,s7,80002c6c <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002cda:	000b0563          	beqz	s6,80002ce4 <namex+0xc8>
    80002cde:	0004c783          	lbu	a5,0(s1)
    80002ce2:	d7dd                	beqz	a5,80002c90 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002ce4:	4601                	li	a2,0
    80002ce6:	85d6                	mv	a1,s5
    80002ce8:	8552                	mv	a0,s4
    80002cea:	e97ff0ef          	jal	80002b80 <dirlookup>
    80002cee:	89aa                	mv	s3,a0
    80002cf0:	d545                	beqz	a0,80002c98 <namex+0x7c>
    iunlockput(ip);
    80002cf2:	8552                	mv	a0,s4
    80002cf4:	c23ff0ef          	jal	80002916 <iunlockput>
    ip = next;
    80002cf8:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002cfa:	0004c783          	lbu	a5,0(s1)
    80002cfe:	01279763          	bne	a5,s2,80002d0c <namex+0xf0>
    path++;
    80002d02:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002d04:	0004c783          	lbu	a5,0(s1)
    80002d08:	ff278de3          	beq	a5,s2,80002d02 <namex+0xe6>
  if(*path == 0)
    80002d0c:	cb8d                	beqz	a5,80002d3e <namex+0x122>
  while(*path != '/' && *path != 0)
    80002d0e:	0004c783          	lbu	a5,0(s1)
    80002d12:	89a6                	mv	s3,s1
  len = path - s;
    80002d14:	4c81                	li	s9,0
    80002d16:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002d18:	01278963          	beq	a5,s2,80002d2a <namex+0x10e>
    80002d1c:	d3d9                	beqz	a5,80002ca2 <namex+0x86>
    path++;
    80002d1e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002d20:	0009c783          	lbu	a5,0(s3)
    80002d24:	ff279ce3          	bne	a5,s2,80002d1c <namex+0x100>
    80002d28:	bfad                	j	80002ca2 <namex+0x86>
    memmove(name, s, len);
    80002d2a:	2601                	sext.w	a2,a2
    80002d2c:	85a6                	mv	a1,s1
    80002d2e:	8556                	mv	a0,s5
    80002d30:	c7afd0ef          	jal	800001aa <memmove>
    name[len] = 0;
    80002d34:	9cd6                	add	s9,s9,s5
    80002d36:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002d3a:	84ce                	mv	s1,s3
    80002d3c:	bfbd                	j	80002cba <namex+0x9e>
  if(nameiparent){
    80002d3e:	f20b0be3          	beqz	s6,80002c74 <namex+0x58>
    iput(ip);
    80002d42:	8552                	mv	a0,s4
    80002d44:	b4bff0ef          	jal	8000288e <iput>
    return 0;
    80002d48:	4a01                	li	s4,0
    80002d4a:	b72d                	j	80002c74 <namex+0x58>

0000000080002d4c <dirlink>:
{
    80002d4c:	7139                	addi	sp,sp,-64
    80002d4e:	fc06                	sd	ra,56(sp)
    80002d50:	f822                	sd	s0,48(sp)
    80002d52:	f04a                	sd	s2,32(sp)
    80002d54:	ec4e                	sd	s3,24(sp)
    80002d56:	e852                	sd	s4,16(sp)
    80002d58:	0080                	addi	s0,sp,64
    80002d5a:	892a                	mv	s2,a0
    80002d5c:	8a2e                	mv	s4,a1
    80002d5e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002d60:	4601                	li	a2,0
    80002d62:	e1fff0ef          	jal	80002b80 <dirlookup>
    80002d66:	e535                	bnez	a0,80002dd2 <dirlink+0x86>
    80002d68:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d6a:	04c92483          	lw	s1,76(s2)
    80002d6e:	c48d                	beqz	s1,80002d98 <dirlink+0x4c>
    80002d70:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002d72:	4741                	li	a4,16
    80002d74:	86a6                	mv	a3,s1
    80002d76:	fc040613          	addi	a2,s0,-64
    80002d7a:	4581                	li	a1,0
    80002d7c:	854a                	mv	a0,s2
    80002d7e:	be3ff0ef          	jal	80002960 <readi>
    80002d82:	47c1                	li	a5,16
    80002d84:	04f51b63          	bne	a0,a5,80002dda <dirlink+0x8e>
    if(de.inum == 0)
    80002d88:	fc045783          	lhu	a5,-64(s0)
    80002d8c:	c791                	beqz	a5,80002d98 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002d8e:	24c1                	addiw	s1,s1,16
    80002d90:	04c92783          	lw	a5,76(s2)
    80002d94:	fcf4efe3          	bltu	s1,a5,80002d72 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002d98:	4639                	li	a2,14
    80002d9a:	85d2                	mv	a1,s4
    80002d9c:	fc240513          	addi	a0,s0,-62
    80002da0:	cb0fd0ef          	jal	80000250 <strncpy>
  de.inum = inum;
    80002da4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002da8:	4741                	li	a4,16
    80002daa:	86a6                	mv	a3,s1
    80002dac:	fc040613          	addi	a2,s0,-64
    80002db0:	4581                	li	a1,0
    80002db2:	854a                	mv	a0,s2
    80002db4:	ca9ff0ef          	jal	80002a5c <writei>
    80002db8:	1541                	addi	a0,a0,-16
    80002dba:	00a03533          	snez	a0,a0
    80002dbe:	40a00533          	neg	a0,a0
    80002dc2:	74a2                	ld	s1,40(sp)
}
    80002dc4:	70e2                	ld	ra,56(sp)
    80002dc6:	7442                	ld	s0,48(sp)
    80002dc8:	7902                	ld	s2,32(sp)
    80002dca:	69e2                	ld	s3,24(sp)
    80002dcc:	6a42                	ld	s4,16(sp)
    80002dce:	6121                	addi	sp,sp,64
    80002dd0:	8082                	ret
    iput(ip);
    80002dd2:	abdff0ef          	jal	8000288e <iput>
    return -1;
    80002dd6:	557d                	li	a0,-1
    80002dd8:	b7f5                	j	80002dc4 <dirlink+0x78>
      panic("dirlink read");
    80002dda:	00004517          	auipc	a0,0x4
    80002dde:	7fe50513          	addi	a0,a0,2046 # 800075d8 <etext+0x5d8>
    80002de2:	6e0020ef          	jal	800054c2 <panic>

0000000080002de6 <namei>:

struct inode*
namei(char *path)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002dee:	fe040613          	addi	a2,s0,-32
    80002df2:	4581                	li	a1,0
    80002df4:	e29ff0ef          	jal	80002c1c <namex>
}
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	6105                	addi	sp,sp,32
    80002dfe:	8082                	ret

0000000080002e00 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002e00:	1141                	addi	sp,sp,-16
    80002e02:	e406                	sd	ra,8(sp)
    80002e04:	e022                	sd	s0,0(sp)
    80002e06:	0800                	addi	s0,sp,16
    80002e08:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002e0a:	4585                	li	a1,1
    80002e0c:	e11ff0ef          	jal	80002c1c <namex>
}
    80002e10:	60a2                	ld	ra,8(sp)
    80002e12:	6402                	ld	s0,0(sp)
    80002e14:	0141                	addi	sp,sp,16
    80002e16:	8082                	ret

0000000080002e18 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	e426                	sd	s1,8(sp)
    80002e20:	e04a                	sd	s2,0(sp)
    80002e22:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002e24:	00018917          	auipc	s2,0x18
    80002e28:	82c90913          	addi	s2,s2,-2004 # 8001a650 <log>
    80002e2c:	01892583          	lw	a1,24(s2)
    80002e30:	02892503          	lw	a0,40(s2)
    80002e34:	9a0ff0ef          	jal	80001fd4 <bread>
    80002e38:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002e3a:	02c92603          	lw	a2,44(s2)
    80002e3e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002e40:	00c05f63          	blez	a2,80002e5e <write_head+0x46>
    80002e44:	00018717          	auipc	a4,0x18
    80002e48:	83c70713          	addi	a4,a4,-1988 # 8001a680 <log+0x30>
    80002e4c:	87aa                	mv	a5,a0
    80002e4e:	060a                	slli	a2,a2,0x2
    80002e50:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002e52:	4314                	lw	a3,0(a4)
    80002e54:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002e56:	0711                	addi	a4,a4,4
    80002e58:	0791                	addi	a5,a5,4
    80002e5a:	fec79ce3          	bne	a5,a2,80002e52 <write_head+0x3a>
  }
  bwrite(buf);
    80002e5e:	8526                	mv	a0,s1
    80002e60:	a4aff0ef          	jal	800020aa <bwrite>
  brelse(buf);
    80002e64:	8526                	mv	a0,s1
    80002e66:	a76ff0ef          	jal	800020dc <brelse>
}
    80002e6a:	60e2                	ld	ra,24(sp)
    80002e6c:	6442                	ld	s0,16(sp)
    80002e6e:	64a2                	ld	s1,8(sp)
    80002e70:	6902                	ld	s2,0(sp)
    80002e72:	6105                	addi	sp,sp,32
    80002e74:	8082                	ret

0000000080002e76 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e76:	00018797          	auipc	a5,0x18
    80002e7a:	8067a783          	lw	a5,-2042(a5) # 8001a67c <log+0x2c>
    80002e7e:	08f05f63          	blez	a5,80002f1c <install_trans+0xa6>
{
    80002e82:	7139                	addi	sp,sp,-64
    80002e84:	fc06                	sd	ra,56(sp)
    80002e86:	f822                	sd	s0,48(sp)
    80002e88:	f426                	sd	s1,40(sp)
    80002e8a:	f04a                	sd	s2,32(sp)
    80002e8c:	ec4e                	sd	s3,24(sp)
    80002e8e:	e852                	sd	s4,16(sp)
    80002e90:	e456                	sd	s5,8(sp)
    80002e92:	e05a                	sd	s6,0(sp)
    80002e94:	0080                	addi	s0,sp,64
    80002e96:	8b2a                	mv	s6,a0
    80002e98:	00017a97          	auipc	s5,0x17
    80002e9c:	7e8a8a93          	addi	s5,s5,2024 # 8001a680 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002ea0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002ea2:	00017997          	auipc	s3,0x17
    80002ea6:	7ae98993          	addi	s3,s3,1966 # 8001a650 <log>
    80002eaa:	a829                	j	80002ec4 <install_trans+0x4e>
    brelse(lbuf);
    80002eac:	854a                	mv	a0,s2
    80002eae:	a2eff0ef          	jal	800020dc <brelse>
    brelse(dbuf);
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	a28ff0ef          	jal	800020dc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002eb8:	2a05                	addiw	s4,s4,1
    80002eba:	0a91                	addi	s5,s5,4
    80002ebc:	02c9a783          	lw	a5,44(s3)
    80002ec0:	04fa5463          	bge	s4,a5,80002f08 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002ec4:	0189a583          	lw	a1,24(s3)
    80002ec8:	014585bb          	addw	a1,a1,s4
    80002ecc:	2585                	addiw	a1,a1,1
    80002ece:	0289a503          	lw	a0,40(s3)
    80002ed2:	902ff0ef          	jal	80001fd4 <bread>
    80002ed6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002ed8:	000aa583          	lw	a1,0(s5)
    80002edc:	0289a503          	lw	a0,40(s3)
    80002ee0:	8f4ff0ef          	jal	80001fd4 <bread>
    80002ee4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002ee6:	40000613          	li	a2,1024
    80002eea:	05890593          	addi	a1,s2,88
    80002eee:	05850513          	addi	a0,a0,88
    80002ef2:	ab8fd0ef          	jal	800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80002ef6:	8526                	mv	a0,s1
    80002ef8:	9b2ff0ef          	jal	800020aa <bwrite>
    if(recovering == 0)
    80002efc:	fa0b18e3          	bnez	s6,80002eac <install_trans+0x36>
      bunpin(dbuf);
    80002f00:	8526                	mv	a0,s1
    80002f02:	a96ff0ef          	jal	80002198 <bunpin>
    80002f06:	b75d                	j	80002eac <install_trans+0x36>
}
    80002f08:	70e2                	ld	ra,56(sp)
    80002f0a:	7442                	ld	s0,48(sp)
    80002f0c:	74a2                	ld	s1,40(sp)
    80002f0e:	7902                	ld	s2,32(sp)
    80002f10:	69e2                	ld	s3,24(sp)
    80002f12:	6a42                	ld	s4,16(sp)
    80002f14:	6aa2                	ld	s5,8(sp)
    80002f16:	6b02                	ld	s6,0(sp)
    80002f18:	6121                	addi	sp,sp,64
    80002f1a:	8082                	ret
    80002f1c:	8082                	ret

0000000080002f1e <initlog>:
{
    80002f1e:	7179                	addi	sp,sp,-48
    80002f20:	f406                	sd	ra,40(sp)
    80002f22:	f022                	sd	s0,32(sp)
    80002f24:	ec26                	sd	s1,24(sp)
    80002f26:	e84a                	sd	s2,16(sp)
    80002f28:	e44e                	sd	s3,8(sp)
    80002f2a:	1800                	addi	s0,sp,48
    80002f2c:	892a                	mv	s2,a0
    80002f2e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002f30:	00017497          	auipc	s1,0x17
    80002f34:	72048493          	addi	s1,s1,1824 # 8001a650 <log>
    80002f38:	00004597          	auipc	a1,0x4
    80002f3c:	6b058593          	addi	a1,a1,1712 # 800075e8 <etext+0x5e8>
    80002f40:	8526                	mv	a0,s1
    80002f42:	02f020ef          	jal	80005770 <initlock>
  log.start = sb->logstart;
    80002f46:	0149a583          	lw	a1,20(s3)
    80002f4a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002f4c:	0109a783          	lw	a5,16(s3)
    80002f50:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002f52:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002f56:	854a                	mv	a0,s2
    80002f58:	87cff0ef          	jal	80001fd4 <bread>
  log.lh.n = lh->n;
    80002f5c:	4d30                	lw	a2,88(a0)
    80002f5e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002f60:	00c05f63          	blez	a2,80002f7e <initlog+0x60>
    80002f64:	87aa                	mv	a5,a0
    80002f66:	00017717          	auipc	a4,0x17
    80002f6a:	71a70713          	addi	a4,a4,1818 # 8001a680 <log+0x30>
    80002f6e:	060a                	slli	a2,a2,0x2
    80002f70:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80002f72:	4ff4                	lw	a3,92(a5)
    80002f74:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002f76:	0791                	addi	a5,a5,4
    80002f78:	0711                	addi	a4,a4,4
    80002f7a:	fec79ce3          	bne	a5,a2,80002f72 <initlog+0x54>
  brelse(buf);
    80002f7e:	95eff0ef          	jal	800020dc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002f82:	4505                	li	a0,1
    80002f84:	ef3ff0ef          	jal	80002e76 <install_trans>
  log.lh.n = 0;
    80002f88:	00017797          	auipc	a5,0x17
    80002f8c:	6e07aa23          	sw	zero,1780(a5) # 8001a67c <log+0x2c>
  write_head(); // clear the log
    80002f90:	e89ff0ef          	jal	80002e18 <write_head>
}
    80002f94:	70a2                	ld	ra,40(sp)
    80002f96:	7402                	ld	s0,32(sp)
    80002f98:	64e2                	ld	s1,24(sp)
    80002f9a:	6942                	ld	s2,16(sp)
    80002f9c:	69a2                	ld	s3,8(sp)
    80002f9e:	6145                	addi	sp,sp,48
    80002fa0:	8082                	ret

0000000080002fa2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002fa2:	1101                	addi	sp,sp,-32
    80002fa4:	ec06                	sd	ra,24(sp)
    80002fa6:	e822                	sd	s0,16(sp)
    80002fa8:	e426                	sd	s1,8(sp)
    80002faa:	e04a                	sd	s2,0(sp)
    80002fac:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002fae:	00017517          	auipc	a0,0x17
    80002fb2:	6a250513          	addi	a0,a0,1698 # 8001a650 <log>
    80002fb6:	03b020ef          	jal	800057f0 <acquire>
  while(1){
    if(log.committing){
    80002fba:	00017497          	auipc	s1,0x17
    80002fbe:	69648493          	addi	s1,s1,1686 # 8001a650 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002fc2:	4979                	li	s2,30
    80002fc4:	a029                	j	80002fce <begin_op+0x2c>
      sleep(&log, &log.lock);
    80002fc6:	85a6                	mv	a1,s1
    80002fc8:	8526                	mv	a0,s1
    80002fca:	b72fe0ef          	jal	8000133c <sleep>
    if(log.committing){
    80002fce:	50dc                	lw	a5,36(s1)
    80002fd0:	fbfd                	bnez	a5,80002fc6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002fd2:	5098                	lw	a4,32(s1)
    80002fd4:	2705                	addiw	a4,a4,1
    80002fd6:	0027179b          	slliw	a5,a4,0x2
    80002fda:	9fb9                	addw	a5,a5,a4
    80002fdc:	0017979b          	slliw	a5,a5,0x1
    80002fe0:	54d4                	lw	a3,44(s1)
    80002fe2:	9fb5                	addw	a5,a5,a3
    80002fe4:	00f95763          	bge	s2,a5,80002ff2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80002fe8:	85a6                	mv	a1,s1
    80002fea:	8526                	mv	a0,s1
    80002fec:	b50fe0ef          	jal	8000133c <sleep>
    80002ff0:	bff9                	j	80002fce <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80002ff2:	00017517          	auipc	a0,0x17
    80002ff6:	65e50513          	addi	a0,a0,1630 # 8001a650 <log>
    80002ffa:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80002ffc:	08d020ef          	jal	80005888 <release>
      break;
    }
  }
}
    80003000:	60e2                	ld	ra,24(sp)
    80003002:	6442                	ld	s0,16(sp)
    80003004:	64a2                	ld	s1,8(sp)
    80003006:	6902                	ld	s2,0(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000300c:	7139                	addi	sp,sp,-64
    8000300e:	fc06                	sd	ra,56(sp)
    80003010:	f822                	sd	s0,48(sp)
    80003012:	f426                	sd	s1,40(sp)
    80003014:	f04a                	sd	s2,32(sp)
    80003016:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003018:	00017497          	auipc	s1,0x17
    8000301c:	63848493          	addi	s1,s1,1592 # 8001a650 <log>
    80003020:	8526                	mv	a0,s1
    80003022:	7ce020ef          	jal	800057f0 <acquire>
  log.outstanding -= 1;
    80003026:	509c                	lw	a5,32(s1)
    80003028:	37fd                	addiw	a5,a5,-1
    8000302a:	0007891b          	sext.w	s2,a5
    8000302e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003030:	50dc                	lw	a5,36(s1)
    80003032:	ef9d                	bnez	a5,80003070 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003034:	04091763          	bnez	s2,80003082 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003038:	00017497          	auipc	s1,0x17
    8000303c:	61848493          	addi	s1,s1,1560 # 8001a650 <log>
    80003040:	4785                	li	a5,1
    80003042:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003044:	8526                	mv	a0,s1
    80003046:	043020ef          	jal	80005888 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000304a:	54dc                	lw	a5,44(s1)
    8000304c:	04f04b63          	bgtz	a5,800030a2 <end_op+0x96>
    acquire(&log.lock);
    80003050:	00017497          	auipc	s1,0x17
    80003054:	60048493          	addi	s1,s1,1536 # 8001a650 <log>
    80003058:	8526                	mv	a0,s1
    8000305a:	796020ef          	jal	800057f0 <acquire>
    log.committing = 0;
    8000305e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003062:	8526                	mv	a0,s1
    80003064:	b24fe0ef          	jal	80001388 <wakeup>
    release(&log.lock);
    80003068:	8526                	mv	a0,s1
    8000306a:	01f020ef          	jal	80005888 <release>
}
    8000306e:	a025                	j	80003096 <end_op+0x8a>
    80003070:	ec4e                	sd	s3,24(sp)
    80003072:	e852                	sd	s4,16(sp)
    80003074:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003076:	00004517          	auipc	a0,0x4
    8000307a:	57a50513          	addi	a0,a0,1402 # 800075f0 <etext+0x5f0>
    8000307e:	444020ef          	jal	800054c2 <panic>
    wakeup(&log);
    80003082:	00017497          	auipc	s1,0x17
    80003086:	5ce48493          	addi	s1,s1,1486 # 8001a650 <log>
    8000308a:	8526                	mv	a0,s1
    8000308c:	afcfe0ef          	jal	80001388 <wakeup>
  release(&log.lock);
    80003090:	8526                	mv	a0,s1
    80003092:	7f6020ef          	jal	80005888 <release>
}
    80003096:	70e2                	ld	ra,56(sp)
    80003098:	7442                	ld	s0,48(sp)
    8000309a:	74a2                	ld	s1,40(sp)
    8000309c:	7902                	ld	s2,32(sp)
    8000309e:	6121                	addi	sp,sp,64
    800030a0:	8082                	ret
    800030a2:	ec4e                	sd	s3,24(sp)
    800030a4:	e852                	sd	s4,16(sp)
    800030a6:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800030a8:	00017a97          	auipc	s5,0x17
    800030ac:	5d8a8a93          	addi	s5,s5,1496 # 8001a680 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800030b0:	00017a17          	auipc	s4,0x17
    800030b4:	5a0a0a13          	addi	s4,s4,1440 # 8001a650 <log>
    800030b8:	018a2583          	lw	a1,24(s4)
    800030bc:	012585bb          	addw	a1,a1,s2
    800030c0:	2585                	addiw	a1,a1,1
    800030c2:	028a2503          	lw	a0,40(s4)
    800030c6:	f0ffe0ef          	jal	80001fd4 <bread>
    800030ca:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800030cc:	000aa583          	lw	a1,0(s5)
    800030d0:	028a2503          	lw	a0,40(s4)
    800030d4:	f01fe0ef          	jal	80001fd4 <bread>
    800030d8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800030da:	40000613          	li	a2,1024
    800030de:	05850593          	addi	a1,a0,88
    800030e2:	05848513          	addi	a0,s1,88
    800030e6:	8c4fd0ef          	jal	800001aa <memmove>
    bwrite(to);  // write the log
    800030ea:	8526                	mv	a0,s1
    800030ec:	fbffe0ef          	jal	800020aa <bwrite>
    brelse(from);
    800030f0:	854e                	mv	a0,s3
    800030f2:	febfe0ef          	jal	800020dc <brelse>
    brelse(to);
    800030f6:	8526                	mv	a0,s1
    800030f8:	fe5fe0ef          	jal	800020dc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800030fc:	2905                	addiw	s2,s2,1
    800030fe:	0a91                	addi	s5,s5,4
    80003100:	02ca2783          	lw	a5,44(s4)
    80003104:	faf94ae3          	blt	s2,a5,800030b8 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003108:	d11ff0ef          	jal	80002e18 <write_head>
    install_trans(0); // Now install writes to home locations
    8000310c:	4501                	li	a0,0
    8000310e:	d69ff0ef          	jal	80002e76 <install_trans>
    log.lh.n = 0;
    80003112:	00017797          	auipc	a5,0x17
    80003116:	5607a523          	sw	zero,1386(a5) # 8001a67c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000311a:	cffff0ef          	jal	80002e18 <write_head>
    8000311e:	69e2                	ld	s3,24(sp)
    80003120:	6a42                	ld	s4,16(sp)
    80003122:	6aa2                	ld	s5,8(sp)
    80003124:	b735                	j	80003050 <end_op+0x44>

0000000080003126 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003126:	1101                	addi	sp,sp,-32
    80003128:	ec06                	sd	ra,24(sp)
    8000312a:	e822                	sd	s0,16(sp)
    8000312c:	e426                	sd	s1,8(sp)
    8000312e:	e04a                	sd	s2,0(sp)
    80003130:	1000                	addi	s0,sp,32
    80003132:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003134:	00017917          	auipc	s2,0x17
    80003138:	51c90913          	addi	s2,s2,1308 # 8001a650 <log>
    8000313c:	854a                	mv	a0,s2
    8000313e:	6b2020ef          	jal	800057f0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003142:	02c92603          	lw	a2,44(s2)
    80003146:	47f5                	li	a5,29
    80003148:	06c7c363          	blt	a5,a2,800031ae <log_write+0x88>
    8000314c:	00017797          	auipc	a5,0x17
    80003150:	5207a783          	lw	a5,1312(a5) # 8001a66c <log+0x1c>
    80003154:	37fd                	addiw	a5,a5,-1
    80003156:	04f65c63          	bge	a2,a5,800031ae <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000315a:	00017797          	auipc	a5,0x17
    8000315e:	5167a783          	lw	a5,1302(a5) # 8001a670 <log+0x20>
    80003162:	04f05c63          	blez	a5,800031ba <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003166:	4781                	li	a5,0
    80003168:	04c05f63          	blez	a2,800031c6 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000316c:	44cc                	lw	a1,12(s1)
    8000316e:	00017717          	auipc	a4,0x17
    80003172:	51270713          	addi	a4,a4,1298 # 8001a680 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003176:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003178:	4314                	lw	a3,0(a4)
    8000317a:	04b68663          	beq	a3,a1,800031c6 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000317e:	2785                	addiw	a5,a5,1
    80003180:	0711                	addi	a4,a4,4
    80003182:	fef61be3          	bne	a2,a5,80003178 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003186:	0621                	addi	a2,a2,8
    80003188:	060a                	slli	a2,a2,0x2
    8000318a:	00017797          	auipc	a5,0x17
    8000318e:	4c678793          	addi	a5,a5,1222 # 8001a650 <log>
    80003192:	97b2                	add	a5,a5,a2
    80003194:	44d8                	lw	a4,12(s1)
    80003196:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003198:	8526                	mv	a0,s1
    8000319a:	fcbfe0ef          	jal	80002164 <bpin>
    log.lh.n++;
    8000319e:	00017717          	auipc	a4,0x17
    800031a2:	4b270713          	addi	a4,a4,1202 # 8001a650 <log>
    800031a6:	575c                	lw	a5,44(a4)
    800031a8:	2785                	addiw	a5,a5,1
    800031aa:	d75c                	sw	a5,44(a4)
    800031ac:	a80d                	j	800031de <log_write+0xb8>
    panic("too big a transaction");
    800031ae:	00004517          	auipc	a0,0x4
    800031b2:	45250513          	addi	a0,a0,1106 # 80007600 <etext+0x600>
    800031b6:	30c020ef          	jal	800054c2 <panic>
    panic("log_write outside of trans");
    800031ba:	00004517          	auipc	a0,0x4
    800031be:	45e50513          	addi	a0,a0,1118 # 80007618 <etext+0x618>
    800031c2:	300020ef          	jal	800054c2 <panic>
  log.lh.block[i] = b->blockno;
    800031c6:	00878693          	addi	a3,a5,8
    800031ca:	068a                	slli	a3,a3,0x2
    800031cc:	00017717          	auipc	a4,0x17
    800031d0:	48470713          	addi	a4,a4,1156 # 8001a650 <log>
    800031d4:	9736                	add	a4,a4,a3
    800031d6:	44d4                	lw	a3,12(s1)
    800031d8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800031da:	faf60fe3          	beq	a2,a5,80003198 <log_write+0x72>
  }
  release(&log.lock);
    800031de:	00017517          	auipc	a0,0x17
    800031e2:	47250513          	addi	a0,a0,1138 # 8001a650 <log>
    800031e6:	6a2020ef          	jal	80005888 <release>
}
    800031ea:	60e2                	ld	ra,24(sp)
    800031ec:	6442                	ld	s0,16(sp)
    800031ee:	64a2                	ld	s1,8(sp)
    800031f0:	6902                	ld	s2,0(sp)
    800031f2:	6105                	addi	sp,sp,32
    800031f4:	8082                	ret

00000000800031f6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800031f6:	1101                	addi	sp,sp,-32
    800031f8:	ec06                	sd	ra,24(sp)
    800031fa:	e822                	sd	s0,16(sp)
    800031fc:	e426                	sd	s1,8(sp)
    800031fe:	e04a                	sd	s2,0(sp)
    80003200:	1000                	addi	s0,sp,32
    80003202:	84aa                	mv	s1,a0
    80003204:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003206:	00004597          	auipc	a1,0x4
    8000320a:	43258593          	addi	a1,a1,1074 # 80007638 <etext+0x638>
    8000320e:	0521                	addi	a0,a0,8
    80003210:	560020ef          	jal	80005770 <initlock>
  lk->name = name;
    80003214:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003218:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000321c:	0204a423          	sw	zero,40(s1)
}
    80003220:	60e2                	ld	ra,24(sp)
    80003222:	6442                	ld	s0,16(sp)
    80003224:	64a2                	ld	s1,8(sp)
    80003226:	6902                	ld	s2,0(sp)
    80003228:	6105                	addi	sp,sp,32
    8000322a:	8082                	ret

000000008000322c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000322c:	1101                	addi	sp,sp,-32
    8000322e:	ec06                	sd	ra,24(sp)
    80003230:	e822                	sd	s0,16(sp)
    80003232:	e426                	sd	s1,8(sp)
    80003234:	e04a                	sd	s2,0(sp)
    80003236:	1000                	addi	s0,sp,32
    80003238:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000323a:	00850913          	addi	s2,a0,8
    8000323e:	854a                	mv	a0,s2
    80003240:	5b0020ef          	jal	800057f0 <acquire>
  while (lk->locked) {
    80003244:	409c                	lw	a5,0(s1)
    80003246:	c799                	beqz	a5,80003254 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003248:	85ca                	mv	a1,s2
    8000324a:	8526                	mv	a0,s1
    8000324c:	8f0fe0ef          	jal	8000133c <sleep>
  while (lk->locked) {
    80003250:	409c                	lw	a5,0(s1)
    80003252:	fbfd                	bnez	a5,80003248 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003254:	4785                	li	a5,1
    80003256:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003258:	b0ffd0ef          	jal	80000d66 <myproc>
    8000325c:	591c                	lw	a5,48(a0)
    8000325e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003260:	854a                	mv	a0,s2
    80003262:	626020ef          	jal	80005888 <release>
}
    80003266:	60e2                	ld	ra,24(sp)
    80003268:	6442                	ld	s0,16(sp)
    8000326a:	64a2                	ld	s1,8(sp)
    8000326c:	6902                	ld	s2,0(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret

0000000080003272 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	e04a                	sd	s2,0(sp)
    8000327c:	1000                	addi	s0,sp,32
    8000327e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003280:	00850913          	addi	s2,a0,8
    80003284:	854a                	mv	a0,s2
    80003286:	56a020ef          	jal	800057f0 <acquire>
  lk->locked = 0;
    8000328a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000328e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003292:	8526                	mv	a0,s1
    80003294:	8f4fe0ef          	jal	80001388 <wakeup>
  release(&lk->lk);
    80003298:	854a                	mv	a0,s2
    8000329a:	5ee020ef          	jal	80005888 <release>
}
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	64a2                	ld	s1,8(sp)
    800032a4:	6902                	ld	s2,0(sp)
    800032a6:	6105                	addi	sp,sp,32
    800032a8:	8082                	ret

00000000800032aa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800032aa:	7179                	addi	sp,sp,-48
    800032ac:	f406                	sd	ra,40(sp)
    800032ae:	f022                	sd	s0,32(sp)
    800032b0:	ec26                	sd	s1,24(sp)
    800032b2:	e84a                	sd	s2,16(sp)
    800032b4:	1800                	addi	s0,sp,48
    800032b6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800032b8:	00850913          	addi	s2,a0,8
    800032bc:	854a                	mv	a0,s2
    800032be:	532020ef          	jal	800057f0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800032c2:	409c                	lw	a5,0(s1)
    800032c4:	ef81                	bnez	a5,800032dc <holdingsleep+0x32>
    800032c6:	4481                	li	s1,0
  release(&lk->lk);
    800032c8:	854a                	mv	a0,s2
    800032ca:	5be020ef          	jal	80005888 <release>
  return r;
}
    800032ce:	8526                	mv	a0,s1
    800032d0:	70a2                	ld	ra,40(sp)
    800032d2:	7402                	ld	s0,32(sp)
    800032d4:	64e2                	ld	s1,24(sp)
    800032d6:	6942                	ld	s2,16(sp)
    800032d8:	6145                	addi	sp,sp,48
    800032da:	8082                	ret
    800032dc:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800032de:	0284a983          	lw	s3,40(s1)
    800032e2:	a85fd0ef          	jal	80000d66 <myproc>
    800032e6:	5904                	lw	s1,48(a0)
    800032e8:	413484b3          	sub	s1,s1,s3
    800032ec:	0014b493          	seqz	s1,s1
    800032f0:	69a2                	ld	s3,8(sp)
    800032f2:	bfd9                	j	800032c8 <holdingsleep+0x1e>

00000000800032f4 <fileinit>:
} ftable;

// initialize file table 
void
fileinit(void)
{
    800032f4:	1141                	addi	sp,sp,-16
    800032f6:	e406                	sd	ra,8(sp)
    800032f8:	e022                	sd	s0,0(sp)
    800032fa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable"); //Initialize spinlock lock for ftable to synchronize access to file table.
    800032fc:	00004597          	auipc	a1,0x4
    80003300:	34c58593          	addi	a1,a1,844 # 80007648 <etext+0x648>
    80003304:	00017517          	auipc	a0,0x17
    80003308:	49450513          	addi	a0,a0,1172 # 8001a798 <ftable>
    8000330c:	464020ef          	jal	80005770 <initlock>
}
    80003310:	60a2                	ld	ra,8(sp)
    80003312:	6402                	ld	s0,0(sp)
    80003314:	0141                	addi	sp,sp,16
    80003316:	8082                	ret

0000000080003318 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003318:	1101                	addi	sp,sp,-32
    8000331a:	ec06                	sd	ra,24(sp)
    8000331c:	e822                	sd	s0,16(sp)
    8000331e:	e426                	sd	s1,8(sp)
    80003320:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003322:	00017517          	auipc	a0,0x17
    80003326:	47650513          	addi	a0,a0,1142 # 8001a798 <ftable>
    8000332a:	4c6020ef          	jal	800057f0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000332e:	00017497          	auipc	s1,0x17
    80003332:	48248493          	addi	s1,s1,1154 # 8001a7b0 <ftable+0x18>
    80003336:	00018717          	auipc	a4,0x18
    8000333a:	41a70713          	addi	a4,a4,1050 # 8001b750 <disk>
    //find file structure that are not used
    if(f->ref == 0){
    8000333e:	40dc                	lw	a5,4(s1)
    80003340:	cf89                	beqz	a5,8000335a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003342:	02848493          	addi	s1,s1,40
    80003346:	fee49ce3          	bne	s1,a4,8000333e <filealloc+0x26>
      f->ref = 1; // mark that it has been used 
      release(&ftable.lock); // unlock
      return f;
    }
  }
  release(&ftable.lock); //unlock afer finding
    8000334a:	00017517          	auipc	a0,0x17
    8000334e:	44e50513          	addi	a0,a0,1102 # 8001a798 <ftable>
    80003352:	536020ef          	jal	80005888 <release>
  return 0;
    80003356:	4481                	li	s1,0
    80003358:	a809                	j	8000336a <filealloc+0x52>
      f->ref = 1; // mark that it has been used 
    8000335a:	4785                	li	a5,1
    8000335c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock); // unlock
    8000335e:	00017517          	auipc	a0,0x17
    80003362:	43a50513          	addi	a0,a0,1082 # 8001a798 <ftable>
    80003366:	522020ef          	jal	80005888 <release>
}
    8000336a:	8526                	mv	a0,s1
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret

0000000080003376 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003376:	1101                	addi	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	e426                	sd	s1,8(sp)
    8000337e:	1000                	addi	s0,sp,32
    80003380:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003382:	00017517          	auipc	a0,0x17
    80003386:	41650513          	addi	a0,a0,1046 # 8001a798 <ftable>
    8000338a:	466020ef          	jal	800057f0 <acquire>
  if(f->ref < 1)
    8000338e:	40dc                	lw	a5,4(s1)
    80003390:	02f05063          	blez	a5,800033b0 <filedup+0x3a>
    panic("filedup"); // panic cannot duplicate because it isnot used
  f->ref++; //duplicate
    80003394:	2785                	addiw	a5,a5,1
    80003396:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003398:	00017517          	auipc	a0,0x17
    8000339c:	40050513          	addi	a0,a0,1024 # 8001a798 <ftable>
    800033a0:	4e8020ef          	jal	80005888 <release>
  return f;
}
    800033a4:	8526                	mv	a0,s1
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	64a2                	ld	s1,8(sp)
    800033ac:	6105                	addi	sp,sp,32
    800033ae:	8082                	ret
    panic("filedup"); // panic cannot duplicate because it isnot used
    800033b0:	00004517          	auipc	a0,0x4
    800033b4:	2a050513          	addi	a0,a0,672 # 80007650 <etext+0x650>
    800033b8:	10a020ef          	jal	800054c2 <panic>

00000000800033bc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.) and release.
void
fileclose(struct file *f)
{
    800033bc:	7139                	addi	sp,sp,-64
    800033be:	fc06                	sd	ra,56(sp)
    800033c0:	f822                	sd	s0,48(sp)
    800033c2:	f426                	sd	s1,40(sp)
    800033c4:	0080                	addi	s0,sp,64
    800033c6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800033c8:	00017517          	auipc	a0,0x17
    800033cc:	3d050513          	addi	a0,a0,976 # 8001a798 <ftable>
    800033d0:	420020ef          	jal	800057f0 <acquire>
  if(f->ref < 1)
    800033d4:	40dc                	lw	a5,4(s1)
    800033d6:	04f05a63          	blez	a5,8000342a <fileclose+0x6e>
    panic("fileclose"); // panic cannot close because it is not used
  // release 1 duplicate
  if(--f->ref > 0){
    800033da:	37fd                	addiw	a5,a5,-1
    800033dc:	0007871b          	sext.w	a4,a5
    800033e0:	c0dc                	sw	a5,4(s1)
    800033e2:	04e04e63          	bgtz	a4,8000343e <fileclose+0x82>
    800033e6:	f04a                	sd	s2,32(sp)
    800033e8:	ec4e                	sd	s3,24(sp)
    800033ea:	e852                	sd	s4,16(sp)
    800033ec:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  //if ref = 0 close file.
  ff = *f;
    800033ee:	0004a903          	lw	s2,0(s1)
    800033f2:	0094ca83          	lbu	s5,9(s1)
    800033f6:	0104ba03          	ld	s4,16(s1)
    800033fa:	0184b983          	ld	s3,24(s1)
  //reset member
  f->ref = 0;
    800033fe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003402:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003406:	00017517          	auipc	a0,0x17
    8000340a:	39250513          	addi	a0,a0,914 # 8001a798 <ftable>
    8000340e:	47a020ef          	jal	80005888 <release>

  //close pipe if open pipe
  if(ff.type == FD_PIPE){
    80003412:	4785                	li	a5,1
    80003414:	04f90063          	beq	s2,a5,80003454 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003418:	3979                	addiw	s2,s2,-2
    8000341a:	4785                	li	a5,1
    8000341c:	0527f563          	bgeu	a5,s2,80003466 <fileclose+0xaa>
    80003420:	7902                	ld	s2,32(sp)
    80003422:	69e2                	ld	s3,24(sp)
    80003424:	6a42                	ld	s4,16(sp)
    80003426:	6aa2                	ld	s5,8(sp)
    80003428:	a00d                	j	8000344a <fileclose+0x8e>
    8000342a:	f04a                	sd	s2,32(sp)
    8000342c:	ec4e                	sd	s3,24(sp)
    8000342e:	e852                	sd	s4,16(sp)
    80003430:	e456                	sd	s5,8(sp)
    panic("fileclose"); // panic cannot close because it is not used
    80003432:	00004517          	auipc	a0,0x4
    80003436:	22650513          	addi	a0,a0,550 # 80007658 <etext+0x658>
    8000343a:	088020ef          	jal	800054c2 <panic>
    release(&ftable.lock);
    8000343e:	00017517          	auipc	a0,0x17
    80003442:	35a50513          	addi	a0,a0,858 # 8001a798 <ftable>
    80003446:	442020ef          	jal	80005888 <release>
    begin_op();
    iput(ff.ip); //release
    end_op();
  }
}
    8000344a:	70e2                	ld	ra,56(sp)
    8000344c:	7442                	ld	s0,48(sp)
    8000344e:	74a2                	ld	s1,40(sp)
    80003450:	6121                	addi	sp,sp,64
    80003452:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003454:	85d6                	mv	a1,s5
    80003456:	8552                	mv	a0,s4
    80003458:	336000ef          	jal	8000378e <pipeclose>
    8000345c:	7902                	ld	s2,32(sp)
    8000345e:	69e2                	ld	s3,24(sp)
    80003460:	6a42                	ld	s4,16(sp)
    80003462:	6aa2                	ld	s5,8(sp)
    80003464:	b7dd                	j	8000344a <fileclose+0x8e>
    begin_op();
    80003466:	b3dff0ef          	jal	80002fa2 <begin_op>
    iput(ff.ip); //release
    8000346a:	854e                	mv	a0,s3
    8000346c:	c22ff0ef          	jal	8000288e <iput>
    end_op();
    80003470:	b9dff0ef          	jal	8000300c <end_op>
    80003474:	7902                	ld	s2,32(sp)
    80003476:	69e2                	ld	s3,24(sp)
    80003478:	6a42                	ld	s4,16(sp)
    8000347a:	6aa2                	ld	s5,8(sp)
    8000347c:	b7f9                	j	8000344a <fileclose+0x8e>

000000008000347e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000347e:	715d                	addi	sp,sp,-80
    80003480:	e486                	sd	ra,72(sp)
    80003482:	e0a2                	sd	s0,64(sp)
    80003484:	fc26                	sd	s1,56(sp)
    80003486:	f44e                	sd	s3,40(sp)
    80003488:	0880                	addi	s0,sp,80
    8000348a:	84aa                	mv	s1,a0
    8000348c:	89ae                	mv	s3,a1
  struct proc *p = myproc(); //process structure
    8000348e:	8d9fd0ef          	jal	80000d66 <myproc>
  struct stat st; // static structure
  
  //get the metadata if the type is inode or device
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003492:	409c                	lw	a5,0(s1)
    80003494:	37f9                	addiw	a5,a5,-2
    80003496:	4705                	li	a4,1
    80003498:	04f76063          	bltu	a4,a5,800034d8 <filestat+0x5a>
    8000349c:	f84a                	sd	s2,48(sp)
    8000349e:	892a                	mv	s2,a0
    ilock(f->ip);
    800034a0:	6c88                	ld	a0,24(s1)
    800034a2:	a6aff0ef          	jal	8000270c <ilock>
    stati(f->ip, &st); //get the data
    800034a6:	fb840593          	addi	a1,s0,-72
    800034aa:	6c88                	ld	a0,24(s1)
    800034ac:	c8aff0ef          	jal	80002936 <stati>
    iunlock(f->ip);
    800034b0:	6c88                	ld	a0,24(s1)
    800034b2:	b08ff0ef          	jal	800027ba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0) //Copy the obtained data to the user's memory space
    800034b6:	46e1                	li	a3,24
    800034b8:	fb840613          	addi	a2,s0,-72
    800034bc:	85ce                	mv	a1,s3
    800034be:	05093503          	ld	a0,80(s2)
    800034c2:	d16fd0ef          	jal	800009d8 <copyout>
    800034c6:	41f5551b          	sraiw	a0,a0,0x1f
    800034ca:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800034cc:	60a6                	ld	ra,72(sp)
    800034ce:	6406                	ld	s0,64(sp)
    800034d0:	74e2                	ld	s1,56(sp)
    800034d2:	79a2                	ld	s3,40(sp)
    800034d4:	6161                	addi	sp,sp,80
    800034d6:	8082                	ret
  return -1;
    800034d8:	557d                	li	a0,-1
    800034da:	bfcd                	j	800034cc <filestat+0x4e>

00000000800034dc <fileread>:

// Read from file f and copy to address.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800034dc:	7179                	addi	sp,sp,-48
    800034de:	f406                	sd	ra,40(sp)
    800034e0:	f022                	sd	s0,32(sp)
    800034e2:	e84a                	sd	s2,16(sp)
    800034e4:	1800                	addi	s0,sp,48
  int r = 0;
  // check if file can be read or not
  if(f->readable == 0)
    800034e6:	00854783          	lbu	a5,8(a0)
    800034ea:	cfd1                	beqz	a5,80003586 <fileread+0xaa>
    800034ec:	ec26                	sd	s1,24(sp)
    800034ee:	e44e                	sd	s3,8(sp)
    800034f0:	84aa                	mv	s1,a0
    800034f2:	89ae                	mv	s3,a1
    800034f4:	8932                	mv	s2,a2
    return -1;

  //read pipe
  if(f->type == FD_PIPE){
    800034f6:	411c                	lw	a5,0(a0)
    800034f8:	4705                	li	a4,1
    800034fa:	04e78363          	beq	a5,a4,80003540 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  //read device
  } else if(f->type == FD_DEVICE){
    800034fe:	470d                	li	a4,3
    80003500:	04e78763          	beq	a5,a4,8000354e <fileread+0x72>
    //get the correct device to read from device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  //read inode  
  } else if(f->type == FD_INODE){
    80003504:	4709                	li	a4,2
    80003506:	06e79a63          	bne	a5,a4,8000357a <fileread+0x9e>
    ilock(f->ip);
    8000350a:	6d08                	ld	a0,24(a0)
    8000350c:	a00ff0ef          	jal	8000270c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003510:	874a                	mv	a4,s2
    80003512:	5094                	lw	a3,32(s1)
    80003514:	864e                	mv	a2,s3
    80003516:	4585                	li	a1,1
    80003518:	6c88                	ld	a0,24(s1)
    8000351a:	c46ff0ef          	jal	80002960 <readi>
    8000351e:	892a                	mv	s2,a0
    80003520:	00a05563          	blez	a0,8000352a <fileread+0x4e>
      f->off += r;
    80003524:	509c                	lw	a5,32(s1)
    80003526:	9fa9                	addw	a5,a5,a0
    80003528:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000352a:	6c88                	ld	a0,24(s1)
    8000352c:	a8eff0ef          	jal	800027ba <iunlock>
    80003530:	64e2                	ld	s1,24(sp)
    80003532:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003534:	854a                	mv	a0,s2
    80003536:	70a2                	ld	ra,40(sp)
    80003538:	7402                	ld	s0,32(sp)
    8000353a:	6942                	ld	s2,16(sp)
    8000353c:	6145                	addi	sp,sp,48
    8000353e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003540:	6908                	ld	a0,16(a0)
    80003542:	388000ef          	jal	800038ca <piperead>
    80003546:	892a                	mv	s2,a0
    80003548:	64e2                	ld	s1,24(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	b7e5                	j	80003534 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000354e:	02451783          	lh	a5,36(a0)
    80003552:	03079693          	slli	a3,a5,0x30
    80003556:	92c1                	srli	a3,a3,0x30
    80003558:	4725                	li	a4,9
    8000355a:	02d76863          	bltu	a4,a3,8000358a <fileread+0xae>
    8000355e:	0792                	slli	a5,a5,0x4
    80003560:	00017717          	auipc	a4,0x17
    80003564:	19870713          	addi	a4,a4,408 # 8001a6f8 <devsw>
    80003568:	97ba                	add	a5,a5,a4
    8000356a:	639c                	ld	a5,0(a5)
    8000356c:	c39d                	beqz	a5,80003592 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000356e:	4505                	li	a0,1
    80003570:	9782                	jalr	a5
    80003572:	892a                	mv	s2,a0
    80003574:	64e2                	ld	s1,24(sp)
    80003576:	69a2                	ld	s3,8(sp)
    80003578:	bf75                	j	80003534 <fileread+0x58>
    panic("fileread");
    8000357a:	00004517          	auipc	a0,0x4
    8000357e:	0ee50513          	addi	a0,a0,238 # 80007668 <etext+0x668>
    80003582:	741010ef          	jal	800054c2 <panic>
    return -1;
    80003586:	597d                	li	s2,-1
    80003588:	b775                	j	80003534 <fileread+0x58>
      return -1;
    8000358a:	597d                	li	s2,-1
    8000358c:	64e2                	ld	s1,24(sp)
    8000358e:	69a2                	ld	s3,8(sp)
    80003590:	b755                	j	80003534 <fileread+0x58>
    80003592:	597d                	li	s2,-1
    80003594:	64e2                	ld	s1,24(sp)
    80003596:	69a2                	ld	s3,8(sp)
    80003598:	bf71                	j	80003534 <fileread+0x58>

000000008000359a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;
  //check if the file can be writen or not
  if(f->writable == 0)
    8000359a:	00954783          	lbu	a5,9(a0)
    8000359e:	10078b63          	beqz	a5,800036b4 <filewrite+0x11a>
{
    800035a2:	715d                	addi	sp,sp,-80
    800035a4:	e486                	sd	ra,72(sp)
    800035a6:	e0a2                	sd	s0,64(sp)
    800035a8:	f84a                	sd	s2,48(sp)
    800035aa:	f052                	sd	s4,32(sp)
    800035ac:	e85a                	sd	s6,16(sp)
    800035ae:	0880                	addi	s0,sp,80
    800035b0:	892a                	mv	s2,a0
    800035b2:	8b2e                	mv	s6,a1
    800035b4:	8a32                	mv	s4,a2
    return -1;

  //write to pipe
  if(f->type == FD_PIPE){
    800035b6:	411c                	lw	a5,0(a0)
    800035b8:	4705                	li	a4,1
    800035ba:	02e78763          	beq	a5,a4,800035e8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800035be:	470d                	li	a4,3
    800035c0:	02e78863          	beq	a5,a4,800035f0 <filewrite+0x56>
    //find the correct device from the device switch table
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800035c4:	4709                	li	a4,2
    800035c6:	0ce79c63          	bne	a5,a4,8000369e <filewrite+0x104>
    800035ca:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800035cc:	0ac05863          	blez	a2,8000367c <filewrite+0xe2>
    800035d0:	fc26                	sd	s1,56(sp)
    800035d2:	ec56                	sd	s5,24(sp)
    800035d4:	e45e                	sd	s7,8(sp)
    800035d6:	e062                	sd	s8,0(sp)
    int i = 0;
    800035d8:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800035da:	6b85                	lui	s7,0x1
    800035dc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800035e0:	6c05                	lui	s8,0x1
    800035e2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800035e6:	a8b5                	j	80003662 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800035e8:	6908                	ld	a0,16(a0)
    800035ea:	1fc000ef          	jal	800037e6 <pipewrite>
    800035ee:	a04d                	j	80003690 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800035f0:	02451783          	lh	a5,36(a0)
    800035f4:	03079693          	slli	a3,a5,0x30
    800035f8:	92c1                	srli	a3,a3,0x30
    800035fa:	4725                	li	a4,9
    800035fc:	0ad76e63          	bltu	a4,a3,800036b8 <filewrite+0x11e>
    80003600:	0792                	slli	a5,a5,0x4
    80003602:	00017717          	auipc	a4,0x17
    80003606:	0f670713          	addi	a4,a4,246 # 8001a6f8 <devsw>
    8000360a:	97ba                	add	a5,a5,a4
    8000360c:	679c                	ld	a5,8(a5)
    8000360e:	c7dd                	beqz	a5,800036bc <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80003610:	4505                	li	a0,1
    80003612:	9782                	jalr	a5
    80003614:	a8b5                	j	80003690 <filewrite+0xf6>
      if(n1 > max)
    80003616:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000361a:	989ff0ef          	jal	80002fa2 <begin_op>
      ilock(f->ip);
    8000361e:	01893503          	ld	a0,24(s2)
    80003622:	8eaff0ef          	jal	8000270c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003626:	8756                	mv	a4,s5
    80003628:	02092683          	lw	a3,32(s2)
    8000362c:	01698633          	add	a2,s3,s6
    80003630:	4585                	li	a1,1
    80003632:	01893503          	ld	a0,24(s2)
    80003636:	c26ff0ef          	jal	80002a5c <writei>
    8000363a:	84aa                	mv	s1,a0
    8000363c:	00a05763          	blez	a0,8000364a <filewrite+0xb0>
        f->off += r;
    80003640:	02092783          	lw	a5,32(s2)
    80003644:	9fa9                	addw	a5,a5,a0
    80003646:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000364a:	01893503          	ld	a0,24(s2)
    8000364e:	96cff0ef          	jal	800027ba <iunlock>
      end_op();
    80003652:	9bbff0ef          	jal	8000300c <end_op>

      if(r != n1){
    80003656:	029a9563          	bne	s5,s1,80003680 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000365a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000365e:	0149da63          	bge	s3,s4,80003672 <filewrite+0xd8>
      int n1 = n - i;
    80003662:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003666:	0004879b          	sext.w	a5,s1
    8000366a:	fafbd6e3          	bge	s7,a5,80003616 <filewrite+0x7c>
    8000366e:	84e2                	mv	s1,s8
    80003670:	b75d                	j	80003616 <filewrite+0x7c>
    80003672:	74e2                	ld	s1,56(sp)
    80003674:	6ae2                	ld	s5,24(sp)
    80003676:	6ba2                	ld	s7,8(sp)
    80003678:	6c02                	ld	s8,0(sp)
    8000367a:	a039                	j	80003688 <filewrite+0xee>
    int i = 0;
    8000367c:	4981                	li	s3,0
    8000367e:	a029                	j	80003688 <filewrite+0xee>
    80003680:	74e2                	ld	s1,56(sp)
    80003682:	6ae2                	ld	s5,24(sp)
    80003684:	6ba2                	ld	s7,8(sp)
    80003686:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003688:	033a1c63          	bne	s4,s3,800036c0 <filewrite+0x126>
    8000368c:	8552                	mv	a0,s4
    8000368e:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003690:	60a6                	ld	ra,72(sp)
    80003692:	6406                	ld	s0,64(sp)
    80003694:	7942                	ld	s2,48(sp)
    80003696:	7a02                	ld	s4,32(sp)
    80003698:	6b42                	ld	s6,16(sp)
    8000369a:	6161                	addi	sp,sp,80
    8000369c:	8082                	ret
    8000369e:	fc26                	sd	s1,56(sp)
    800036a0:	f44e                	sd	s3,40(sp)
    800036a2:	ec56                	sd	s5,24(sp)
    800036a4:	e45e                	sd	s7,8(sp)
    800036a6:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800036a8:	00004517          	auipc	a0,0x4
    800036ac:	fd050513          	addi	a0,a0,-48 # 80007678 <etext+0x678>
    800036b0:	613010ef          	jal	800054c2 <panic>
    return -1;
    800036b4:	557d                	li	a0,-1
}
    800036b6:	8082                	ret
      return -1;
    800036b8:	557d                	li	a0,-1
    800036ba:	bfd9                	j	80003690 <filewrite+0xf6>
    800036bc:	557d                	li	a0,-1
    800036be:	bfc9                	j	80003690 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800036c0:	557d                	li	a0,-1
    800036c2:	79a2                	ld	s3,40(sp)
    800036c4:	b7f1                	j	80003690 <filewrite+0xf6>

00000000800036c6 <pipealloc>:
};

//nitializes a pipe, and returns two file descriptors: one for read and one for write 
int
pipealloc(struct file **f0, struct file **f1)
{
    800036c6:	7179                	addi	sp,sp,-48
    800036c8:	f406                	sd	ra,40(sp)
    800036ca:	f022                	sd	s0,32(sp)
    800036cc:	ec26                	sd	s1,24(sp)
    800036ce:	e052                	sd	s4,0(sp)
    800036d0:	1800                	addi	s0,sp,48
    800036d2:	84aa                	mv	s1,a0
    800036d4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  //initialize file descriptors
  pi = 0;
  *f0 = *f1 = 0;
    800036d6:	0005b023          	sd	zero,0(a1)
    800036da:	00053023          	sd	zero,0(a0)
  //allocate descriptors
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800036de:	c3bff0ef          	jal	80003318 <filealloc>
    800036e2:	e088                	sd	a0,0(s1)
    800036e4:	c549                	beqz	a0,8000376e <pipealloc+0xa8>
    800036e6:	c33ff0ef          	jal	80003318 <filealloc>
    800036ea:	00aa3023          	sd	a0,0(s4)
    800036ee:	cd25                	beqz	a0,80003766 <pipealloc+0xa0>
    800036f0:	e84a                	sd	s2,16(sp)
    goto bad;
  //allocate for pipe
  if((pi = (struct pipe*)kalloc()) == 0)
    800036f2:	a0dfc0ef          	jal	800000fe <kalloc>
    800036f6:	892a                	mv	s2,a0
    800036f8:	c12d                	beqz	a0,8000375a <pipealloc+0x94>
    800036fa:	e44e                	sd	s3,8(sp)
    goto bad;
  //set up values
  pi->readopen = 1;
    800036fc:	4985                	li	s3,1
    800036fe:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003702:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003706:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000370a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe"); // init lock
    8000370e:	00004597          	auipc	a1,0x4
    80003712:	cf258593          	addi	a1,a1,-782 # 80007400 <etext+0x400>
    80003716:	05a020ef          	jal	80005770 <initlock>
  //set up values and link file with pipe
  (*f0)->type = FD_PIPE;
    8000371a:	609c                	ld	a5,0(s1)
    8000371c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003720:	609c                	ld	a5,0(s1)
    80003722:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003726:	609c                	ld	a5,0(s1)
    80003728:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000372c:	609c                	ld	a5,0(s1)
    8000372e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003732:	000a3783          	ld	a5,0(s4)
    80003736:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000373a:	000a3783          	ld	a5,0(s4)
    8000373e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003742:	000a3783          	ld	a5,0(s4)
    80003746:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000374a:	000a3783          	ld	a5,0(s4)
    8000374e:	0127b823          	sd	s2,16(a5)
  return 0;
    80003752:	4501                	li	a0,0
    80003754:	6942                	ld	s2,16(sp)
    80003756:	69a2                	ld	s3,8(sp)
    80003758:	a01d                	j	8000377e <pipealloc+0xb8>

//exception
 bad:
  if(pi)
    kfree((char*)pi); //deallocate pipe
  if(*f0)
    8000375a:	6088                	ld	a0,0(s1)
    8000375c:	c119                	beqz	a0,80003762 <pipealloc+0x9c>
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	a029                	j	8000376a <pipealloc+0xa4>
    80003762:	6942                	ld	s2,16(sp)
    80003764:	a029                	j	8000376e <pipealloc+0xa8>
    80003766:	6088                	ld	a0,0(s1)
    80003768:	c10d                	beqz	a0,8000378a <pipealloc+0xc4>
    fileclose(*f0); //close file and release
    8000376a:	c53ff0ef          	jal	800033bc <fileclose>
  if(*f1)
    8000376e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003772:	557d                	li	a0,-1
  if(*f1)
    80003774:	c789                	beqz	a5,8000377e <pipealloc+0xb8>
    fileclose(*f1);
    80003776:	853e                	mv	a0,a5
    80003778:	c45ff0ef          	jal	800033bc <fileclose>
  return -1;
    8000377c:	557d                	li	a0,-1
}
    8000377e:	70a2                	ld	ra,40(sp)
    80003780:	7402                	ld	s0,32(sp)
    80003782:	64e2                	ld	s1,24(sp)
    80003784:	6a02                	ld	s4,0(sp)
    80003786:	6145                	addi	sp,sp,48
    80003788:	8082                	ret
  return -1;
    8000378a:	557d                	li	a0,-1
    8000378c:	bfcd                	j	8000377e <pipealloc+0xb8>

000000008000378e <pipeclose>:
//Close one end of the pipe (read or write). If both ends are closed, release the pipe's memory.
// writable = 1 => writable = 0
// writable = 0 => readable = 0
void
pipeclose(struct pipe *pi, int writable)
{
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	e04a                	sd	s2,0(sp)
    80003798:	1000                	addi	s0,sp,32
    8000379a:	84aa                	mv	s1,a0
    8000379c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000379e:	052020ef          	jal	800057f0 <acquire>
  if(writable){
    800037a2:	02090763          	beqz	s2,800037d0 <pipeclose+0x42>
    pi->writeopen = 0;
    800037a6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread); // wake the reader up when the writer close
    800037aa:	21848513          	addi	a0,s1,536
    800037ae:	bdbfd0ef          	jal	80001388 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite); // wake the write up when the reader close
  }
  // if all are close, release the memory
  if(pi->readopen == 0 && pi->writeopen == 0){
    800037b2:	2204b783          	ld	a5,544(s1)
    800037b6:	e785                	bnez	a5,800037de <pipeclose+0x50>
    release(&pi->lock); // release lock
    800037b8:	8526                	mv	a0,s1
    800037ba:	0ce020ef          	jal	80005888 <release>
    kfree((char*)pi); // deallocate
    800037be:	8526                	mv	a0,s1
    800037c0:	85dfc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    800037c4:	60e2                	ld	ra,24(sp)
    800037c6:	6442                	ld	s0,16(sp)
    800037c8:	64a2                	ld	s1,8(sp)
    800037ca:	6902                	ld	s2,0(sp)
    800037cc:	6105                	addi	sp,sp,32
    800037ce:	8082                	ret
    pi->readopen = 0;
    800037d0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite); // wake the write up when the reader close
    800037d4:	21c48513          	addi	a0,s1,540
    800037d8:	bb1fd0ef          	jal	80001388 <wakeup>
    800037dc:	bfd9                	j	800037b2 <pipeclose+0x24>
    release(&pi->lock);
    800037de:	8526                	mv	a0,s1
    800037e0:	0a8020ef          	jal	80005888 <release>
}
    800037e4:	b7c5                	j	800037c4 <pipeclose+0x36>

00000000800037e6 <pipewrite>:

//Writes data from the process's memory to the pipe.
int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800037e6:	711d                	addi	sp,sp,-96
    800037e8:	ec86                	sd	ra,88(sp)
    800037ea:	e8a2                	sd	s0,80(sp)
    800037ec:	e4a6                	sd	s1,72(sp)
    800037ee:	e0ca                	sd	s2,64(sp)
    800037f0:	fc4e                	sd	s3,56(sp)
    800037f2:	f852                	sd	s4,48(sp)
    800037f4:	f456                	sd	s5,40(sp)
    800037f6:	1080                	addi	s0,sp,96
    800037f8:	84aa                	mv	s1,a0
    800037fa:	8aae                	mv	s5,a1
    800037fc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800037fe:	d68fd0ef          	jal	80000d66 <myproc>
    80003802:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003804:	8526                	mv	a0,s1
    80003806:	7eb010ef          	jal	800057f0 <acquire>
  while(i < n){
    8000380a:	0b405a63          	blez	s4,800038be <pipewrite+0xd8>
    8000380e:	f05a                	sd	s6,32(sp)
    80003810:	ec5e                	sd	s7,24(sp)
    80003812:	e862                	sd	s8,16(sp)
  int i = 0;
    80003814:	4901                	li	s2,0
      wakeup(&pi->nread); //wake up reader
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    } else {
      char ch;
      //read each byte from the process's memory (copyin) and write to the pipe's circular buffer
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003816:	5b7d                	li	s6,-1
      wakeup(&pi->nread); //wake up reader
    80003818:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    8000381c:	21c48b93          	addi	s7,s1,540
    80003820:	a81d                	j	80003856 <pipewrite+0x70>
      release(&pi->lock);
    80003822:	8526                	mv	a0,s1
    80003824:	064020ef          	jal	80005888 <release>
      return -1;
    80003828:	597d                	li	s2,-1
    8000382a:	7b02                	ld	s6,32(sp)
    8000382c:	6be2                	ld	s7,24(sp)
    8000382e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003830:	854a                	mv	a0,s2
    80003832:	60e6                	ld	ra,88(sp)
    80003834:	6446                	ld	s0,80(sp)
    80003836:	64a6                	ld	s1,72(sp)
    80003838:	6906                	ld	s2,64(sp)
    8000383a:	79e2                	ld	s3,56(sp)
    8000383c:	7a42                	ld	s4,48(sp)
    8000383e:	7aa2                	ld	s5,40(sp)
    80003840:	6125                	addi	sp,sp,96
    80003842:	8082                	ret
      wakeup(&pi->nread); //wake up reader
    80003844:	8562                	mv	a0,s8
    80003846:	b43fd0ef          	jal	80001388 <wakeup>
      sleep(&pi->nwrite, &pi->lock); //sleep writer waiting
    8000384a:	85a6                	mv	a1,s1
    8000384c:	855e                	mv	a0,s7
    8000384e:	aeffd0ef          	jal	8000133c <sleep>
  while(i < n){
    80003852:	05495b63          	bge	s2,s4,800038a8 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003856:	2204a783          	lw	a5,544(s1)
    8000385a:	d7e1                	beqz	a5,80003822 <pipewrite+0x3c>
    8000385c:	854e                	mv	a0,s3
    8000385e:	d17fd0ef          	jal	80001574 <killed>
    80003862:	f161                	bnez	a0,80003822 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full cannot write more
    80003864:	2184a783          	lw	a5,536(s1)
    80003868:	21c4a703          	lw	a4,540(s1)
    8000386c:	2007879b          	addiw	a5,a5,512
    80003870:	fcf70ae3          	beq	a4,a5,80003844 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003874:	4685                	li	a3,1
    80003876:	01590633          	add	a2,s2,s5
    8000387a:	faf40593          	addi	a1,s0,-81
    8000387e:	0509b503          	ld	a0,80(s3)
    80003882:	a2cfd0ef          	jal	80000aae <copyin>
    80003886:	03650e63          	beq	a0,s6,800038c2 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000388a:	21c4a783          	lw	a5,540(s1)
    8000388e:	0017871b          	addiw	a4,a5,1
    80003892:	20e4ae23          	sw	a4,540(s1)
    80003896:	1ff7f793          	andi	a5,a5,511
    8000389a:	97a6                	add	a5,a5,s1
    8000389c:	faf44703          	lbu	a4,-81(s0)
    800038a0:	00e78c23          	sb	a4,24(a5)
      i++;
    800038a4:	2905                	addiw	s2,s2,1
    800038a6:	b775                	j	80003852 <pipewrite+0x6c>
    800038a8:	7b02                	ld	s6,32(sp)
    800038aa:	6be2                	ld	s7,24(sp)
    800038ac:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800038ae:	21848513          	addi	a0,s1,536
    800038b2:	ad7fd0ef          	jal	80001388 <wakeup>
  release(&pi->lock);
    800038b6:	8526                	mv	a0,s1
    800038b8:	7d1010ef          	jal	80005888 <release>
  return i;
    800038bc:	bf95                	j	80003830 <pipewrite+0x4a>
  int i = 0;
    800038be:	4901                	li	s2,0
    800038c0:	b7fd                	j	800038ae <pipewrite+0xc8>
    800038c2:	7b02                	ld	s6,32(sp)
    800038c4:	6be2                	ld	s7,24(sp)
    800038c6:	6c42                	ld	s8,16(sp)
    800038c8:	b7dd                	j	800038ae <pipewrite+0xc8>

00000000800038ca <piperead>:

//Read data from the pipe into the process's memory.
int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800038ca:	715d                	addi	sp,sp,-80
    800038cc:	e486                	sd	ra,72(sp)
    800038ce:	e0a2                	sd	s0,64(sp)
    800038d0:	fc26                	sd	s1,56(sp)
    800038d2:	f84a                	sd	s2,48(sp)
    800038d4:	f44e                	sd	s3,40(sp)
    800038d6:	f052                	sd	s4,32(sp)
    800038d8:	ec56                	sd	s5,24(sp)
    800038da:	0880                	addi	s0,sp,80
    800038dc:	84aa                	mv	s1,a0
    800038de:	892e                	mv	s2,a1
    800038e0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800038e2:	c84fd0ef          	jal	80000d66 <myproc>
    800038e6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800038e8:	8526                	mv	a0,s1
    800038ea:	707010ef          	jal	800057f0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038ee:	2184a703          	lw	a4,536(s1)
    800038f2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    //waiting
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800038f6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    800038fa:	02f71563          	bne	a4,a5,80003924 <piperead+0x5a>
    800038fe:	2244a783          	lw	a5,548(s1)
    80003902:	cb85                	beqz	a5,80003932 <piperead+0x68>
    if(killed(pr)){
    80003904:	8552                	mv	a0,s4
    80003906:	c6ffd0ef          	jal	80001574 <killed>
    8000390a:	ed19                	bnez	a0,80003928 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000390c:	85a6                	mv	a1,s1
    8000390e:	854e                	mv	a0,s3
    80003910:	a2dfd0ef          	jal	8000133c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty check if pipe is empty
    80003914:	2184a703          	lw	a4,536(s1)
    80003918:	21c4a783          	lw	a5,540(s1)
    8000391c:	fef701e3          	beq	a4,a5,800038fe <piperead+0x34>
    80003920:	e85a                	sd	s6,16(sp)
    80003922:	a809                	j	80003934 <piperead+0x6a>
    80003924:	e85a                	sd	s6,16(sp)
    80003926:	a039                	j	80003934 <piperead+0x6a>
      release(&pi->lock);
    80003928:	8526                	mv	a0,s1
    8000392a:	75f010ef          	jal	80005888 <release>
      return -1;
    8000392e:	59fd                	li	s3,-1
    80003930:	a8b1                	j	8000398c <piperead+0xc2>
    80003932:	e85a                	sd	s6,16(sp)
  }
  //Read each byte from the pipe's circular buffer and write it to the process's memory (copyout).
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003934:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    //increasing nread after reading
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003936:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003938:	05505263          	blez	s5,8000397c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000393c:	2184a783          	lw	a5,536(s1)
    80003940:	21c4a703          	lw	a4,540(s1)
    80003944:	02f70c63          	beq	a4,a5,8000397c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003948:	0017871b          	addiw	a4,a5,1
    8000394c:	20e4ac23          	sw	a4,536(s1)
    80003950:	1ff7f793          	andi	a5,a5,511
    80003954:	97a6                	add	a5,a5,s1
    80003956:	0187c783          	lbu	a5,24(a5)
    8000395a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000395e:	4685                	li	a3,1
    80003960:	fbf40613          	addi	a2,s0,-65
    80003964:	85ca                	mv	a1,s2
    80003966:	050a3503          	ld	a0,80(s4)
    8000396a:	86efd0ef          	jal	800009d8 <copyout>
    8000396e:	01650763          	beq	a0,s6,8000397c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003972:	2985                	addiw	s3,s3,1
    80003974:	0905                	addi	s2,s2,1
    80003976:	fd3a93e3          	bne	s5,s3,8000393c <piperead+0x72>
    8000397a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000397c:	21c48513          	addi	a0,s1,540
    80003980:	a09fd0ef          	jal	80001388 <wakeup>
  release(&pi->lock);
    80003984:	8526                	mv	a0,s1
    80003986:	703010ef          	jal	80005888 <release>
    8000398a:	6b42                	ld	s6,16(sp)
  return i;
}
    8000398c:	854e                	mv	a0,s3
    8000398e:	60a6                	ld	ra,72(sp)
    80003990:	6406                	ld	s0,64(sp)
    80003992:	74e2                	ld	s1,56(sp)
    80003994:	7942                	ld	s2,48(sp)
    80003996:	79a2                	ld	s3,40(sp)
    80003998:	7a02                	ld	s4,32(sp)
    8000399a:	6ae2                	ld	s5,24(sp)
    8000399c:	6161                	addi	sp,sp,80
    8000399e:	8082                	ret

00000000800039a0 <flags2perm>:
//Load file contents into memory
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

//convert ELF flag into type of access  
int flags2perm(int flags)
{
    800039a0:	1141                	addi	sp,sp,-16
    800039a2:	e422                	sd	s0,8(sp)
    800039a4:	0800                	addi	s0,sp,16
    800039a6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800039a8:	8905                	andi	a0,a0,1
    800039aa:	050e                	slli	a0,a0,0x3
      perm = PTE_X; //execute access
    if(flags & 0x2)
    800039ac:	8b89                	andi	a5,a5,2
    800039ae:	c399                	beqz	a5,800039b4 <flags2perm+0x14>
      perm |= PTE_W; //write access
    800039b0:	00456513          	ori	a0,a0,4
    return perm;
}
    800039b4:	6422                	ld	s0,8(sp)
    800039b6:	0141                	addi	sp,sp,16
    800039b8:	8082                	ret

00000000800039ba <exec>:

//execute file
int
exec(char *path, char **argv)
{
    800039ba:	df010113          	addi	sp,sp,-528
    800039be:	20113423          	sd	ra,520(sp)
    800039c2:	20813023          	sd	s0,512(sp)
    800039c6:	ffa6                	sd	s1,504(sp)
    800039c8:	fbca                	sd	s2,496(sp)
    800039ca:	0c00                	addi	s0,sp,528
    800039cc:	892a                	mv	s2,a0
    800039ce:	dea43c23          	sd	a0,-520(s0)
    800039d2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800039d6:	b90fd0ef          	jal	80000d66 <myproc>
    800039da:	84aa                	mv	s1,a0

// open execute file
  begin_op(); //begin a transaction of file system
    800039dc:	dc6ff0ef          	jal	80002fa2 <begin_op>

  if((ip = namei(path)) == 0){ //find inode 
    800039e0:	854a                	mv	a0,s2
    800039e2:	c04ff0ef          	jal	80002de6 <namei>
    800039e6:	c931                	beqz	a0,80003a3a <exec+0x80>
    800039e8:	f3d2                	sd	s4,480(sp)
    800039ea:	8a2a                	mv	s4,a0
    end_op(); // end transaction
    return -1;
  }
  ilock(ip); //lock inode to make sure that inode can not be modified during executing
    800039ec:	d21fe0ef          	jal	8000270c <ilock>

  //read and check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) //read
    800039f0:	04000713          	li	a4,64
    800039f4:	4681                	li	a3,0
    800039f6:	e5040613          	addi	a2,s0,-432
    800039fa:	4581                	li	a1,0
    800039fc:	8552                	mv	a0,s4
    800039fe:	f63fe0ef          	jal	80002960 <readi>
    80003a02:	04000793          	li	a5,64
    80003a06:	00f51a63          	bne	a0,a5,80003a1a <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC) //check
    80003a0a:	e5042703          	lw	a4,-432(s0)
    80003a0e:	464c47b7          	lui	a5,0x464c4
    80003a12:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003a16:	02f70663          	beq	a4,a5,80003a42 <exec+0x88>
//handle the unvalid
 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003a1a:	8552                	mv	a0,s4
    80003a1c:	efbfe0ef          	jal	80002916 <iunlockput>
    end_op();
    80003a20:	decff0ef          	jal	8000300c <end_op>
  }
  return -1;
    80003a24:	557d                	li	a0,-1
    80003a26:	7a1e                	ld	s4,480(sp)
}
    80003a28:	20813083          	ld	ra,520(sp)
    80003a2c:	20013403          	ld	s0,512(sp)
    80003a30:	74fe                	ld	s1,504(sp)
    80003a32:	795e                	ld	s2,496(sp)
    80003a34:	21010113          	addi	sp,sp,528
    80003a38:	8082                	ret
    end_op(); // end transaction
    80003a3a:	dd2ff0ef          	jal	8000300c <end_op>
    return -1;
    80003a3e:	557d                	li	a0,-1
    80003a40:	b7e5                	j	80003a28 <exec+0x6e>
    80003a42:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0) //create new pagetable for executing
    80003a44:	8526                	mv	a0,s1
    80003a46:	bc8fd0ef          	jal	80000e0e <proc_pagetable>
    80003a4a:	8b2a                	mv	s6,a0
    80003a4c:	2c050b63          	beqz	a0,80003d22 <exec+0x368>
    80003a50:	f7ce                	sd	s3,488(sp)
    80003a52:	efd6                	sd	s5,472(sp)
    80003a54:	e7de                	sd	s7,456(sp)
    80003a56:	e3e2                	sd	s8,448(sp)
    80003a58:	ff66                	sd	s9,440(sp)
    80003a5a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a5c:	e7042d03          	lw	s10,-400(s0)
    80003a60:	e8845783          	lhu	a5,-376(s0)
    80003a64:	12078963          	beqz	a5,80003b96 <exec+0x1dc>
    80003a68:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003a6a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003a6c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003a6e:	6c85                	lui	s9,0x1
    80003a70:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003a74:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003a78:	6a85                	lui	s5,0x1
    80003a7a:	a085                	j	80003ada <exec+0x120>
      panic("loadseg: address should exist");
    80003a7c:	00004517          	auipc	a0,0x4
    80003a80:	c0c50513          	addi	a0,a0,-1012 # 80007688 <etext+0x688>
    80003a84:	23f010ef          	jal	800054c2 <panic>
    if(sz - i < PGSIZE)
    80003a88:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003a8a:	8726                	mv	a4,s1
    80003a8c:	012c06bb          	addw	a3,s8,s2
    80003a90:	4581                	li	a1,0
    80003a92:	8552                	mv	a0,s4
    80003a94:	ecdfe0ef          	jal	80002960 <readi>
    80003a98:	2501                	sext.w	a0,a0
    80003a9a:	24a49a63          	bne	s1,a0,80003cee <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003a9e:	012a893b          	addw	s2,s5,s2
    80003aa2:	03397363          	bgeu	s2,s3,80003ac8 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003aa6:	02091593          	slli	a1,s2,0x20
    80003aaa:	9181                	srli	a1,a1,0x20
    80003aac:	95de                	add	a1,a1,s7
    80003aae:	855a                	mv	a0,s6
    80003ab0:	9adfc0ef          	jal	8000045c <walkaddr>
    80003ab4:	862a                	mv	a2,a0
    if(pa == 0)
    80003ab6:	d179                	beqz	a0,80003a7c <exec+0xc2>
    if(sz - i < PGSIZE)
    80003ab8:	412984bb          	subw	s1,s3,s2
    80003abc:	0004879b          	sext.w	a5,s1
    80003ac0:	fcfcf4e3          	bgeu	s9,a5,80003a88 <exec+0xce>
    80003ac4:	84d6                	mv	s1,s5
    80003ac6:	b7c9                	j	80003a88 <exec+0xce>
    sz = sz1;
    80003ac8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003acc:	2d85                	addiw	s11,s11,1
    80003ace:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003ad2:	e8845783          	lhu	a5,-376(s0)
    80003ad6:	08fdd063          	bge	s11,a5,80003b56 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003ada:	2d01                	sext.w	s10,s10
    80003adc:	03800713          	li	a4,56
    80003ae0:	86ea                	mv	a3,s10
    80003ae2:	e1840613          	addi	a2,s0,-488
    80003ae6:	4581                	li	a1,0
    80003ae8:	8552                	mv	a0,s4
    80003aea:	e77fe0ef          	jal	80002960 <readi>
    80003aee:	03800793          	li	a5,56
    80003af2:	1cf51663          	bne	a0,a5,80003cbe <exec+0x304>
    if(ph.type != ELF_PROG_LOAD) //checks if a segment is the type to load into memory 
    80003af6:	e1842783          	lw	a5,-488(s0)
    80003afa:	4705                	li	a4,1
    80003afc:	fce798e3          	bne	a5,a4,80003acc <exec+0x112>
    if(ph.memsz < ph.filesz) //memory size >= file size
    80003b00:	e4043483          	ld	s1,-448(s0)
    80003b04:	e3843783          	ld	a5,-456(s0)
    80003b08:	1af4ef63          	bltu	s1,a5,80003cc6 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr) //address must align to the page size
    80003b0c:	e2843783          	ld	a5,-472(s0)
    80003b10:	94be                	add	s1,s1,a5
    80003b12:	1af4ee63          	bltu	s1,a5,80003cce <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003b16:	df043703          	ld	a4,-528(s0)
    80003b1a:	8ff9                	and	a5,a5,a4
    80003b1c:	1a079d63          	bnez	a5,80003cd6 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)//allocate memory for segment
    80003b20:	e1c42503          	lw	a0,-484(s0)
    80003b24:	e7dff0ef          	jal	800039a0 <flags2perm>
    80003b28:	86aa                	mv	a3,a0
    80003b2a:	8626                	mv	a2,s1
    80003b2c:	85ca                	mv	a1,s2
    80003b2e:	855a                	mv	a0,s6
    80003b30:	c95fc0ef          	jal	800007c4 <uvmalloc>
    80003b34:	e0a43423          	sd	a0,-504(s0)
    80003b38:	1a050363          	beqz	a0,80003cde <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0) //Load file contents into memory
    80003b3c:	e2843b83          	ld	s7,-472(s0)
    80003b40:	e2042c03          	lw	s8,-480(s0)
    80003b44:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003b48:	00098463          	beqz	s3,80003b50 <exec+0x196>
    80003b4c:	4901                	li	s2,0
    80003b4e:	bfa1                	j	80003aa6 <exec+0xec>
    sz = sz1;
    80003b50:	e0843903          	ld	s2,-504(s0)
    80003b54:	bfa5                	j	80003acc <exec+0x112>
    80003b56:	7dba                	ld	s11,424(sp)
  iunlockput(ip); //unlock ip
    80003b58:	8552                	mv	a0,s4
    80003b5a:	dbdfe0ef          	jal	80002916 <iunlockput>
  end_op(); // end transaction
    80003b5e:	caeff0ef          	jal	8000300c <end_op>
  p = myproc();
    80003b62:	a04fd0ef          	jal	80000d66 <myproc>
    80003b66:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003b68:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz); //round the value
    80003b6c:	6985                	lui	s3,0x1
    80003b6e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003b70:	99ca                	add	s3,s3,s2
    80003b72:	77fd                	lui	a5,0xfffff
    80003b74:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0) //allocate stack space in memory.
    80003b78:	4691                	li	a3,4
    80003b7a:	660d                	lui	a2,0x3
    80003b7c:	964e                	add	a2,a2,s3
    80003b7e:	85ce                	mv	a1,s3
    80003b80:	855a                	mv	a0,s6
    80003b82:	c43fc0ef          	jal	800007c4 <uvmalloc>
    80003b86:	892a                	mv	s2,a0
    80003b88:	e0a43423          	sd	a0,-504(s0)
    80003b8c:	e519                	bnez	a0,80003b9a <exec+0x1e0>
  if(pagetable)
    80003b8e:	e1343423          	sd	s3,-504(s0)
    80003b92:	4a01                	li	s4,0
    80003b94:	aab1                	j	80003cf0 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b96:	4901                	li	s2,0
    80003b98:	b7c1                	j	80003b58 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE); //makes the first page inaccessible, acting as a "stack guard".
    80003b9a:	75f5                	lui	a1,0xffffd
    80003b9c:	95aa                	add	a1,a1,a0
    80003b9e:	855a                	mv	a0,s6
    80003ba0:	e0ffc0ef          	jal	800009ae <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003ba4:	7bf9                	lui	s7,0xffffe
    80003ba6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003ba8:	e0043783          	ld	a5,-512(s0)
    80003bac:	6388                	ld	a0,0(a5)
    80003bae:	cd39                	beqz	a0,80003c0c <exec+0x252>
    80003bb0:	e9040993          	addi	s3,s0,-368
    80003bb4:	f9040c13          	addi	s8,s0,-112
    80003bb8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003bba:	f04fc0ef          	jal	800002be <strlen>
    80003bbe:	0015079b          	addiw	a5,a0,1
    80003bc2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003bc6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003bca:	11796e63          	bltu	s2,s7,80003ce6 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003bce:	e0043d03          	ld	s10,-512(s0)
    80003bd2:	000d3a03          	ld	s4,0(s10)
    80003bd6:	8552                	mv	a0,s4
    80003bd8:	ee6fc0ef          	jal	800002be <strlen>
    80003bdc:	0015069b          	addiw	a3,a0,1
    80003be0:	8652                	mv	a2,s4
    80003be2:	85ca                	mv	a1,s2
    80003be4:	855a                	mv	a0,s6
    80003be6:	df3fc0ef          	jal	800009d8 <copyout>
    80003bea:	10054063          	bltz	a0,80003cea <exec+0x330>
    ustack[argc] = sp;
    80003bee:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003bf2:	0485                	addi	s1,s1,1
    80003bf4:	008d0793          	addi	a5,s10,8
    80003bf8:	e0f43023          	sd	a5,-512(s0)
    80003bfc:	008d3503          	ld	a0,8(s10)
    80003c00:	c909                	beqz	a0,80003c12 <exec+0x258>
    if(argc >= MAXARG)
    80003c02:	09a1                	addi	s3,s3,8
    80003c04:	fb899be3          	bne	s3,s8,80003bba <exec+0x200>
  ip = 0;
    80003c08:	4a01                	li	s4,0
    80003c0a:	a0dd                	j	80003cf0 <exec+0x336>
  sp = sz;
    80003c0c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003c10:	4481                	li	s1,0
  ustack[argc] = 0;
    80003c12:	00349793          	slli	a5,s1,0x3
    80003c16:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb600>
    80003c1a:	97a2                	add	a5,a5,s0
    80003c1c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003c20:	00148693          	addi	a3,s1,1
    80003c24:	068e                	slli	a3,a3,0x3
    80003c26:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003c2a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003c2e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003c32:	f5796ee3          	bltu	s2,s7,80003b8e <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003c36:	e9040613          	addi	a2,s0,-368
    80003c3a:	85ca                	mv	a1,s2
    80003c3c:	855a                	mv	a0,s6
    80003c3e:	d9bfc0ef          	jal	800009d8 <copyout>
    80003c42:	0e054263          	bltz	a0,80003d26 <exec+0x36c>
  p->trapframe->a1 = sp;
    80003c46:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003c4a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003c4e:	df843783          	ld	a5,-520(s0)
    80003c52:	0007c703          	lbu	a4,0(a5)
    80003c56:	cf11                	beqz	a4,80003c72 <exec+0x2b8>
    80003c58:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003c5a:	02f00693          	li	a3,47
    80003c5e:	a039                	j	80003c6c <exec+0x2b2>
      last = s+1;
    80003c60:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003c64:	0785                	addi	a5,a5,1
    80003c66:	fff7c703          	lbu	a4,-1(a5)
    80003c6a:	c701                	beqz	a4,80003c72 <exec+0x2b8>
    if(*s == '/')
    80003c6c:	fed71ce3          	bne	a4,a3,80003c64 <exec+0x2aa>
    80003c70:	bfc5                	j	80003c60 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003c72:	4641                	li	a2,16
    80003c74:	df843583          	ld	a1,-520(s0)
    80003c78:	158a8513          	addi	a0,s5,344
    80003c7c:	e10fc0ef          	jal	8000028c <safestrcpy>
  oldpagetable = p->pagetable;
    80003c80:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003c84:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003c88:	e0843783          	ld	a5,-504(s0)
    80003c8c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003c90:	058ab783          	ld	a5,88(s5)
    80003c94:	e6843703          	ld	a4,-408(s0)
    80003c98:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003c9a:	058ab783          	ld	a5,88(s5)
    80003c9e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz); //deallocate the old page table
    80003ca2:	85e6                	mv	a1,s9
    80003ca4:	9eefd0ef          	jal	80000e92 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003ca8:	0004851b          	sext.w	a0,s1
    80003cac:	79be                	ld	s3,488(sp)
    80003cae:	7a1e                	ld	s4,480(sp)
    80003cb0:	6afe                	ld	s5,472(sp)
    80003cb2:	6b5e                	ld	s6,464(sp)
    80003cb4:	6bbe                	ld	s7,456(sp)
    80003cb6:	6c1e                	ld	s8,448(sp)
    80003cb8:	7cfa                	ld	s9,440(sp)
    80003cba:	7d5a                	ld	s10,432(sp)
    80003cbc:	b3b5                	j	80003a28 <exec+0x6e>
    80003cbe:	e1243423          	sd	s2,-504(s0)
    80003cc2:	7dba                	ld	s11,424(sp)
    80003cc4:	a035                	j	80003cf0 <exec+0x336>
    80003cc6:	e1243423          	sd	s2,-504(s0)
    80003cca:	7dba                	ld	s11,424(sp)
    80003ccc:	a015                	j	80003cf0 <exec+0x336>
    80003cce:	e1243423          	sd	s2,-504(s0)
    80003cd2:	7dba                	ld	s11,424(sp)
    80003cd4:	a831                	j	80003cf0 <exec+0x336>
    80003cd6:	e1243423          	sd	s2,-504(s0)
    80003cda:	7dba                	ld	s11,424(sp)
    80003cdc:	a811                	j	80003cf0 <exec+0x336>
    80003cde:	e1243423          	sd	s2,-504(s0)
    80003ce2:	7dba                	ld	s11,424(sp)
    80003ce4:	a031                	j	80003cf0 <exec+0x336>
  ip = 0;
    80003ce6:	4a01                	li	s4,0
    80003ce8:	a021                	j	80003cf0 <exec+0x336>
    80003cea:	4a01                	li	s4,0
  if(pagetable)
    80003cec:	a011                	j	80003cf0 <exec+0x336>
    80003cee:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003cf0:	e0843583          	ld	a1,-504(s0)
    80003cf4:	855a                	mv	a0,s6
    80003cf6:	99cfd0ef          	jal	80000e92 <proc_freepagetable>
  return -1;
    80003cfa:	557d                	li	a0,-1
  if(ip){
    80003cfc:	000a1b63          	bnez	s4,80003d12 <exec+0x358>
    80003d00:	79be                	ld	s3,488(sp)
    80003d02:	7a1e                	ld	s4,480(sp)
    80003d04:	6afe                	ld	s5,472(sp)
    80003d06:	6b5e                	ld	s6,464(sp)
    80003d08:	6bbe                	ld	s7,456(sp)
    80003d0a:	6c1e                	ld	s8,448(sp)
    80003d0c:	7cfa                	ld	s9,440(sp)
    80003d0e:	7d5a                	ld	s10,432(sp)
    80003d10:	bb21                	j	80003a28 <exec+0x6e>
    80003d12:	79be                	ld	s3,488(sp)
    80003d14:	6afe                	ld	s5,472(sp)
    80003d16:	6b5e                	ld	s6,464(sp)
    80003d18:	6bbe                	ld	s7,456(sp)
    80003d1a:	6c1e                	ld	s8,448(sp)
    80003d1c:	7cfa                	ld	s9,440(sp)
    80003d1e:	7d5a                	ld	s10,432(sp)
    80003d20:	b9ed                	j	80003a1a <exec+0x60>
    80003d22:	6b5e                	ld	s6,464(sp)
    80003d24:	b9dd                	j	80003a1a <exec+0x60>
  sz = sz1;
    80003d26:	e0843983          	ld	s3,-504(s0)
    80003d2a:	b595                	j	80003b8e <exec+0x1d4>

0000000080003d2c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003d2c:	7179                	addi	sp,sp,-48
    80003d2e:	f406                	sd	ra,40(sp)
    80003d30:	f022                	sd	s0,32(sp)
    80003d32:	ec26                	sd	s1,24(sp)
    80003d34:	e84a                	sd	s2,16(sp)
    80003d36:	1800                	addi	s0,sp,48
    80003d38:	892e                	mv	s2,a1
    80003d3a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003d3c:	fdc40593          	addi	a1,s0,-36
    80003d40:	ee3fd0ef          	jal	80001c22 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003d44:	fdc42703          	lw	a4,-36(s0)
    80003d48:	47bd                	li	a5,15
    80003d4a:	02e7e963          	bltu	a5,a4,80003d7c <argfd+0x50>
    80003d4e:	818fd0ef          	jal	80000d66 <myproc>
    80003d52:	fdc42703          	lw	a4,-36(s0)
    80003d56:	01a70793          	addi	a5,a4,26
    80003d5a:	078e                	slli	a5,a5,0x3
    80003d5c:	953e                	add	a0,a0,a5
    80003d5e:	611c                	ld	a5,0(a0)
    80003d60:	c385                	beqz	a5,80003d80 <argfd+0x54>
    return -1;
  if(pfd)
    80003d62:	00090463          	beqz	s2,80003d6a <argfd+0x3e>
    *pfd = fd;
    80003d66:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003d6a:	4501                	li	a0,0
  if(pf)
    80003d6c:	c091                	beqz	s1,80003d70 <argfd+0x44>
    *pf = f;
    80003d6e:	e09c                	sd	a5,0(s1)
}
    80003d70:	70a2                	ld	ra,40(sp)
    80003d72:	7402                	ld	s0,32(sp)
    80003d74:	64e2                	ld	s1,24(sp)
    80003d76:	6942                	ld	s2,16(sp)
    80003d78:	6145                	addi	sp,sp,48
    80003d7a:	8082                	ret
    return -1;
    80003d7c:	557d                	li	a0,-1
    80003d7e:	bfcd                	j	80003d70 <argfd+0x44>
    80003d80:	557d                	li	a0,-1
    80003d82:	b7fd                	j	80003d70 <argfd+0x44>

0000000080003d84 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003d84:	1101                	addi	sp,sp,-32
    80003d86:	ec06                	sd	ra,24(sp)
    80003d88:	e822                	sd	s0,16(sp)
    80003d8a:	e426                	sd	s1,8(sp)
    80003d8c:	1000                	addi	s0,sp,32
    80003d8e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003d90:	fd7fc0ef          	jal	80000d66 <myproc>
    80003d94:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003d96:	0d050793          	addi	a5,a0,208
    80003d9a:	4501                	li	a0,0
    80003d9c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003d9e:	6398                	ld	a4,0(a5)
    80003da0:	cb19                	beqz	a4,80003db6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003da2:	2505                	addiw	a0,a0,1
    80003da4:	07a1                	addi	a5,a5,8
    80003da6:	fed51ce3          	bne	a0,a3,80003d9e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003daa:	557d                	li	a0,-1
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	64a2                	ld	s1,8(sp)
    80003db2:	6105                	addi	sp,sp,32
    80003db4:	8082                	ret
      p->ofile[fd] = f;
    80003db6:	01a50793          	addi	a5,a0,26
    80003dba:	078e                	slli	a5,a5,0x3
    80003dbc:	963e                	add	a2,a2,a5
    80003dbe:	e204                	sd	s1,0(a2)
      return fd;
    80003dc0:	b7f5                	j	80003dac <fdalloc+0x28>

0000000080003dc2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003dc2:	715d                	addi	sp,sp,-80
    80003dc4:	e486                	sd	ra,72(sp)
    80003dc6:	e0a2                	sd	s0,64(sp)
    80003dc8:	fc26                	sd	s1,56(sp)
    80003dca:	f84a                	sd	s2,48(sp)
    80003dcc:	f44e                	sd	s3,40(sp)
    80003dce:	ec56                	sd	s5,24(sp)
    80003dd0:	e85a                	sd	s6,16(sp)
    80003dd2:	0880                	addi	s0,sp,80
    80003dd4:	8b2e                	mv	s6,a1
    80003dd6:	89b2                	mv	s3,a2
    80003dd8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003dda:	fb040593          	addi	a1,s0,-80
    80003dde:	822ff0ef          	jal	80002e00 <nameiparent>
    80003de2:	84aa                	mv	s1,a0
    80003de4:	10050a63          	beqz	a0,80003ef8 <create+0x136>
    return 0;

  ilock(dp);
    80003de8:	925fe0ef          	jal	8000270c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dec:	4601                	li	a2,0
    80003dee:	fb040593          	addi	a1,s0,-80
    80003df2:	8526                	mv	a0,s1
    80003df4:	d8dfe0ef          	jal	80002b80 <dirlookup>
    80003df8:	8aaa                	mv	s5,a0
    80003dfa:	c129                	beqz	a0,80003e3c <create+0x7a>
    iunlockput(dp);
    80003dfc:	8526                	mv	a0,s1
    80003dfe:	b19fe0ef          	jal	80002916 <iunlockput>
    ilock(ip);
    80003e02:	8556                	mv	a0,s5
    80003e04:	909fe0ef          	jal	8000270c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003e08:	4789                	li	a5,2
    80003e0a:	02fb1463          	bne	s6,a5,80003e32 <create+0x70>
    80003e0e:	044ad783          	lhu	a5,68(s5)
    80003e12:	37f9                	addiw	a5,a5,-2
    80003e14:	17c2                	slli	a5,a5,0x30
    80003e16:	93c1                	srli	a5,a5,0x30
    80003e18:	4705                	li	a4,1
    80003e1a:	00f76c63          	bltu	a4,a5,80003e32 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003e1e:	8556                	mv	a0,s5
    80003e20:	60a6                	ld	ra,72(sp)
    80003e22:	6406                	ld	s0,64(sp)
    80003e24:	74e2                	ld	s1,56(sp)
    80003e26:	7942                	ld	s2,48(sp)
    80003e28:	79a2                	ld	s3,40(sp)
    80003e2a:	6ae2                	ld	s5,24(sp)
    80003e2c:	6b42                	ld	s6,16(sp)
    80003e2e:	6161                	addi	sp,sp,80
    80003e30:	8082                	ret
    iunlockput(ip);
    80003e32:	8556                	mv	a0,s5
    80003e34:	ae3fe0ef          	jal	80002916 <iunlockput>
    return 0;
    80003e38:	4a81                	li	s5,0
    80003e3a:	b7d5                	j	80003e1e <create+0x5c>
    80003e3c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003e3e:	85da                	mv	a1,s6
    80003e40:	4088                	lw	a0,0(s1)
    80003e42:	f5afe0ef          	jal	8000259c <ialloc>
    80003e46:	8a2a                	mv	s4,a0
    80003e48:	cd15                	beqz	a0,80003e84 <create+0xc2>
  ilock(ip);
    80003e4a:	8c3fe0ef          	jal	8000270c <ilock>
  ip->major = major;
    80003e4e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003e52:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003e56:	4905                	li	s2,1
    80003e58:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003e5c:	8552                	mv	a0,s4
    80003e5e:	ffafe0ef          	jal	80002658 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003e62:	032b0763          	beq	s6,s2,80003e90 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003e66:	004a2603          	lw	a2,4(s4)
    80003e6a:	fb040593          	addi	a1,s0,-80
    80003e6e:	8526                	mv	a0,s1
    80003e70:	eddfe0ef          	jal	80002d4c <dirlink>
    80003e74:	06054563          	bltz	a0,80003ede <create+0x11c>
  iunlockput(dp);
    80003e78:	8526                	mv	a0,s1
    80003e7a:	a9dfe0ef          	jal	80002916 <iunlockput>
  return ip;
    80003e7e:	8ad2                	mv	s5,s4
    80003e80:	7a02                	ld	s4,32(sp)
    80003e82:	bf71                	j	80003e1e <create+0x5c>
    iunlockput(dp);
    80003e84:	8526                	mv	a0,s1
    80003e86:	a91fe0ef          	jal	80002916 <iunlockput>
    return 0;
    80003e8a:	8ad2                	mv	s5,s4
    80003e8c:	7a02                	ld	s4,32(sp)
    80003e8e:	bf41                	j	80003e1e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003e90:	004a2603          	lw	a2,4(s4)
    80003e94:	00004597          	auipc	a1,0x4
    80003e98:	81458593          	addi	a1,a1,-2028 # 800076a8 <etext+0x6a8>
    80003e9c:	8552                	mv	a0,s4
    80003e9e:	eaffe0ef          	jal	80002d4c <dirlink>
    80003ea2:	02054e63          	bltz	a0,80003ede <create+0x11c>
    80003ea6:	40d0                	lw	a2,4(s1)
    80003ea8:	00004597          	auipc	a1,0x4
    80003eac:	80858593          	addi	a1,a1,-2040 # 800076b0 <etext+0x6b0>
    80003eb0:	8552                	mv	a0,s4
    80003eb2:	e9bfe0ef          	jal	80002d4c <dirlink>
    80003eb6:	02054463          	bltz	a0,80003ede <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003eba:	004a2603          	lw	a2,4(s4)
    80003ebe:	fb040593          	addi	a1,s0,-80
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	e89fe0ef          	jal	80002d4c <dirlink>
    80003ec8:	00054b63          	bltz	a0,80003ede <create+0x11c>
    dp->nlink++;  // for ".."
    80003ecc:	04a4d783          	lhu	a5,74(s1)
    80003ed0:	2785                	addiw	a5,a5,1
    80003ed2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	f80fe0ef          	jal	80002658 <iupdate>
    80003edc:	bf71                	j	80003e78 <create+0xb6>
  ip->nlink = 0;
    80003ede:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003ee2:	8552                	mv	a0,s4
    80003ee4:	f74fe0ef          	jal	80002658 <iupdate>
  iunlockput(ip);
    80003ee8:	8552                	mv	a0,s4
    80003eea:	a2dfe0ef          	jal	80002916 <iunlockput>
  iunlockput(dp);
    80003eee:	8526                	mv	a0,s1
    80003ef0:	a27fe0ef          	jal	80002916 <iunlockput>
  return 0;
    80003ef4:	7a02                	ld	s4,32(sp)
    80003ef6:	b725                	j	80003e1e <create+0x5c>
    return 0;
    80003ef8:	8aaa                	mv	s5,a0
    80003efa:	b715                	j	80003e1e <create+0x5c>

0000000080003efc <sys_dup>:
{
    80003efc:	7179                	addi	sp,sp,-48
    80003efe:	f406                	sd	ra,40(sp)
    80003f00:	f022                	sd	s0,32(sp)
    80003f02:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003f04:	fd840613          	addi	a2,s0,-40
    80003f08:	4581                	li	a1,0
    80003f0a:	4501                	li	a0,0
    80003f0c:	e21ff0ef          	jal	80003d2c <argfd>
    return -1;
    80003f10:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003f12:	02054363          	bltz	a0,80003f38 <sys_dup+0x3c>
    80003f16:	ec26                	sd	s1,24(sp)
    80003f18:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80003f1a:	fd843903          	ld	s2,-40(s0)
    80003f1e:	854a                	mv	a0,s2
    80003f20:	e65ff0ef          	jal	80003d84 <fdalloc>
    80003f24:	84aa                	mv	s1,a0
    return -1;
    80003f26:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003f28:	00054d63          	bltz	a0,80003f42 <sys_dup+0x46>
  filedup(f);
    80003f2c:	854a                	mv	a0,s2
    80003f2e:	c48ff0ef          	jal	80003376 <filedup>
  return fd;
    80003f32:	87a6                	mv	a5,s1
    80003f34:	64e2                	ld	s1,24(sp)
    80003f36:	6942                	ld	s2,16(sp)
}
    80003f38:	853e                	mv	a0,a5
    80003f3a:	70a2                	ld	ra,40(sp)
    80003f3c:	7402                	ld	s0,32(sp)
    80003f3e:	6145                	addi	sp,sp,48
    80003f40:	8082                	ret
    80003f42:	64e2                	ld	s1,24(sp)
    80003f44:	6942                	ld	s2,16(sp)
    80003f46:	bfcd                	j	80003f38 <sys_dup+0x3c>

0000000080003f48 <sys_read>:
{
    80003f48:	7179                	addi	sp,sp,-48
    80003f4a:	f406                	sd	ra,40(sp)
    80003f4c:	f022                	sd	s0,32(sp)
    80003f4e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f50:	fd840593          	addi	a1,s0,-40
    80003f54:	4505                	li	a0,1
    80003f56:	ce9fd0ef          	jal	80001c3e <argaddr>
  argint(2, &n);
    80003f5a:	fe440593          	addi	a1,s0,-28
    80003f5e:	4509                	li	a0,2
    80003f60:	cc3fd0ef          	jal	80001c22 <argint>
  if(argfd(0, 0, &f) < 0)
    80003f64:	fe840613          	addi	a2,s0,-24
    80003f68:	4581                	li	a1,0
    80003f6a:	4501                	li	a0,0
    80003f6c:	dc1ff0ef          	jal	80003d2c <argfd>
    80003f70:	87aa                	mv	a5,a0
    return -1;
    80003f72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f74:	0007ca63          	bltz	a5,80003f88 <sys_read+0x40>
  return fileread(f, p, n);
    80003f78:	fe442603          	lw	a2,-28(s0)
    80003f7c:	fd843583          	ld	a1,-40(s0)
    80003f80:	fe843503          	ld	a0,-24(s0)
    80003f84:	d58ff0ef          	jal	800034dc <fileread>
}
    80003f88:	70a2                	ld	ra,40(sp)
    80003f8a:	7402                	ld	s0,32(sp)
    80003f8c:	6145                	addi	sp,sp,48
    80003f8e:	8082                	ret

0000000080003f90 <sys_write>:
{
    80003f90:	7179                	addi	sp,sp,-48
    80003f92:	f406                	sd	ra,40(sp)
    80003f94:	f022                	sd	s0,32(sp)
    80003f96:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003f98:	fd840593          	addi	a1,s0,-40
    80003f9c:	4505                	li	a0,1
    80003f9e:	ca1fd0ef          	jal	80001c3e <argaddr>
  argint(2, &n);
    80003fa2:	fe440593          	addi	a1,s0,-28
    80003fa6:	4509                	li	a0,2
    80003fa8:	c7bfd0ef          	jal	80001c22 <argint>
  if(argfd(0, 0, &f) < 0)
    80003fac:	fe840613          	addi	a2,s0,-24
    80003fb0:	4581                	li	a1,0
    80003fb2:	4501                	li	a0,0
    80003fb4:	d79ff0ef          	jal	80003d2c <argfd>
    80003fb8:	87aa                	mv	a5,a0
    return -1;
    80003fba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003fbc:	0007ca63          	bltz	a5,80003fd0 <sys_write+0x40>
  return filewrite(f, p, n);
    80003fc0:	fe442603          	lw	a2,-28(s0)
    80003fc4:	fd843583          	ld	a1,-40(s0)
    80003fc8:	fe843503          	ld	a0,-24(s0)
    80003fcc:	dceff0ef          	jal	8000359a <filewrite>
}
    80003fd0:	70a2                	ld	ra,40(sp)
    80003fd2:	7402                	ld	s0,32(sp)
    80003fd4:	6145                	addi	sp,sp,48
    80003fd6:	8082                	ret

0000000080003fd8 <sys_close>:
{
    80003fd8:	1101                	addi	sp,sp,-32
    80003fda:	ec06                	sd	ra,24(sp)
    80003fdc:	e822                	sd	s0,16(sp)
    80003fde:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003fe0:	fe040613          	addi	a2,s0,-32
    80003fe4:	fec40593          	addi	a1,s0,-20
    80003fe8:	4501                	li	a0,0
    80003fea:	d43ff0ef          	jal	80003d2c <argfd>
    return -1;
    80003fee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003ff0:	02054063          	bltz	a0,80004010 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003ff4:	d73fc0ef          	jal	80000d66 <myproc>
    80003ff8:	fec42783          	lw	a5,-20(s0)
    80003ffc:	07e9                	addi	a5,a5,26
    80003ffe:	078e                	slli	a5,a5,0x3
    80004000:	953e                	add	a0,a0,a5
    80004002:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004006:	fe043503          	ld	a0,-32(s0)
    8000400a:	bb2ff0ef          	jal	800033bc <fileclose>
  return 0;
    8000400e:	4781                	li	a5,0
}
    80004010:	853e                	mv	a0,a5
    80004012:	60e2                	ld	ra,24(sp)
    80004014:	6442                	ld	s0,16(sp)
    80004016:	6105                	addi	sp,sp,32
    80004018:	8082                	ret

000000008000401a <sys_fstat>:
{
    8000401a:	1101                	addi	sp,sp,-32
    8000401c:	ec06                	sd	ra,24(sp)
    8000401e:	e822                	sd	s0,16(sp)
    80004020:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004022:	fe040593          	addi	a1,s0,-32
    80004026:	4505                	li	a0,1
    80004028:	c17fd0ef          	jal	80001c3e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000402c:	fe840613          	addi	a2,s0,-24
    80004030:	4581                	li	a1,0
    80004032:	4501                	li	a0,0
    80004034:	cf9ff0ef          	jal	80003d2c <argfd>
    80004038:	87aa                	mv	a5,a0
    return -1;
    8000403a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000403c:	0007c863          	bltz	a5,8000404c <sys_fstat+0x32>
  return filestat(f, st);
    80004040:	fe043583          	ld	a1,-32(s0)
    80004044:	fe843503          	ld	a0,-24(s0)
    80004048:	c36ff0ef          	jal	8000347e <filestat>
}
    8000404c:	60e2                	ld	ra,24(sp)
    8000404e:	6442                	ld	s0,16(sp)
    80004050:	6105                	addi	sp,sp,32
    80004052:	8082                	ret

0000000080004054 <sys_link>:
{
    80004054:	7169                	addi	sp,sp,-304
    80004056:	f606                	sd	ra,296(sp)
    80004058:	f222                	sd	s0,288(sp)
    8000405a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000405c:	08000613          	li	a2,128
    80004060:	ed040593          	addi	a1,s0,-304
    80004064:	4501                	li	a0,0
    80004066:	bf5fd0ef          	jal	80001c5a <argstr>
    return -1;
    8000406a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000406c:	0c054e63          	bltz	a0,80004148 <sys_link+0xf4>
    80004070:	08000613          	li	a2,128
    80004074:	f5040593          	addi	a1,s0,-176
    80004078:	4505                	li	a0,1
    8000407a:	be1fd0ef          	jal	80001c5a <argstr>
    return -1;
    8000407e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004080:	0c054463          	bltz	a0,80004148 <sys_link+0xf4>
    80004084:	ee26                	sd	s1,280(sp)
  begin_op();
    80004086:	f1dfe0ef          	jal	80002fa2 <begin_op>
  if((ip = namei(old)) == 0){
    8000408a:	ed040513          	addi	a0,s0,-304
    8000408e:	d59fe0ef          	jal	80002de6 <namei>
    80004092:	84aa                	mv	s1,a0
    80004094:	c53d                	beqz	a0,80004102 <sys_link+0xae>
  ilock(ip);
    80004096:	e76fe0ef          	jal	8000270c <ilock>
  if(ip->type == T_DIR){
    8000409a:	04449703          	lh	a4,68(s1)
    8000409e:	4785                	li	a5,1
    800040a0:	06f70663          	beq	a4,a5,8000410c <sys_link+0xb8>
    800040a4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800040a6:	04a4d783          	lhu	a5,74(s1)
    800040aa:	2785                	addiw	a5,a5,1
    800040ac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800040b0:	8526                	mv	a0,s1
    800040b2:	da6fe0ef          	jal	80002658 <iupdate>
  iunlock(ip);
    800040b6:	8526                	mv	a0,s1
    800040b8:	f02fe0ef          	jal	800027ba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800040bc:	fd040593          	addi	a1,s0,-48
    800040c0:	f5040513          	addi	a0,s0,-176
    800040c4:	d3dfe0ef          	jal	80002e00 <nameiparent>
    800040c8:	892a                	mv	s2,a0
    800040ca:	cd21                	beqz	a0,80004122 <sys_link+0xce>
  ilock(dp);
    800040cc:	e40fe0ef          	jal	8000270c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800040d0:	00092703          	lw	a4,0(s2)
    800040d4:	409c                	lw	a5,0(s1)
    800040d6:	04f71363          	bne	a4,a5,8000411c <sys_link+0xc8>
    800040da:	40d0                	lw	a2,4(s1)
    800040dc:	fd040593          	addi	a1,s0,-48
    800040e0:	854a                	mv	a0,s2
    800040e2:	c6bfe0ef          	jal	80002d4c <dirlink>
    800040e6:	02054b63          	bltz	a0,8000411c <sys_link+0xc8>
  iunlockput(dp);
    800040ea:	854a                	mv	a0,s2
    800040ec:	82bfe0ef          	jal	80002916 <iunlockput>
  iput(ip);
    800040f0:	8526                	mv	a0,s1
    800040f2:	f9cfe0ef          	jal	8000288e <iput>
  end_op();
    800040f6:	f17fe0ef          	jal	8000300c <end_op>
  return 0;
    800040fa:	4781                	li	a5,0
    800040fc:	64f2                	ld	s1,280(sp)
    800040fe:	6952                	ld	s2,272(sp)
    80004100:	a0a1                	j	80004148 <sys_link+0xf4>
    end_op();
    80004102:	f0bfe0ef          	jal	8000300c <end_op>
    return -1;
    80004106:	57fd                	li	a5,-1
    80004108:	64f2                	ld	s1,280(sp)
    8000410a:	a83d                	j	80004148 <sys_link+0xf4>
    iunlockput(ip);
    8000410c:	8526                	mv	a0,s1
    8000410e:	809fe0ef          	jal	80002916 <iunlockput>
    end_op();
    80004112:	efbfe0ef          	jal	8000300c <end_op>
    return -1;
    80004116:	57fd                	li	a5,-1
    80004118:	64f2                	ld	s1,280(sp)
    8000411a:	a03d                	j	80004148 <sys_link+0xf4>
    iunlockput(dp);
    8000411c:	854a                	mv	a0,s2
    8000411e:	ff8fe0ef          	jal	80002916 <iunlockput>
  ilock(ip);
    80004122:	8526                	mv	a0,s1
    80004124:	de8fe0ef          	jal	8000270c <ilock>
  ip->nlink--;
    80004128:	04a4d783          	lhu	a5,74(s1)
    8000412c:	37fd                	addiw	a5,a5,-1
    8000412e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004132:	8526                	mv	a0,s1
    80004134:	d24fe0ef          	jal	80002658 <iupdate>
  iunlockput(ip);
    80004138:	8526                	mv	a0,s1
    8000413a:	fdcfe0ef          	jal	80002916 <iunlockput>
  end_op();
    8000413e:	ecffe0ef          	jal	8000300c <end_op>
  return -1;
    80004142:	57fd                	li	a5,-1
    80004144:	64f2                	ld	s1,280(sp)
    80004146:	6952                	ld	s2,272(sp)
}
    80004148:	853e                	mv	a0,a5
    8000414a:	70b2                	ld	ra,296(sp)
    8000414c:	7412                	ld	s0,288(sp)
    8000414e:	6155                	addi	sp,sp,304
    80004150:	8082                	ret

0000000080004152 <sys_unlink>:
{
    80004152:	7151                	addi	sp,sp,-240
    80004154:	f586                	sd	ra,232(sp)
    80004156:	f1a2                	sd	s0,224(sp)
    80004158:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000415a:	08000613          	li	a2,128
    8000415e:	f3040593          	addi	a1,s0,-208
    80004162:	4501                	li	a0,0
    80004164:	af7fd0ef          	jal	80001c5a <argstr>
    80004168:	16054063          	bltz	a0,800042c8 <sys_unlink+0x176>
    8000416c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000416e:	e35fe0ef          	jal	80002fa2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004172:	fb040593          	addi	a1,s0,-80
    80004176:	f3040513          	addi	a0,s0,-208
    8000417a:	c87fe0ef          	jal	80002e00 <nameiparent>
    8000417e:	84aa                	mv	s1,a0
    80004180:	c945                	beqz	a0,80004230 <sys_unlink+0xde>
  ilock(dp);
    80004182:	d8afe0ef          	jal	8000270c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004186:	00003597          	auipc	a1,0x3
    8000418a:	52258593          	addi	a1,a1,1314 # 800076a8 <etext+0x6a8>
    8000418e:	fb040513          	addi	a0,s0,-80
    80004192:	9d9fe0ef          	jal	80002b6a <namecmp>
    80004196:	10050e63          	beqz	a0,800042b2 <sys_unlink+0x160>
    8000419a:	00003597          	auipc	a1,0x3
    8000419e:	51658593          	addi	a1,a1,1302 # 800076b0 <etext+0x6b0>
    800041a2:	fb040513          	addi	a0,s0,-80
    800041a6:	9c5fe0ef          	jal	80002b6a <namecmp>
    800041aa:	10050463          	beqz	a0,800042b2 <sys_unlink+0x160>
    800041ae:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800041b0:	f2c40613          	addi	a2,s0,-212
    800041b4:	fb040593          	addi	a1,s0,-80
    800041b8:	8526                	mv	a0,s1
    800041ba:	9c7fe0ef          	jal	80002b80 <dirlookup>
    800041be:	892a                	mv	s2,a0
    800041c0:	0e050863          	beqz	a0,800042b0 <sys_unlink+0x15e>
  ilock(ip);
    800041c4:	d48fe0ef          	jal	8000270c <ilock>
  if(ip->nlink < 1)
    800041c8:	04a91783          	lh	a5,74(s2)
    800041cc:	06f05763          	blez	a5,8000423a <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800041d0:	04491703          	lh	a4,68(s2)
    800041d4:	4785                	li	a5,1
    800041d6:	06f70963          	beq	a4,a5,80004248 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800041da:	4641                	li	a2,16
    800041dc:	4581                	li	a1,0
    800041de:	fc040513          	addi	a0,s0,-64
    800041e2:	f6dfb0ef          	jal	8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041e6:	4741                	li	a4,16
    800041e8:	f2c42683          	lw	a3,-212(s0)
    800041ec:	fc040613          	addi	a2,s0,-64
    800041f0:	4581                	li	a1,0
    800041f2:	8526                	mv	a0,s1
    800041f4:	869fe0ef          	jal	80002a5c <writei>
    800041f8:	47c1                	li	a5,16
    800041fa:	08f51b63          	bne	a0,a5,80004290 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800041fe:	04491703          	lh	a4,68(s2)
    80004202:	4785                	li	a5,1
    80004204:	08f70d63          	beq	a4,a5,8000429e <sys_unlink+0x14c>
  iunlockput(dp);
    80004208:	8526                	mv	a0,s1
    8000420a:	f0cfe0ef          	jal	80002916 <iunlockput>
  ip->nlink--;
    8000420e:	04a95783          	lhu	a5,74(s2)
    80004212:	37fd                	addiw	a5,a5,-1
    80004214:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004218:	854a                	mv	a0,s2
    8000421a:	c3efe0ef          	jal	80002658 <iupdate>
  iunlockput(ip);
    8000421e:	854a                	mv	a0,s2
    80004220:	ef6fe0ef          	jal	80002916 <iunlockput>
  end_op();
    80004224:	de9fe0ef          	jal	8000300c <end_op>
  return 0;
    80004228:	4501                	li	a0,0
    8000422a:	64ee                	ld	s1,216(sp)
    8000422c:	694e                	ld	s2,208(sp)
    8000422e:	a849                	j	800042c0 <sys_unlink+0x16e>
    end_op();
    80004230:	dddfe0ef          	jal	8000300c <end_op>
    return -1;
    80004234:	557d                	li	a0,-1
    80004236:	64ee                	ld	s1,216(sp)
    80004238:	a061                	j	800042c0 <sys_unlink+0x16e>
    8000423a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000423c:	00003517          	auipc	a0,0x3
    80004240:	47c50513          	addi	a0,a0,1148 # 800076b8 <etext+0x6b8>
    80004244:	27e010ef          	jal	800054c2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004248:	04c92703          	lw	a4,76(s2)
    8000424c:	02000793          	li	a5,32
    80004250:	f8e7f5e3          	bgeu	a5,a4,800041da <sys_unlink+0x88>
    80004254:	e5ce                	sd	s3,200(sp)
    80004256:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000425a:	4741                	li	a4,16
    8000425c:	86ce                	mv	a3,s3
    8000425e:	f1840613          	addi	a2,s0,-232
    80004262:	4581                	li	a1,0
    80004264:	854a                	mv	a0,s2
    80004266:	efafe0ef          	jal	80002960 <readi>
    8000426a:	47c1                	li	a5,16
    8000426c:	00f51c63          	bne	a0,a5,80004284 <sys_unlink+0x132>
    if(de.inum != 0)
    80004270:	f1845783          	lhu	a5,-232(s0)
    80004274:	efa1                	bnez	a5,800042cc <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004276:	29c1                	addiw	s3,s3,16
    80004278:	04c92783          	lw	a5,76(s2)
    8000427c:	fcf9efe3          	bltu	s3,a5,8000425a <sys_unlink+0x108>
    80004280:	69ae                	ld	s3,200(sp)
    80004282:	bfa1                	j	800041da <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004284:	00003517          	auipc	a0,0x3
    80004288:	44c50513          	addi	a0,a0,1100 # 800076d0 <etext+0x6d0>
    8000428c:	236010ef          	jal	800054c2 <panic>
    80004290:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004292:	00003517          	auipc	a0,0x3
    80004296:	45650513          	addi	a0,a0,1110 # 800076e8 <etext+0x6e8>
    8000429a:	228010ef          	jal	800054c2 <panic>
    dp->nlink--;
    8000429e:	04a4d783          	lhu	a5,74(s1)
    800042a2:	37fd                	addiw	a5,a5,-1
    800042a4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800042a8:	8526                	mv	a0,s1
    800042aa:	baefe0ef          	jal	80002658 <iupdate>
    800042ae:	bfa9                	j	80004208 <sys_unlink+0xb6>
    800042b0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800042b2:	8526                	mv	a0,s1
    800042b4:	e62fe0ef          	jal	80002916 <iunlockput>
  end_op();
    800042b8:	d55fe0ef          	jal	8000300c <end_op>
  return -1;
    800042bc:	557d                	li	a0,-1
    800042be:	64ee                	ld	s1,216(sp)
}
    800042c0:	70ae                	ld	ra,232(sp)
    800042c2:	740e                	ld	s0,224(sp)
    800042c4:	616d                	addi	sp,sp,240
    800042c6:	8082                	ret
    return -1;
    800042c8:	557d                	li	a0,-1
    800042ca:	bfdd                	j	800042c0 <sys_unlink+0x16e>
    iunlockput(ip);
    800042cc:	854a                	mv	a0,s2
    800042ce:	e48fe0ef          	jal	80002916 <iunlockput>
    goto bad;
    800042d2:	694e                	ld	s2,208(sp)
    800042d4:	69ae                	ld	s3,200(sp)
    800042d6:	bff1                	j	800042b2 <sys_unlink+0x160>

00000000800042d8 <sys_open>:

uint64
sys_open(void)
{
    800042d8:	7131                	addi	sp,sp,-192
    800042da:	fd06                	sd	ra,184(sp)
    800042dc:	f922                	sd	s0,176(sp)
    800042de:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800042e0:	f4c40593          	addi	a1,s0,-180
    800042e4:	4505                	li	a0,1
    800042e6:	93dfd0ef          	jal	80001c22 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800042ea:	08000613          	li	a2,128
    800042ee:	f5040593          	addi	a1,s0,-176
    800042f2:	4501                	li	a0,0
    800042f4:	967fd0ef          	jal	80001c5a <argstr>
    800042f8:	87aa                	mv	a5,a0
    return -1;
    800042fa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800042fc:	0a07c263          	bltz	a5,800043a0 <sys_open+0xc8>
    80004300:	f526                	sd	s1,168(sp)

  begin_op();
    80004302:	ca1fe0ef          	jal	80002fa2 <begin_op>

  if(omode & O_CREATE){
    80004306:	f4c42783          	lw	a5,-180(s0)
    8000430a:	2007f793          	andi	a5,a5,512
    8000430e:	c3d5                	beqz	a5,800043b2 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004310:	4681                	li	a3,0
    80004312:	4601                	li	a2,0
    80004314:	4589                	li	a1,2
    80004316:	f5040513          	addi	a0,s0,-176
    8000431a:	aa9ff0ef          	jal	80003dc2 <create>
    8000431e:	84aa                	mv	s1,a0
    if(ip == 0){
    80004320:	c541                	beqz	a0,800043a8 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004322:	04449703          	lh	a4,68(s1)
    80004326:	478d                	li	a5,3
    80004328:	00f71763          	bne	a4,a5,80004336 <sys_open+0x5e>
    8000432c:	0464d703          	lhu	a4,70(s1)
    80004330:	47a5                	li	a5,9
    80004332:	0ae7ed63          	bltu	a5,a4,800043ec <sys_open+0x114>
    80004336:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004338:	fe1fe0ef          	jal	80003318 <filealloc>
    8000433c:	892a                	mv	s2,a0
    8000433e:	c179                	beqz	a0,80004404 <sys_open+0x12c>
    80004340:	ed4e                	sd	s3,152(sp)
    80004342:	a43ff0ef          	jal	80003d84 <fdalloc>
    80004346:	89aa                	mv	s3,a0
    80004348:	0a054a63          	bltz	a0,800043fc <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000434c:	04449703          	lh	a4,68(s1)
    80004350:	478d                	li	a5,3
    80004352:	0cf70263          	beq	a4,a5,80004416 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004356:	4789                	li	a5,2
    80004358:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000435c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004360:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004364:	f4c42783          	lw	a5,-180(s0)
    80004368:	0017c713          	xori	a4,a5,1
    8000436c:	8b05                	andi	a4,a4,1
    8000436e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004372:	0037f713          	andi	a4,a5,3
    80004376:	00e03733          	snez	a4,a4
    8000437a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000437e:	4007f793          	andi	a5,a5,1024
    80004382:	c791                	beqz	a5,8000438e <sys_open+0xb6>
    80004384:	04449703          	lh	a4,68(s1)
    80004388:	4789                	li	a5,2
    8000438a:	08f70d63          	beq	a4,a5,80004424 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000438e:	8526                	mv	a0,s1
    80004390:	c2afe0ef          	jal	800027ba <iunlock>
  end_op();
    80004394:	c79fe0ef          	jal	8000300c <end_op>

  return fd;
    80004398:	854e                	mv	a0,s3
    8000439a:	74aa                	ld	s1,168(sp)
    8000439c:	790a                	ld	s2,160(sp)
    8000439e:	69ea                	ld	s3,152(sp)
}
    800043a0:	70ea                	ld	ra,184(sp)
    800043a2:	744a                	ld	s0,176(sp)
    800043a4:	6129                	addi	sp,sp,192
    800043a6:	8082                	ret
      end_op();
    800043a8:	c65fe0ef          	jal	8000300c <end_op>
      return -1;
    800043ac:	557d                	li	a0,-1
    800043ae:	74aa                	ld	s1,168(sp)
    800043b0:	bfc5                	j	800043a0 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800043b2:	f5040513          	addi	a0,s0,-176
    800043b6:	a31fe0ef          	jal	80002de6 <namei>
    800043ba:	84aa                	mv	s1,a0
    800043bc:	c11d                	beqz	a0,800043e2 <sys_open+0x10a>
    ilock(ip);
    800043be:	b4efe0ef          	jal	8000270c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800043c2:	04449703          	lh	a4,68(s1)
    800043c6:	4785                	li	a5,1
    800043c8:	f4f71de3          	bne	a4,a5,80004322 <sys_open+0x4a>
    800043cc:	f4c42783          	lw	a5,-180(s0)
    800043d0:	d3bd                	beqz	a5,80004336 <sys_open+0x5e>
      iunlockput(ip);
    800043d2:	8526                	mv	a0,s1
    800043d4:	d42fe0ef          	jal	80002916 <iunlockput>
      end_op();
    800043d8:	c35fe0ef          	jal	8000300c <end_op>
      return -1;
    800043dc:	557d                	li	a0,-1
    800043de:	74aa                	ld	s1,168(sp)
    800043e0:	b7c1                	j	800043a0 <sys_open+0xc8>
      end_op();
    800043e2:	c2bfe0ef          	jal	8000300c <end_op>
      return -1;
    800043e6:	557d                	li	a0,-1
    800043e8:	74aa                	ld	s1,168(sp)
    800043ea:	bf5d                	j	800043a0 <sys_open+0xc8>
    iunlockput(ip);
    800043ec:	8526                	mv	a0,s1
    800043ee:	d28fe0ef          	jal	80002916 <iunlockput>
    end_op();
    800043f2:	c1bfe0ef          	jal	8000300c <end_op>
    return -1;
    800043f6:	557d                	li	a0,-1
    800043f8:	74aa                	ld	s1,168(sp)
    800043fa:	b75d                	j	800043a0 <sys_open+0xc8>
      fileclose(f);
    800043fc:	854a                	mv	a0,s2
    800043fe:	fbffe0ef          	jal	800033bc <fileclose>
    80004402:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004404:	8526                	mv	a0,s1
    80004406:	d10fe0ef          	jal	80002916 <iunlockput>
    end_op();
    8000440a:	c03fe0ef          	jal	8000300c <end_op>
    return -1;
    8000440e:	557d                	li	a0,-1
    80004410:	74aa                	ld	s1,168(sp)
    80004412:	790a                	ld	s2,160(sp)
    80004414:	b771                	j	800043a0 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004416:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000441a:	04649783          	lh	a5,70(s1)
    8000441e:	02f91223          	sh	a5,36(s2)
    80004422:	bf3d                	j	80004360 <sys_open+0x88>
    itrunc(ip);
    80004424:	8526                	mv	a0,s1
    80004426:	bd4fe0ef          	jal	800027fa <itrunc>
    8000442a:	b795                	j	8000438e <sys_open+0xb6>

000000008000442c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000442c:	7175                	addi	sp,sp,-144
    8000442e:	e506                	sd	ra,136(sp)
    80004430:	e122                	sd	s0,128(sp)
    80004432:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004434:	b6ffe0ef          	jal	80002fa2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004438:	08000613          	li	a2,128
    8000443c:	f7040593          	addi	a1,s0,-144
    80004440:	4501                	li	a0,0
    80004442:	819fd0ef          	jal	80001c5a <argstr>
    80004446:	02054363          	bltz	a0,8000446c <sys_mkdir+0x40>
    8000444a:	4681                	li	a3,0
    8000444c:	4601                	li	a2,0
    8000444e:	4585                	li	a1,1
    80004450:	f7040513          	addi	a0,s0,-144
    80004454:	96fff0ef          	jal	80003dc2 <create>
    80004458:	c911                	beqz	a0,8000446c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000445a:	cbcfe0ef          	jal	80002916 <iunlockput>
  end_op();
    8000445e:	baffe0ef          	jal	8000300c <end_op>
  return 0;
    80004462:	4501                	li	a0,0
}
    80004464:	60aa                	ld	ra,136(sp)
    80004466:	640a                	ld	s0,128(sp)
    80004468:	6149                	addi	sp,sp,144
    8000446a:	8082                	ret
    end_op();
    8000446c:	ba1fe0ef          	jal	8000300c <end_op>
    return -1;
    80004470:	557d                	li	a0,-1
    80004472:	bfcd                	j	80004464 <sys_mkdir+0x38>

0000000080004474 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004474:	7135                	addi	sp,sp,-160
    80004476:	ed06                	sd	ra,152(sp)
    80004478:	e922                	sd	s0,144(sp)
    8000447a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000447c:	b27fe0ef          	jal	80002fa2 <begin_op>
  argint(1, &major);
    80004480:	f6c40593          	addi	a1,s0,-148
    80004484:	4505                	li	a0,1
    80004486:	f9cfd0ef          	jal	80001c22 <argint>
  argint(2, &minor);
    8000448a:	f6840593          	addi	a1,s0,-152
    8000448e:	4509                	li	a0,2
    80004490:	f92fd0ef          	jal	80001c22 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004494:	08000613          	li	a2,128
    80004498:	f7040593          	addi	a1,s0,-144
    8000449c:	4501                	li	a0,0
    8000449e:	fbcfd0ef          	jal	80001c5a <argstr>
    800044a2:	02054563          	bltz	a0,800044cc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800044a6:	f6841683          	lh	a3,-152(s0)
    800044aa:	f6c41603          	lh	a2,-148(s0)
    800044ae:	458d                	li	a1,3
    800044b0:	f7040513          	addi	a0,s0,-144
    800044b4:	90fff0ef          	jal	80003dc2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800044b8:	c911                	beqz	a0,800044cc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800044ba:	c5cfe0ef          	jal	80002916 <iunlockput>
  end_op();
    800044be:	b4ffe0ef          	jal	8000300c <end_op>
  return 0;
    800044c2:	4501                	li	a0,0
}
    800044c4:	60ea                	ld	ra,152(sp)
    800044c6:	644a                	ld	s0,144(sp)
    800044c8:	610d                	addi	sp,sp,160
    800044ca:	8082                	ret
    end_op();
    800044cc:	b41fe0ef          	jal	8000300c <end_op>
    return -1;
    800044d0:	557d                	li	a0,-1
    800044d2:	bfcd                	j	800044c4 <sys_mknod+0x50>

00000000800044d4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800044d4:	7135                	addi	sp,sp,-160
    800044d6:	ed06                	sd	ra,152(sp)
    800044d8:	e922                	sd	s0,144(sp)
    800044da:	e14a                	sd	s2,128(sp)
    800044dc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800044de:	889fc0ef          	jal	80000d66 <myproc>
    800044e2:	892a                	mv	s2,a0
  
  begin_op();
    800044e4:	abffe0ef          	jal	80002fa2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800044e8:	08000613          	li	a2,128
    800044ec:	f6040593          	addi	a1,s0,-160
    800044f0:	4501                	li	a0,0
    800044f2:	f68fd0ef          	jal	80001c5a <argstr>
    800044f6:	04054363          	bltz	a0,8000453c <sys_chdir+0x68>
    800044fa:	e526                	sd	s1,136(sp)
    800044fc:	f6040513          	addi	a0,s0,-160
    80004500:	8e7fe0ef          	jal	80002de6 <namei>
    80004504:	84aa                	mv	s1,a0
    80004506:	c915                	beqz	a0,8000453a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004508:	a04fe0ef          	jal	8000270c <ilock>
  if(ip->type != T_DIR){
    8000450c:	04449703          	lh	a4,68(s1)
    80004510:	4785                	li	a5,1
    80004512:	02f71963          	bne	a4,a5,80004544 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004516:	8526                	mv	a0,s1
    80004518:	aa2fe0ef          	jal	800027ba <iunlock>
  iput(p->cwd);
    8000451c:	15093503          	ld	a0,336(s2)
    80004520:	b6efe0ef          	jal	8000288e <iput>
  end_op();
    80004524:	ae9fe0ef          	jal	8000300c <end_op>
  p->cwd = ip;
    80004528:	14993823          	sd	s1,336(s2)
  return 0;
    8000452c:	4501                	li	a0,0
    8000452e:	64aa                	ld	s1,136(sp)
}
    80004530:	60ea                	ld	ra,152(sp)
    80004532:	644a                	ld	s0,144(sp)
    80004534:	690a                	ld	s2,128(sp)
    80004536:	610d                	addi	sp,sp,160
    80004538:	8082                	ret
    8000453a:	64aa                	ld	s1,136(sp)
    end_op();
    8000453c:	ad1fe0ef          	jal	8000300c <end_op>
    return -1;
    80004540:	557d                	li	a0,-1
    80004542:	b7fd                	j	80004530 <sys_chdir+0x5c>
    iunlockput(ip);
    80004544:	8526                	mv	a0,s1
    80004546:	bd0fe0ef          	jal	80002916 <iunlockput>
    end_op();
    8000454a:	ac3fe0ef          	jal	8000300c <end_op>
    return -1;
    8000454e:	557d                	li	a0,-1
    80004550:	64aa                	ld	s1,136(sp)
    80004552:	bff9                	j	80004530 <sys_chdir+0x5c>

0000000080004554 <sys_exec>:

uint64
sys_exec(void)
{
    80004554:	7121                	addi	sp,sp,-448
    80004556:	ff06                	sd	ra,440(sp)
    80004558:	fb22                	sd	s0,432(sp)
    8000455a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000455c:	e4840593          	addi	a1,s0,-440
    80004560:	4505                	li	a0,1
    80004562:	edcfd0ef          	jal	80001c3e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004566:	08000613          	li	a2,128
    8000456a:	f5040593          	addi	a1,s0,-176
    8000456e:	4501                	li	a0,0
    80004570:	eeafd0ef          	jal	80001c5a <argstr>
    80004574:	87aa                	mv	a5,a0
    return -1;
    80004576:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004578:	0c07c463          	bltz	a5,80004640 <sys_exec+0xec>
    8000457c:	f726                	sd	s1,424(sp)
    8000457e:	f34a                	sd	s2,416(sp)
    80004580:	ef4e                	sd	s3,408(sp)
    80004582:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004584:	10000613          	li	a2,256
    80004588:	4581                	li	a1,0
    8000458a:	e5040513          	addi	a0,s0,-432
    8000458e:	bc1fb0ef          	jal	8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004592:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004596:	89a6                	mv	s3,s1
    80004598:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000459a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000459e:	00391513          	slli	a0,s2,0x3
    800045a2:	e4040593          	addi	a1,s0,-448
    800045a6:	e4843783          	ld	a5,-440(s0)
    800045aa:	953e                	add	a0,a0,a5
    800045ac:	decfd0ef          	jal	80001b98 <fetchaddr>
    800045b0:	02054663          	bltz	a0,800045dc <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800045b4:	e4043783          	ld	a5,-448(s0)
    800045b8:	c3a9                	beqz	a5,800045fa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800045ba:	b45fb0ef          	jal	800000fe <kalloc>
    800045be:	85aa                	mv	a1,a0
    800045c0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800045c4:	cd01                	beqz	a0,800045dc <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800045c6:	6605                	lui	a2,0x1
    800045c8:	e4043503          	ld	a0,-448(s0)
    800045cc:	e16fd0ef          	jal	80001be2 <fetchstr>
    800045d0:	00054663          	bltz	a0,800045dc <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800045d4:	0905                	addi	s2,s2,1
    800045d6:	09a1                	addi	s3,s3,8
    800045d8:	fd4913e3          	bne	s2,s4,8000459e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045dc:	f5040913          	addi	s2,s0,-176
    800045e0:	6088                	ld	a0,0(s1)
    800045e2:	c931                	beqz	a0,80004636 <sys_exec+0xe2>
    kfree(argv[i]);
    800045e4:	a39fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800045e8:	04a1                	addi	s1,s1,8
    800045ea:	ff249be3          	bne	s1,s2,800045e0 <sys_exec+0x8c>
  return -1;
    800045ee:	557d                	li	a0,-1
    800045f0:	74ba                	ld	s1,424(sp)
    800045f2:	791a                	ld	s2,416(sp)
    800045f4:	69fa                	ld	s3,408(sp)
    800045f6:	6a5a                	ld	s4,400(sp)
    800045f8:	a0a1                	j	80004640 <sys_exec+0xec>
      argv[i] = 0;
    800045fa:	0009079b          	sext.w	a5,s2
    800045fe:	078e                	slli	a5,a5,0x3
    80004600:	fd078793          	addi	a5,a5,-48
    80004604:	97a2                	add	a5,a5,s0
    80004606:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000460a:	e5040593          	addi	a1,s0,-432
    8000460e:	f5040513          	addi	a0,s0,-176
    80004612:	ba8ff0ef          	jal	800039ba <exec>
    80004616:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004618:	f5040993          	addi	s3,s0,-176
    8000461c:	6088                	ld	a0,0(s1)
    8000461e:	c511                	beqz	a0,8000462a <sys_exec+0xd6>
    kfree(argv[i]);
    80004620:	9fdfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004624:	04a1                	addi	s1,s1,8
    80004626:	ff349be3          	bne	s1,s3,8000461c <sys_exec+0xc8>
  return ret;
    8000462a:	854a                	mv	a0,s2
    8000462c:	74ba                	ld	s1,424(sp)
    8000462e:	791a                	ld	s2,416(sp)
    80004630:	69fa                	ld	s3,408(sp)
    80004632:	6a5a                	ld	s4,400(sp)
    80004634:	a031                	j	80004640 <sys_exec+0xec>
  return -1;
    80004636:	557d                	li	a0,-1
    80004638:	74ba                	ld	s1,424(sp)
    8000463a:	791a                	ld	s2,416(sp)
    8000463c:	69fa                	ld	s3,408(sp)
    8000463e:	6a5a                	ld	s4,400(sp)
}
    80004640:	70fa                	ld	ra,440(sp)
    80004642:	745a                	ld	s0,432(sp)
    80004644:	6139                	addi	sp,sp,448
    80004646:	8082                	ret

0000000080004648 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004648:	7139                	addi	sp,sp,-64
    8000464a:	fc06                	sd	ra,56(sp)
    8000464c:	f822                	sd	s0,48(sp)
    8000464e:	f426                	sd	s1,40(sp)
    80004650:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004652:	f14fc0ef          	jal	80000d66 <myproc>
    80004656:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004658:	fd840593          	addi	a1,s0,-40
    8000465c:	4501                	li	a0,0
    8000465e:	de0fd0ef          	jal	80001c3e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004662:	fc840593          	addi	a1,s0,-56
    80004666:	fd040513          	addi	a0,s0,-48
    8000466a:	85cff0ef          	jal	800036c6 <pipealloc>
    return -1;
    8000466e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004670:	0a054463          	bltz	a0,80004718 <sys_pipe+0xd0>
  fd0 = -1;
    80004674:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004678:	fd043503          	ld	a0,-48(s0)
    8000467c:	f08ff0ef          	jal	80003d84 <fdalloc>
    80004680:	fca42223          	sw	a0,-60(s0)
    80004684:	08054163          	bltz	a0,80004706 <sys_pipe+0xbe>
    80004688:	fc843503          	ld	a0,-56(s0)
    8000468c:	ef8ff0ef          	jal	80003d84 <fdalloc>
    80004690:	fca42023          	sw	a0,-64(s0)
    80004694:	06054063          	bltz	a0,800046f4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004698:	4691                	li	a3,4
    8000469a:	fc440613          	addi	a2,s0,-60
    8000469e:	fd843583          	ld	a1,-40(s0)
    800046a2:	68a8                	ld	a0,80(s1)
    800046a4:	b34fc0ef          	jal	800009d8 <copyout>
    800046a8:	00054e63          	bltz	a0,800046c4 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800046ac:	4691                	li	a3,4
    800046ae:	fc040613          	addi	a2,s0,-64
    800046b2:	fd843583          	ld	a1,-40(s0)
    800046b6:	0591                	addi	a1,a1,4
    800046b8:	68a8                	ld	a0,80(s1)
    800046ba:	b1efc0ef          	jal	800009d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800046be:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800046c0:	04055c63          	bgez	a0,80004718 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800046c4:	fc442783          	lw	a5,-60(s0)
    800046c8:	07e9                	addi	a5,a5,26
    800046ca:	078e                	slli	a5,a5,0x3
    800046cc:	97a6                	add	a5,a5,s1
    800046ce:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800046d2:	fc042783          	lw	a5,-64(s0)
    800046d6:	07e9                	addi	a5,a5,26
    800046d8:	078e                	slli	a5,a5,0x3
    800046da:	94be                	add	s1,s1,a5
    800046dc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800046e0:	fd043503          	ld	a0,-48(s0)
    800046e4:	cd9fe0ef          	jal	800033bc <fileclose>
    fileclose(wf);
    800046e8:	fc843503          	ld	a0,-56(s0)
    800046ec:	cd1fe0ef          	jal	800033bc <fileclose>
    return -1;
    800046f0:	57fd                	li	a5,-1
    800046f2:	a01d                	j	80004718 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800046f4:	fc442783          	lw	a5,-60(s0)
    800046f8:	0007c763          	bltz	a5,80004706 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800046fc:	07e9                	addi	a5,a5,26
    800046fe:	078e                	slli	a5,a5,0x3
    80004700:	97a6                	add	a5,a5,s1
    80004702:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004706:	fd043503          	ld	a0,-48(s0)
    8000470a:	cb3fe0ef          	jal	800033bc <fileclose>
    fileclose(wf);
    8000470e:	fc843503          	ld	a0,-56(s0)
    80004712:	cabfe0ef          	jal	800033bc <fileclose>
    return -1;
    80004716:	57fd                	li	a5,-1
}
    80004718:	853e                	mv	a0,a5
    8000471a:	70e2                	ld	ra,56(sp)
    8000471c:	7442                	ld	s0,48(sp)
    8000471e:	74a2                	ld	s1,40(sp)
    80004720:	6121                	addi	sp,sp,64
    80004722:	8082                	ret
	...

0000000080004730 <kernelvec>:
    80004730:	7111                	addi	sp,sp,-256
    80004732:	e006                	sd	ra,0(sp)
    80004734:	e40a                	sd	sp,8(sp)
    80004736:	e80e                	sd	gp,16(sp)
    80004738:	ec12                	sd	tp,24(sp)
    8000473a:	f016                	sd	t0,32(sp)
    8000473c:	f41a                	sd	t1,40(sp)
    8000473e:	f81e                	sd	t2,48(sp)
    80004740:	e4aa                	sd	a0,72(sp)
    80004742:	e8ae                	sd	a1,80(sp)
    80004744:	ecb2                	sd	a2,88(sp)
    80004746:	f0b6                	sd	a3,96(sp)
    80004748:	f4ba                	sd	a4,104(sp)
    8000474a:	f8be                	sd	a5,112(sp)
    8000474c:	fcc2                	sd	a6,120(sp)
    8000474e:	e146                	sd	a7,128(sp)
    80004750:	edf2                	sd	t3,216(sp)
    80004752:	f1f6                	sd	t4,224(sp)
    80004754:	f5fa                	sd	t5,232(sp)
    80004756:	f9fe                	sd	t6,240(sp)
    80004758:	b50fd0ef          	jal	80001aa8 <kerneltrap>
    8000475c:	6082                	ld	ra,0(sp)
    8000475e:	6122                	ld	sp,8(sp)
    80004760:	61c2                	ld	gp,16(sp)
    80004762:	7282                	ld	t0,32(sp)
    80004764:	7322                	ld	t1,40(sp)
    80004766:	73c2                	ld	t2,48(sp)
    80004768:	6526                	ld	a0,72(sp)
    8000476a:	65c6                	ld	a1,80(sp)
    8000476c:	6666                	ld	a2,88(sp)
    8000476e:	7686                	ld	a3,96(sp)
    80004770:	7726                	ld	a4,104(sp)
    80004772:	77c6                	ld	a5,112(sp)
    80004774:	7866                	ld	a6,120(sp)
    80004776:	688a                	ld	a7,128(sp)
    80004778:	6e6e                	ld	t3,216(sp)
    8000477a:	7e8e                	ld	t4,224(sp)
    8000477c:	7f2e                	ld	t5,232(sp)
    8000477e:	7fce                	ld	t6,240(sp)
    80004780:	6111                	addi	sp,sp,256
    80004782:	10200073          	sret
	...

000000008000478e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000478e:	1141                	addi	sp,sp,-16
    80004790:	e422                	sd	s0,8(sp)
    80004792:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004794:	0c0007b7          	lui	a5,0xc000
    80004798:	4705                	li	a4,1
    8000479a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000479c:	0c0007b7          	lui	a5,0xc000
    800047a0:	c3d8                	sw	a4,4(a5)
}
    800047a2:	6422                	ld	s0,8(sp)
    800047a4:	0141                	addi	sp,sp,16
    800047a6:	8082                	ret

00000000800047a8 <plicinithart>:

void
plicinithart(void)
{
    800047a8:	1141                	addi	sp,sp,-16
    800047aa:	e406                	sd	ra,8(sp)
    800047ac:	e022                	sd	s0,0(sp)
    800047ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800047b0:	d8afc0ef          	jal	80000d3a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800047b4:	0085171b          	slliw	a4,a0,0x8
    800047b8:	0c0027b7          	lui	a5,0xc002
    800047bc:	97ba                	add	a5,a5,a4
    800047be:	40200713          	li	a4,1026
    800047c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800047c6:	00d5151b          	slliw	a0,a0,0xd
    800047ca:	0c2017b7          	lui	a5,0xc201
    800047ce:	97aa                	add	a5,a5,a0
    800047d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800047d4:	60a2                	ld	ra,8(sp)
    800047d6:	6402                	ld	s0,0(sp)
    800047d8:	0141                	addi	sp,sp,16
    800047da:	8082                	ret

00000000800047dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800047dc:	1141                	addi	sp,sp,-16
    800047de:	e406                	sd	ra,8(sp)
    800047e0:	e022                	sd	s0,0(sp)
    800047e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800047e4:	d56fc0ef          	jal	80000d3a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800047e8:	00d5151b          	slliw	a0,a0,0xd
    800047ec:	0c2017b7          	lui	a5,0xc201
    800047f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800047f2:	43c8                	lw	a0,4(a5)
    800047f4:	60a2                	ld	ra,8(sp)
    800047f6:	6402                	ld	s0,0(sp)
    800047f8:	0141                	addi	sp,sp,16
    800047fa:	8082                	ret

00000000800047fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800047fc:	1101                	addi	sp,sp,-32
    800047fe:	ec06                	sd	ra,24(sp)
    80004800:	e822                	sd	s0,16(sp)
    80004802:	e426                	sd	s1,8(sp)
    80004804:	1000                	addi	s0,sp,32
    80004806:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004808:	d32fc0ef          	jal	80000d3a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000480c:	00d5151b          	slliw	a0,a0,0xd
    80004810:	0c2017b7          	lui	a5,0xc201
    80004814:	97aa                	add	a5,a5,a0
    80004816:	c3c4                	sw	s1,4(a5)
}
    80004818:	60e2                	ld	ra,24(sp)
    8000481a:	6442                	ld	s0,16(sp)
    8000481c:	64a2                	ld	s1,8(sp)
    8000481e:	6105                	addi	sp,sp,32
    80004820:	8082                	ret

0000000080004822 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004822:	1141                	addi	sp,sp,-16
    80004824:	e406                	sd	ra,8(sp)
    80004826:	e022                	sd	s0,0(sp)
    80004828:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000482a:	479d                	li	a5,7
    8000482c:	04a7ca63          	blt	a5,a0,80004880 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004830:	00017797          	auipc	a5,0x17
    80004834:	f2078793          	addi	a5,a5,-224 # 8001b750 <disk>
    80004838:	97aa                	add	a5,a5,a0
    8000483a:	0187c783          	lbu	a5,24(a5)
    8000483e:	e7b9                	bnez	a5,8000488c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004840:	00451693          	slli	a3,a0,0x4
    80004844:	00017797          	auipc	a5,0x17
    80004848:	f0c78793          	addi	a5,a5,-244 # 8001b750 <disk>
    8000484c:	6398                	ld	a4,0(a5)
    8000484e:	9736                	add	a4,a4,a3
    80004850:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004854:	6398                	ld	a4,0(a5)
    80004856:	9736                	add	a4,a4,a3
    80004858:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000485c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004860:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004864:	97aa                	add	a5,a5,a0
    80004866:	4705                	li	a4,1
    80004868:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000486c:	00017517          	auipc	a0,0x17
    80004870:	efc50513          	addi	a0,a0,-260 # 8001b768 <disk+0x18>
    80004874:	b15fc0ef          	jal	80001388 <wakeup>
}
    80004878:	60a2                	ld	ra,8(sp)
    8000487a:	6402                	ld	s0,0(sp)
    8000487c:	0141                	addi	sp,sp,16
    8000487e:	8082                	ret
    panic("free_desc 1");
    80004880:	00003517          	auipc	a0,0x3
    80004884:	e7850513          	addi	a0,a0,-392 # 800076f8 <etext+0x6f8>
    80004888:	43b000ef          	jal	800054c2 <panic>
    panic("free_desc 2");
    8000488c:	00003517          	auipc	a0,0x3
    80004890:	e7c50513          	addi	a0,a0,-388 # 80007708 <etext+0x708>
    80004894:	42f000ef          	jal	800054c2 <panic>

0000000080004898 <virtio_disk_init>:
{
    80004898:	1101                	addi	sp,sp,-32
    8000489a:	ec06                	sd	ra,24(sp)
    8000489c:	e822                	sd	s0,16(sp)
    8000489e:	e426                	sd	s1,8(sp)
    800048a0:	e04a                	sd	s2,0(sp)
    800048a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800048a4:	00003597          	auipc	a1,0x3
    800048a8:	e7458593          	addi	a1,a1,-396 # 80007718 <etext+0x718>
    800048ac:	00017517          	auipc	a0,0x17
    800048b0:	fcc50513          	addi	a0,a0,-52 # 8001b878 <disk+0x128>
    800048b4:	6bd000ef          	jal	80005770 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800048b8:	100017b7          	lui	a5,0x10001
    800048bc:	4398                	lw	a4,0(a5)
    800048be:	2701                	sext.w	a4,a4
    800048c0:	747277b7          	lui	a5,0x74727
    800048c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800048c8:	18f71063          	bne	a4,a5,80004a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800048cc:	100017b7          	lui	a5,0x10001
    800048d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800048d2:	439c                	lw	a5,0(a5)
    800048d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800048d6:	4709                	li	a4,2
    800048d8:	16e79863          	bne	a5,a4,80004a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048dc:	100017b7          	lui	a5,0x10001
    800048e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800048e2:	439c                	lw	a5,0(a5)
    800048e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800048e6:	16e79163          	bne	a5,a4,80004a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800048ea:	100017b7          	lui	a5,0x10001
    800048ee:	47d8                	lw	a4,12(a5)
    800048f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800048f2:	554d47b7          	lui	a5,0x554d4
    800048f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800048fa:	14f71763          	bne	a4,a5,80004a48 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800048fe:	100017b7          	lui	a5,0x10001
    80004902:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004906:	4705                	li	a4,1
    80004908:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000490a:	470d                	li	a4,3
    8000490c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000490e:	10001737          	lui	a4,0x10001
    80004912:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004914:	c7ffe737          	lui	a4,0xc7ffe
    80004918:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdadcf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000491c:	8ef9                	and	a3,a3,a4
    8000491e:	10001737          	lui	a4,0x10001
    80004922:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004924:	472d                	li	a4,11
    80004926:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004928:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000492c:	439c                	lw	a5,0(a5)
    8000492e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004932:	8ba1                	andi	a5,a5,8
    80004934:	12078063          	beqz	a5,80004a54 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004938:	100017b7          	lui	a5,0x10001
    8000493c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004940:	100017b7          	lui	a5,0x10001
    80004944:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004948:	439c                	lw	a5,0(a5)
    8000494a:	2781                	sext.w	a5,a5
    8000494c:	10079a63          	bnez	a5,80004a60 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004950:	100017b7          	lui	a5,0x10001
    80004954:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004958:	439c                	lw	a5,0(a5)
    8000495a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000495c:	10078863          	beqz	a5,80004a6c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004960:	471d                	li	a4,7
    80004962:	10f77b63          	bgeu	a4,a5,80004a78 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004966:	f98fb0ef          	jal	800000fe <kalloc>
    8000496a:	00017497          	auipc	s1,0x17
    8000496e:	de648493          	addi	s1,s1,-538 # 8001b750 <disk>
    80004972:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004974:	f8afb0ef          	jal	800000fe <kalloc>
    80004978:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000497a:	f84fb0ef          	jal	800000fe <kalloc>
    8000497e:	87aa                	mv	a5,a0
    80004980:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004982:	6088                	ld	a0,0(s1)
    80004984:	10050063          	beqz	a0,80004a84 <virtio_disk_init+0x1ec>
    80004988:	00017717          	auipc	a4,0x17
    8000498c:	dd073703          	ld	a4,-560(a4) # 8001b758 <disk+0x8>
    80004990:	0e070a63          	beqz	a4,80004a84 <virtio_disk_init+0x1ec>
    80004994:	0e078863          	beqz	a5,80004a84 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004998:	6605                	lui	a2,0x1
    8000499a:	4581                	li	a1,0
    8000499c:	fb2fb0ef          	jal	8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    800049a0:	00017497          	auipc	s1,0x17
    800049a4:	db048493          	addi	s1,s1,-592 # 8001b750 <disk>
    800049a8:	6605                	lui	a2,0x1
    800049aa:	4581                	li	a1,0
    800049ac:	6488                	ld	a0,8(s1)
    800049ae:	fa0fb0ef          	jal	8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    800049b2:	6605                	lui	a2,0x1
    800049b4:	4581                	li	a1,0
    800049b6:	6888                	ld	a0,16(s1)
    800049b8:	f96fb0ef          	jal	8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800049bc:	100017b7          	lui	a5,0x10001
    800049c0:	4721                	li	a4,8
    800049c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800049c4:	4098                	lw	a4,0(s1)
    800049c6:	100017b7          	lui	a5,0x10001
    800049ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800049ce:	40d8                	lw	a4,4(s1)
    800049d0:	100017b7          	lui	a5,0x10001
    800049d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800049d8:	649c                	ld	a5,8(s1)
    800049da:	0007869b          	sext.w	a3,a5
    800049de:	10001737          	lui	a4,0x10001
    800049e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800049e6:	9781                	srai	a5,a5,0x20
    800049e8:	10001737          	lui	a4,0x10001
    800049ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800049f0:	689c                	ld	a5,16(s1)
    800049f2:	0007869b          	sext.w	a3,a5
    800049f6:	10001737          	lui	a4,0x10001
    800049fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800049fe:	9781                	srai	a5,a5,0x20
    80004a00:	10001737          	lui	a4,0x10001
    80004a04:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004a08:	10001737          	lui	a4,0x10001
    80004a0c:	4785                	li	a5,1
    80004a0e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004a10:	00f48c23          	sb	a5,24(s1)
    80004a14:	00f48ca3          	sb	a5,25(s1)
    80004a18:	00f48d23          	sb	a5,26(s1)
    80004a1c:	00f48da3          	sb	a5,27(s1)
    80004a20:	00f48e23          	sb	a5,28(s1)
    80004a24:	00f48ea3          	sb	a5,29(s1)
    80004a28:	00f48f23          	sb	a5,30(s1)
    80004a2c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004a30:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a34:	100017b7          	lui	a5,0x10001
    80004a38:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004a3c:	60e2                	ld	ra,24(sp)
    80004a3e:	6442                	ld	s0,16(sp)
    80004a40:	64a2                	ld	s1,8(sp)
    80004a42:	6902                	ld	s2,0(sp)
    80004a44:	6105                	addi	sp,sp,32
    80004a46:	8082                	ret
    panic("could not find virtio disk");
    80004a48:	00003517          	auipc	a0,0x3
    80004a4c:	ce050513          	addi	a0,a0,-800 # 80007728 <etext+0x728>
    80004a50:	273000ef          	jal	800054c2 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004a54:	00003517          	auipc	a0,0x3
    80004a58:	cf450513          	addi	a0,a0,-780 # 80007748 <etext+0x748>
    80004a5c:	267000ef          	jal	800054c2 <panic>
    panic("virtio disk should not be ready");
    80004a60:	00003517          	auipc	a0,0x3
    80004a64:	d0850513          	addi	a0,a0,-760 # 80007768 <etext+0x768>
    80004a68:	25b000ef          	jal	800054c2 <panic>
    panic("virtio disk has no queue 0");
    80004a6c:	00003517          	auipc	a0,0x3
    80004a70:	d1c50513          	addi	a0,a0,-740 # 80007788 <etext+0x788>
    80004a74:	24f000ef          	jal	800054c2 <panic>
    panic("virtio disk max queue too short");
    80004a78:	00003517          	auipc	a0,0x3
    80004a7c:	d3050513          	addi	a0,a0,-720 # 800077a8 <etext+0x7a8>
    80004a80:	243000ef          	jal	800054c2 <panic>
    panic("virtio disk kalloc");
    80004a84:	00003517          	auipc	a0,0x3
    80004a88:	d4450513          	addi	a0,a0,-700 # 800077c8 <etext+0x7c8>
    80004a8c:	237000ef          	jal	800054c2 <panic>

0000000080004a90 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004a90:	7159                	addi	sp,sp,-112
    80004a92:	f486                	sd	ra,104(sp)
    80004a94:	f0a2                	sd	s0,96(sp)
    80004a96:	eca6                	sd	s1,88(sp)
    80004a98:	e8ca                	sd	s2,80(sp)
    80004a9a:	e4ce                	sd	s3,72(sp)
    80004a9c:	e0d2                	sd	s4,64(sp)
    80004a9e:	fc56                	sd	s5,56(sp)
    80004aa0:	f85a                	sd	s6,48(sp)
    80004aa2:	f45e                	sd	s7,40(sp)
    80004aa4:	f062                	sd	s8,32(sp)
    80004aa6:	ec66                	sd	s9,24(sp)
    80004aa8:	1880                	addi	s0,sp,112
    80004aaa:	8a2a                	mv	s4,a0
    80004aac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004aae:	00c52c83          	lw	s9,12(a0)
    80004ab2:	001c9c9b          	slliw	s9,s9,0x1
    80004ab6:	1c82                	slli	s9,s9,0x20
    80004ab8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004abc:	00017517          	auipc	a0,0x17
    80004ac0:	dbc50513          	addi	a0,a0,-580 # 8001b878 <disk+0x128>
    80004ac4:	52d000ef          	jal	800057f0 <acquire>
  for(int i = 0; i < 3; i++){
    80004ac8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004aca:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004acc:	00017b17          	auipc	s6,0x17
    80004ad0:	c84b0b13          	addi	s6,s6,-892 # 8001b750 <disk>
  for(int i = 0; i < 3; i++){
    80004ad4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004ad6:	00017c17          	auipc	s8,0x17
    80004ada:	da2c0c13          	addi	s8,s8,-606 # 8001b878 <disk+0x128>
    80004ade:	a8b9                	j	80004b3c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004ae0:	00fb0733          	add	a4,s6,a5
    80004ae4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004ae8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004aea:	0207c563          	bltz	a5,80004b14 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004aee:	2905                	addiw	s2,s2,1
    80004af0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004af2:	05590963          	beq	s2,s5,80004b44 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004af6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004af8:	00017717          	auipc	a4,0x17
    80004afc:	c5870713          	addi	a4,a4,-936 # 8001b750 <disk>
    80004b00:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004b02:	01874683          	lbu	a3,24(a4)
    80004b06:	fee9                	bnez	a3,80004ae0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004b08:	2785                	addiw	a5,a5,1
    80004b0a:	0705                	addi	a4,a4,1
    80004b0c:	fe979be3          	bne	a5,s1,80004b02 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004b10:	57fd                	li	a5,-1
    80004b12:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004b14:	01205d63          	blez	s2,80004b2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004b18:	f9042503          	lw	a0,-112(s0)
    80004b1c:	d07ff0ef          	jal	80004822 <free_desc>
      for(int j = 0; j < i; j++)
    80004b20:	4785                	li	a5,1
    80004b22:	0127d663          	bge	a5,s2,80004b2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004b26:	f9442503          	lw	a0,-108(s0)
    80004b2a:	cf9ff0ef          	jal	80004822 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004b2e:	85e2                	mv	a1,s8
    80004b30:	00017517          	auipc	a0,0x17
    80004b34:	c3850513          	addi	a0,a0,-968 # 8001b768 <disk+0x18>
    80004b38:	805fc0ef          	jal	8000133c <sleep>
  for(int i = 0; i < 3; i++){
    80004b3c:	f9040613          	addi	a2,s0,-112
    80004b40:	894e                	mv	s2,s3
    80004b42:	bf55                	j	80004af6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b44:	f9042503          	lw	a0,-112(s0)
    80004b48:	00451693          	slli	a3,a0,0x4

  if(write)
    80004b4c:	00017797          	auipc	a5,0x17
    80004b50:	c0478793          	addi	a5,a5,-1020 # 8001b750 <disk>
    80004b54:	00a50713          	addi	a4,a0,10
    80004b58:	0712                	slli	a4,a4,0x4
    80004b5a:	973e                	add	a4,a4,a5
    80004b5c:	01703633          	snez	a2,s7
    80004b60:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004b62:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004b66:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b6a:	6398                	ld	a4,0(a5)
    80004b6c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b6e:	0a868613          	addi	a2,a3,168
    80004b72:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004b74:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004b76:	6390                	ld	a2,0(a5)
    80004b78:	00d605b3          	add	a1,a2,a3
    80004b7c:	4741                	li	a4,16
    80004b7e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004b80:	4805                	li	a6,1
    80004b82:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004b86:	f9442703          	lw	a4,-108(s0)
    80004b8a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004b8e:	0712                	slli	a4,a4,0x4
    80004b90:	963a                	add	a2,a2,a4
    80004b92:	058a0593          	addi	a1,s4,88
    80004b96:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004b98:	0007b883          	ld	a7,0(a5)
    80004b9c:	9746                	add	a4,a4,a7
    80004b9e:	40000613          	li	a2,1024
    80004ba2:	c710                	sw	a2,8(a4)
  if(write)
    80004ba4:	001bb613          	seqz	a2,s7
    80004ba8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004bac:	00166613          	ori	a2,a2,1
    80004bb0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004bb4:	f9842583          	lw	a1,-104(s0)
    80004bb8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004bbc:	00250613          	addi	a2,a0,2
    80004bc0:	0612                	slli	a2,a2,0x4
    80004bc2:	963e                	add	a2,a2,a5
    80004bc4:	577d                	li	a4,-1
    80004bc6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004bca:	0592                	slli	a1,a1,0x4
    80004bcc:	98ae                	add	a7,a7,a1
    80004bce:	03068713          	addi	a4,a3,48
    80004bd2:	973e                	add	a4,a4,a5
    80004bd4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004bd8:	6398                	ld	a4,0(a5)
    80004bda:	972e                	add	a4,a4,a1
    80004bdc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004be0:	4689                	li	a3,2
    80004be2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004be6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004bea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004bee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004bf2:	6794                	ld	a3,8(a5)
    80004bf4:	0026d703          	lhu	a4,2(a3)
    80004bf8:	8b1d                	andi	a4,a4,7
    80004bfa:	0706                	slli	a4,a4,0x1
    80004bfc:	96ba                	add	a3,a3,a4
    80004bfe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004c02:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004c06:	6798                	ld	a4,8(a5)
    80004c08:	00275783          	lhu	a5,2(a4)
    80004c0c:	2785                	addiw	a5,a5,1
    80004c0e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004c12:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004c16:	100017b7          	lui	a5,0x10001
    80004c1a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004c1e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004c22:	00017917          	auipc	s2,0x17
    80004c26:	c5690913          	addi	s2,s2,-938 # 8001b878 <disk+0x128>
  while(b->disk == 1) {
    80004c2a:	4485                	li	s1,1
    80004c2c:	01079a63          	bne	a5,a6,80004c40 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004c30:	85ca                	mv	a1,s2
    80004c32:	8552                	mv	a0,s4
    80004c34:	f08fc0ef          	jal	8000133c <sleep>
  while(b->disk == 1) {
    80004c38:	004a2783          	lw	a5,4(s4)
    80004c3c:	fe978ae3          	beq	a5,s1,80004c30 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004c40:	f9042903          	lw	s2,-112(s0)
    80004c44:	00290713          	addi	a4,s2,2
    80004c48:	0712                	slli	a4,a4,0x4
    80004c4a:	00017797          	auipc	a5,0x17
    80004c4e:	b0678793          	addi	a5,a5,-1274 # 8001b750 <disk>
    80004c52:	97ba                	add	a5,a5,a4
    80004c54:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004c58:	00017997          	auipc	s3,0x17
    80004c5c:	af898993          	addi	s3,s3,-1288 # 8001b750 <disk>
    80004c60:	00491713          	slli	a4,s2,0x4
    80004c64:	0009b783          	ld	a5,0(s3)
    80004c68:	97ba                	add	a5,a5,a4
    80004c6a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004c6e:	854a                	mv	a0,s2
    80004c70:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004c74:	bafff0ef          	jal	80004822 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004c78:	8885                	andi	s1,s1,1
    80004c7a:	f0fd                	bnez	s1,80004c60 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004c7c:	00017517          	auipc	a0,0x17
    80004c80:	bfc50513          	addi	a0,a0,-1028 # 8001b878 <disk+0x128>
    80004c84:	405000ef          	jal	80005888 <release>
}
    80004c88:	70a6                	ld	ra,104(sp)
    80004c8a:	7406                	ld	s0,96(sp)
    80004c8c:	64e6                	ld	s1,88(sp)
    80004c8e:	6946                	ld	s2,80(sp)
    80004c90:	69a6                	ld	s3,72(sp)
    80004c92:	6a06                	ld	s4,64(sp)
    80004c94:	7ae2                	ld	s5,56(sp)
    80004c96:	7b42                	ld	s6,48(sp)
    80004c98:	7ba2                	ld	s7,40(sp)
    80004c9a:	7c02                	ld	s8,32(sp)
    80004c9c:	6ce2                	ld	s9,24(sp)
    80004c9e:	6165                	addi	sp,sp,112
    80004ca0:	8082                	ret

0000000080004ca2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004ca2:	1101                	addi	sp,sp,-32
    80004ca4:	ec06                	sd	ra,24(sp)
    80004ca6:	e822                	sd	s0,16(sp)
    80004ca8:	e426                	sd	s1,8(sp)
    80004caa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004cac:	00017497          	auipc	s1,0x17
    80004cb0:	aa448493          	addi	s1,s1,-1372 # 8001b750 <disk>
    80004cb4:	00017517          	auipc	a0,0x17
    80004cb8:	bc450513          	addi	a0,a0,-1084 # 8001b878 <disk+0x128>
    80004cbc:	335000ef          	jal	800057f0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004cc0:	100017b7          	lui	a5,0x10001
    80004cc4:	53b8                	lw	a4,96(a5)
    80004cc6:	8b0d                	andi	a4,a4,3
    80004cc8:	100017b7          	lui	a5,0x10001
    80004ccc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004cce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004cd2:	689c                	ld	a5,16(s1)
    80004cd4:	0204d703          	lhu	a4,32(s1)
    80004cd8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004cdc:	04f70663          	beq	a4,a5,80004d28 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004ce0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004ce4:	6898                	ld	a4,16(s1)
    80004ce6:	0204d783          	lhu	a5,32(s1)
    80004cea:	8b9d                	andi	a5,a5,7
    80004cec:	078e                	slli	a5,a5,0x3
    80004cee:	97ba                	add	a5,a5,a4
    80004cf0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004cf2:	00278713          	addi	a4,a5,2
    80004cf6:	0712                	slli	a4,a4,0x4
    80004cf8:	9726                	add	a4,a4,s1
    80004cfa:	01074703          	lbu	a4,16(a4)
    80004cfe:	e321                	bnez	a4,80004d3e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004d00:	0789                	addi	a5,a5,2
    80004d02:	0792                	slli	a5,a5,0x4
    80004d04:	97a6                	add	a5,a5,s1
    80004d06:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004d08:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004d0c:	e7cfc0ef          	jal	80001388 <wakeup>

    disk.used_idx += 1;
    80004d10:	0204d783          	lhu	a5,32(s1)
    80004d14:	2785                	addiw	a5,a5,1
    80004d16:	17c2                	slli	a5,a5,0x30
    80004d18:	93c1                	srli	a5,a5,0x30
    80004d1a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004d1e:	6898                	ld	a4,16(s1)
    80004d20:	00275703          	lhu	a4,2(a4)
    80004d24:	faf71ee3          	bne	a4,a5,80004ce0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004d28:	00017517          	auipc	a0,0x17
    80004d2c:	b5050513          	addi	a0,a0,-1200 # 8001b878 <disk+0x128>
    80004d30:	359000ef          	jal	80005888 <release>
}
    80004d34:	60e2                	ld	ra,24(sp)
    80004d36:	6442                	ld	s0,16(sp)
    80004d38:	64a2                	ld	s1,8(sp)
    80004d3a:	6105                	addi	sp,sp,32
    80004d3c:	8082                	ret
      panic("virtio_disk_intr status");
    80004d3e:	00003517          	auipc	a0,0x3
    80004d42:	aa250513          	addi	a0,a0,-1374 # 800077e0 <etext+0x7e0>
    80004d46:	77c000ef          	jal	800054c2 <panic>

0000000080004d4a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004d4a:	1141                	addi	sp,sp,-16
    80004d4c:	e422                	sd	s0,8(sp)
    80004d4e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004d50:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004d54:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004d58:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004d5c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004d60:	577d                	li	a4,-1
    80004d62:	177e                	slli	a4,a4,0x3f
    80004d64:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004d66:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004d6a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004d6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004d72:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004d76:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004d7a:	000f4737          	lui	a4,0xf4
    80004d7e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004d82:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004d84:	14d79073          	csrw	stimecmp,a5
}
    80004d88:	6422                	ld	s0,8(sp)
    80004d8a:	0141                	addi	sp,sp,16
    80004d8c:	8082                	ret

0000000080004d8e <start>:
{
    80004d8e:	1141                	addi	sp,sp,-16
    80004d90:	e406                	sd	ra,8(sp)
    80004d92:	e022                	sd	s0,0(sp)
    80004d94:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004d96:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004d9a:	7779                	lui	a4,0xffffe
    80004d9c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae6f>
    80004da0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004da2:	6705                	lui	a4,0x1
    80004da4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004da8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004daa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004dae:	ffffb797          	auipc	a5,0xffffb
    80004db2:	53a78793          	addi	a5,a5,1338 # 800002e8 <main>
    80004db6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004dba:	4781                	li	a5,0
    80004dbc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004dc0:	67c1                	lui	a5,0x10
    80004dc2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004dc4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004dc8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004dcc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004dd0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004dd4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004dd8:	57fd                	li	a5,-1
    80004dda:	83a9                	srli	a5,a5,0xa
    80004ddc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004de0:	47bd                	li	a5,15
    80004de2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004de6:	f65ff0ef          	jal	80004d4a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004dea:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004dee:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004df0:	823e                	mv	tp,a5
  asm volatile("mret");
    80004df2:	30200073          	mret
}
    80004df6:	60a2                	ld	ra,8(sp)
    80004df8:	6402                	ld	s0,0(sp)
    80004dfa:	0141                	addi	sp,sp,16
    80004dfc:	8082                	ret

0000000080004dfe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004dfe:	715d                	addi	sp,sp,-80
    80004e00:	e486                	sd	ra,72(sp)
    80004e02:	e0a2                	sd	s0,64(sp)
    80004e04:	f84a                	sd	s2,48(sp)
    80004e06:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004e08:	04c05263          	blez	a2,80004e4c <consolewrite+0x4e>
    80004e0c:	fc26                	sd	s1,56(sp)
    80004e0e:	f44e                	sd	s3,40(sp)
    80004e10:	f052                	sd	s4,32(sp)
    80004e12:	ec56                	sd	s5,24(sp)
    80004e14:	8a2a                	mv	s4,a0
    80004e16:	84ae                	mv	s1,a1
    80004e18:	89b2                	mv	s3,a2
    80004e1a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004e1c:	5afd                	li	s5,-1
    80004e1e:	4685                	li	a3,1
    80004e20:	8626                	mv	a2,s1
    80004e22:	85d2                	mv	a1,s4
    80004e24:	fbf40513          	addi	a0,s0,-65
    80004e28:	8bbfc0ef          	jal	800016e2 <either_copyin>
    80004e2c:	03550263          	beq	a0,s5,80004e50 <consolewrite+0x52>
      break;
    uartputc(c);
    80004e30:	fbf44503          	lbu	a0,-65(s0)
    80004e34:	035000ef          	jal	80005668 <uartputc>
  for(i = 0; i < n; i++){
    80004e38:	2905                	addiw	s2,s2,1
    80004e3a:	0485                	addi	s1,s1,1
    80004e3c:	ff2991e3          	bne	s3,s2,80004e1e <consolewrite+0x20>
    80004e40:	894e                	mv	s2,s3
    80004e42:	74e2                	ld	s1,56(sp)
    80004e44:	79a2                	ld	s3,40(sp)
    80004e46:	7a02                	ld	s4,32(sp)
    80004e48:	6ae2                	ld	s5,24(sp)
    80004e4a:	a039                	j	80004e58 <consolewrite+0x5a>
    80004e4c:	4901                	li	s2,0
    80004e4e:	a029                	j	80004e58 <consolewrite+0x5a>
    80004e50:	74e2                	ld	s1,56(sp)
    80004e52:	79a2                	ld	s3,40(sp)
    80004e54:	7a02                	ld	s4,32(sp)
    80004e56:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80004e58:	854a                	mv	a0,s2
    80004e5a:	60a6                	ld	ra,72(sp)
    80004e5c:	6406                	ld	s0,64(sp)
    80004e5e:	7942                	ld	s2,48(sp)
    80004e60:	6161                	addi	sp,sp,80
    80004e62:	8082                	ret

0000000080004e64 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004e64:	711d                	addi	sp,sp,-96
    80004e66:	ec86                	sd	ra,88(sp)
    80004e68:	e8a2                	sd	s0,80(sp)
    80004e6a:	e4a6                	sd	s1,72(sp)
    80004e6c:	e0ca                	sd	s2,64(sp)
    80004e6e:	fc4e                	sd	s3,56(sp)
    80004e70:	f852                	sd	s4,48(sp)
    80004e72:	f456                	sd	s5,40(sp)
    80004e74:	f05a                	sd	s6,32(sp)
    80004e76:	1080                	addi	s0,sp,96
    80004e78:	8aaa                	mv	s5,a0
    80004e7a:	8a2e                	mv	s4,a1
    80004e7c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004e7e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004e82:	0001f517          	auipc	a0,0x1f
    80004e86:	a0e50513          	addi	a0,a0,-1522 # 80023890 <cons>
    80004e8a:	167000ef          	jal	800057f0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004e8e:	0001f497          	auipc	s1,0x1f
    80004e92:	a0248493          	addi	s1,s1,-1534 # 80023890 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004e96:	0001f917          	auipc	s2,0x1f
    80004e9a:	a9290913          	addi	s2,s2,-1390 # 80023928 <cons+0x98>
  while(n > 0){
    80004e9e:	0b305d63          	blez	s3,80004f58 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004ea2:	0984a783          	lw	a5,152(s1)
    80004ea6:	09c4a703          	lw	a4,156(s1)
    80004eaa:	0af71263          	bne	a4,a5,80004f4e <consoleread+0xea>
      if(killed(myproc())){
    80004eae:	eb9fb0ef          	jal	80000d66 <myproc>
    80004eb2:	ec2fc0ef          	jal	80001574 <killed>
    80004eb6:	e12d                	bnez	a0,80004f18 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004eb8:	85a6                	mv	a1,s1
    80004eba:	854a                	mv	a0,s2
    80004ebc:	c80fc0ef          	jal	8000133c <sleep>
    while(cons.r == cons.w){
    80004ec0:	0984a783          	lw	a5,152(s1)
    80004ec4:	09c4a703          	lw	a4,156(s1)
    80004ec8:	fef703e3          	beq	a4,a5,80004eae <consoleread+0x4a>
    80004ecc:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004ece:	0001f717          	auipc	a4,0x1f
    80004ed2:	9c270713          	addi	a4,a4,-1598 # 80023890 <cons>
    80004ed6:	0017869b          	addiw	a3,a5,1
    80004eda:	08d72c23          	sw	a3,152(a4)
    80004ede:	07f7f693          	andi	a3,a5,127
    80004ee2:	9736                	add	a4,a4,a3
    80004ee4:	01874703          	lbu	a4,24(a4)
    80004ee8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004eec:	4691                	li	a3,4
    80004eee:	04db8663          	beq	s7,a3,80004f3a <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80004ef2:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004ef6:	4685                	li	a3,1
    80004ef8:	faf40613          	addi	a2,s0,-81
    80004efc:	85d2                	mv	a1,s4
    80004efe:	8556                	mv	a0,s5
    80004f00:	f98fc0ef          	jal	80001698 <either_copyout>
    80004f04:	57fd                	li	a5,-1
    80004f06:	04f50863          	beq	a0,a5,80004f56 <consoleread+0xf2>
      break;

    dst++;
    80004f0a:	0a05                	addi	s4,s4,1
    --n;
    80004f0c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80004f0e:	47a9                	li	a5,10
    80004f10:	04fb8d63          	beq	s7,a5,80004f6a <consoleread+0x106>
    80004f14:	6be2                	ld	s7,24(sp)
    80004f16:	b761                	j	80004e9e <consoleread+0x3a>
        release(&cons.lock);
    80004f18:	0001f517          	auipc	a0,0x1f
    80004f1c:	97850513          	addi	a0,a0,-1672 # 80023890 <cons>
    80004f20:	169000ef          	jal	80005888 <release>
        return -1;
    80004f24:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80004f26:	60e6                	ld	ra,88(sp)
    80004f28:	6446                	ld	s0,80(sp)
    80004f2a:	64a6                	ld	s1,72(sp)
    80004f2c:	6906                	ld	s2,64(sp)
    80004f2e:	79e2                	ld	s3,56(sp)
    80004f30:	7a42                	ld	s4,48(sp)
    80004f32:	7aa2                	ld	s5,40(sp)
    80004f34:	7b02                	ld	s6,32(sp)
    80004f36:	6125                	addi	sp,sp,96
    80004f38:	8082                	ret
      if(n < target){
    80004f3a:	0009871b          	sext.w	a4,s3
    80004f3e:	01677a63          	bgeu	a4,s6,80004f52 <consoleread+0xee>
        cons.r--;
    80004f42:	0001f717          	auipc	a4,0x1f
    80004f46:	9ef72323          	sw	a5,-1562(a4) # 80023928 <cons+0x98>
    80004f4a:	6be2                	ld	s7,24(sp)
    80004f4c:	a031                	j	80004f58 <consoleread+0xf4>
    80004f4e:	ec5e                	sd	s7,24(sp)
    80004f50:	bfbd                	j	80004ece <consoleread+0x6a>
    80004f52:	6be2                	ld	s7,24(sp)
    80004f54:	a011                	j	80004f58 <consoleread+0xf4>
    80004f56:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80004f58:	0001f517          	auipc	a0,0x1f
    80004f5c:	93850513          	addi	a0,a0,-1736 # 80023890 <cons>
    80004f60:	129000ef          	jal	80005888 <release>
  return target - n;
    80004f64:	413b053b          	subw	a0,s6,s3
    80004f68:	bf7d                	j	80004f26 <consoleread+0xc2>
    80004f6a:	6be2                	ld	s7,24(sp)
    80004f6c:	b7f5                	j	80004f58 <consoleread+0xf4>

0000000080004f6e <consputc>:
{
    80004f6e:	1141                	addi	sp,sp,-16
    80004f70:	e406                	sd	ra,8(sp)
    80004f72:	e022                	sd	s0,0(sp)
    80004f74:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004f76:	10000793          	li	a5,256
    80004f7a:	00f50863          	beq	a0,a5,80004f8a <consputc+0x1c>
    uartputc_sync(c);
    80004f7e:	604000ef          	jal	80005582 <uartputc_sync>
}
    80004f82:	60a2                	ld	ra,8(sp)
    80004f84:	6402                	ld	s0,0(sp)
    80004f86:	0141                	addi	sp,sp,16
    80004f88:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004f8a:	4521                	li	a0,8
    80004f8c:	5f6000ef          	jal	80005582 <uartputc_sync>
    80004f90:	02000513          	li	a0,32
    80004f94:	5ee000ef          	jal	80005582 <uartputc_sync>
    80004f98:	4521                	li	a0,8
    80004f9a:	5e8000ef          	jal	80005582 <uartputc_sync>
    80004f9e:	b7d5                	j	80004f82 <consputc+0x14>

0000000080004fa0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004fa0:	1101                	addi	sp,sp,-32
    80004fa2:	ec06                	sd	ra,24(sp)
    80004fa4:	e822                	sd	s0,16(sp)
    80004fa6:	e426                	sd	s1,8(sp)
    80004fa8:	1000                	addi	s0,sp,32
    80004faa:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004fac:	0001f517          	auipc	a0,0x1f
    80004fb0:	8e450513          	addi	a0,a0,-1820 # 80023890 <cons>
    80004fb4:	03d000ef          	jal	800057f0 <acquire>

  switch(c){
    80004fb8:	47d5                	li	a5,21
    80004fba:	08f48f63          	beq	s1,a5,80005058 <consoleintr+0xb8>
    80004fbe:	0297c563          	blt	a5,s1,80004fe8 <consoleintr+0x48>
    80004fc2:	47a1                	li	a5,8
    80004fc4:	0ef48463          	beq	s1,a5,800050ac <consoleintr+0x10c>
    80004fc8:	47c1                	li	a5,16
    80004fca:	10f49563          	bne	s1,a5,800050d4 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    80004fce:	f5efc0ef          	jal	8000172c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80004fd2:	0001f517          	auipc	a0,0x1f
    80004fd6:	8be50513          	addi	a0,a0,-1858 # 80023890 <cons>
    80004fda:	0af000ef          	jal	80005888 <release>
}
    80004fde:	60e2                	ld	ra,24(sp)
    80004fe0:	6442                	ld	s0,16(sp)
    80004fe2:	64a2                	ld	s1,8(sp)
    80004fe4:	6105                	addi	sp,sp,32
    80004fe6:	8082                	ret
  switch(c){
    80004fe8:	07f00793          	li	a5,127
    80004fec:	0cf48063          	beq	s1,a5,800050ac <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004ff0:	0001f717          	auipc	a4,0x1f
    80004ff4:	8a070713          	addi	a4,a4,-1888 # 80023890 <cons>
    80004ff8:	0a072783          	lw	a5,160(a4)
    80004ffc:	09872703          	lw	a4,152(a4)
    80005000:	9f99                	subw	a5,a5,a4
    80005002:	07f00713          	li	a4,127
    80005006:	fcf766e3          	bltu	a4,a5,80004fd2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    8000500a:	47b5                	li	a5,13
    8000500c:	0cf48763          	beq	s1,a5,800050da <consoleintr+0x13a>
      consputc(c);
    80005010:	8526                	mv	a0,s1
    80005012:	f5dff0ef          	jal	80004f6e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005016:	0001f797          	auipc	a5,0x1f
    8000501a:	87a78793          	addi	a5,a5,-1926 # 80023890 <cons>
    8000501e:	0a07a683          	lw	a3,160(a5)
    80005022:	0016871b          	addiw	a4,a3,1
    80005026:	0007061b          	sext.w	a2,a4
    8000502a:	0ae7a023          	sw	a4,160(a5)
    8000502e:	07f6f693          	andi	a3,a3,127
    80005032:	97b6                	add	a5,a5,a3
    80005034:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005038:	47a9                	li	a5,10
    8000503a:	0cf48563          	beq	s1,a5,80005104 <consoleintr+0x164>
    8000503e:	4791                	li	a5,4
    80005040:	0cf48263          	beq	s1,a5,80005104 <consoleintr+0x164>
    80005044:	0001f797          	auipc	a5,0x1f
    80005048:	8e47a783          	lw	a5,-1820(a5) # 80023928 <cons+0x98>
    8000504c:	9f1d                	subw	a4,a4,a5
    8000504e:	08000793          	li	a5,128
    80005052:	f8f710e3          	bne	a4,a5,80004fd2 <consoleintr+0x32>
    80005056:	a07d                	j	80005104 <consoleintr+0x164>
    80005058:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000505a:	0001f717          	auipc	a4,0x1f
    8000505e:	83670713          	addi	a4,a4,-1994 # 80023890 <cons>
    80005062:	0a072783          	lw	a5,160(a4)
    80005066:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000506a:	0001f497          	auipc	s1,0x1f
    8000506e:	82648493          	addi	s1,s1,-2010 # 80023890 <cons>
    while(cons.e != cons.w &&
    80005072:	4929                	li	s2,10
    80005074:	02f70863          	beq	a4,a5,800050a4 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005078:	37fd                	addiw	a5,a5,-1
    8000507a:	07f7f713          	andi	a4,a5,127
    8000507e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005080:	01874703          	lbu	a4,24(a4)
    80005084:	03270263          	beq	a4,s2,800050a8 <consoleintr+0x108>
      cons.e--;
    80005088:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000508c:	10000513          	li	a0,256
    80005090:	edfff0ef          	jal	80004f6e <consputc>
    while(cons.e != cons.w &&
    80005094:	0a04a783          	lw	a5,160(s1)
    80005098:	09c4a703          	lw	a4,156(s1)
    8000509c:	fcf71ee3          	bne	a4,a5,80005078 <consoleintr+0xd8>
    800050a0:	6902                	ld	s2,0(sp)
    800050a2:	bf05                	j	80004fd2 <consoleintr+0x32>
    800050a4:	6902                	ld	s2,0(sp)
    800050a6:	b735                	j	80004fd2 <consoleintr+0x32>
    800050a8:	6902                	ld	s2,0(sp)
    800050aa:	b725                	j	80004fd2 <consoleintr+0x32>
    if(cons.e != cons.w){
    800050ac:	0001e717          	auipc	a4,0x1e
    800050b0:	7e470713          	addi	a4,a4,2020 # 80023890 <cons>
    800050b4:	0a072783          	lw	a5,160(a4)
    800050b8:	09c72703          	lw	a4,156(a4)
    800050bc:	f0f70be3          	beq	a4,a5,80004fd2 <consoleintr+0x32>
      cons.e--;
    800050c0:	37fd                	addiw	a5,a5,-1
    800050c2:	0001f717          	auipc	a4,0x1f
    800050c6:	86f72723          	sw	a5,-1938(a4) # 80023930 <cons+0xa0>
      consputc(BACKSPACE);
    800050ca:	10000513          	li	a0,256
    800050ce:	ea1ff0ef          	jal	80004f6e <consputc>
    800050d2:	b701                	j	80004fd2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800050d4:	ee048fe3          	beqz	s1,80004fd2 <consoleintr+0x32>
    800050d8:	bf21                	j	80004ff0 <consoleintr+0x50>
      consputc(c);
    800050da:	4529                	li	a0,10
    800050dc:	e93ff0ef          	jal	80004f6e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800050e0:	0001e797          	auipc	a5,0x1e
    800050e4:	7b078793          	addi	a5,a5,1968 # 80023890 <cons>
    800050e8:	0a07a703          	lw	a4,160(a5)
    800050ec:	0017069b          	addiw	a3,a4,1
    800050f0:	0006861b          	sext.w	a2,a3
    800050f4:	0ad7a023          	sw	a3,160(a5)
    800050f8:	07f77713          	andi	a4,a4,127
    800050fc:	97ba                	add	a5,a5,a4
    800050fe:	4729                	li	a4,10
    80005100:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005104:	0001f797          	auipc	a5,0x1f
    80005108:	82c7a423          	sw	a2,-2008(a5) # 8002392c <cons+0x9c>
        wakeup(&cons.r);
    8000510c:	0001f517          	auipc	a0,0x1f
    80005110:	81c50513          	addi	a0,a0,-2020 # 80023928 <cons+0x98>
    80005114:	a74fc0ef          	jal	80001388 <wakeup>
    80005118:	bd6d                	j	80004fd2 <consoleintr+0x32>

000000008000511a <consoleinit>:

void
consoleinit(void)
{
    8000511a:	1141                	addi	sp,sp,-16
    8000511c:	e406                	sd	ra,8(sp)
    8000511e:	e022                	sd	s0,0(sp)
    80005120:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005122:	00002597          	auipc	a1,0x2
    80005126:	6d658593          	addi	a1,a1,1750 # 800077f8 <etext+0x7f8>
    8000512a:	0001e517          	auipc	a0,0x1e
    8000512e:	76650513          	addi	a0,a0,1894 # 80023890 <cons>
    80005132:	63e000ef          	jal	80005770 <initlock>

  uartinit();
    80005136:	3f4000ef          	jal	8000552a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000513a:	00015797          	auipc	a5,0x15
    8000513e:	5be78793          	addi	a5,a5,1470 # 8001a6f8 <devsw>
    80005142:	00000717          	auipc	a4,0x0
    80005146:	d2270713          	addi	a4,a4,-734 # 80004e64 <consoleread>
    8000514a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000514c:	00000717          	auipc	a4,0x0
    80005150:	cb270713          	addi	a4,a4,-846 # 80004dfe <consolewrite>
    80005154:	ef98                	sd	a4,24(a5)
}
    80005156:	60a2                	ld	ra,8(sp)
    80005158:	6402                	ld	s0,0(sp)
    8000515a:	0141                	addi	sp,sp,16
    8000515c:	8082                	ret

000000008000515e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000515e:	7179                	addi	sp,sp,-48
    80005160:	f406                	sd	ra,40(sp)
    80005162:	f022                	sd	s0,32(sp)
    80005164:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005166:	c219                	beqz	a2,8000516c <printint+0xe>
    80005168:	08054063          	bltz	a0,800051e8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000516c:	4881                	li	a7,0
    8000516e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005172:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005174:	00003617          	auipc	a2,0x3
    80005178:	8bc60613          	addi	a2,a2,-1860 # 80007a30 <digits>
    8000517c:	883e                	mv	a6,a5
    8000517e:	2785                	addiw	a5,a5,1
    80005180:	02b57733          	remu	a4,a0,a1
    80005184:	9732                	add	a4,a4,a2
    80005186:	00074703          	lbu	a4,0(a4)
    8000518a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000518e:	872a                	mv	a4,a0
    80005190:	02b55533          	divu	a0,a0,a1
    80005194:	0685                	addi	a3,a3,1
    80005196:	feb773e3          	bgeu	a4,a1,8000517c <printint+0x1e>

  if(sign)
    8000519a:	00088a63          	beqz	a7,800051ae <printint+0x50>
    buf[i++] = '-';
    8000519e:	1781                	addi	a5,a5,-32
    800051a0:	97a2                	add	a5,a5,s0
    800051a2:	02d00713          	li	a4,45
    800051a6:	fee78823          	sb	a4,-16(a5)
    800051aa:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800051ae:	02f05963          	blez	a5,800051e0 <printint+0x82>
    800051b2:	ec26                	sd	s1,24(sp)
    800051b4:	e84a                	sd	s2,16(sp)
    800051b6:	fd040713          	addi	a4,s0,-48
    800051ba:	00f704b3          	add	s1,a4,a5
    800051be:	fff70913          	addi	s2,a4,-1
    800051c2:	993e                	add	s2,s2,a5
    800051c4:	37fd                	addiw	a5,a5,-1
    800051c6:	1782                	slli	a5,a5,0x20
    800051c8:	9381                	srli	a5,a5,0x20
    800051ca:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800051ce:	fff4c503          	lbu	a0,-1(s1)
    800051d2:	d9dff0ef          	jal	80004f6e <consputc>
  while(--i >= 0)
    800051d6:	14fd                	addi	s1,s1,-1
    800051d8:	ff249be3          	bne	s1,s2,800051ce <printint+0x70>
    800051dc:	64e2                	ld	s1,24(sp)
    800051de:	6942                	ld	s2,16(sp)
}
    800051e0:	70a2                	ld	ra,40(sp)
    800051e2:	7402                	ld	s0,32(sp)
    800051e4:	6145                	addi	sp,sp,48
    800051e6:	8082                	ret
    x = -xx;
    800051e8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800051ec:	4885                	li	a7,1
    x = -xx;
    800051ee:	b741                	j	8000516e <printint+0x10>

00000000800051f0 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800051f0:	7155                	addi	sp,sp,-208
    800051f2:	e506                	sd	ra,136(sp)
    800051f4:	e122                	sd	s0,128(sp)
    800051f6:	f0d2                	sd	s4,96(sp)
    800051f8:	0900                	addi	s0,sp,144
    800051fa:	8a2a                	mv	s4,a0
    800051fc:	e40c                	sd	a1,8(s0)
    800051fe:	e810                	sd	a2,16(s0)
    80005200:	ec14                	sd	a3,24(s0)
    80005202:	f018                	sd	a4,32(s0)
    80005204:	f41c                	sd	a5,40(s0)
    80005206:	03043823          	sd	a6,48(s0)
    8000520a:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    8000520e:	0001e797          	auipc	a5,0x1e
    80005212:	7427a783          	lw	a5,1858(a5) # 80023950 <pr+0x18>
    80005216:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000521a:	e3a1                	bnez	a5,8000525a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000521c:	00840793          	addi	a5,s0,8
    80005220:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005224:	00054503          	lbu	a0,0(a0)
    80005228:	26050763          	beqz	a0,80005496 <printf+0x2a6>
    8000522c:	fca6                	sd	s1,120(sp)
    8000522e:	f8ca                	sd	s2,112(sp)
    80005230:	f4ce                	sd	s3,104(sp)
    80005232:	ecd6                	sd	s5,88(sp)
    80005234:	e8da                	sd	s6,80(sp)
    80005236:	e0e2                	sd	s8,64(sp)
    80005238:	fc66                	sd	s9,56(sp)
    8000523a:	f86a                	sd	s10,48(sp)
    8000523c:	f46e                	sd	s11,40(sp)
    8000523e:	4981                	li	s3,0
    if(cx != '%'){
    80005240:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005244:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005248:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000524c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005250:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005254:	07000d93          	li	s11,112
    80005258:	a815                	j	8000528c <printf+0x9c>
    acquire(&pr.lock);
    8000525a:	0001e517          	auipc	a0,0x1e
    8000525e:	6de50513          	addi	a0,a0,1758 # 80023938 <pr>
    80005262:	58e000ef          	jal	800057f0 <acquire>
  va_start(ap, fmt);
    80005266:	00840793          	addi	a5,s0,8
    8000526a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000526e:	000a4503          	lbu	a0,0(s4)
    80005272:	fd4d                	bnez	a0,8000522c <printf+0x3c>
    80005274:	a481                	j	800054b4 <printf+0x2c4>
      consputc(cx);
    80005276:	cf9ff0ef          	jal	80004f6e <consputc>
      continue;
    8000527a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000527c:	0014899b          	addiw	s3,s1,1
    80005280:	013a07b3          	add	a5,s4,s3
    80005284:	0007c503          	lbu	a0,0(a5)
    80005288:	1e050b63          	beqz	a0,8000547e <printf+0x28e>
    if(cx != '%'){
    8000528c:	ff5515e3          	bne	a0,s5,80005276 <printf+0x86>
    i++;
    80005290:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005294:	009a07b3          	add	a5,s4,s1
    80005298:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000529c:	1e090163          	beqz	s2,8000547e <printf+0x28e>
    800052a0:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800052a4:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800052a6:	c789                	beqz	a5,800052b0 <printf+0xc0>
    800052a8:	009a0733          	add	a4,s4,s1
    800052ac:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800052b0:	03690763          	beq	s2,s6,800052de <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    800052b4:	05890163          	beq	s2,s8,800052f6 <printf+0x106>
    } else if(c0 == 'u'){
    800052b8:	0d990b63          	beq	s2,s9,8000538e <printf+0x19e>
    } else if(c0 == 'x'){
    800052bc:	13a90163          	beq	s2,s10,800053de <printf+0x1ee>
    } else if(c0 == 'p'){
    800052c0:	13b90b63          	beq	s2,s11,800053f6 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800052c4:	07300793          	li	a5,115
    800052c8:	16f90a63          	beq	s2,a5,8000543c <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800052cc:	1b590463          	beq	s2,s5,80005474 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800052d0:	8556                	mv	a0,s5
    800052d2:	c9dff0ef          	jal	80004f6e <consputc>
      consputc(c0);
    800052d6:	854a                	mv	a0,s2
    800052d8:	c97ff0ef          	jal	80004f6e <consputc>
    800052dc:	b745                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800052de:	f8843783          	ld	a5,-120(s0)
    800052e2:	00878713          	addi	a4,a5,8
    800052e6:	f8e43423          	sd	a4,-120(s0)
    800052ea:	4605                	li	a2,1
    800052ec:	45a9                	li	a1,10
    800052ee:	4388                	lw	a0,0(a5)
    800052f0:	e6fff0ef          	jal	8000515e <printint>
    800052f4:	b761                	j	8000527c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800052f6:	03678663          	beq	a5,s6,80005322 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800052fa:	05878263          	beq	a5,s8,8000533e <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800052fe:	0b978463          	beq	a5,s9,800053a6 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    80005302:	fda797e3          	bne	a5,s10,800052d0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005306:	f8843783          	ld	a5,-120(s0)
    8000530a:	00878713          	addi	a4,a5,8
    8000530e:	f8e43423          	sd	a4,-120(s0)
    80005312:	4601                	li	a2,0
    80005314:	45c1                	li	a1,16
    80005316:	6388                	ld	a0,0(a5)
    80005318:	e47ff0ef          	jal	8000515e <printint>
      i += 1;
    8000531c:	0029849b          	addiw	s1,s3,2
    80005320:	bfb1                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005322:	f8843783          	ld	a5,-120(s0)
    80005326:	00878713          	addi	a4,a5,8
    8000532a:	f8e43423          	sd	a4,-120(s0)
    8000532e:	4605                	li	a2,1
    80005330:	45a9                	li	a1,10
    80005332:	6388                	ld	a0,0(a5)
    80005334:	e2bff0ef          	jal	8000515e <printint>
      i += 1;
    80005338:	0029849b          	addiw	s1,s3,2
    8000533c:	b781                	j	8000527c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000533e:	06400793          	li	a5,100
    80005342:	02f68863          	beq	a3,a5,80005372 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005346:	07500793          	li	a5,117
    8000534a:	06f68c63          	beq	a3,a5,800053c2 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000534e:	07800793          	li	a5,120
    80005352:	f6f69fe3          	bne	a3,a5,800052d0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005356:	f8843783          	ld	a5,-120(s0)
    8000535a:	00878713          	addi	a4,a5,8
    8000535e:	f8e43423          	sd	a4,-120(s0)
    80005362:	4601                	li	a2,0
    80005364:	45c1                	li	a1,16
    80005366:	6388                	ld	a0,0(a5)
    80005368:	df7ff0ef          	jal	8000515e <printint>
      i += 2;
    8000536c:	0039849b          	addiw	s1,s3,3
    80005370:	b731                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005372:	f8843783          	ld	a5,-120(s0)
    80005376:	00878713          	addi	a4,a5,8
    8000537a:	f8e43423          	sd	a4,-120(s0)
    8000537e:	4605                	li	a2,1
    80005380:	45a9                	li	a1,10
    80005382:	6388                	ld	a0,0(a5)
    80005384:	ddbff0ef          	jal	8000515e <printint>
      i += 2;
    80005388:	0039849b          	addiw	s1,s3,3
    8000538c:	bdc5                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000538e:	f8843783          	ld	a5,-120(s0)
    80005392:	00878713          	addi	a4,a5,8
    80005396:	f8e43423          	sd	a4,-120(s0)
    8000539a:	4601                	li	a2,0
    8000539c:	45a9                	li	a1,10
    8000539e:	4388                	lw	a0,0(a5)
    800053a0:	dbfff0ef          	jal	8000515e <printint>
    800053a4:	bde1                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800053a6:	f8843783          	ld	a5,-120(s0)
    800053aa:	00878713          	addi	a4,a5,8
    800053ae:	f8e43423          	sd	a4,-120(s0)
    800053b2:	4601                	li	a2,0
    800053b4:	45a9                	li	a1,10
    800053b6:	6388                	ld	a0,0(a5)
    800053b8:	da7ff0ef          	jal	8000515e <printint>
      i += 1;
    800053bc:	0029849b          	addiw	s1,s3,2
    800053c0:	bd75                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800053c2:	f8843783          	ld	a5,-120(s0)
    800053c6:	00878713          	addi	a4,a5,8
    800053ca:	f8e43423          	sd	a4,-120(s0)
    800053ce:	4601                	li	a2,0
    800053d0:	45a9                	li	a1,10
    800053d2:	6388                	ld	a0,0(a5)
    800053d4:	d8bff0ef          	jal	8000515e <printint>
      i += 2;
    800053d8:	0039849b          	addiw	s1,s3,3
    800053dc:	b545                	j	8000527c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800053de:	f8843783          	ld	a5,-120(s0)
    800053e2:	00878713          	addi	a4,a5,8
    800053e6:	f8e43423          	sd	a4,-120(s0)
    800053ea:	4601                	li	a2,0
    800053ec:	45c1                	li	a1,16
    800053ee:	4388                	lw	a0,0(a5)
    800053f0:	d6fff0ef          	jal	8000515e <printint>
    800053f4:	b561                	j	8000527c <printf+0x8c>
    800053f6:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800053f8:	f8843783          	ld	a5,-120(s0)
    800053fc:	00878713          	addi	a4,a5,8
    80005400:	f8e43423          	sd	a4,-120(s0)
    80005404:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005408:	03000513          	li	a0,48
    8000540c:	b63ff0ef          	jal	80004f6e <consputc>
  consputc('x');
    80005410:	07800513          	li	a0,120
    80005414:	b5bff0ef          	jal	80004f6e <consputc>
    80005418:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000541a:	00002b97          	auipc	s7,0x2
    8000541e:	616b8b93          	addi	s7,s7,1558 # 80007a30 <digits>
    80005422:	03c9d793          	srli	a5,s3,0x3c
    80005426:	97de                	add	a5,a5,s7
    80005428:	0007c503          	lbu	a0,0(a5)
    8000542c:	b43ff0ef          	jal	80004f6e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005430:	0992                	slli	s3,s3,0x4
    80005432:	397d                	addiw	s2,s2,-1
    80005434:	fe0917e3          	bnez	s2,80005422 <printf+0x232>
    80005438:	6ba6                	ld	s7,72(sp)
    8000543a:	b589                	j	8000527c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000543c:	f8843783          	ld	a5,-120(s0)
    80005440:	00878713          	addi	a4,a5,8
    80005444:	f8e43423          	sd	a4,-120(s0)
    80005448:	0007b903          	ld	s2,0(a5)
    8000544c:	00090d63          	beqz	s2,80005466 <printf+0x276>
      for(; *s; s++)
    80005450:	00094503          	lbu	a0,0(s2)
    80005454:	e20504e3          	beqz	a0,8000527c <printf+0x8c>
        consputc(*s);
    80005458:	b17ff0ef          	jal	80004f6e <consputc>
      for(; *s; s++)
    8000545c:	0905                	addi	s2,s2,1
    8000545e:	00094503          	lbu	a0,0(s2)
    80005462:	f97d                	bnez	a0,80005458 <printf+0x268>
    80005464:	bd21                	j	8000527c <printf+0x8c>
        s = "(null)";
    80005466:	00002917          	auipc	s2,0x2
    8000546a:	39a90913          	addi	s2,s2,922 # 80007800 <etext+0x800>
      for(; *s; s++)
    8000546e:	02800513          	li	a0,40
    80005472:	b7dd                	j	80005458 <printf+0x268>
      consputc('%');
    80005474:	02500513          	li	a0,37
    80005478:	af7ff0ef          	jal	80004f6e <consputc>
    8000547c:	b501                	j	8000527c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000547e:	f7843783          	ld	a5,-136(s0)
    80005482:	e385                	bnez	a5,800054a2 <printf+0x2b2>
    80005484:	74e6                	ld	s1,120(sp)
    80005486:	7946                	ld	s2,112(sp)
    80005488:	79a6                	ld	s3,104(sp)
    8000548a:	6ae6                	ld	s5,88(sp)
    8000548c:	6b46                	ld	s6,80(sp)
    8000548e:	6c06                	ld	s8,64(sp)
    80005490:	7ce2                	ld	s9,56(sp)
    80005492:	7d42                	ld	s10,48(sp)
    80005494:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80005496:	4501                	li	a0,0
    80005498:	60aa                	ld	ra,136(sp)
    8000549a:	640a                	ld	s0,128(sp)
    8000549c:	7a06                	ld	s4,96(sp)
    8000549e:	6169                	addi	sp,sp,208
    800054a0:	8082                	ret
    800054a2:	74e6                	ld	s1,120(sp)
    800054a4:	7946                	ld	s2,112(sp)
    800054a6:	79a6                	ld	s3,104(sp)
    800054a8:	6ae6                	ld	s5,88(sp)
    800054aa:	6b46                	ld	s6,80(sp)
    800054ac:	6c06                	ld	s8,64(sp)
    800054ae:	7ce2                	ld	s9,56(sp)
    800054b0:	7d42                	ld	s10,48(sp)
    800054b2:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    800054b4:	0001e517          	auipc	a0,0x1e
    800054b8:	48450513          	addi	a0,a0,1156 # 80023938 <pr>
    800054bc:	3cc000ef          	jal	80005888 <release>
    800054c0:	bfd9                	j	80005496 <printf+0x2a6>

00000000800054c2 <panic>:

void
panic(char *s)
{
    800054c2:	1101                	addi	sp,sp,-32
    800054c4:	ec06                	sd	ra,24(sp)
    800054c6:	e822                	sd	s0,16(sp)
    800054c8:	e426                	sd	s1,8(sp)
    800054ca:	1000                	addi	s0,sp,32
    800054cc:	84aa                	mv	s1,a0
  pr.locking = 0;
    800054ce:	0001e797          	auipc	a5,0x1e
    800054d2:	4807a123          	sw	zero,1154(a5) # 80023950 <pr+0x18>
  printf("panic: ");
    800054d6:	00002517          	auipc	a0,0x2
    800054da:	33250513          	addi	a0,a0,818 # 80007808 <etext+0x808>
    800054de:	d13ff0ef          	jal	800051f0 <printf>
  printf("%s\n", s);
    800054e2:	85a6                	mv	a1,s1
    800054e4:	00002517          	auipc	a0,0x2
    800054e8:	32c50513          	addi	a0,a0,812 # 80007810 <etext+0x810>
    800054ec:	d05ff0ef          	jal	800051f0 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800054f0:	4785                	li	a5,1
    800054f2:	00005717          	auipc	a4,0x5
    800054f6:	f4f72d23          	sw	a5,-166(a4) # 8000a44c <panicked>
  for(;;)
    800054fa:	a001                	j	800054fa <panic+0x38>

00000000800054fc <printfinit>:
    ;
}

void
printfinit(void)
{
    800054fc:	1101                	addi	sp,sp,-32
    800054fe:	ec06                	sd	ra,24(sp)
    80005500:	e822                	sd	s0,16(sp)
    80005502:	e426                	sd	s1,8(sp)
    80005504:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005506:	0001e497          	auipc	s1,0x1e
    8000550a:	43248493          	addi	s1,s1,1074 # 80023938 <pr>
    8000550e:	00002597          	auipc	a1,0x2
    80005512:	30a58593          	addi	a1,a1,778 # 80007818 <etext+0x818>
    80005516:	8526                	mv	a0,s1
    80005518:	258000ef          	jal	80005770 <initlock>
  pr.locking = 1;
    8000551c:	4785                	li	a5,1
    8000551e:	cc9c                	sw	a5,24(s1)
}
    80005520:	60e2                	ld	ra,24(sp)
    80005522:	6442                	ld	s0,16(sp)
    80005524:	64a2                	ld	s1,8(sp)
    80005526:	6105                	addi	sp,sp,32
    80005528:	8082                	ret

000000008000552a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000552a:	1141                	addi	sp,sp,-16
    8000552c:	e406                	sd	ra,8(sp)
    8000552e:	e022                	sd	s0,0(sp)
    80005530:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005532:	100007b7          	lui	a5,0x10000
    80005536:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000553a:	10000737          	lui	a4,0x10000
    8000553e:	f8000693          	li	a3,-128
    80005542:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005546:	468d                	li	a3,3
    80005548:	10000637          	lui	a2,0x10000
    8000554c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005550:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005554:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005558:	10000737          	lui	a4,0x10000
    8000555c:	461d                	li	a2,7
    8000555e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005562:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005566:	00002597          	auipc	a1,0x2
    8000556a:	2ba58593          	addi	a1,a1,698 # 80007820 <etext+0x820>
    8000556e:	0001e517          	auipc	a0,0x1e
    80005572:	3ea50513          	addi	a0,a0,1002 # 80023958 <uart_tx_lock>
    80005576:	1fa000ef          	jal	80005770 <initlock>
}
    8000557a:	60a2                	ld	ra,8(sp)
    8000557c:	6402                	ld	s0,0(sp)
    8000557e:	0141                	addi	sp,sp,16
    80005580:	8082                	ret

0000000080005582 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005582:	1101                	addi	sp,sp,-32
    80005584:	ec06                	sd	ra,24(sp)
    80005586:	e822                	sd	s0,16(sp)
    80005588:	e426                	sd	s1,8(sp)
    8000558a:	1000                	addi	s0,sp,32
    8000558c:	84aa                	mv	s1,a0
  push_off();
    8000558e:	222000ef          	jal	800057b0 <push_off>

  if(panicked){
    80005592:	00005797          	auipc	a5,0x5
    80005596:	eba7a783          	lw	a5,-326(a5) # 8000a44c <panicked>
    8000559a:	e795                	bnez	a5,800055c6 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000559c:	10000737          	lui	a4,0x10000
    800055a0:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800055a2:	00074783          	lbu	a5,0(a4)
    800055a6:	0207f793          	andi	a5,a5,32
    800055aa:	dfe5                	beqz	a5,800055a2 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800055ac:	0ff4f513          	zext.b	a0,s1
    800055b0:	100007b7          	lui	a5,0x10000
    800055b4:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800055b8:	27c000ef          	jal	80005834 <pop_off>
}
    800055bc:	60e2                	ld	ra,24(sp)
    800055be:	6442                	ld	s0,16(sp)
    800055c0:	64a2                	ld	s1,8(sp)
    800055c2:	6105                	addi	sp,sp,32
    800055c4:	8082                	ret
    for(;;)
    800055c6:	a001                	j	800055c6 <uartputc_sync+0x44>

00000000800055c8 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800055c8:	00005797          	auipc	a5,0x5
    800055cc:	e887b783          	ld	a5,-376(a5) # 8000a450 <uart_tx_r>
    800055d0:	00005717          	auipc	a4,0x5
    800055d4:	e8873703          	ld	a4,-376(a4) # 8000a458 <uart_tx_w>
    800055d8:	08f70263          	beq	a4,a5,8000565c <uartstart+0x94>
{
    800055dc:	7139                	addi	sp,sp,-64
    800055de:	fc06                	sd	ra,56(sp)
    800055e0:	f822                	sd	s0,48(sp)
    800055e2:	f426                	sd	s1,40(sp)
    800055e4:	f04a                	sd	s2,32(sp)
    800055e6:	ec4e                	sd	s3,24(sp)
    800055e8:	e852                	sd	s4,16(sp)
    800055ea:	e456                	sd	s5,8(sp)
    800055ec:	e05a                	sd	s6,0(sp)
    800055ee:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800055f0:	10000937          	lui	s2,0x10000
    800055f4:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800055f6:	0001ea97          	auipc	s5,0x1e
    800055fa:	362a8a93          	addi	s5,s5,866 # 80023958 <uart_tx_lock>
    uart_tx_r += 1;
    800055fe:	00005497          	auipc	s1,0x5
    80005602:	e5248493          	addi	s1,s1,-430 # 8000a450 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    80005606:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    8000560a:	00005997          	auipc	s3,0x5
    8000560e:	e4e98993          	addi	s3,s3,-434 # 8000a458 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005612:	00094703          	lbu	a4,0(s2)
    80005616:	02077713          	andi	a4,a4,32
    8000561a:	c71d                	beqz	a4,80005648 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000561c:	01f7f713          	andi	a4,a5,31
    80005620:	9756                	add	a4,a4,s5
    80005622:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80005626:	0785                	addi	a5,a5,1
    80005628:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    8000562a:	8526                	mv	a0,s1
    8000562c:	d5dfb0ef          	jal	80001388 <wakeup>
    WriteReg(THR, c);
    80005630:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80005634:	609c                	ld	a5,0(s1)
    80005636:	0009b703          	ld	a4,0(s3)
    8000563a:	fcf71ce3          	bne	a4,a5,80005612 <uartstart+0x4a>
      ReadReg(ISR);
    8000563e:	100007b7          	lui	a5,0x10000
    80005642:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005644:	0007c783          	lbu	a5,0(a5)
  }
}
    80005648:	70e2                	ld	ra,56(sp)
    8000564a:	7442                	ld	s0,48(sp)
    8000564c:	74a2                	ld	s1,40(sp)
    8000564e:	7902                	ld	s2,32(sp)
    80005650:	69e2                	ld	s3,24(sp)
    80005652:	6a42                	ld	s4,16(sp)
    80005654:	6aa2                	ld	s5,8(sp)
    80005656:	6b02                	ld	s6,0(sp)
    80005658:	6121                	addi	sp,sp,64
    8000565a:	8082                	ret
      ReadReg(ISR);
    8000565c:	100007b7          	lui	a5,0x10000
    80005660:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005662:	0007c783          	lbu	a5,0(a5)
      return;
    80005666:	8082                	ret

0000000080005668 <uartputc>:
{
    80005668:	7179                	addi	sp,sp,-48
    8000566a:	f406                	sd	ra,40(sp)
    8000566c:	f022                	sd	s0,32(sp)
    8000566e:	ec26                	sd	s1,24(sp)
    80005670:	e84a                	sd	s2,16(sp)
    80005672:	e44e                	sd	s3,8(sp)
    80005674:	e052                	sd	s4,0(sp)
    80005676:	1800                	addi	s0,sp,48
    80005678:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000567a:	0001e517          	auipc	a0,0x1e
    8000567e:	2de50513          	addi	a0,a0,734 # 80023958 <uart_tx_lock>
    80005682:	16e000ef          	jal	800057f0 <acquire>
  if(panicked){
    80005686:	00005797          	auipc	a5,0x5
    8000568a:	dc67a783          	lw	a5,-570(a5) # 8000a44c <panicked>
    8000568e:	efbd                	bnez	a5,8000570c <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005690:	00005717          	auipc	a4,0x5
    80005694:	dc873703          	ld	a4,-568(a4) # 8000a458 <uart_tx_w>
    80005698:	00005797          	auipc	a5,0x5
    8000569c:	db87b783          	ld	a5,-584(a5) # 8000a450 <uart_tx_r>
    800056a0:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800056a4:	0001e997          	auipc	s3,0x1e
    800056a8:	2b498993          	addi	s3,s3,692 # 80023958 <uart_tx_lock>
    800056ac:	00005497          	auipc	s1,0x5
    800056b0:	da448493          	addi	s1,s1,-604 # 8000a450 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800056b4:	00005917          	auipc	s2,0x5
    800056b8:	da490913          	addi	s2,s2,-604 # 8000a458 <uart_tx_w>
    800056bc:	00e79d63          	bne	a5,a4,800056d6 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800056c0:	85ce                	mv	a1,s3
    800056c2:	8526                	mv	a0,s1
    800056c4:	c79fb0ef          	jal	8000133c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800056c8:	00093703          	ld	a4,0(s2)
    800056cc:	609c                	ld	a5,0(s1)
    800056ce:	02078793          	addi	a5,a5,32
    800056d2:	fee787e3          	beq	a5,a4,800056c0 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800056d6:	0001e497          	auipc	s1,0x1e
    800056da:	28248493          	addi	s1,s1,642 # 80023958 <uart_tx_lock>
    800056de:	01f77793          	andi	a5,a4,31
    800056e2:	97a6                	add	a5,a5,s1
    800056e4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800056e8:	0705                	addi	a4,a4,1
    800056ea:	00005797          	auipc	a5,0x5
    800056ee:	d6e7b723          	sd	a4,-658(a5) # 8000a458 <uart_tx_w>
  uartstart();
    800056f2:	ed7ff0ef          	jal	800055c8 <uartstart>
  release(&uart_tx_lock);
    800056f6:	8526                	mv	a0,s1
    800056f8:	190000ef          	jal	80005888 <release>
}
    800056fc:	70a2                	ld	ra,40(sp)
    800056fe:	7402                	ld	s0,32(sp)
    80005700:	64e2                	ld	s1,24(sp)
    80005702:	6942                	ld	s2,16(sp)
    80005704:	69a2                	ld	s3,8(sp)
    80005706:	6a02                	ld	s4,0(sp)
    80005708:	6145                	addi	sp,sp,48
    8000570a:	8082                	ret
    for(;;)
    8000570c:	a001                	j	8000570c <uartputc+0xa4>

000000008000570e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000570e:	1141                	addi	sp,sp,-16
    80005710:	e422                	sd	s0,8(sp)
    80005712:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005714:	100007b7          	lui	a5,0x10000
    80005718:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    8000571a:	0007c783          	lbu	a5,0(a5)
    8000571e:	8b85                	andi	a5,a5,1
    80005720:	cb81                	beqz	a5,80005730 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005722:	100007b7          	lui	a5,0x10000
    80005726:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000572a:	6422                	ld	s0,8(sp)
    8000572c:	0141                	addi	sp,sp,16
    8000572e:	8082                	ret
    return -1;
    80005730:	557d                	li	a0,-1
    80005732:	bfe5                	j	8000572a <uartgetc+0x1c>

0000000080005734 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005734:	1101                	addi	sp,sp,-32
    80005736:	ec06                	sd	ra,24(sp)
    80005738:	e822                	sd	s0,16(sp)
    8000573a:	e426                	sd	s1,8(sp)
    8000573c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000573e:	54fd                	li	s1,-1
    80005740:	a019                	j	80005746 <uartintr+0x12>
      break;
    consoleintr(c);
    80005742:	85fff0ef          	jal	80004fa0 <consoleintr>
    int c = uartgetc();
    80005746:	fc9ff0ef          	jal	8000570e <uartgetc>
    if(c == -1)
    8000574a:	fe951ce3          	bne	a0,s1,80005742 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000574e:	0001e497          	auipc	s1,0x1e
    80005752:	20a48493          	addi	s1,s1,522 # 80023958 <uart_tx_lock>
    80005756:	8526                	mv	a0,s1
    80005758:	098000ef          	jal	800057f0 <acquire>
  uartstart();
    8000575c:	e6dff0ef          	jal	800055c8 <uartstart>
  release(&uart_tx_lock);
    80005760:	8526                	mv	a0,s1
    80005762:	126000ef          	jal	80005888 <release>
}
    80005766:	60e2                	ld	ra,24(sp)
    80005768:	6442                	ld	s0,16(sp)
    8000576a:	64a2                	ld	s1,8(sp)
    8000576c:	6105                	addi	sp,sp,32
    8000576e:	8082                	ret

0000000080005770 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005770:	1141                	addi	sp,sp,-16
    80005772:	e422                	sd	s0,8(sp)
    80005774:	0800                	addi	s0,sp,16
  lk->name = name;
    80005776:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005778:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000577c:	00053823          	sd	zero,16(a0)
}
    80005780:	6422                	ld	s0,8(sp)
    80005782:	0141                	addi	sp,sp,16
    80005784:	8082                	ret

0000000080005786 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005786:	411c                	lw	a5,0(a0)
    80005788:	e399                	bnez	a5,8000578e <holding+0x8>
    8000578a:	4501                	li	a0,0
  return r;
}
    8000578c:	8082                	ret
{
    8000578e:	1101                	addi	sp,sp,-32
    80005790:	ec06                	sd	ra,24(sp)
    80005792:	e822                	sd	s0,16(sp)
    80005794:	e426                	sd	s1,8(sp)
    80005796:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005798:	6904                	ld	s1,16(a0)
    8000579a:	db0fb0ef          	jal	80000d4a <mycpu>
    8000579e:	40a48533          	sub	a0,s1,a0
    800057a2:	00153513          	seqz	a0,a0
}
    800057a6:	60e2                	ld	ra,24(sp)
    800057a8:	6442                	ld	s0,16(sp)
    800057aa:	64a2                	ld	s1,8(sp)
    800057ac:	6105                	addi	sp,sp,32
    800057ae:	8082                	ret

00000000800057b0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800057b0:	1101                	addi	sp,sp,-32
    800057b2:	ec06                	sd	ra,24(sp)
    800057b4:	e822                	sd	s0,16(sp)
    800057b6:	e426                	sd	s1,8(sp)
    800057b8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800057ba:	100024f3          	csrr	s1,sstatus
    800057be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800057c2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800057c4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800057c8:	d82fb0ef          	jal	80000d4a <mycpu>
    800057cc:	5d3c                	lw	a5,120(a0)
    800057ce:	cb99                	beqz	a5,800057e4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800057d0:	d7afb0ef          	jal	80000d4a <mycpu>
    800057d4:	5d3c                	lw	a5,120(a0)
    800057d6:	2785                	addiw	a5,a5,1
    800057d8:	dd3c                	sw	a5,120(a0)
}
    800057da:	60e2                	ld	ra,24(sp)
    800057dc:	6442                	ld	s0,16(sp)
    800057de:	64a2                	ld	s1,8(sp)
    800057e0:	6105                	addi	sp,sp,32
    800057e2:	8082                	ret
    mycpu()->intena = old;
    800057e4:	d66fb0ef          	jal	80000d4a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800057e8:	8085                	srli	s1,s1,0x1
    800057ea:	8885                	andi	s1,s1,1
    800057ec:	dd64                	sw	s1,124(a0)
    800057ee:	b7cd                	j	800057d0 <push_off+0x20>

00000000800057f0 <acquire>:
{
    800057f0:	1101                	addi	sp,sp,-32
    800057f2:	ec06                	sd	ra,24(sp)
    800057f4:	e822                	sd	s0,16(sp)
    800057f6:	e426                	sd	s1,8(sp)
    800057f8:	1000                	addi	s0,sp,32
    800057fa:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800057fc:	fb5ff0ef          	jal	800057b0 <push_off>
  if(holding(lk))
    80005800:	8526                	mv	a0,s1
    80005802:	f85ff0ef          	jal	80005786 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005806:	4705                	li	a4,1
  if(holding(lk))
    80005808:	e105                	bnez	a0,80005828 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000580a:	87ba                	mv	a5,a4
    8000580c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005810:	2781                	sext.w	a5,a5
    80005812:	ffe5                	bnez	a5,8000580a <acquire+0x1a>
  __sync_synchronize();
    80005814:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80005818:	d32fb0ef          	jal	80000d4a <mycpu>
    8000581c:	e888                	sd	a0,16(s1)
}
    8000581e:	60e2                	ld	ra,24(sp)
    80005820:	6442                	ld	s0,16(sp)
    80005822:	64a2                	ld	s1,8(sp)
    80005824:	6105                	addi	sp,sp,32
    80005826:	8082                	ret
    panic("acquire");
    80005828:	00002517          	auipc	a0,0x2
    8000582c:	00050513          	mv	a0,a0
    80005830:	c93ff0ef          	jal	800054c2 <panic>

0000000080005834 <pop_off>:

void
pop_off(void)
{
    80005834:	1141                	addi	sp,sp,-16
    80005836:	e406                	sd	ra,8(sp)
    80005838:	e022                	sd	s0,0(sp)
    8000583a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000583c:	d0efb0ef          	jal	80000d4a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005840:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005844:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005846:	e78d                	bnez	a5,80005870 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005848:	5d3c                	lw	a5,120(a0)
    8000584a:	02f05963          	blez	a5,8000587c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    8000584e:	37fd                	addiw	a5,a5,-1
    80005850:	0007871b          	sext.w	a4,a5
    80005854:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005856:	eb09                	bnez	a4,80005868 <pop_off+0x34>
    80005858:	5d7c                	lw	a5,124(a0)
    8000585a:	c799                	beqz	a5,80005868 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000585c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005860:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005864:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005868:	60a2                	ld	ra,8(sp)
    8000586a:	6402                	ld	s0,0(sp)
    8000586c:	0141                	addi	sp,sp,16
    8000586e:	8082                	ret
    panic("pop_off - interruptible");
    80005870:	00002517          	auipc	a0,0x2
    80005874:	fc050513          	addi	a0,a0,-64 # 80007830 <etext+0x830>
    80005878:	c4bff0ef          	jal	800054c2 <panic>
    panic("pop_off");
    8000587c:	00002517          	auipc	a0,0x2
    80005880:	fcc50513          	addi	a0,a0,-52 # 80007848 <etext+0x848>
    80005884:	c3fff0ef          	jal	800054c2 <panic>

0000000080005888 <release>:
{
    80005888:	1101                	addi	sp,sp,-32
    8000588a:	ec06                	sd	ra,24(sp)
    8000588c:	e822                	sd	s0,16(sp)
    8000588e:	e426                	sd	s1,8(sp)
    80005890:	1000                	addi	s0,sp,32
    80005892:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005894:	ef3ff0ef          	jal	80005786 <holding>
    80005898:	c105                	beqz	a0,800058b8 <release+0x30>
  lk->cpu = 0;
    8000589a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000589e:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    800058a2:	0310000f          	fence	rw,w
    800058a6:	0004a023          	sw	zero,0(s1)
  pop_off();
    800058aa:	f8bff0ef          	jal	80005834 <pop_off>
}
    800058ae:	60e2                	ld	ra,24(sp)
    800058b0:	6442                	ld	s0,16(sp)
    800058b2:	64a2                	ld	s1,8(sp)
    800058b4:	6105                	addi	sp,sp,32
    800058b6:	8082                	ret
    panic("release");
    800058b8:	00002517          	auipc	a0,0x2
    800058bc:	f9850513          	addi	a0,a0,-104 # 80007850 <etext+0x850>
    800058c0:	c03ff0ef          	jal	800054c2 <panic>
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
