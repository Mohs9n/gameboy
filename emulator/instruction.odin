package emulator

Instruction :: struct {
	type:  InType,
	mode:  AddrMode,
	reg_1: RegType,
	reg_2: RegType,
	cond:  CondType,
	param: u8,
	fn:    InsProc,
}

InsProc :: proc(gb: ^GameBoy)


instructions: [0x100]Instruction = {
	0x00 = Instruction{type = .IN_NOP, mode = .AM_IMP, fn = ins_nop},
	0x01 = Instruction{type = .IN_LD, mode = .AM_R_D16, reg_1 = .RT_BC, fn = ins_ld},
	0x02 = Instruction{type = .IN_LD, mode = .AM_MR_R, reg_1 = .RT_BC, reg_2 = .RT_A, fn = ins_ld},
	0x05 = Instruction{type = .IN_DEC, mode = .AM_R, reg_1 = .RT_B},
	0x06 = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_B, fn = ins_ld},
	0x08 = Instruction{type = .IN_LD, mode = .AM_A16_R, reg_2 = .RT_SP, fn = ins_ld},
	0x0A = Instruction{type = .IN_LD, mode = .AM_R_MR, reg_1 = .RT_A, reg_2 = .RT_BC, fn = ins_ld},
	0x0E = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_C, fn = ins_ld},

	// 0x1X
	0x11 = Instruction{type = .IN_LD, mode = .AM_R_D16, reg_1 = .RT_DE, fn = ins_ld},
	0x12 = Instruction{type = .IN_LD, mode = .AM_MR_R, reg_1 = .RT_DE, reg_2 = .RT_A, fn = ins_ld},
	0x15 = Instruction{type = .IN_DEC, mode = .AM_R, reg_1 = .RT_D},
	0x16 = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_D, fn = ins_ld},
	0x1A = Instruction{type = .IN_LD, mode = .AM_R_MR, reg_1 = .RT_A, reg_2 = .RT_DE, fn = ins_ld},
	0x1E = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_E, fn = ins_ld},

	// 0x2X
	0x21 = Instruction{type = .IN_LD, mode = .AM_R_D16, reg_1 = .RT_HL, fn = ins_ld},
	0x22 = Instruction {
		type = .IN_LD,
		mode = .AM_HLI_R,
		reg_1 = .RT_HL,
		reg_2 = .RT_A,
		fn = ins_ld,
	},
	0x25 = Instruction{type = .IN_DEC, mode = .AM_R, reg_1 = .RT_H},
	0x26 = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_H, fn = ins_ld},
	0x2A = Instruction {
		type = .IN_LD,
		mode = .AM_R_HLI,
		reg_1 = .RT_A,
		reg_2 = .RT_HL,
		fn = ins_ld,
	},
	0x2E = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_L, fn = ins_ld},

	// 0x3X
	0x31 = Instruction{type = .IN_LD, mode = .AM_R_D16, reg_1 = .RT_SP, fn = ins_ld},
	0x32 = Instruction {
		type = .IN_LD,
		mode = .AM_HLD_R,
		reg_1 = .RT_HL,
		reg_2 = .RT_A,
		fn = ins_ld,
	},
	0x35 = Instruction{type = .IN_DEC, mode = .AM_R, reg_1 = .RT_HL},
	0x36 = Instruction{type = .IN_LD, mode = .AM_MR_D8, reg_1 = .RT_HL, fn = ins_ld},
	0x3A = Instruction {
		type = .IN_LD,
		mode = .AM_R_HLD,
		reg_1 = .RT_A,
		reg_2 = .RT_HL,
		fn = ins_ld,
	},
	0x3E = Instruction{type = .IN_LD, mode = .AM_R_D8, reg_1 = .RT_A, fn = ins_ld},

	// Sample continuation
	0xAF = Instruction{type = .IN_XOR, mode = .AM_R, reg_1 = .RT_A, fn = ins_xor},
	0xC3 = Instruction{type = .IN_JP, mode = .AM_D16, fn = ins_jp},

	// 0xEx
	0xE0 = Instruction{type = .IN_LDH, mode = .AM_A8_R, reg_2 = .RT_A, fn = ins_ldh},
	0xE2 = Instruction{type = .IN_LD, mode = .AM_MR_R, reg_1 = .RT_C, reg_2 = .RT_A, fn = ins_ld},
	0xEA = Instruction{type = .IN_LD, mode = .AM_A16_R, reg_2 = .RT_A, fn = ins_ld},

	// 0xFx
	0xF0 = Instruction{type = .IN_LDH, mode = .AM_R_A8, reg_1 = .RT_A, fn = ins_ldh},
	0xF2 = Instruction{type = .IN_LD, mode = .AM_R_MR, reg_1 = .RT_A, reg_2 = .RT_C, fn = ins_ld},
	0xF3 = Instruction{type = .IN_DI, fn = ins_di},
	0xFA = Instruction{type = .IN_LD, mode = .AM_R_A16, reg_1 = .RT_A, fn = ins_ld},
}

