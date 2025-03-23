package emulator

import "core:fmt"
import "core:os"

// 0x0000 - 0x3FFF : ROM Bank 0
// 0x4000 - 0x7FFF : ROM Bank 1 - Switchable
// 0x8000 - 0x97FF : CHR RAM
// 0x9800 - 0x9BFF : BG Map 1
// 0x9C00 - 0x9FFF : BG Map 2
// 0xA000 - 0xBFFF : Cartridge RAM
// 0xC000 - 0xCFFF : RAM Bank 0
// 0xD000 - 0xDFFF : RAM Bank 1-7 - switchable - Color only
// 0xE000 - 0xFDFF : Reserved - Echo RAM
// 0xFE00 - 0xFE9F : Object Attribute Memory
// 0xFEA0 - 0xFEFF : Reserved - Unusable
// 0xFF00 - 0xFF7F : I/O Registers
// 0xFF80 - 0xFFFE : Zero Page


bus_read :: proc(gb: ^GameBoy, address: u16) -> u8 {
	if address < 0x8000 {
		//ROM Data
		return cart_read(gb.cart, address)
	} else if address < 0xA000 {
		//Char/Map Data
		//TODO
		fmt.printf("UNSUPPORTED bus_read(%04X)\n", address)
		todo()
	} else if address < 0xC000 {
		//Cartridge RAM
		return cart_read(gb.cart, address)
	} else if address < 0xE000 {
		//WRAM (Working RAM)
		return wram_read(gb.ram, address)
	} else if address < 0xFE00 {
		//reserved echo ram...
		return 0
	} else if address < 0xFEA0 {
		//OAM
		//TODO
		fmt.printf("UNSUPPORTED bus_read(%04X)\n", address)
		todo()
	} else if address < 0xFF00 {
		//reserved unusable...
		return 0
	} else if address < 0xFF80 {
		//IO Registers...
		//TODO
		fmt.printf("UNSUPPORTED bus_read(%04X)\n", address)
		todo()
	} else if address == 0xFFFF {
		//CPU ENABLE REGISTER...
		//TODO
		return cpu_get_ie_register(gb.cpu)
	}

	//NO_IMPL
	return hram_read(gb.ram, address)
}

bus_write :: proc(gb: ^GameBoy, address: u16, value: u8) {
	if (address < 0x8000) {
		//ROM Data
		cart_write(gb.cart, address, value)
	} else if (address < 0xA000) {
		//Char/Map Data
		//TODO
		fmt.printf("UNSUPPORTED bus_write(%04X)\n", address)
		todo()
	} else if (address < 0xC000) {
		//EXT-RAM
		cart_write(gb.cart, address, value)
	} else if (address < 0xE000) {
		//WRAM
		wram_write(gb.ram, address, value)
	} else if (address < 0xFE00) {
		//reserved echo ram
	} else if (address < 0xFEA0) {
		//OAM

		//TODO
		fmt.printf("UNSUPPORTED bus_write(%04X)\n", address)
		todo()
	} else if (address < 0xFF00) {
		//unusable reserved
	} else if (address < 0xFF80) {
		//IO Registers...
		//TODO
		fmt.printf("UNSUPPORTED bus_write(%04X)\n", address)
		//NO_IMPL
	} else if (address == 0xFFFF) {
		//CPU SET ENABLE REGISTER

		cpu_set_ie_register(gb.cpu, value)
	} else {
		hram_write(gb.ram, address, value)
	}
}


bus_read16 :: proc(gb: ^GameBoy, address: u16) -> u16 {
	lo := u16(bus_read(gb, address))
	hi := u16(bus_read(gb, address + 1))

	return lo | (hi << 8)
}

bus_write16 :: proc(gb: ^GameBoy, address, value: u16) {
	bus_write(gb, address + 1, u8((value >> 8) & 0xFF))
	bus_write(gb, address, u8(value & 0xFF))
}
