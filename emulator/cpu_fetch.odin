package emulator

import "core:fmt"
import "core:os"

fetch_data :: proc(gb: ^GameBoy) {
	cpu := gb.cpu

	cpu.mem_dest = 0
	cpu.dest_is_mem = false

	if cpu.cur_inst == nil {
		return
	}

	switch cpu.cur_inst.mode {
	case .AM_IMP:
		return

	case .AM_R:
		cpu.fetched_data = cpu_read_reg(gb.cpu, gb.cpu.cur_inst.reg_1)
		return

	case .AM_R_R:
		cpu.fetched_data = cpu_read_reg(gb.cpu, gb.cpu.cur_inst.reg_2)
		return

	case .AM_R_D8:
		cpu.fetched_data = u16(bus_read(gb, gb.cpu.regs.pc))
		emu_cycles(1)
		cpu.regs.pc += 1
		return

	case .AM_R_D16:
	case .AM_D16:
		{
			lo := u16(bus_read(gb, cpu.regs.pc))
			emu_cycles(1)

			hi := u16(bus_read(gb, cpu.regs.pc + 1))
			emu_cycles(1)

			cpu.fetched_data = lo | (hi << 8)

			cpu.regs.pc += 2

			return
		}

	case .AM_MR_R:
		cpu.fetched_data = cpu_read_reg(cpu, cpu.cur_inst.reg_2)
		cpu.mem_dest = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
		cpu.dest_is_mem = true

		if cpu.cur_inst.reg_1 == .RT_C {
			cpu.mem_dest |= 0xFF00
		}

		return

	case .AM_R_MR:
		{
			addr := cpu_read_reg(cpu, cpu.cur_inst.reg_2)

			if cpu.cur_inst.reg_2 == .RT_C {
				addr |= 0xFF00
			}

			cpu.fetched_data = u16(bus_read(gb, addr))
			emu_cycles(1)

		};return

	case .AM_R_HLI:
		cpu.fetched_data = u16(bus_read(gb, cpu_read_reg(cpu, cpu.cur_inst.reg_2)))
		emu_cycles(1)
		cpu_set_reg(cpu, .RT_HL, cpu_read_reg(cpu, .RT_HL) + 1)
		return

	case .AM_R_HLD:
		cpu.fetched_data = u16(bus_read(gb, cpu_read_reg(cpu, cpu.cur_inst.reg_2)))
		emu_cycles(1)
		cpu_set_reg(cpu, .RT_HL, cpu_read_reg(cpu, .RT_HL) - 1)
		return

	case .AM_HLI_R:
		cpu.fetched_data = cpu_read_reg(cpu, cpu.cur_inst.reg_2)
		cpu.mem_dest = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
		cpu.dest_is_mem = true
		cpu_set_reg(cpu, .RT_HL, cpu_read_reg(cpu, .RT_HL) + 1)
		return

	case .AM_HLD_R:
		cpu.fetched_data = cpu_read_reg(cpu, cpu.cur_inst.reg_2)
		cpu.mem_dest = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
		cpu.dest_is_mem = true
		cpu_set_reg(cpu, .RT_HL, cpu_read_reg(cpu, .RT_HL) - 1)
		return

	case .AM_R_A8:
		cpu.fetched_data = u16(bus_read(gb, cpu.regs.pc))
		emu_cycles(1)
		cpu.regs.pc += 1
		return

	case .AM_A8_R:
		cpu.mem_dest = u16(bus_read(gb, cpu.regs.pc)) | 0xFF00
		cpu.dest_is_mem = true
		emu_cycles(1)
		cpu.regs.pc += 1
		return

	case .AM_HL_SPR:
		cpu.fetched_data = u16(bus_read(gb, cpu.regs.pc))
		emu_cycles(1)
		cpu.regs.pc += 1
		return

	case .AM_D8:
		cpu.fetched_data = u16(bus_read(gb, cpu.regs.pc))
		emu_cycles(1)
		cpu.regs.pc += 1
		return

	case .AM_A16_R:
	case .AM_D16_R:
		{
			lo := u16(bus_read(gb, cpu.regs.pc))
			emu_cycles(1)

			hi := u16(bus_read(gb, cpu.regs.pc + 1))
			emu_cycles(1)

			cpu.mem_dest = lo | (hi << 8)
			cpu.dest_is_mem = true

			cpu.regs.pc += 2
			cpu.fetched_data = cpu_read_reg(cpu, cpu.cur_inst.reg_2)

		};return

	case .AM_MR_D8:
		cpu.fetched_data = u16(bus_read(gb, cpu.regs.pc))
		emu_cycles(1)
		cpu.regs.pc += 1
		cpu.mem_dest = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
		cpu.dest_is_mem = true
		return

	case .AM_MR:
		cpu.mem_dest = cpu_read_reg(cpu, cpu.cur_inst.reg_1)
		cpu.dest_is_mem = true
		cpu.fetched_data = u16(bus_read(gb, cpu_read_reg(cpu, cpu.cur_inst.reg_1)))
		emu_cycles(1)
		return

	case .AM_R_A16:
		{
			lo := u16(bus_read(gb, cpu.regs.pc))
			emu_cycles(1)

			hi := u16(bus_read(gb, cpu.regs.pc + 1))
			emu_cycles(1)

			addr := lo | (hi << 8)

			cpu.regs.pc += 2
			cpu.fetched_data = u16(bus_read(gb, addr))
			emu_cycles(1)

			return
		}

	case:
		fmt.printf("Unknown Addressing Mode! %d (%02X)\n", cpu.cur_inst.mode, cpu.cur_opcode)
		os.exit(-7)
	// return
	}
}
