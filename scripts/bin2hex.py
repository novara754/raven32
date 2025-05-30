import sys
import os
import binascii

def main():
    bin_filename = sys.argv[1];
    hex_filename = os.path.splitext(bin_filename)[0] + ".hex"

    with open(bin_filename, "rb") as ifile, open(hex_filename, "wb") as ofile:
        while word := ifile.read(4):
            word = word[::-1]
            if len(word) < 4: word = b"\0" * (4 - len(word)) + word
            ofile.write(binascii.hexlify(word))
            ofile.write(b"\n")


if __name__ == "__main__":
    main()
