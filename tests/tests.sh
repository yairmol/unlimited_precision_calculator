make
#./generator
./calc < random_input.txt > expected_output.txt
./calc2 < random_input.txt > output.txt
./test
make clean