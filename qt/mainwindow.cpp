#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "Sudoku.h"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    QObject::connect(ui->actionNeu, SIGNAL(triggered(bool)), this, SLOT(resetField()));
    s = new Sudoku();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::resetField()
{
    printf("Hi\n");
    s->reset();
}
