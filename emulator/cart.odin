// #+feature dynamic-literals

package emulator

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

RomHeader :: struct {
	entry:           [4]u8,
	logo:            [0x30]u8,
	title:           [16]u8,
	new_lic_code:    u16,
	sgb_flag:        u8,
	type:            u8,
	rom_size:        u8,
	ram_size:        u8,
	dest_code:       u8,
	lic_code:        u8,
	version:         u8,
	checksum:        u8,
	global_checksum: u16,
}

Cart :: struct {
	filename: string,
	rom_size: u32,
	rom_data: []byte,
	header:   ^RomHeader,
}

load_cart :: proc(path: string) -> ^Cart {
	fd, err := os.open(path)
	defer os.close(fd)
	if err != nil {
		fmt.printf("Failed to load cart file, err: %v", err)
		return nil
	}

	fmt.printf("Opened: %s\n", path)

	cart := new(Cart)
	cart.filename = filepath.base(path)
	if size, err := os.file_size(fd); err == nil {
		cart.rom_size = u32(size)
	}

	cart.rom_data = make([]byte, cart.rom_size)
	os.read(fd, cart.rom_data)

	cart.header = cast(^RomHeader)(&cart.rom_data[0x100])
	cart.header.title[15] = 0

	print_cart_info(cart)
	cart_checksum(cart)

	return cart
}

destroy_cart :: proc(cart: ^Cart) {
	delete(cart.rom_data)
	free(cart)
}

cart_read :: proc(cart: ^Cart, address: u16) -> u8 {
	//for now just ROM ONLY type supported...

	return cart.rom_data[address]
}

cart_write :: proc(cart: ^Cart, address: u16, value: u8) {
	//for now, ROM ONLY...

	todo()
}


get_title :: proc(header: ^RomHeader) -> string {
	return strings.string_from_null_terminated_ptr(&header.title[0], 16)
	// return strings.trim_right(s, "\x00")
}

cart_checksum :: proc(cart: ^Cart) {
	x: u16
	for i := 0x0134; i <= 0x014C; i += 1 {
		x = x - u16(cart.rom_data[i]) - 1
	}

	fmt.printf(
		"\t Checksum : %2.2X (%s)\n",
		cart.header.checksum,
		(x & 0xFF) != 0 ? "PASSED" : "FAILED",
	)
}


print_cart_info :: proc(cart: ^Cart) {
	fmt.printf("\t Title    : %s\n", get_title(cart.header))
	fmt.printf("\t Type     : %2.2X (%s)\n", cart.header.type, cart_type_name(cart.header))
	fmt.printf("\t ROM Size : %d KB\n", i32(32) << cart.header.rom_size)
	fmt.printf("\t RAM Size : %2.2X\n", cart.header.ram_size)
	fmt.printf("\t LIC Code : %2.2X (%s)\n", cart.header.lic_code, cart_lic_name(cart.header))
	fmt.printf("\t ROM Vers : %2.2X\n", cart.header.version)
}

cart_lic_name :: proc(rh: ^RomHeader) -> string {
	if rh.new_lic_code <= 0xA4 {
		return LIC_CODE[rh.lic_code]
	}

	return "UNKNOWN"
}

cart_type_name :: proc(rh: ^RomHeader) -> string {
	if rh.type <= 0x22 {
		return ROM_TYPES[rh.type]
	}

	return "UNKNOWN"
}

@(rodata)
ROM_TYPES: [35]string = {
	"ROM ONLY",
	"MBC1",
	"MBC1+RAM",
	"MBC1+RAM+BATTERY",
	"0x04 ???",
	"MBC2",
	"MBC2+BATTERY",
	"0x07 ???",
	"ROM+RAM 1",
	"ROM+RAM+BATTERY 1",
	"0x0A ???",
	"MMM01",
	"MMM01+RAM",
	"MMM01+RAM+BATTERY",
	"0x0E ???",
	"MBC3+TIMER+BATTERY",
	"MBC3+TIMER+RAM+BATTERY 2",
	"MBC3",
	"MBC3+RAM 2",
	"MBC3+RAM+BATTERY 2",
	"0x14 ???",
	"0x15 ???",
	"0x16 ???",
	"0x17 ???",
	"0x18 ???",
	"MBC5",
	"MBC5+RAM",
	"MBC5+RAM+BATTERY",
	"MBC5+RUMBLE",
	"MBC5+RUMBLE+RAM",
	"MBC5+RUMBLE+RAM+BATTERY",
	"0x1F ???",
	"MBC6",
	"0x21 ???",
	"MBC7+SENSOR+RUMBLE+RAM+BATTERY",
}


@(rodata)
LIC_CODE: []string = {
	0x00 = "None",
	0x01 = "Nintendo R&D1",
	0x08 = "Capcom",
	0x13 = "Electronic Arts",
	0x18 = "Hudson Soft",
	0x19 = "b-ai",
	0x20 = "kss",
	0x22 = "pow",
	0x24 = "PCM Complete",
	0x25 = "san-x",
	0x28 = "Kemco Japan",
	0x29 = "seta",
	0x30 = "Viacom",
	0x31 = "Nintendo",
	0x32 = "Bandai",
	0x33 = "Ocean/Acclaim",
	0x34 = "Konami",
	0x35 = "Hector",
	0x37 = "Taito",
	0x38 = "Hudson",
	0x39 = "Banpresto",
	0x41 = "Ubi Soft",
	0x42 = "Atlus",
	0x44 = "Malibu",
	0x46 = "angel",
	0x47 = "Bullet-Proof",
	0x49 = "irem",
	0x50 = "Absolute",
	0x51 = "Acclaim",
	0x52 = "Activision",
	0x53 = "American sammy",
	0x54 = "Konami",
	0x55 = "Hi tech entertainment",
	0x56 = "LJN",
	0x57 = "Matchbox",
	0x58 = "Mattel",
	0x59 = "Milton Bradley",
	0x60 = "Titus",
	0x61 = "Virgin",
	0x64 = "LucasArts",
	0x67 = "Ocean",
	0x69 = "Electronic Arts",
	0x70 = "Infogrames",
	0x71 = "Interplay",
	0x72 = "Broderbund",
	0x73 = "sculptured",
	0x75 = "sci",
	0x78 = "THQ",
	0x79 = "Accolade",
	0x80 = "misawa",
	0x83 = "lozc",
	0x86 = "Tokuma Shoten Intermedia",
	0x87 = "Tsukuda Original",
	0x91 = "Chunsoft",
	0x92 = "Video system",
	0x93 = "Ocean/Acclaim",
	0x95 = "Varie",
	0x96 = "Yonezawa/s’pal",
	0x97 = "Kaneko",
	0x99 = "Pack in soft",
	0xA4 = "Konami (Yu-Gi-Oh!)",
}
