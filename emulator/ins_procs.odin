package emulator

import "core:fmt"
import "core:os"


ins_none :: proc(gb: ^GameBoy) {
	fmt.printf("INVALID INSTRUCTION!\n")
	os.exit(-7)
}

ins_nop :: proc(gb: ^GameBoy) {

}

ins_di :: proc(gb: ^GameBoy) {
	gb.cpu.int_master_enabled = false
}

ins_ld :: proc(gb: ^GameBoy) {
	cpu := gb.cpu

	if gb.cpu.dest_is_mem {
		//LD (BC), A for instance...

		if gb.cpu.cur_inst.reg_2 >= .RT_AF {
			//if 16 bit register...
			emu_cycles(1)
			bus_write16(gb, cpu.mem_dest, cpu.fetched_data)
		} else {
			bus_write(gb, cpu.mem_dest, u8(cpu.fetched_data))
		}

		return
	}

	if cpu.cur_inst.mode == .AM_HL_SPR {
		// hflag: u16 =
		// 	(cpu_read_reg(cpu, cpu.cur_inst.reg_2) & 0xF) + (cpu.fetched_data & 0xF) >= 0x10
		hflag: u8 =
			((cpu_read_reg(cpu, cpu.cur_inst.reg_2) & 0xF) + (cpu.fetched_data & 0xF)) >= 0x10

		// cflag: u16 =
		// 	(cpu_read_reg(cpu, cpu.cur_inst.reg_2) & 0xFF) + (cpu.fetched_data & 0xFF) >= 0x100
		cflag: u8 =
			((cpu_read_reg(cpu, cpu.cur_inst.reg_2) & 0xFF) + (cpu.fetched_data & 0xFF)) >= 0x100

		cpu_set_flags(cpu, 0, 0, i8(hflag), i8(cflag))
		cpu_set_reg(
			cpu,
			cpu.cur_inst.reg_1,
			cpu_read_reg(cpu, cpu.cur_inst.reg_2) + cpu.fetched_data,
		)

		return
	}

	cpu_set_reg(cpu, cpu.cur_inst.reg_1, cpu.fetched_data)
}


ins_ldh :: proc(gb: ^GameBoy) {
	if (gb.cpu.cur_inst.reg_1 == .RT_A) {
		cpu_set_reg(gb.cpu, gb.cpu.cur_inst.reg_1, u16(bus_read(gb, 0xFF00 | gb.cpu.fetched_data)))
	} else {
		bus_write(gb, 0xFF00 | gb.cpu.fetched_data, gb.cpu.regs.a)
	}

	emu_cycles(1)
}


ins_jp :: proc(gb: ^GameBoy) {
	goto_addr(gb, gb.cpu.fetched_data, false)
}

ins_xor :: proc(gb: ^GameBoy) {
	gb.cpu.regs.a ~= u8(gb.cpu.fetched_data & 0xFF)
	cpu_set_flags(gb.cpu, gb.cpu.regs.a == 0, 0, 0, 0)
}


ins_jr :: proc(gb: ^GameBoy) {
	rel := i8((gb.cpu.fetched_data & 0xFF))
	addr: u16 = gb.cpu.regs.pc + u16(rel)
	goto_addr(gb, addr, false)
}

ins_call :: proc(gb: ^GameBoy) {
	goto_addr(gb, gb.cpu.fetched_data, true)
}

ins_rst :: proc(gb: ^GameBoy) {
	goto_addr(gb, u16(gb.cpu.cur_inst.param), true)
}

ins_ret :: proc(gb: ^GameBoy) {
	if gb.cpu.cur_inst.cond != .CT_NONE {
		emu_cycles(1)
	}

	if check_cond(gb.cpu) {
		lo: u16 = u16(stack_pop(gb))
		emu_cycles(1)
		hi := u16(stack_pop(gb))
		emu_cycles(1)

		n: u16 = (hi << 8) | lo
		gb.cpu.regs.pc = n

		emu_cycles(1)
	}
}

ins_reti :: proc(gb: ^GameBoy) {
	gb.cpu.int_master_enabled = true
	ins_ret(gb)
}

ins_pop :: proc(gb: ^GameBoy) {
	lo := u16(stack_pop(gb))
	emu_cycles(1)
	hi := u16(stack_pop(gb))
	emu_cycles(1)

	n := (hi << 8) | lo

	cpu_set_reg(gb.cpu, gb.cpu.cur_inst.reg_1, n)

	if (gb.cpu.cur_inst.reg_1 == .RT_AF) {
		cpu_set_reg(gb.cpu, gb.cpu.cur_inst.reg_1, n & 0xFFF0)
	}
}

ins_push :: proc(gb: ^GameBoy) {
	hi := (cpu_read_reg(gb.cpu, gb.cpu.cur_inst.reg_1) >> 8) & 0xFF
	emu_cycles(1)
	stack_push(gb, u8(hi))

	lo := cpu_read_reg(gb.cpu, gb.cpu.cur_inst.reg_1) & 0xFF
	emu_cycles(1)
	stack_push(gb, u8(lo))

	emu_cycles(1)
}


goto_addr :: proc(gb: ^GameBoy, addr: u16, pushpc: bool) {
	if check_cond(gb.cpu) {
		if pushpc {
			emu_cycles(2)
			stack_push16(gb, gb.cpu.regs.pc)
		}

		gb.cpu.regs.pc = addr
		emu_cycles(1)
	}
}


cpu_set_flags :: proc(cpu: ^CPU, z, n, h, c: i8) {
	if (z != -1) {
		set_bit(&cpu.regs.f, 7, bool(z))
	}

	if (n != -1) {
		set_bit(&cpu.regs.f, 6, bool(n))
	}

	if (h != -1) {
		set_bit(&cpu.regs.f, 5, bool(h))
	}

	if (c != -1) {
		set_bit(&cpu.regs.f, 4, bool(c))
	}
}


check_cond :: proc(cpu: ^CPU) -> bool {
	z: bool = cpu_flag_z(cpu)
	c: bool = cpu_flag_c(cpu)

	switch (cpu.cur_inst.cond) {
	case .CT_NONE:
		return true
	case .CT_C:
		return c
	case .CT_NC:
		return !c
	case .CT_Z:
		return z
	case .CT_NZ:
		return !z
	}

	return false
}
