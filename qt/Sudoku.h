#ifndef SUDOKU_H
#define SUDOKU_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string>

#define PIPE_READ 0
#define PIPE_WRITE 1

#define DBG // debug output switch

class Sudoku
{
  public:
    Sudoku();
    virtual ~Sudoku();
    void reset();
    char getNr(char, char);
    void setNr(char, char, char);

  private:
    int callExec();
    void killChild();
    char childRead();
    void childSkip(int);
    void childWrite(char, char, char);
    void childWrite(char);

    int aStdinPipe[2];
    int aStdoutPipe[2];
    int pidChild, childResult;
    int toChild, fromChild;
    char childRunning;
    char** command;
    char field[9][9];
};

#endif
