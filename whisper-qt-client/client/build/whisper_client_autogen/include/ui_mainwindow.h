/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 6.9.3
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QTextEdit>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QAction *actionExit;
    QAction *actionAbout;
    QWidget *centralwidget;
    QVBoxLayout *verticalLayout;
    QGroupBox *connectionGroup;
    QHBoxLayout *horizontalLayout_2;
    QLabel *labelHost;
    QLineEdit *lineEditHost;
    QLabel *labelPort;
    QLineEdit *lineEditPort;
    QPushButton *btnConnect;
    QGroupBox *statusGroup;
    QHBoxLayout *horizontalLayout_3;
    QLabel *labelStatus;
    QSpacerItem *horizontalSpacer;
    QLabel *labelAudioLevel;
    QGroupBox *transcriptGroup;
    QVBoxLayout *verticalLayout_2;
    QTextEdit *textEditTranscript;
    QPushButton *btnStartStop;
    QPushButton *btnClear;
    QMenuBar *menubar;
    QMenu *menuFile;
    QMenu *menuHelp;
    QStatusBar *statusbar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName("MainWindow");
        MainWindow->resize(600, 500);
        actionExit = new QAction(MainWindow);
        actionExit->setObjectName("actionExit");
        actionAbout = new QAction(MainWindow);
        actionAbout->setObjectName("actionAbout");
        centralwidget = new QWidget(MainWindow);
        centralwidget->setObjectName("centralwidget");
        verticalLayout = new QVBoxLayout(centralwidget);
        verticalLayout->setObjectName("verticalLayout");
        connectionGroup = new QGroupBox(centralwidget);
        connectionGroup->setObjectName("connectionGroup");
        horizontalLayout_2 = new QHBoxLayout(connectionGroup);
        horizontalLayout_2->setObjectName("horizontalLayout_2");
        labelHost = new QLabel(connectionGroup);
        labelHost->setObjectName("labelHost");

        horizontalLayout_2->addWidget(labelHost);

        lineEditHost = new QLineEdit(connectionGroup);
        lineEditHost->setObjectName("lineEditHost");

        horizontalLayout_2->addWidget(lineEditHost);

        labelPort = new QLabel(connectionGroup);
        labelPort->setObjectName("labelPort");

        horizontalLayout_2->addWidget(labelPort);

        lineEditPort = new QLineEdit(connectionGroup);
        lineEditPort->setObjectName("lineEditPort");

        horizontalLayout_2->addWidget(lineEditPort);

        btnConnect = new QPushButton(connectionGroup);
        btnConnect->setObjectName("btnConnect");

        horizontalLayout_2->addWidget(btnConnect);


        verticalLayout->addWidget(connectionGroup);

        statusGroup = new QGroupBox(centralwidget);
        statusGroup->setObjectName("statusGroup");
        horizontalLayout_3 = new QHBoxLayout(statusGroup);
        horizontalLayout_3->setObjectName("horizontalLayout_3");
        labelStatus = new QLabel(statusGroup);
        labelStatus->setObjectName("labelStatus");

        horizontalLayout_3->addWidget(labelStatus);

        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout_3->addItem(horizontalSpacer);

        labelAudioLevel = new QLabel(statusGroup);
        labelAudioLevel->setObjectName("labelAudioLevel");

        horizontalLayout_3->addWidget(labelAudioLevel);


        verticalLayout->addWidget(statusGroup);

        transcriptGroup = new QGroupBox(centralwidget);
        transcriptGroup->setObjectName("transcriptGroup");
        verticalLayout_2 = new QVBoxLayout(transcriptGroup);
        verticalLayout_2->setObjectName("verticalLayout_2");
        textEditTranscript = new QTextEdit(transcriptGroup);
        textEditTranscript->setObjectName("textEditTranscript");
        textEditTranscript->setReadOnly(true);

        verticalLayout_2->addWidget(textEditTranscript);


        verticalLayout->addWidget(transcriptGroup);

        btnStartStop = new QPushButton(centralwidget);
        btnStartStop->setObjectName("btnStartStop");
        btnStartStop->setEnabled(false);

        verticalLayout->addWidget(btnStartStop);

        btnClear = new QPushButton(centralwidget);
        btnClear->setObjectName("btnClear");

        verticalLayout->addWidget(btnClear);

        MainWindow->setCentralWidget(centralwidget);
        menubar = new QMenuBar(MainWindow);
        menubar->setObjectName("menubar");
        menubar->setGeometry(QRect(0, 0, 600, 24));
        menuFile = new QMenu(menubar);
        menuFile->setObjectName("menuFile");
        menuHelp = new QMenu(menubar);
        menuHelp->setObjectName("menuHelp");
        MainWindow->setMenuBar(menubar);
        statusbar = new QStatusBar(MainWindow);
        statusbar->setObjectName("statusbar");
        MainWindow->setStatusBar(statusbar);

        menubar->addAction(menuFile->menuAction());
        menubar->addAction(menuHelp->menuAction());
        menuFile->addAction(actionExit);
        menuHelp->addAction(actionAbout);

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "Whisper ASR Client", nullptr));
        actionExit->setText(QCoreApplication::translate("MainWindow", "Exit", nullptr));
        actionAbout->setText(QCoreApplication::translate("MainWindow", "About", nullptr));
        connectionGroup->setTitle(QCoreApplication::translate("MainWindow", "Connection", nullptr));
        labelHost->setText(QCoreApplication::translate("MainWindow", "Host:", nullptr));
        lineEditHost->setText(QCoreApplication::translate("MainWindow", "localhost", nullptr));
        labelPort->setText(QCoreApplication::translate("MainWindow", "Port:", nullptr));
        lineEditPort->setText(QCoreApplication::translate("MainWindow", "8765", nullptr));
        btnConnect->setText(QCoreApplication::translate("MainWindow", "Connect", nullptr));
        statusGroup->setTitle(QCoreApplication::translate("MainWindow", "Status", nullptr));
        labelStatus->setText(QCoreApplication::translate("MainWindow", "Disconnected", nullptr));
        labelAudioLevel->setText(QCoreApplication::translate("MainWindow", "Audio Level: 0%", nullptr));
        transcriptGroup->setTitle(QCoreApplication::translate("MainWindow", "Transcription", nullptr));
        btnStartStop->setText(QCoreApplication::translate("MainWindow", "Start Recording", nullptr));
        btnClear->setText(QCoreApplication::translate("MainWindow", "Clear", nullptr));
        menuFile->setTitle(QCoreApplication::translate("MainWindow", "File", nullptr));
        menuHelp->setTitle(QCoreApplication::translate("MainWindow", "Help", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
