from pathlib import Path

import dual_emu
from dual_emu import IEmulatorWithInput, parse_args_cli

import os, sys

INSIZE = 32

def entry_hook(emu: IEmulatorWithInput):
    print('// Entry hook')

def print_hook(emu):
    ptr = emu.read_reg_i('r0')
    sys.stdout.write("PRINT: ")
    i = 0
    while True:
        c = emu.read_mem_u8(ptr + i)
        c = chr(c)
        if c == '\0': break
        sys.stdout.write(c)
        i += 1
    ra = emu.read_reg_i('lr')
    emu.write_reg('pc', ra)

def gsm_cmd_hook(emu):
    print("// GSM command")
    ptr = emu.read_reg_i('r3')
    emu.cur_input.mark_symbolic_span(0, INSIZE)
    emu.write_mem_b(ptr, emu.cur_input.get_span(0, INSIZE))
    emu.write_reg('r0', 1)
    ra = emu.read_reg_i('lr')
    emu.write_reg('pc', ra)

dump_path = Path(__file__).parent / 'dump' / 'info.json'
args = parse_args_cli(input_file_required=True)

with open(str(args.input), 'rb') as f: inp = f.read()
if len(inp) < INSIZE: inp += b'\x00' * (INSIZE - len(inp))
if len(inp) > INSIZE: inp = inp[:INSIZE]
with open(str(args.input), 'wb') as f: f.write(inp)

emu = dual_emu.make_emulator_with_input(args.angr, args.input, dump_file=dump_path, exits=[0x000000F6],
                                        lighthouse_out_path=args.lighthouse)

if args.qiling:
    emu.hook_fuzzer_start(emu.start_addr)

emu.hook_addr(emu.start_addr, entry_hook)
emu.hook_addr(0x000000C2, print_hook)
emu.hook_addr(0x000002C8, gsm_cmd_hook)

emu.run()

if args.angr:
    if emu.sim_man.errored:
        print('Crashes:')
        print(emu.sim_man.errored)

    dual_emu.dump_new_inputs(emu, args.out_dir, clean=True)
