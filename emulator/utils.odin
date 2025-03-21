package emulator

import "core:fmt"
import "core:os"

todo :: proc() -> ! {
	panic("NOT YET IMPLEMENTED\n")
}


bit :: proc(a: u8, n: u8) -> bool {
	return true if (a & (1 << n) != 0) else false
}

set_bit :: proc(a: ^u8, n: u8, on: bool) {
	if on {
		a^ |= (1 << n)
	} else {
		a^ &= ~(1 << n)
	}
}

between :: proc(a, b, c: int) -> bool {
	return a >= b && a <= c
}

// Usage-specific procs
cpu_flag_z :: proc(cpu: ^CPU) -> bool {
	return bit(cpu.regs.f, 7)
}

cpu_flag_c :: proc(cpu: ^CPU) -> bool {
	return bit(cpu.regs.f, 4)
}


reverse :: proc(n: u16) -> u16 {
	return ((n & 0xFF00) >> 8) | ((n & 0x00FF) << 8)
}

cpu_read_reg :: proc(cpu: ^CPU, rt: RegType) -> u16 {
	#partial switch rt {
	case .RT_A:
		return u16(cpu.regs.a)
	case .RT_F:
		return u16(cpu.regs.f)
	case .RT_B:
		return u16(cpu.regs.b)
	case .RT_C:
		return u16(cpu.regs.c)
	case .RT_D:
		return u16(cpu.regs.d)
	case .RT_E:
		return u16(cpu.regs.e)
	case .RT_H:
		return u16(cpu.regs.h)
	case .RT_L:
		return u16(cpu.regs.l)

	case .RT_AF:
		return reverse(u16(cpu.regs.a))
	case .RT_BC:
		return reverse(u16(cpu.regs.b))
	case .RT_DE:
		return reverse(u16(cpu.regs.d))
	case .RT_HL:
		return reverse(u16(cpu.regs.h))

	case .RT_PC:
		return cpu.regs.pc
	case .RT_SP:
		return cpu.regs.sp
	case:
		return 0
	}
}
