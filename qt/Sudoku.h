#ifndef SUDOKU_H
#define SUDOKU_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string>

#define PIPE_READ 0
#define PIPE_WRITE 1

class Sudoku
{
  public:
    Sudoku();
    virtual ~Sudoku();
    void reset();

  private:
    int callExec();

    int aStdinPipe[2];
    int aStdoutPipe[2];
    int pidChild, childResult;
    char** command;
};

#endif
