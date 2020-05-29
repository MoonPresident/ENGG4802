import serial
import bitstruct

opcode = {
    "lui"   : ['uType', '0110111'],
    "auipc" : ['uType', '0010111'],
    
    "jal"   : ['jType', '1101111'],
    "jalr"  : ['iType', '1100111', '000'],
    
    "beq"   : ['bType', '1100011', '000'],
    "bne"   : ['bType', '1100011', '001'],
    "blt"   : ['bType', '1100011', '100'],
    "bge"   : ['bType', '1100011', '101'],
    "bltu"  : ['bType', '1100011', '110'],
    "bgeu"  : ['bType', '1100011', '111'],
               
    "lb"    : ['iType', '0000011', '000'],
    "lh"    : ['iType', '0000011', '001'],
    "lw"    : ['iType', '0000011', '010'],
    "lbu"   : ['iType', '0000011', '100'],
    "lhu"   : ['iType', '0000011', '101'],

    "sb"    : ['sType', '0100011', '000'],
    "sh"    : ['sType', '0100011', '001'],
    "sw"    : ['sType', '0100011', '010'],
    
    "addi"  : ['iType', '0010011', '000'],
    "slti"  : ['iType', '0010011', '010'],
    "sltiu" : ['iType', '0010011', '011'],
    "xori"  : ['iType', '0010011', '100'],
    "ori"   : ['iType', '0010011', '110'],
    "andi"  : ['iType', '0010011', '111'],
    
    "slli"  : ['rType', '0010011', '001', '0000000'],
    "srli"  : ['rType', '0010011', '101', '0000000'],
    "srai"  : ['rType', '0010011', '101', '0100000'],
    
    "add"   : ['rType', '0110011', '000', '0000000'],
    "sub"   : ['rType', '0110011', '000', '0100000'],
    "sll"   : ['rType', '0110011', '001', '0000000'],
    "slt"   : ['rType', '0110011', '010', '0000000'],
    "sltu"  : ['rType', '0110011', '011', '0000000'],
    "xor"   : ['rType', '0110011', '100', '0000000'],
    "srl"   : ['rType', '0110011', '101', '0000000'],
    "sra"   : ['rType', '0110011', '101', '0100000'],
    "or"    : ['rType', '0110011', '110', '0000000'],
    "and"   : ['rType', '0110011', '111', '0000000'],

    #special cases
    #"fence" : [fm, pred, succ, rs1, 000, rd, 0001111]
    "ecall" : ['00000000000000000000000001110011'],
    "ebreak" : ['00000000000100000000000001110011'],

    #ZICSR Extension
    "csrrw" : ['iType', '1110011', '001'],
    "csrrs" : ['iType', '1110011', '010'],
    "csrrc" : ['iType', '1110011', '011'],
    "csrrwi": ['iType', '1110011', '101'],
    "csrrsi": ['iType', '1110011', '110'],
    "csrrci": ['iType', '1110011', '111']
}

registers = {
    "zero": 0, #Hard-wired zero
    "ra" :  1, #Return address
    "sp" :  2, #Stack pointer
    "gp" :  3, #Global pointer
    "tp" :  4, #Thread pointer
    "t0" :  5, #Temporary / alternate link register
    "t1" :  6, #Temporaries
    "t2" :  7, #Temporaries
    "s0" :  8, #Saved register/frame pointer
    "fp" :  8, #Saved register/frame pointer double up
    "s1" :  9, #Saved register
    "a0" : 10, #Function arguments/return values
    "a1" : 11 #Function arguments/return values
}

def push_vals(register_list, offset, prefix, start, stop):
    for i in range(start, stop + 1):
        new_entry = prefix + str(i)
        register_list[new_entry] = i + offset

#Function arguments
push_vals(registers, 10, "a", 2, 7)

#Saved registers
push_vals(registers, 16, "s", 2, 11)

#Temporaries
push_vals(registers, 25, "t", 3, 6)



#Function pointers
funcPointers = {}

#FP temporaries
push_vals(funcPointers, 0,  "tf", 0, 7)

#FP saved registers
push_vals(funcPointers, 8,  "fs", 0, 1)

#FP arguments/return values
push_vals(funcPointers, 10, "fa", 0, 1)

#FP arguments
push_vals(funcPointers, 10, "fa", 2, 7)

#FP saved registers
push_vals(funcPointers, 16, "fs", 2, 11)

#FP temporaries
push_vals(funcPointers, 20, "ft", 8, 11)


class rType:
    funct7  = 0
    rs2     = 0
    rs1     = 0
    funct3  = 0
    rd      = 0
    opcode  = 0
    
    def __init__(self, _funct7, _rs2, _rs1, _funct3, _rd, _opcode):
        self.funct7 = _funct7
        self.rs2    = _rs2
        self.rs1    = _rs1
        self.funct3 = _funct3
        self.rd     = _rd
        self.opcode = _opcode

    def getHex(self):
        #7 bits, 5 bits, 5 bits, 3 bits, 5 bits, 7 bits
        return bitstruct.pack('u7u5u5u3u5u7', self.funct7, self.rs2, self.rs1, self.funct3, self.rd, self.opcode)



