import serial


file = input("Input filename: ")
file = open(file, 'r')

outputFile = file.name.split('.')
print(outputFile)

command = file.readline)

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
push_vals(registers, offset=10, "a", 2, 7)

#Saved registers
push_vals(registers, offset=16, "s", 2, 11)

#Temporaries
push_vals(registers, offset=25, "t", 3, 6)



#Function pointers
funcPointers = {}

#FP temporaries
push_vals(funcPointers, offset=0,  "tf", 0, 7)

#FP saved registers
push_vals(funcPointers, offset=8,  "fs", 0, 1)

#FP arguments/return values
push_vals(funcPointers, offset=10, "fa", 0, 1)

#FP arguments
push_vals(funcPointers, offset=10, "fa", 2, 7)

#FP saved registers
push_vals(funcPointers, offset=16, "fs", 2, 11)

#FP temporaries
push_vals(funcPointers, offset=20, "ft", 8, 11)


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

    def getHex():
        #7 bits, 5 bits, 5 bits, 3 bits, 5 bits, 7 bits
        print(bitarray(funct7), bitarray(rs2), bitarray(rs1), bitarray(funct3), bitarray(rd), bitarray(opcode))

        
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

    def getHex():
        #7 bits, 5 bits, 5 bits, 3 bits, 5 bits, 7 bits
        print(bitarray(imm), bitarray(rs2), bitarray(rs1), bitarray(funct3), bitarray(rd), bitarray(opcode))


class bType(sType):
    def getHex():
        pass

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
    "ebreak" : ['00000000000100000000000001110011']
}

while(command != ""):
    print(command)
    print(byte_array
    command = file.readline()
    





file.close()
