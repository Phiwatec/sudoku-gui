#include "Sudoku.h"

Sudoku::Sudoku()
{
    char* sudoku = "./sudoku";
    command = (char**)malloc(sizeof(char*)*2);
    command[0] = sudoku;
    command[1] = NULL;
    childRunning = 0;
}

Sudoku::~Sudoku()
{
    killChild();
}

void Sudoku::reset()
{
    if(childRunning)
    {
        killChild();
    }
    callExec();
    childSkip(309);     //welcome message + empty field
    //test
    /*
    printf("field\n");
    setNr('1','1','3');
    printf("field\n");
    setNr('9','9','9');
    printf("field\n");
    setNr('2','1','2');
    */
}

char Sudoku::getNr(char x, char y)
{
    return field[x][y];
}

void Sudoku::setNr(char x, char y, char n)
{
    if(!childRunning)
    {
        reset();
    }
    childWrite(x, y, n);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    childSkip(6);
    for(char i = 0;i<9;i++)
    {
        for(char j = 0;j<9;j++)
        {
            field[x][y] = childRead(1);
            childSkip(1);
            if(j%3==2)
            {
                childSkip(1);
            }
        }
        if(i%3==2)
        {
            childSkip(1);
        }
    }
    childSkip(1);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
}

char Sudoku::childRead(char print)
{
    char c;
    while(read(fromChild, &c, 1)==0);
#ifdef DBG
    if(print)
    {
    write(STDOUT_FILENO, &c, 1);
    }
#endif
    return c;
}

void Sudoku::childSkip(int anz)
{
    for(int i = 0;i<anz;i++)
    {
        childRead(1);
    }
}

void Sudoku::childWrite(char* c, int len)
{
    write(toChild, c, len);
}

void Sudoku::childWrite(char x, char y, char n)
{
    char* word = (char*)malloc(sizeof(char)*6);
    word[0] = x;
    word[1] = x;
    word[2] = y;
    word[3] = y;
    word[4] = n;
    word[5] = '\n';
    childWrite(word, 6);
    free(word);
}

void Sudoku::killChild()
{
    char* x = "x\n";
    childWrite(x,2);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    system("pkill -9 sudoku");
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    system("pkill -9 sudoku");
    childRunning = 0;
    close(toChild);
    close(fromChild);
}

int Sudoku::callExec()
{
    if (pipe(aStdinPipe) < 0) {
      perror("allocating pipe for child input redirect");
      return -1;
    }
    if (pipe(aStdoutPipe) < 0) {
      close(aStdinPipe[PIPE_READ]);
      close(aStdinPipe[PIPE_WRITE]);
      perror("allocating pipe for child output redirect");
      return -1;
    }

    pidChild = fork();
    if (0 == pidChild) {
      // child continues here

      // redirect stdin
      if (dup2(aStdinPipe[PIPE_READ], STDIN_FILENO) == -1) {
        exit(errno);
      }

      // redirect stdout
      if (dup2(aStdoutPipe[PIPE_WRITE], STDOUT_FILENO) == -1) {
        exit(errno);
      }

      // redirect stderr
      if (dup2(aStdoutPipe[PIPE_WRITE], STDERR_FILENO) == -1) {
        exit(errno);
      }

      // all these are for use by parent only
      close(aStdinPipe[PIPE_READ]);
      close(aStdinPipe[PIPE_WRITE]);
      close(aStdoutPipe[PIPE_READ]);
      close(aStdoutPipe[PIPE_WRITE]);

      // run sudoku
      childResult = execvp(command[0], command);

      // if we get here at all, an error occurred, but we are in the child
      // process, so just exit
      exit(childResult);
    } else if (pidChild > 0) {
      // parent continues here

      // close unused file descriptors, these are for child only
      close(aStdinPipe[PIPE_READ]);
      close(aStdoutPipe[PIPE_WRITE]);

      // keep as easier names
      toChild = aStdinPipe[PIPE_WRITE];
      fromChild = aStdoutPipe[PIPE_READ];
      childRunning = 1;
    } else {
      // failed to create child
      close(aStdinPipe[PIPE_READ]);
      close(aStdinPipe[PIPE_WRITE]);
      close(aStdoutPipe[PIPE_READ]);
      close(aStdoutPipe[PIPE_WRITE]);
      return 1;
    }
    return 0;
}
