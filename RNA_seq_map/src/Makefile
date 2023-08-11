CXX = g++
CXXFLAGS = -std=c++0x -O3 -funroll-loops -finline-limit-50000
#CXXFLAGS = -std=c++0x -O0 -g -funroll-loops -finline-limit-50000

PRG = depth_bed depth_bed_bin depth_bed_mean bam_read_name_grep
SRC = depth_bed.cpp depth_bed_bin.cpp depth_bed_mean.cpp bam_read_name_grep.cpp

all: $(PRG)

$(PRG): $(SRC)
	$(CXX) -o $@ $(CXXFLAGS) $@.cpp

clean:
	rm -f $(PRG)
