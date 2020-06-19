#include "Sudoku.h"

Sudoku::Sudoku()
{
    char* sudoku = "./sudoku";
    command = (char**)malloc(sizeof(char*)*2);
    command[0] = sudoku;
    command[1] = NULL;
}

Sudoku::~Sudoku()
{
    free(command[0]);
    free(command[1]);
    free(command);
}

void Sudoku::reset()
{
    callExec();
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

      // run child process image
      // replace this with any exec* function find easier to use ("man exec")

      childResult = execvp(command[0], command);

      // if we get here at all, an error occurred, but we are in the child
      // process, so just exit
      exit(childResult);
    } else if (pidChild > 0) {
      // parent continues here

      // close unused file descriptors, these are for child only
      close(aStdinPipe[PIPE_READ]);
      close(aStdoutPipe[PIPE_WRITE]);

      // write
      char message[] = "1 1 1\n";

      //write(aStdinPipe[PIPE_WRITE], message, 6);


      // read
      char nChar;

      while (read(aStdoutPipe[PIPE_READ], &nChar, 1) == 1) {
        write(STDOUT_FILENO, &nChar, 1);
      }


      // done with these in this example program, you would normally keep these
      // open of course as long as you want to talk to the child
      close(aStdinPipe[PIPE_WRITE]);
      close(aStdoutPipe[PIPE_READ]);
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
