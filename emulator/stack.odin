package emulator

stack_push :: proc(gb: ^GameBoy, data: u8) {
	gb.cpu.regs.sp -= 1
	bus_write(gb, gb.cpu.regs.sp, data)
}

stack_push16 :: proc(gb: ^GameBoy, data: u16) {
	stack_push(gb, u8((data >> 8) & 0xFF))
	stack_push(gb, u8(data & 0xFF))
}

stack_pop :: proc(gb: ^GameBoy) -> u8 {
	addr := gb.cpu.regs.sp
	ret := bus_read(gb, gb.cpu.regs.sp)
	gb.cpu.regs.sp += 1

	return ret
}

stack_pop16 :: proc(gb: ^GameBoy) -> u16 {
	lo := stack_pop(gb)
	hi := stack_pop(gb)

	return u16((hi << 8) | lo)
}
