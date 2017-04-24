// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>
#include <kern/env.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "trace back the stack", mon_backtrace },
	{ "showmappings", "showmappings", showmappings },
	{ "setmapping", "setmapping", setmapping },
	{ "dumpmem", "dumpmem", dumpmem },
	{ "x", "display the memory", mon_x},
	{ "si", "executing the code instruction by instruction", mon_si},
	{ "c", "continue execution from the current location", mon_c},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
	return 0;
}

// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
    return pretaddr;
}

void
do_overflow(void)
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
	// You should use a techique similar to buffer overflow
	// to invoke the do_overflow function and
	// the procedure must return normally.

	// And you must use the "cprintf" function with %n specifier
	// you augmented in the "Exercise 9" to do this job.

	// hint: You can use the read_pretaddr function to retrieve 
	//       the pointer to the function call return address;

	// Your code here.
        char str[256] = {};
        int nstr = 0;
        char *pret_addr=(char*)read_pretaddr();
	unsigned int ret_addr=*(unsigned int*)pret_addr;
	memset(str,'a',256);
	uint32_t hack_address = (uint32_t)do_overflow+3;
	uint32_t a0 = hack_address & 0xff;
	uint32_t a1 = (hack_address >> 8) & 0xff;
	uint32_t a2 = (hack_address >> 16) & 0xff;
	uint32_t a3 = (hack_address >> 24) & 0xff;
	str[a0] = '\0';
	cprintf("%s%n", str, pret_addr);
	str[a0] = 'a';
	str[a1] = '\0';
	cprintf("%s%n", str, pret_addr+1);
	str[a1] = 'a';
	str[a2] = '\0';
	cprintf("%s%n", str, pret_addr+2);
	str[a2] = 'a';
	str[a3] = '\0';
	cprintf("%s%n", str, pret_addr+3);
	*(((unsigned int*)pret_addr)+1)=ret_addr;



}

void
overflow_me(void)
{
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	unsigned int ebp=read_ebp();
	struct Eipdebuginfo info;
	while (ebp!=0)
	{
		unsigned int* _ebp=(unsigned int*)ebp;
		cprintf("eip %08x ebp %08x args %08x %08x %08x %08x %08x\n",*(_ebp+1),ebp,*(_ebp+2),*(_ebp+3),*(_ebp+4),*(_ebp+5),*(_ebp+6));
		int re=debuginfo_eip(*(_ebp+1), &info);
		if (re!=-1)
		{
			cprintf("%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,*(_ebp+1)-info.eip_fn_addr);
		}
		ebp=*_ebp;
	}
    overflow_me();
    cprintf("Backtrace success\n");
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2;
	while (*buf) { 
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void print_pte(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if (argc == 1) 
	{
		cprintf("Usage: showmappings [begin] [end]\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("Mapping begin: 0x%x, end: 0x%x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) 
	{
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);
		if (!pte) panic("show mapping error: out of memory");
		if (*pte & PTE_P) 
		{
			cprintf("Page 0x%x Info: ", begin);
			print_pte(pte);
		} else cprintf("Page Not Exist: 0x%x\n", begin);
	}
	return 0;
}

int setmapping(int argc, char **argv, struct Trapframe *tf) {
	if (argc == 1) 
	{
		cprintf("Usage: setmapping [addr] [0|1] [P|U|W]\n");
		return 0;
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	uint32_t perm = 0;

	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[3][0] == 'W') perm = PTE_W;

	if (argv[2][0] == '0') *pte = *pte & ~perm;
	else  *pte = *pte | perm;
	cprintf("Mapping Set Succeed");
	return 0;
}

int dumpmem(int argc, char **argv, struct Trapframe *tf) {
	if (argc == 1)
	{
		cprintf("Usage: dumpmem [v|p] [BEGIN] [END]\n");
		return 0;
	}
	uint32_t begin=strtol(argv[2],0,0);
	uint32_t end=strtol(argv[3],0,0);
	if(begin!=ROUNDUP(begin,4) || end!=ROUNDUP(end,4) || begin > end)
	{
		cprintf("dumpmem: Invalid address\n");
		return 0;
	}
	if(argv[1][0]!='v' && argv[1][0]!='p')
	{
		cprintf("dumpmem: Invalid address type\n");
		return 0;
	}
	if(argv[1][0]=='p')
	{
		begin+=KERNBASE;
		end+=KERNBASE;
	}
	while(begin<end)
	{
		cprintf("0x%08x: ",begin);
		int i;
		for(i=0;i<4 && begin<end;i++,begin+=4){
			cprintf("0x%08x ",*((uint32_t*)begin));
		}
		cprintf("\n");
	}
	return 0;
}

int
mon_x(int argc, char **argv, struct Trapframe *tf){
	int addr = strtol(argv[1], NULL, 16);
	cprintf("%d\n",*(int*)addr);
	return 0;
}

int
mon_si(int argc, char **argv, struct Trapframe *tf){
	tf->tf_eflags |= FL_TF;
	cprintf("tf_eip=%08x\n", tf->tf_eip);
	env_run(curenv);
	return 0;
}

int
mon_c(int argc, char **argv, struct Trapframe *tf){
	tf->tf_eflags &= (~FL_TF);
	env_run(curenv);
	return 0;
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}
