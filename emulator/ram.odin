package emulator

import "core:os"
import "core:fmt"

Ram :: struct {
  wram: [0x2000]u8,
  hram: [0x80]u8,
}

init_ram :: proc() -> ^Ram{
  return new(Ram)
}

destroy_ram :: proc(ram: ^Ram){
  free(ram)
}

wram_read :: proc(ram: ^Ram, address: u16) -> u8 {
    index := address - 0xC000

    if index >= 0x2000 {
        fmt.printf("INVALID WRAM ADDR %08X\n", address + 0xC000);
        os.exit(-1);
    }

    return ram.wram[index];
}

wram_write :: proc(ram: ^Ram, address: u16, value: u8) {
    index := address - 0xC000

    ram.wram[index] = value
}

hram_read :: proc(ram: ^Ram, address: u16)  -> u8{
  index := address - 0xFF80

    return ram.hram[index]
}

hram_write :: proc(ram: ^Ram, address: u16, value: u8) {
  index := address - 0xFF80

    ram.hram[index] = value
}
