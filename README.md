The Thesis_General folder contains an RPU implementation with modifications made to the machine code.

The risc_programmer.py file runs a program that looks for a predefined text file in the environment and outputs the machine equivalent of ASM commands in the file.
In this case, it looks at rpu_hello_world.txt, a program that increments a single register indefinitely. This is output to the 7-seg display.