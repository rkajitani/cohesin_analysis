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
	if (argc != 4) {
		cerr << "usage: " << argv[0] << " depth.tsv region.bed3 ref.fa\n";
		exit(1);
	}

	ifstream ifs;
	string seq;
	string line;
	string name;
	unordered_map<string, vector<uint32_t> > base_depth;


	ifs.open(argv[3]);
	if (!ifs) {
		cerr << "cannot open\n";
		return 1;
	}
	while (get_fasta(ifs, name, seq))
		base_depth[name] = vector<uint32_t>(seq.size(), 0);
	ifs.close();


	ifs.open(argv[1]);
	if (!ifs) {
		cerr << "cannot open\n";
		return 1;
	}
	while (1) {
		string seq_name;
		int64_t pos;
		uint32_t depth;
		ifs >> seq_name >> pos >> depth;
		if (!ifs)
			break;
		base_depth[seq_name][pos - 1]  = depth;
	}
	ifs.close();


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
		ifs >> seq_name >> start >> end;
		if (!ifs)
			break;

		auto seq_itr = base_depth.find(seq_name);
		if (seq_itr == base_depth.end())
			continue;

		int64_t num = 0;
		int64_t sum = 0;
		for (int64_t pos = start; pos < end; ++pos) {
			++num;
			sum += seq_itr->second[pos];
		}
		if (num > 0)
			cout << seq_name << '\t' << (double)sum / num << '\n';
		else
			cout << seq_name << '\t' << 0 << '\n';
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
