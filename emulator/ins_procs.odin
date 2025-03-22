package emulator

import "core:fmt"
import "core:os"


ins_none :: proc(cpu: ^CPU, cart: ^Cart) {
	fmt.printf("INVALID INSTRUCTION!\n")
	os.exit(-7)
}

ins_nop :: proc(cpu: ^CPU, cart: ^Cart) {

}

ins_di :: proc(cpu: ^CPU, cart: ^Cart) {
	cpu.int_master_enabled = false
}

ins_ld :: proc(cpu: ^CPU, cart: ^Cart) {
	if cpu.dest_is_mem {
		//LD (BC), A for instance...

		if cpu.cur_inst.reg_2 >= .RT_AF {
			//if 16 bit register...
			emu_cycles(1)
			bus_write16(cart, cpu.mem_dest, cpu.fetched_data)
		} else {
			bus_write(cart, cpu.mem_dest, u8(cpu.fetched_data))
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


ins_jp :: proc(cpu: ^CPU, cart: ^Cart) {
	if (check_cond(cpu)) {
		cpu.regs.pc = cpu.fetched_data
		emu_cycles(1)
	}
}

ins_xor :: proc(cpu: ^CPU, cart: ^Cart) {
	cpu.regs.a ~= u8(cpu.fetched_data & 0xFF)
	cpu_set_flags(cpu, cpu.regs.a == 0, 0, 0, 0)
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