class iType:
    imm     = 0
    rs1     = 0
    funct3  = 0
    rd      = 0
    opcode  = 0
    
    def __init__(self, _imm, _rs1, _funct3, _rd, _opcode):
        self.imm    = _imm
        self.rs1    = _rs1
        self.funct3 = _funct3
        self.rd     = _rd
        self.opcode = _opcode

    def getHex(self):
        #11 bits, 5 bits, 3 bits, 5 bits, 7 bits
        return bitstruct.pack('s12u5u3u5u7', self.imm, self.rs1, self.funct3, self.rd, self.opcode)



class sType:
    imm     = 0
    rs2     = 0
    rs1     = 0
    funct3  = 0
    opcode  = 0
    
    def __init__(self, _imm, _rs2, _rs1, _funct3, _opcode):
        self.imm    = _imm
        self.rs2    = _rs2
        self.rs1    = _rs1
        self.funct3 = _funct3
        self.opcode = _opcode

    def getHex(self):
        #7 bits, 5 bits, 5 bits, 3 bits, 5 bits, 7 bits
        return bitstruct.pack('s7u5u5u3u5u7', self.imm >> 5, self.rs2, self.rs1, self.funct3, self.imm & 0x1f, self.opcode)



class bType(sType):
    def getHex(self):
        #1 bit, 6 bits, 5 bits, 5 bits, 3 bits, 5 bits, 7 bits
        return bitstruct.pack('s1u6u5u5u3u4u1u7', self.imm >> 12,(self.imm >> 5) & 0x3f, self.rs2, self.rs1,
                                                           self.funct3, (self.imm >> 4) & 0xf, self.imm & 0x1, self.opcode)



class uType:
    imm = 0
    rd = 0
    opcode = 0

    def __init__(self, _imm, _rd, _opcode):
        self.imm = _imm
        self.rd = _rd
        self.opcode = _opcode
    
    def getHex(self):
        #20 bits, 5 bits, 7 bits
        return bitstruct.pack('s20u5u7', imm >> 12, self.rd, self.opcode)



class jType(uType):
    def getHex(self):
        #1 bit, 10 bits, 1 bit, 8 bits, 5 bits, 7 bits
##        print(self.imm >> 20, (self.imm >> 1) & 0x3ff, (self.imm >> 11) & 1, (self.imm >> 12) & 0xff, self.rd, self.opcode)
        return bitstruct.pack('s1u10u1u8u5u7', self.imm >> 20, (self.imm >> 1) & 0x3ff,
                                                           (self.imm >> 11) & 1, (self.imm >> 12) & 0xff, self.rd, self.opcode)

file = "rpu_hello_world.txt"
#file = input("Input filename: ")
file = open(file, 'r')

outputFile = file.name.split('.')
print(outputFile)

command = file.readline()

while(command != ""):
##    print(command)
    flag = 0
    prefix = "  X\""
    postfix = "\",  -- " + command.strip('\n')
    if '(' in command:
        flag = 1
    command = command.strip('\n').strip('\t').replace(",", " ").replace(")", "").replace("(", " ").split(' ')
    while "" in command:
        command.remove("")
##    print(command)
    op = opcode[command[0]]
    args = command[1:]
    if(flag):
        temp = args[1]
##        print("Before: " + str(args))
        args[1] = args[2]
        args[2] = temp
##        print("After: " + str(args))
        
##    print(op, args)
    if(op[0] == 'rType'):
        a = rType(int(op[3], 2), register[args[1]], registers[args[2]], int(op[2], 2), registers[args[0]], int(op[1], 2))
    elif(op[0] == 'iType'):
        #               _imm,           _rs1,               _funct3,        _rd,            _opcode
##        print(int(op[1],2))
        a = iType(int(args[2], 10), registers[args[1]], int(op[2], 2), registers[args[0]], int(op[1], 2))
    elif(op[0] == 'sType'):
        a = sType(int(args[2], 10), registers[args[1]], registers[args[0]], int(op[2], 2), int(op[1], 2))
    elif(op[0] == 'bType'):
        a = bType(int(args[2], 10), registers[args[1]], registers[args[0]], int(op[2], 2), int(op[1], 2))
    elif(op[0] == 'uType'):
        a = uType(int(args[1], 10), registers[args[0]], int(op[1], 2))
    elif(op[0] == 'jType'):
        a = jType(int(args[1], 10), registers[args[0]], int(op[1], 2))
    #print(command)
    print(prefix + str(hex(bitstruct.unpack('u32', a.getHex())[0]))[2:].zfill(8) + postfix)
    command = file.readline()
    





file.close()