instruction_by_opcode :: proc(opcode: u8) -> ^Instruction {
	return &instructions[opcode]
}

@(rodata)
inst_lookup := [?]string {
	"<NONE>",
	"NOP",
	"LD",
	"INC",
	"DEC",
	"RLCA",
	"ADD",
	"RRCA",
	"STOP",
	"RLA",
	"JR",
	"RRA",
	"DAA",
	"CPL",
	"SCF",
	"CCF",
	"HALT",
	"ADC",
	"SUB",
	"SBC",
	"AND",
	"XOR",
	"OR",
	"CP",
	"POP",
	"JP",
	"PUSH",
	"RET",
	"CB",
	"CALL",
	"RETI",
	"LDH",
	"JPHL",
	"DI",
	"EI",
	"RST",
	"IN_ERR",
	"IN_RLC",
	"IN_RRC",
	"IN_RL",
	"IN_RR",
	"IN_SLA",
	"IN_SRA",
	"IN_SWAP",
	"IN_SRL",
	"IN_BIT",
	"IN_RES",
	"IN_SET",
}

inst_name :: proc(t: InType) -> string {
	return inst_lookup[t]
}


AddrMode :: enum {
	AM_IMP,
	AM_R_D16,
	AM_R_R,
	AM_MR_R,
	AM_R,
	AM_R_D8,
	AM_R_MR,
	AM_R_HLI,
	AM_R_HLD,
	AM_HLI_R,
	AM_HLD_R,
	AM_R_A8,
	AM_A8_R,
	AM_HL_SPR,
	AM_D16,
	AM_D8,
	AM_D16_R,
	AM_MR_D8,
	AM_MR,
	AM_A16_R,
	AM_R_A16,
}

RegType :: enum {
	RT_NONE,
	RT_A,
	RT_F,
	RT_B,
	RT_C,
	RT_D,
	RT_E,
	RT_H,
	RT_L,
	RT_AF,
	RT_BC,
	RT_DE,
	RT_HL,
	RT_SP,
	RT_PC,
}

InType :: enum {
	IN_NONE,
	IN_NOP,
	IN_LD,
	IN_INC,
	IN_DEC,
	IN_RLCA,
	IN_ADD,
	IN_RRCA,
	IN_STOP,
	IN_RLA,
	IN_JR,
	IN_RRA,
	IN_DAA,
	IN_CPL,
	IN_SCF,
	IN_CCF,
	IN_HALT,
	IN_ADC,
	IN_SUB,
	IN_SBC,
	IN_AND,
	IN_XOR,
	IN_OR,
	IN_CP,
	IN_POP,
	IN_JP,
	IN_PUSH,
	IN_RET,
	IN_CB,
	IN_CALL,
	IN_RETI,
	IN_LDH,
	IN_JPHL,
	IN_DI,
	IN_EI,
	IN_RST,
	IN_ERR,
	//CB instructions...
	IN_RLC,
	IN_RRC,
	IN_RL,
	IN_RR,
	IN_SLA,
	IN_SRA,
	IN_SWAP,
	IN_SRL,
	IN_BIT,
	IN_RES,
	IN_SET,
}

CondType :: enum {
	CT_NONE,
	CT_NZ,
	CT_Z,
	CT_NC,
	CT_C,
}
