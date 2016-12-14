	.file	"cpu.s"
	.version	"01.01"
	.text
	.globl	main
	.align	4
main:
	# Reserve some stack space for the sting, must be dword-aligned!
	subl	$32, %esp
	# First, get the maximum number of bytes, supported by cpuid.
	xorl	%eax,%eax
	cpuid
	cmpl	$2, %eax
	movl	$.na, %eax	# just in case it's not applicable 
	jbe	.return
	# If we got here, then its a Pentium III, neither II, nor IV+.
	movl	$1, %eax
	cpuid
	pushl	%esp		# Serial # string. Beware: pushed only once!
	pushl	%eax
	call	.itoa
	popl	%eax
	movl	$3, %eax
	cpuid
	pushl	%edx
	call	.itoa
	popl	%eax
	pushl	%ecx
	call	.itoa
	popl	%eax
	popl	%eax
	decl	%eax
	movb	$0, (%eax)
	movl	%esp, %eax

.return:
	pushl	%eax
	pushl	$.format
	call	printf
	addl	$40, %esp	# 8 of printf + 32 of subl 
	ret/1


.itoa:
	serstr	= 0x14(%esp)
	num	= 0x10(%esp)
	pushl	%edx
	pushl	%ecx
	pushl	%ebx 
	movl	num, %eax
	movl	serstr, %ebx
	movl	$8, %ecx
.digit:
	roll	$4, %eax
	cmpb	$4, %cl
	jnz	.nodash
	movb	$0x2D, (%ebx)
	incl	%ebx

.nodash:
	movb	%al, %dl
	andb	$0xF, %dl
	addb	$0x30, %dl
	cmpb	$0x39, %dl
	jbe	.skip
	addb	$7, %dl
.skip:
	movb	%dl,(%ebx) 
	incl	%ebx
	loop	.digit
	movb	$0x2D, (%ebx)
	incl	%ebx
	movl	%ebx, serstr
	popl	%ebx
	popl	%ecx
	popl	%edx
	ret

.na:
	.string "N/A"
.format:
	.string "CPU serial #: %s\n"
	.size	main,.-main
	.ident	"acomp: (CCS) 3.0  04/27/98 (u213_bl5)"
