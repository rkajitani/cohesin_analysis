#include <stdint.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <ctype.h>
#include <cmath>

using namespace std;

long get_fasta(ifstream &ifs, string &name, string &seq);


int main(int argc, char **argv)
{
	if (argc != 5) {
		cerr << "usage: " << argv[0] << " depth.tsv region.bed ref.fa bin_num\n";
		exit(1);
	}

	ifstream ifs;
	string seq;
	string line;
	string name;
	unordered_map<string, vector<int32_t> > base_depth;
	int64_t n_bin = atoi(argv[4]);


	ifs.open(argv[3]);
	if (!ifs) {
		cerr << "cannot open\n";
		return 1;
	}
	while (get_fasta(ifs, name, seq))
		base_depth[name] = vector<int32_t>(seq.size(), -1);
	ifs.close();


	ifs.open(argv[1]);
	if (!ifs) {
		cerr << "cannot open\n";
		return 1;
	}
	while (1) {
		string seq_name;
		int64_t pos;
		int32_t depth;
		ifs >> seq_name >> pos >> depth;
		if (!ifs)
			break;
		base_depth[seq_name][pos - 1]  = depth;
	}
	ifs.close();


	vector<int64_t> sum_buffer(n_bin, 0);
	vector<int64_t> num_buffer(n_bin, 0);
	ifs.open(argv[2]);
	if (!ifs) {
		cerr << "cannot open\n";
		return 1;
	}
	while (1) {
		string seq_name;
		string strand;
		int64_t start;
		int64_t end;
		ifs >> seq_name >> start >> end >> name >> strand >> strand;
		if (!ifs)
			break;

		if (end - start < n_bin)
			continue;

		auto seq_itr = base_depth.find(seq_name);
		if (seq_itr == base_depth.end())
			continue;

		fill(num_buffer.begin(), num_buffer.end(), 0);
		fill(sum_buffer.begin(), sum_buffer.end(), 0);
		int64_t bin_size = ceil((double)(end - start) / n_bin);
		if (strand == "+") {
			for (int64_t pos = start; pos < end; ++pos) {
				int64_t bin_idx = (pos - start) / bin_size;
				if (seq_itr->second[pos] >= 0) {
					++num_buffer[bin_idx];
					sum_buffer[bin_idx] += seq_itr->second[pos];
				}
			}
		}
		else {
			for (int64_t pos = start; pos < end; ++pos) {
				int64_t bin_idx = (end - pos - 1) / bin_size;
				if (seq_itr->second[pos] >= 0) {
					++num_buffer[bin_idx];
					sum_buffer[bin_idx] += seq_itr->second[pos];
				}
			}
		}
		cout << name;
		for (int64_t i = 0; i < n_bin; ++i) {
			if (num_buffer[i] > 0)
				cout << "\t" << (double)sum_buffer[i] / num_buffer[i];
			else
				cout << "\tnan";
		}
		cout << "\n";
	}
	ifs.close();

	return 0;
}


long get_fasta(ifstream &ifs, string &name, string &seq)
{
	string line;

	seq.clear();
	while (getline(ifs, line)) {
		 if (line.size() > 0 && line[0] == '>') {
			stringstream buf(line.substr(1));
			buf >> name;
		 	break;
		}
	}
	if (line.size() == 0)
		return 0;

	while (getline(ifs, line)) {
		if (line.size() > 0 && line[0] == '>')
			break;
		seq += line;
	}
	if (line.size() > 0 && line[0] == '>') {
		ifs.seekg(-((long)line.size() + 1), ios_base::cur);
	}

	return 1;
}
