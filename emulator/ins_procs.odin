package emulator

import "core:fmt"
import "core:os"


ins_none :: proc(cpu: ^CPU) {
	fmt.printf("INVALID INSTRUCTION!\n")
	os.exit(-7)
}

ins_nop :: proc(cpu: ^CPU) {

}

ins_di :: proc(cpu: ^CPU) {
	cpu.int_master_enabled = false
}

ins_ld :: proc(cpu: ^CPU) {
	//TODO...
}


ins_jp :: proc(cpu: ^CPU) {
	if (check_cond(cpu)) {
		cpu.regs.pc = cpu.fetched_data
		emu_cycles(1)
	}
}

ins_xor :: proc(cpu: ^CPU) {
	cpu.regs.a ~= u8(cpu.fetched_data & 0xFF)
	cpu_set_flags(cpu, cpu.regs.a == 0, 0, 0, 0)
}

cpu_set_flags :: proc(cpu: ^CPU, z, n, h, c: int) {
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
