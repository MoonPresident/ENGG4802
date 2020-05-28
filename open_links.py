from subprocess import call
from subprocess import Popen
import os

websites = [
    "https://godbolt.org/",
    "https://rosettacode.org/wiki/Fast_Fourier_transform",
    "https://news.ycombinator.com/item?id=19118642",
    "https://rv8.io/isa.html",
    "https://www.cl.cam.ac.uk/teaching/1617/ECAD+Arch/files/docs/RISCVGreenCardv8-20151013.pdf",
    "https://metalcode.eu/2019-12-06-rv32i.html",
    "https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf"
]

for website in websites:
    try:
        call(["C:\\Program Files\\Mozilla Firefox\\firefox.exe",\
                website])
    except:
        continue;
