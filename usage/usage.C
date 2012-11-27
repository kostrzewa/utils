#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <sstream>
#include <string>
#include <fstream>

//#define DEBUG 

const int gid_etmc = 3585;
const int gid_nic = 1414;

double etmc_size = 0.0;
double nic_size = 0.0;
double other_size = 0.0;

unsigned long int etmc_fcount = 0;
unsigned long int nic_fcount = 0;
unsigned long int other_fcount = 0;

int main(int argc, char* argv[]) {
  if( argc < 2 ) {
    printf("USAGE:\n");
    printf("\t ./usage findlist\n");
    printf("\t where findlist is the output of find $DIRECTORY\n");
    exit(0);
  }
 
  std::string line;
  std::ifstream findlist(argv[1]);

  struct stat fstat;
  
  while(findlist >> line) {
    lstat(line.c_str(),&fstat);
    if( S_ISREG(fstat.st_mode) ) {
        if( fstat.st_gid == gid_etmc ) {
          etmc_size += 1.0e-12*(double)fstat.st_size;
          ++etmc_fcount;
        } else if ( fstat.st_gid == gid_nic ) {
          nic_size += 1.0e-12*(double)fstat.st_size;
          ++nic_fcount;
        } else {
          other_size += 1.0e-12*(double)fstat.st_size;
          ++other_fcount;
        }
#ifdef DEBUG
      printf("Filename: %s, Size: %lf, Gid: %d, Attbs: %ud \n",line.c_str(),(double)fstat.st_size,fstat.st_gid,fstat.st_mode);
#endif
    }
  }

  printf("%lf %lf %lf %ld %ld %ld\n",etmc_size,nic_size,other_size,etmc_fcount,nic_fcount,other_fcount);

  return(0);
}
