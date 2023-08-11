#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <unordered_set>

using namespace std;


FILE *getline_fp(stringstream &ss, FILE *fp);
void print_bam_header(const char *bam_name);
void grep_bam(const unordered_set<string> &read_name_set, const char *bam_name);


int main(int argc, char **argv)
{
	if (argc < 3) {
		cerr << "usage: " << argv[0] << " read_name_list.txt in.bam > out.sam\n";
		exit(1);
	}

	unordered_set<string> read_name_set; 
	ifstream fin(argv[1]);
	string ln;
	if (fin.is_open()) {
		while (std::getline(fin, ln)) {
			read_name_set.insert(ln);
		}
		fin.close();
	}

	print_bam_header(argv[2]);
	grep_bam(read_name_set, argv[2]);

	return 0;
}


FILE *getline_fp(stringstream &ss, FILE *fp)
{
	ss.str("");
	ss.clear();

	char c = getc(fp);
	while (c != '\n' && c != EOF) {
		ss << c;
		c = getc(fp);
	}
	
	if (c == EOF)
		return NULL;
	else
		return fp;
}


void print_bam_header(const char *bam_name)
{
	string cmd("samtools view -H ");
	FILE *fp;

	cmd += bam_name;
	if ((fp = popen(cmd.c_str(), "r")) == NULL) {
		fputs("cannot open!\n", stderr);
		exit(1);
	}

	stringstream buf;

	while (getline_fp(buf, fp) != NULL) {
		cout << buf.str() << '\n';
	}

	pclose(fp);
}


void grep_bam(const unordered_set<string> &read_name_set, const char *bam_name)
{
	string cmd("samtools view ");
	FILE *fp;

	cmd += bam_name;
	if ((fp = popen(cmd.c_str(), "r")) == NULL) {
		fputs("cannot open!\n", stderr);
		exit(1);
	}

	stringstream buf;
	string read_name;

	while (getline_fp(buf, fp) != NULL) {
		buf >> read_name;
		if (read_name_set.find(read_name) != read_name_set.end()) {
			cout << buf.str() << '\n';
		}
	}

	pclose(fp);
}
