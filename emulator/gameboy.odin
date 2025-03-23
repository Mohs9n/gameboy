package emulator

import "core:fmt"
import sdl "vendor:sdl2"

GameBoy :: struct {
	paused:  bool,
	running: bool,
	ticks:   u64,
	cart:    ^Cart,
	cpu:     ^CPU,
	ram:     ^Ram,
}

create_gameboy :: proc() -> ^GameBoy {
	gb := new(GameBoy)
	// gb.cart = load_cart("refs/roms/The_Legend_of_Zelda_Link's_Awakening.gb")
	gb.cart = load_cart("refs/roms/Super_Mario_Land.gb")
	// gb.cart = load_cart("roms/01-special.gb")
	gb.cpu = cpu_init()
	gb.ram = init_ram()

	gb.running = true
	gb.paused = false
	gb.ticks = 0

	return gb
}

run_gameboy :: proc(gb: ^GameBoy) {
	for gb.running {
		if gb.paused {
			delay(10)
			continue
		}

		if !cpu_step(gb) {
			fmt.printf("CPU Stopped\n")
			return
		}

		gb.ticks += 1
	}

}

destroy_gameboy :: proc(gb: ^GameBoy) {
	destroy_cart(gb.cart)
	destroy_cpu(gb.cpu)
	destroy_ram(gb.ram)
	free(gb)
}


emu_cycles :: proc(cpu_cycles: int) {
	//TODO...
}


delay :: proc(ms: u32) {
	sdl.Delay(ms)
}
