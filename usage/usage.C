/* This file is part of the "usage" utilty for analysing disk usage
  on a per directory level and attributing it to a unix group
  
   Copyright (C) 2012  Bartosz Kostrzewa

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. */


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

unsigned long int line_count = 0;

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

  double percent_done = 0.0;
 
  std::ifstream::pos_type start_of_data = findlist.tellg();
  findlist.seekg(0, std::ios::end);
  std::ifstream::pos_type end_of_data = findlist.tellg();
  findlist.seekg(start_of_data);

  std::ifstream::pos_type curr_point_in_data;
  
  while(findlist >> line) {
    ++line_count;
    if( line_count % 1000 == 0 ) {
      percent_done = static_cast<double>(findlist.tellg()) * 100 / static_cast<double>(end_of_data);
      fprintf(stderr,"Percent done: %6.2lf \% \r",percent_done);
      fflush(stderr);
    }
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
      printf("\nFilename: %s, Size: %lf, Gid: %d, Attbs: %ud \n",line.c_str(),(double)fstat.st_size,fstat.st_gid,fstat.st_mode);
#endif
    }
  }

  printf("%lf %lf %lf %lu %lu %lu\n",etmc_size,nic_size,other_size,etmc_fcount,nic_fcount,other_fcount);

  return(0);
}
