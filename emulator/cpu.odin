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

fetch_instruction :: proc(cpu: ^CPU, cart: ^Cart) {
	defer cpu.regs.pc += 1
	cpu.cur_opcode = bus_read(cart, cpu.regs.pc)
	cpu.cur_inst = instruction_by_opcode(cpu.cur_opcode)
}


// fetch_data :: proc(cpu: ^CPU, cart: ^Cart) {
// 	cpu.mem_dest = 0
// 	cpu.dest_is_mem = false
//
// 	if cpu.cur_inst == nil {
// 		return
// 	}
//
// 	#partial switch cpu.cur_inst.mode {
// 	case .AM_IMP:
// 		return
//
// 	case .AM_R:
// 		cpu.fetched_data = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
// 		return
//
// 	case .AM_R_D8:
// 		cpu.fetched_data = u16(bus_read(cart, cpu.regs.pc))
// 		emu_cycles(1)
// 		cpu.regs.pc += 1
// 		return
//
// 	// remove Maybe
// 	case .AM_A8_R:
// 		{
// 			cpu.fetched_data = u16(bus_read(cart, cpu.regs.pc))
// 			emu_cycles(1)
// 			cpu.regs.pc += 1
// 			return
// 		}
//
// 	case .AM_D16:
// 		{
// 			lo := u16(bus_read(cart, cpu.regs.pc))
// 			emu_cycles(1)
//
// 			hi := u16(bus_read(cart, cpu.regs.pc + 1))
// 			emu_cycles(1)
//
// 			cpu.fetched_data = lo | (hi << 8)
//
// 			cpu.regs.pc += 2
//
// 			return
// 		}
//
// 	case:
// 		fmt.printf("Unknown Addressing Mode! %d (%02X)\n", cpu.cur_inst.mode, cpu.cur_opcode)
// 		os.exit(-7)
// 	// return
// 	}
// }


execute :: proc(cpu: ^CPU, cart: ^Cart) {
	fn := cpu.cur_inst.fn

	if fn == nil {
		todo()
	}

	fn(cpu, cart)
}


cpu_step :: proc(cpu: ^CPU, cart: ^Cart) -> bool {

	if !cpu.halted {
		pc := cpu.regs.pc

		fetch_instruction(cpu, cart)
		fetch_data(cpu, cart)

		fmt.printf(
			"%04X: %-7s (%02X %02X %02X) A: %02X B: %02X C: %02X\n",
			pc,
			inst_name(cpu.cur_inst.type),
			cpu.cur_opcode,
			bus_read(cart, pc + 1),
			bus_read(cart, pc + 2),
			cpu.regs.a,
			cpu.regs.b,
			cpu.regs.c,
		)

		if (cpu.cur_inst == nil) {
			fmt.printf("Unknown Instruction! %02X\n", cpu.cur_opcode)
			os.exit(-7)
		}

		execute(cpu, cart)
	}

	return true
}
