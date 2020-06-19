#include <unistd.h>
#include <stdint.h>

const int STDOUT = 1;
const int STDIN  = 0;
//.data
char message[]  = "_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n"
"_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n"
"_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n_ _ _  _ _ _  _ _ _ \n\n";
int len = 193;

char *hello = "SUDOKU-solver by gedobbles   \n"
"Format: x y n where x,y are coordinates (1-9) and n is the number.\n"
"Enter x to exit.\n\n";
int lh = 116;

char input[] = "12345678";

uint16_t dat[] = {511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511, \
  511,511,511,511,511,511,511,511,511 };


  //struct für Rückgabe von countbits
  struct cbRes {
    char n;
    char eindeutig;
    char erg;
  };

  //.text

  void prints();
  void print(char*, int);
  struct cbRes countbits(uint16_t);
  void stnr(uint16_t, uint8_t, uint8_t);
  uint16_t ldnr(uint8_t, uint8_t);
  void check(uint8_t, uint8_t);
  void influence(uint8_t, uint8_t);
  void inr(uint16_t, uint8_t, uint8_t);
  void heur();
  void dump();
  void dumph();

  int main(int argc, char const *argv[]) {
    print(hello, lh);
    while (1) {                   //loop
      prints();
      *((uint32_t*) input) = 0;    //read
      *(((uint32_t*) input) + 1) = 0;
      read(STDIN, input, 6);
      print(input, 6);
      if(input[0] == 'x')
        break;
      if(input[0] == 'd'){
        dump();
        continue;
      }
      if(input[0] == 'h'){
        dumph();
        continue;
      }
      stnr((1 << (input[4]-'1'))|0x4000, input[0]-'1', input[2]-'1'); //magic
      magic2:
      for(int i = 0;i<9;i++){ //magic2
        for(int j = 0;j<9;j++){
          if(ldnr(i,j) & 0x4000){
            check(i,j);
            goto magic2;
          }
        }
      }
      char *ptr = message; //dat_out
      int nrptr = 0;
      for(int z = 0;z<3;z++){       //3 Zeilen
        for(int b = 0;b<9;b++){     //9 Blöcke, dann eins weiter
          for(int c = 0;c<3;c++){   //3 Zeichen pro Block
            struct cbRes res = countbits(dat[nrptr]);
            char chr = res.erg;
            if(res.eindeutig){
              dat[nrptr] |= 0x8000;
            }else{    //dat_d
              chr = '_';
              if(res.n == 0)
                chr = 'X';
            }
            *ptr = chr;  //dat_st
            ptr += 2;    //eins weiter plu eins für leerzeichen
            nrptr ++;
          }
          ptr++;    //Leerzeichen zw Blöcken
        }
        ptr++;    //zusätzlicher Umbruch
      }
    }   //b loop
    return 0;                     //exit, return
  }

  void prints(){
    print(message, len);
  }

  void print(char* a, int b){
    write(STDOUT, a, b);
  }

  struct cbRes countbits(uint16_t nr){    //r1
    char n = 0;     //r0
    char eindeutig = 0;
    char i = 9;     //r2
    char c = 0;     //r3
    char erg = '1'; //r6

    while(i != 0){
      if(nr & 1){
        n++;
        c++;
      }
      if(c == 0)
        erg++;
      nr >>= 1;
      i--;
    }
    if(n == 1)
      eindeutig = 1;
    struct cbRes a = {n, eindeutig, erg};
    return a;
  }

  void stnr(uint16_t d, uint8_t x, uint8_t y){
    //*((uint16_t*) dat + y * 18 + (x << 1)) = d;
    dat[y*9+x] = d;
  }

  uint16_t ldnr(uint8_t x, uint8_t y){
    //return *((uint16_t*) dat + y * 18 + (x << 1));
    return dat[y*9+x];
  }

  void check(uint8_t x, uint8_t y){
    uint16_t nr = ldnr(x, y);
    nr ^= 0x4000;
    if(countbits(nr).eindeutig){
      influence(x, y);
      heur();
    }
    stnr(nr, x, y);
  }

  void influence(uint8_t x, uint8_t y){
    uint16_t nr = ldnr(x, y);
    int i, j;
    for(i = 0;i<9;i++){ //ix
      if(i != x)
        inr(nr, i, y);
    }
    for(j = 0;j<9;j++){ //iy
      if(j != y)
        inr(nr, x, j);
    }
    i = 0;              //ib
    while(x>2){         //ibxc
      i += 3;
      x -= 3;
    }
    j = 0;
    while(y>2){         //ibyc
      j += 3;
      y -= 3;
    }
    for(int k = 0;k<3;k++){ //ibl
      inr(nr,i  ,j+k);
      inr(nr,i+1,j+k);
      inr(nr,i+2,j+k);
    }
  }

  void inr(uint16_t nr, uint8_t x, uint8_t y){
    uint16_t inr = ldnr(x, y);
    if(!(inr & 0x8000)){
      inr &= ~(nr & 511);
      if(countbits(inr).eindeutig){
        inr |= 0xC000;
      }else{
        inr |= 0x4000;
      }
      stnr(inr, x, y);
    }
  }

  void heur(){
    uint16_t amask;             //bitmask for number a
    uint16_t t;   //just a temp
    uint8_t o;                  //o number of occurences
    uint8_t x, y;               //x, y coordinates of occurence
    reheur:
    for(uint8_t a = 0;a<9;a++){   //a number to check for
      amask = 1<<a;
      for(uint8_t i = 0;i<9;i++){   //for every row
        o = 0;
        for(uint8_t j = 0;j<9;j++){
          t = ldnr(j, i);
          if(t & amask){
            if(t & 0x8000)
              goto already_there_r;
            o++;
            x = j;
            y = i;
          }
        }
        if(o == 1){
          stnr((1<<a) | 0x8000,x ,y);
          influence(x,y);
          goto reheur;
        }
        already_there_r:
        ;
      }
      for(uint8_t i = 0;i<9;i++){   //for every column
        o = 0;
        for(uint8_t j = 0;j<9;j++){
          t = ldnr(i, j);
          if(t & amask){
            if(t & 0x8000)
              goto already_there_c;
            o++;
            x = i;
            y = j;
          }
        }
        if(o == 1){
          stnr((1<<a) | 0x8000,x ,y);
          influence(x,y);
          goto reheur;
        }
        already_there_c:
        ;
      }
      //not yet for blocks
    }
  }

  void dump(){
    char out[1379];
    char *ptr = out;
    uint16_t nr;
    for(int i = 0;i<9;i++){
      for(int j = 0;j<9;j++){
        nr = ldnr(j, i);
        for (int k = 0; k < 16; k++) {
          if(nr & 1){
            *ptr = '1';
          }else{
            *ptr = '0';
          }
          nr >>= 1;
          ptr++;
        }
        *ptr = ' ';
        ptr++;
      }
      ptr--;
      *ptr = '\n';
      ptr++;
    }
    *ptr = '\n';
    print(out,1378);
  }

  void dumph(){
    char out[567];
    char* ptr = out;
    uint16_t nr;
    for(int i = 0;i<9;i++){
      for(int j = 0;j<9;j++){
        *ptr = '0';
        ptr++;
        *ptr = 'x';
        ptr++;
        nr = ldnr(j, i);
        for (int k = 0; k < 4; k++) {
          *ptr = '0' + ((nr & 0xf000)>>12);
          if (*ptr > '9') {
            *ptr += ('a'-'9'-1);
          }
          nr <<= 4;
          ptr++;
        }
        *ptr = ' ';
        ptr++;
      }
      ptr--;
      *ptr = '\n';
      ptr++;
    }
    *ptr = '\n';
    print(out,567);
  }
