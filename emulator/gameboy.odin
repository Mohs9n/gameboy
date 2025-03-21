package emulator

GameBoy :: struct {
	Cart: ^Cart,
}

create_gameboy :: proc() -> ^GameBoy {
	gb := new(GameBoy)
	gb.Cart = load_cart("refs/roms/The_Legend_of_Zelda_Link's_Awakening.gb")

	return gb
}
