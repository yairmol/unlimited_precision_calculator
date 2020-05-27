make
./generator
./calc < input.txt > expected_output.txt
./calc2 < input.txt > output.txt
./test
make clean