#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    QObject::connect(ui->actionNeu, SIGNAL(triggered(bool)), this, SLOT(resetField()));
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::resetField()
{
    printf("Hi\n");
}
