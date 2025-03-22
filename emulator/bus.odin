package emulator

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


bus_read :: proc(cart: ^Cart, address: u16) -> u8 {
	if address < 0x8000 {
		//ROM Data
		return cart_read(cart, address)
	}

	todo()
}

bus_write :: proc(cart: ^Cart, address: u16, value: u8) {
	if address < 0x8000 {
		//ROM Data
		cart_write(cart, address, value)
		return
	}

	todo()
}


bus_read16 :: proc(cart: ^Cart, address: u16) -> u16 {
	lo := u16(bus_read(cart, address))
	hi := u16(bus_read(cart, address + 1))

	return lo | (hi << 8)
}

bus_write16 :: proc(cart: ^Cart, address, value: u16) {
	bus_write(cart, address + 1, u8((value >> 8) & 0xFF))
	bus_write(cart, address, u8(value & 0xFF))
}
