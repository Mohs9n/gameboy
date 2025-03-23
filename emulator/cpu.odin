package emulator

import "core:fmt"
import "core:os"

Registers :: struct {
	a:  u8,
	f:  u8,
	b:  u8,
	c:  u8,
	d:  u8,
	e:  u8,
	h:  u8,
	l:  u8,
	pc: u16,
	sp: u16,
}

CPU :: struct {
	regs:               Registers,

	//current fetch...
	fetched_data:       u16,
	mem_dest:           u16,
	dest_is_mem:        bool,
	cur_opcode:         u8,
	cur_inst:           ^Instruction,
	halted:             bool,
	stepping:           bool,
	int_master_enabled: bool,
	ie_register:        u8,
}


cpu_init :: proc() -> ^CPU {
	cpu := new(CPU)
	cpu.regs.pc = 0x100
	cpu.regs.a = 0x01

	return cpu
}

destroy_cpu :: proc(cpu: ^CPU) {
	free(cpu)
}

fetch_instruction :: proc(gb: ^GameBoy) {
	defer gb.cpu.regs.pc += 1
	gb.cpu.cur_opcode = bus_read(gb, gb.cpu.regs.pc)
	gb.cpu.cur_inst = instruction_by_opcode(gb.cpu.cur_opcode)
}


execute :: proc(gb: ^GameBoy) {
	fn := gb.cpu.cur_inst.fn

	if fn == nil {
		todo()
	}

	fn(gb)
}


cpu_step :: proc(gb: ^GameBoy) -> bool {
	cpu := gb.cpu

	if !gb.cpu.halted {
		pc := gb.cpu.regs.pc

		fetch_instruction(gb)
		fetch_data(gb)

		fmt.printf(
			"%04X: %-7s (%02X %02X %02X) A: %02X B: %02X C: %02X\n",
			pc,
			inst_name(cpu.cur_inst.type),
			cpu.cur_opcode,
			bus_read(gb, pc + 1),
			bus_read(gb, pc + 2),
			cpu.regs.a,
			cpu.regs.b,
			cpu.regs.c,
		)

		if (cpu.cur_inst == nil) {
			fmt.printf("Unknown Instruction! %02X\n", cpu.cur_opcode)
			os.exit(-7)
		}

		execute(gb)
	}

	return true
}


cpu_get_ie_register :: proc(cpu: ^CPU) -> u8 {
	return cpu.ie_register
}

cpu_set_ie_register :: proc(cpu: ^CPU, n: u8) {
	cpu.ie_register = n
}
